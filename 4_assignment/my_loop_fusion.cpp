#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"

#include "llvm/Analysis/LoopInfo.h"
#include "llvm/IR/Dominators.h"
#include "llvm/Analysis/PostDominators.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/ScalarEvolutionExpressions.h"
#include "llvm/Analysis/DependenceAnalysis.h"

using namespace llvm;
  
namespace {

struct MyLoopFusionPass: PassInfoMixin<MyLoopFusionPass> {

  // Assumptions:
  // - LA and LB are siblings.
  // - Both loops are in canonical form.
  // For educational purposes, we are not concerned with how we loop through the analysis.
  bool areLoopsFuseable(Loop *LA, Loop *LB, DominatorTree &DT, PostDominatorTree &PDT, ScalarEvolution &SE, DependenceInfo &DI) {

    // First pruning: If one loop is guarded while the other is unguarded, then they cannot merge
    // because they do not satisfy condition 3.
    BranchInst *GuardA = LA->getLoopGuardBranch();
    BranchInst *GuardB = LB->getLoopGuardBranch();
    bool isLAGuarded = (GuardA != nullptr);
    bool isLBGuarded = (GuardB != nullptr);
    if (isLAGuarded != isLBGuarded)
      return false;

    // Second pruning: If both loops are guarded and have a logically different guard condition,
    // then they cannot merge because they do not satisfy condition 3.
    if (isLAGuarded && isLBGuarded) {
      Value *CA = GuardA->getCondition();
      Value *CB = GuardB->getCondition();
      // The two loops use different registers for comparison.
      if (CA != CB) {
        Instruction *IA = dyn_cast<Instruction>(CA);
        Instruction *IB = dyn_cast<Instruction>(CB);
        if (IA && IB) {
          // The definition of the comparison registers uses the same operators and operands.
          if (!IA->isIdenticalTo(IB)) {
            errs() << "The two loops have different guards.\n";
            return false;
          }
          errs() << "The two loops have the same guard.\n";
        } else {
          // Either one of them is not an instruction, or they are both different constants.
          return false;
        }
      }
    }

    // Third pruning: Both loops must have only one exiting block, otherwise condition 2 risks
    // becoming false.
    // Note: The function getExitingBlock returns nullptr if there are multiple exiting blocks.
    BasicBlock *ExitingBlockA = LA->getExitingBlock();
    BasicBlock *ExitingBlockB = LB->getExitingBlock();
    if (!ExitingBlockA || !ExitingBlockB) {
      errs() << "There are multiple exit points.\n";
      return false;
    }
    
    // Fourth pruning: Both loops have no internal nesting. Otherwise, the implementation of
    // condition 4 becomes significantly more complicated.
    if (!LA->isInnermost() || !LB->isInnermost())
      return false;

    // Condition 3: Control Flow Equivalence
    Loop *L0 = nullptr;
    Loop *L1 = nullptr;
    BasicBlock *Entry0 = nullptr;
    BasicBlock *Entry1 = nullptr;
    // If both loops are guarded, then one guard must dominate the other guard.
    // If both loops are unguarded, then one preheader must dominate the other preheader.
    BasicBlock *EntryA = isLAGuarded ? GuardA->getParent() : LA->getLoopPreheader();
    BasicBlock *EntryB = isLBGuarded ? GuardB->getParent() : LB->getLoopPreheader();
    // 1. The entry of one loop must dominate the entry of the other loop.
    if (DT.dominates(EntryA, EntryB) && PDT.dominates(EntryB, EntryA)) {
      L0 = LA; L1 = LB;
      Entry0 = EntryA; Entry1 = EntryB;
    } else if (DT.dominates(EntryB, EntryA) && PDT.dominates(EntryA, EntryB)) {
      L0 = LB; L1 = LA;
      Entry0 = EntryB; Entry1 = EntryA;
    } else {
      // Condition 3 is not met.
      return false;
    }

    // Condition 1: Adjacency
    // The exit block of the first loop must be the entry block of the second loop.
    BasicBlock *ExitBlock0 = L0->getExitBlock();
    if (ExitBlock0 != Entry1) {
      errs() << "The exit of the first loop does not match the entry of the second loop.\n";
      // In guarded do-while loops, the dedicated exit block is a block that sits between the
      // exiting block of the first loop and the guard block of the second loop. Consequently,
      // the exit block of the first loop will never be the entry block of the second loop.
      // For this reason, we need to verify that the successor of the dedicated exit block of
      // the first loop coincides with the entry block of the second loop.
      Instruction *Term = ExitBlock0->getTerminator();
      if (!Term || Term->getSuccessor(0) != Entry1) {
        errs() << "The dedicated exit of the first loop does not match the entry of the second loop.\n";
        return false;
      }
    }
    // The pre-header of the second loop must not contain any instructions other
    // than the unconditional jump to the header.
    BasicBlock *Preheader1 = L1->getLoopPreheader();
    if (Preheader1 && Preheader1->size() != 1) {
      errs() << "The second preheader has other instructions besides the unconditional branch.\n";
      return false;
    }
    // The guard of the second loop (if it exists) must have only the comparison instruction
    // and the conditional branch.
    BranchInst *Guard1 = L1->getLoopGuardBranch();
    if (Guard1 && Guard1->getParent()->size() > 2)
      return false;
    
    // Condition 2: Trip Count Equivalence
    // Counting the number of trip counts is like counting the number of times the back edge is
    // traveled.
    const SCEV *TripCount0 = SE.getBackedgeTakenCount(L0);
    const SCEV *TripCount1 = SE.getBackedgeTakenCount(L1);
    // If at least one of the two algebraic expressions of the trip count could not be calculated,
    // then the two loops cannot be merged.
    if (isa<SCEVCouldNotCompute>(TripCount0) || isa<SCEVCouldNotCompute>(TripCount1)) {
      errs() << "Algebraic expression of the trip count cannot be calculated.\n";
      return false;
    }
    // If the algebraic expressions of the trip counts are different, then they cannot be merged.
    if (TripCount0 != TripCount1) {
      errs() << "Different trip count.\n";
      return false;
    }

    // Condition 4: Absence of Negative Dependencies
    // First loop memory access instructions.
    SmallVector<Instruction*, 16> MemInsts0;
    for (BasicBlock *BB : L0->blocks()) {
      for (Instruction &I : *BB) {
        if (isa<LoadInst>(I) || isa<StoreInst>(I))
          MemInsts0.push_back(&I);
      }
    }
    // Second loop memory access instructions.
    SmallVector<Instruction*, 16> MemInsts1;
    for (BasicBlock *BB : L1->blocks()) {
      for (Instruction &I : *BB) {
        if (isa<LoadInst>(I) || isa<StoreInst>(I))
          MemInsts1.push_back(&I);
      }
    }
    // Negative dependence check for each pair of (I0, I1).
    for (Instruction *I0 : MemInsts0) {
      for (Instruction *I1 : MemInsts1) {
        // If both instructions are load statements, then they have no dependencies.
        if (isa<LoadInst>(I0) && isa<LoadInst>(I1))
          continue;
        // Dep acts as a strict dependency checker.
        std::unique_ptr<Dependence> Dep = DI.depends(I0, I1, true);
        // There are no dependencies between the two instructions.
        if (!Dep) {
          errs() << "No depencency between instructions\n";
          continue;
        }
        // The compiler doesn't understand the dependency and assumes the worst case.
        if (Dep->isConfused())
          return false;
        // Hybrid Approach: Calculate negative distance using SCEV to bypass the lack of 'SameSD'
        // support in LLVM 19.
        Value *Ptr0 = getLoadStorePointerOperand(I0);
        Value *Ptr1 = getLoadStorePointerOperand(I1);
        const SCEV *S0 = SE.getSCEV(Ptr0);
        const SCEV *S1 = SE.getSCEV(Ptr1); // questo mi ritorna la f(i)
        // Polynomial expressions expressions of array indices (example: A[f(i)]).
        const SCEVAddRecExpr *AR0 = dyn_cast<SCEVAddRecExpr>(S0);
        const SCEVAddRecExpr *AR1 = dyn_cast<SCEVAddRecExpr>(S1);
        if (!AR0 || !AR1) {
          errs() << "Access with non-affine indexes.\n";
          return false;
        }
        // The indices must grow identically (example: A[i+1] and A[2 * i] cannot be merged).
        if (AR0->getStepRecurrence(SE) != AR1->getStepRecurrence(SE)) {
          errs() << "Different steps.\n";
          return false;
        }
        // Calculate spatial distance based on starting points: d = Start0 (&A) - Start1 (&A + offset).
        const SCEV *Dist = SE.getMinusSCEV(AR0->getStart(), AR1->getStart());
        const SCEV *Step = AR0->getStepRecurrence(SE);
        errs() << "Distance: " << *Dist << "\tStep: " << *Step << "\n";
        // If the step is positive...
        if (SE.isKnownPositive(Step)) {
          // ...if the distance is not non-negative, or cannot be determined at compile time,
          // then the two loops cannot be merged.
          if (!SE.isKnownNonNegative(Dist)) {
            errs() << "Negative temporal dependence detected (positive step).\n";
            return false;
          }
        }
        // ...else if the step is negative...
        else if (SE.isKnownNegative(Step)) {
          // ...if the distance is not negative or zero, then the two loops cannot be merged.
          if (!SE.isKnownNegative(Dist) && !Dist->isZero()) {
            errs() << "Negative temporal dependence detected (negative step).\n";
            return false;
          } 
        } else {
          // step cannot be determined at compile time, or infinite (es. true)
          return false;
        }
      }
    }

    return true;
  }

  // Pre-ordering the loops ensures that we visit them with the same order present in the source code.
  // For simplicity, we don't include conditional statements in our tests.
  bool loopFusion(Loop *L0, Loop *L1, ScalarEvolution &SE) {
    // Count the number of phi nodes in the headers. 
    // We expect exactly one phi node (the induction variable) in our simplified canonical loops.
    // If there are more, the loop contains internal recurrences (like a sum reduction)
    // which our basic code motion cannot safely fuse without breaking SSA.
    unsigned PhiCount0 = 0;
    for (auto &Phi : L0->getHeader()->phis()) PhiCount0++;
    unsigned PhiCount1 = 0;
    for (auto &Phi : L1->getHeader()->phis()) PhiCount1++;

    if (PhiCount0 > 1 || PhiCount1 > 1) {
      errs() << "Error: loops contain multiple phi nodes in header.\n";
      return false;
    }

    // Find induction variables of the loop (this correspond to the only phi node in the headers)
    PHINode *IV0 = &*L0->getHeader()->phis().begin();
    PHINode *IV1 = &*L1->getHeader()->phis().begin();

    // Ensuring that the loops don't have if-else statements to avoid complications 
    // during the code motions of the instruction from body 2 to body 1.
    if (L0->getBlocks().size() > 3 || L1->getBlocks().size() > 3) {
      errs() << "Error: loops have more than 3 blocks (if-else statements).\n";
      return false;
    }

    // Moving the body of the second loop right after the body of the first loop,
    // and changing the exit of the first loop with the exit of the second loop.
    // Since we are assuming the absence of internal if-else statements or early exits within the loop body, 
    // this implies that the body of the loop is composed of exactly one BB. 
    // Therefore, we can move the instruction from the body of the second right 
    // into the body of the first, without implementing additional control logic.
    // We first obtain the relevant blocks:
    BasicBlock *Latch0 = L0->getLoopLatch();
    BasicBlock *Latch1 = L1->getLoopLatch();
    BasicBlock *Body0 = Latch0->getSinglePredecessor();
    BasicBlock *Body1 = Latch1->getSinglePredecessor();

    // Getting the insert point of where to moving the instruction of the body of the second loop:
    Instruction *InsertPt = Body0->getTerminator();
    // Getting the increment instruction for the second loop (we don't want to move it)
    // Also we want to change the uses of the second with the first
    Value *IncValue0 = IV0->getIncomingValueForBlock(Latch0);
    Value *IncValue1 = IV1->getIncomingValueForBlock(Latch1);

    // Instructions motion
    for (auto iter = Body1->begin(); iter != Body1->end(); ) {
      Instruction &Inst = *iter++;
      if (Inst.isTerminator()) break; 
      if (isa<PHINode>(&Inst) ||
          &Inst == dyn_cast_or_null<Instruction>(IncValue1)) // In do-while cases
            continue;
      Inst.replaceUsesOfWith(IV1, IV0); // we replace the uses only of the instruction we effectively move
      Inst.moveBefore(InsertPt); // code motion
    }

    // Replacing uses outside the loops
    for (auto iter = IV1->use_begin(); iter != IV1->use_end();) {
      Use &U = *iter++; // advancing the iterator before it is modified
      Instruction *UserInst = dyn_cast<Instruction>(U.getUser()); 
      if (UserInst && L1->contains(UserInst)) 
        continue; // ignoring uses inside the "skeleton" of the second loop
      U.set(IV0);
    }

    // Replacing the uses of the incremented variable of the second loop, with the incremented variable of the first
    for (auto iter = IncValue1->use_begin(); iter != IncValue1->use_end();) {
      Use &U = *iter++;
      Instruction *UserInst = dyn_cast<Instruction>(U.getUser());
      if (UserInst && L1->contains(UserInst)) 
        continue;
      U.set(IncValue0);
    }

    // Changing the exit block of the first loop with the exit block of the second loop
    BasicBlock *Exiting0 = L0->getExitingBlock();
    BasicBlock *Exiting1 = L1->getExitingBlock();
    BasicBlock *Exit0 = L0->getExitBlock();
    BasicBlock *Exit1 = L1->getExitBlock();

    // If the terminator instruction of the exiting block of L0 is a
    // branch instruction, we cycle on its successor until we find the 
    // one that jumps on exit0, and we change it to force the jump on exit1.
    if (BranchInst *BI = dyn_cast<BranchInst>(Exiting0->getTerminator())) {
      for (unsigned i = 0; i < BI->getNumSuccessors(); i++) {
        if (BI->getSuccessor(i) == Exit0)
          BI->setSuccessor(i, Exit1);
      }
    }
    else return false;

    return true;
  }

  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {

    errs() << "Starting analysis for " << F.getName() << "...\n";

    LoopInfo &LI = FAM.getResult<LoopAnalysis>(F);
    DominatorTree &DT = FAM.getResult<DominatorTreeAnalysis>(F);
    PostDominatorTree &PDT = FAM.getResult<PostDominatorTreeAnalysis>(F);
    ScalarEvolution &SE = FAM.getResult<ScalarEvolutionAnalysis>(F);
    DependenceInfo &DI = FAM.getResult<DependenceAnalysis>(F);

    SmallVector<Loop*, 8> Loops(LI.getLoopsInPreorder());

    for (unsigned i = 0; i < Loops.size(); i++) {
      Loop *LA = Loops[i];
      if (!LA->isLoopSimplifyForm())
        continue;
      for (unsigned j = i + 1; j < Loops.size(); j++) {
        Loop *LB = Loops[j];
        if (!LB->isLoopSimplifyForm())
          continue;
        if (LA->getParentLoop() != LB->getParentLoop())
          continue;
        if (areLoopsFuseable(LA, LB, DT, PDT, SE, DI)) {
          errs() << "Suitable for Loop Fusion: ";
          LA->getHeader()->printAsOperand(errs(), false);
          errs() << " and ";
          LB->getHeader()->printAsOperand(errs(), false);
          errs() << "\n";

          if (loopFusion(LA, LB, SE)) {
            errs() << "Fusion successfully applied!\n"; 
            // here we need to recalculate the analyses if invalidated
          }
        }
      }
    }

    errs() << "Ending analysis for " << F.getName() << "...\n\n";

    return PreservedAnalyses::all();
  }
  static bool isRequired() { return true; }
};
} // namespace

//-----------------------------------------------------------------------------
// New PM Registration
//-----------------------------------------------------------------------------
llvm::PassPluginLibraryInfo getMyLoopFusionPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "MyLoopFusionPass", LLVM_VERSION_STRING,
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "my-loop-fusion") { // Command-line pipeline name
                    FPM.addPass(MyLoopFusionPass());
                    return true;
                  }
                  return false;
                });
          }};
}

// This is the core interface for pass plugins. It guarantees that 'opt' will
// be able to recognize TestPass when added to the pass pipeline on the
// command line, i.e. via '-passes=test-pass'
extern "C" LLVM_ATTRIBUTE_WEAK ::llvm::PassPluginLibraryInfo
llvmGetPassPluginInfo() {
  return getMyLoopFusionPassPluginInfo();
}