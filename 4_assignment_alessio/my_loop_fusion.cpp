#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Analysis/PostDominators.h"
#include "llvm/Analysis/DependenceAnalysis.h"
#include <algorithm>

using namespace llvm;
  
namespace {

struct MyLoopFusionPass: PassInfoMixin<MyLoopFusionPass> {

  // Assumptions:
  // - LA and LB are siblings.
  // - Both loops are in canonical form.
  // We are not concerned with how the loops are visited.
  bool areLoopsFuseable(Loop *LA, Loop *LB, DominatorTree &DT,
    PostDominatorTree &PDT, ScalarEvolution &SE, DependenceInfo &DI) {

    // First pruning: If one loop is guarded while the other is unguarded, then they
    // cannot merge because they do not satisfy condition 3.
    BranchInst *GuardA = LA->getLoopGuardBranch();
    BranchInst *GuardB = LB->getLoopGuardBranch();
    bool isLAGuarded = (GuardA != nullptr);
    bool isLBGuarded = (GuardB != nullptr);
    if (isLAGuarded != isLBGuarded)
      return false;

    // Second pruning: If both loops are guarded and have a logically different guard
    // condition, then they cannot merge because they do not satisfy condition 3.
    if (isLAGuarded && isLBGuarded) {
      Value *CA = GuardA->getCondition();
      Value *CB = GuardB->getCondition();
      // The two loops use different registers for comparison.
      if (CA != CB) {
        Instruction *IA = dyn_cast<Instruction>(CA);
        Instruction *IB = dyn_cast<Instruction>(CB);
        if (IA && IB) {
          // The definition of the comparison registers uses the same operators and
          // operands.
          if (!IA->isIdenticalTo(IB)) {
            errs() << "The two loops have different guards.\n";
            return false;
          }
          errs() << "The two loops have the same guard.\n";
        }
        else
          return false; // Either one of them is not an instruction, or they are both
                        // different constants.
      }
    }

    // Third pruning: Both loops must have only one exiting block, otherwise
    // condition 2 risks becoming false.
    // Note: The function getExitingBlock returns nullptr if there are multiple
    // exiting blocks.
    BasicBlock *ExitingBlockA = LA->getExitingBlock();
    BasicBlock *ExitingBlockB = LB->getExitingBlock();
    if (!ExitingBlockA || !ExitingBlockB) {
      errs() << "There are multiple exit points.\n";
      return false;
    }
    
    // Fourth pruning: Both loops have no internal nesting. Otherwise, the
    // implementation of condition 4 becomes significantly more complicated.
    if (!LA->isInnermost() || !LB->isInnermost())
      return false;

    // Condition 3: Control Flow Equivalence
    Loop *L0 = nullptr;
    Loop *L1 = nullptr;
    BasicBlock *Entry0 = nullptr;
    BasicBlock *Entry1 = nullptr;
    // If both loops are guarded, then one guard must dominate the other guard.
    // If both loops are unguarded, then one preheader must dominate the other
    // preheader.
    BasicBlock *EntryA = isLAGuarded ? GuardA->getParent() : LA->getLoopPreheader();
    BasicBlock *EntryB = isLBGuarded ? GuardB->getParent() : LB->getLoopPreheader();
    // 1. The entry of LA/LB must dominate the entry of LB/LA.
    // 2. The entry of LB/LA must post-dominate the entry of LA/LB.
    if (DT.dominates(EntryA, EntryB) && PDT.dominates(EntryB, EntryA)) {
      L0 = LA; L1 = LB;
      Entry0 = EntryA; Entry1 = EntryB;
    }
    else if (DT.dominates(EntryB, EntryA) && PDT.dominates(EntryA, EntryB)) {
      L0 = LB; L1 = LA;
      Entry0 = EntryB; Entry1 = EntryA;
    }
    else
      return false; // Condition 3 is not met.

    // Condition 1: Adjacency
    // The exit block of the first loop must be the entry block of the second loop.
    BasicBlock *ExitBlock0 = L0->getExitBlock();
    if (ExitBlock0 != Entry1) {
      errs() << "The exit of the first loop does not match the entry of the second "
                "loop.\n";
      // In guarded do-while loops, the dedicated exit block is a block that sits
      // between the exiting block of the first loop and the guard block of the
      // second loop. Consequently, the exit block of the first loop will never be
      // the entry block of the second loop. For this reason, we need to verify that
      // the successor of the dedicated exit block of the first loop coincides with
      // the entry block of the second loop.
      Instruction *Term = ExitBlock0->getTerminator();
      if (!Term || Term->getSuccessor(0) != Entry1) {
        errs() << "The dedicated exit of the first loop does not match the entry of "
                  "the second loop.\n";
        return false;
      }
    }
    // The pre-header of the second loop must not contain any instructions other than
    // the unconditional jump to the header.
    BasicBlock *Preheader1 = L1->getLoopPreheader();
    if (Preheader1 && Preheader1->size() != 1) {
      errs() << "The second preheader has other instructions besides the "
                "unconditional branch.\n";
      return false;
    }
    // The guard of the second loop (if it exists) must have only the comparison
    // instruction and the conditional branch.
    BranchInst *Guard1 = L1->getLoopGuardBranch();
    if (Guard1 && Guard1->getParent()->size() > 2) {
      errs() << "The second guard has other instructions besides the compare "
                "instruction and the unconditional branch.\n";
      return false;
    }
    
    // Condition 2: Trip Count Equivalence
    // Counting the number of trips is equivalent to counting the number of times the
    // back edge is traveled.
    // The SCEV class represents an algebraic expression associated with a value.
    const SCEV *TripCount0 = SE.getBackedgeTakenCount(L0);
    const SCEV *TripCount1 = SE.getBackedgeTakenCount(L1);
    // If at least one of the two algebraic expressions of the trip count could not
    // be calculated, then the two loops cannot be merged.
    if (isa<SCEVCouldNotCompute>(TripCount0) ||
        isa<SCEVCouldNotCompute>(TripCount1)) {
      errs() << "Algebraic expression of the trip count cannot be calculated.\n";
      return false;
    }
    // If the algebraic expressions of the trip counts are different, then they
    // cannot be merged.
    if (TripCount0 != TripCount1) {
      errs() << "Different trip count.\n";
      return false;
    }

    // Condition 4: Absence of Negative Dependencies
    SmallVector<Instruction*, 16> MemInsts0;
    for (BasicBlock *BB : L0->blocks())
      for (Instruction &I : *BB)
        if (isa<LoadInst>(I) || isa<StoreInst>(I))
          MemInsts0.push_back(&I);
    SmallVector<Instruction*, 16> MemInsts1;
    for (BasicBlock *BB : L1->blocks())
      for (Instruction &I : *BB)
        if (isa<LoadInst>(I) || isa<StoreInst>(I))
          MemInsts1.push_back(&I);
    // Negative dependence check for each pair (I0, I1).
    for (Instruction *I0 : MemInsts0) {
      for (Instruction *I1 : MemInsts1) {
        if (isa<LoadInst>(I0) && isa<LoadInst>(I1)) {
          errs() << "Load instructions have no depencency.\n";
          continue;
        }
        // Dependency Analysis represents our first pruning to discard pairs that are
        // independent of each other.
        std::unique_ptr<Dependence> Dep = DI.depends(I0, I1, true);
        if (!Dep) {
          // Different array bases (e.g., A[] and B[]).
          // Different constant indices (e.g., A[0] and A[1]).
          errs() << "No depencency between instructions.\n";
          continue;
        }
        // The compiler doesn't understand the dependency and assumes the worst case.
        if (Dep->isConfused())
          return false;
        // Hybrid Approach: calculate negative distance using SCEV to bypass the lack
        // of 'SameSD' support in LLVM 19.1.7.
        Value *Ptr0 = getLoadStorePointerOperand(I0);
        Value *Ptr1 = getLoadStorePointerOperand(I1);
        const SCEV *S0 = SE.getSCEVAtScope(Ptr0, L0);
        const SCEV *S1 = SE.getSCEVAtScope(Ptr1, L1);
        // If the SCEV cannot be calculated, then the two loops cannot be merged.
        if (isa<SCEVCouldNotCompute>(S0) || isa<SCEVCouldNotCompute>(S1)) {
          errs() << "Access with unpredictable indexes.\n";
          return false;
        }
        errs() << *S0 << " and " << *S1 << ".\n";
        // Calculate distance for generic SCEV: d(i) = S0(i) - S1(i).
        const SCEV *Dist = SE.getMinusSCEV(S0, S1);
        errs() << "Generic distance: " << *Dist << ".\n";
        if (Dist->isZero()) {
          errs() << "The distance is exactly zero and therefore there are no "
                    "dependencies.\n";
          continue;
        }
        // We only consider accesses expressible as additive recurrence expressions.
        // Example: Start + Step * i, where i is the induction variable of the loop.
        const SCEVAddRecExpr *AR0 = dyn_cast<SCEVAddRecExpr>(S0);
        const SCEVAddRecExpr *AR1 = dyn_cast<SCEVAddRecExpr>(S1);
        if (!AR0 || !AR1) {
          // Constant access and additive recurring access (e.g., A[0] and A[i]).
          // Access with complex indices (e.g., A[B[i]]).
          errs() << "Access with no additive recurrence indexes.\n";
          return false;
        }
        // The indices must grow identically.
        if (AR0->getStepRecurrence(SE) != AR1->getStepRecurrence(SE)) {
          // Example:
          // S0 = Start0 + Step0 * i
          // S1 = Start1 + Step1 * i
          // d(i) = S0(i) - S1(i) = (Start0 - Start1) + (Step0 - Step1) * i
          // If Step0 != Step1, then the distance depends on the induction variable.
          errs() << "Different steps.\n";
          return false;
        }
        // Calculate distance for additive recurrence: d(i) = S0(i) - S1(i).
        const SCEV *Step = AR0->getStepRecurrence(SE);
        Dist = SE.getMinusSCEV(AR0->getStart(), AR1->getStart());
        errs() << "Additive recurrence distance: " << *Dist << ".\n";
        errs() << "Step: " << *Step << ".\n";
        // If the step is positive...
        if (SE.isKnownPositive(Step)) {
          if (SE.isKnownNegative(Dist)) {
            errs() << "Negative dependence detected.\n";
            return false;
          }
          if (!SE.isKnownNonNegative(Dist)) {
            errs() << "Distance is not statically determinable.\n";
            return false;
          }
        }
        // If the step is negative...
        else if (SE.isKnownNegative(Step)) {
          if (SE.isKnownPositive(Dist)) {
            errs() << "Positive dependence detected.\n";
            return false;
          }
          if (!SE.isKnownNonPositive(Dist)) {
            errs() << "Distance is not statically determinable.\n";
            return false;
          }
        }
      }
    }

    return true;
  }

  // Pre-ordering the loops ensures that L0 always dominates L1.
  // For simplicity, we don't handle cases where loops have conditional statements.
  bool loopFusion(Loop *L0, Loop *L1, ScalarEvolution &SE) {

    // First pruning: If a loop has more than one phi instruction in the header, then
    // we do not merge them.
    // We onsider only the simplest case of loop, where the only phi instruction
    // present in the header is the induction variable.
    int PhiCount0 = 0;
    for (const PHINode &Phi : L0->getHeader()->phis())
      PhiCount0++;
    int PhiCount1 = 0;
    for (const PHINode &Phi : L1->getHeader()->phis())
      PhiCount1++;
    if (PhiCount0 > 1 || PhiCount1 > 1) {
      errs() << "Loops contain multiple phi instructions in the header.\n";
      return false;
    }
    PHINode *IV0 = &*L0->getHeader()->phis().begin();
    PHINode *IV1 = &*L1->getHeader()->phis().begin();

    // Second pruning: We ensure that the loops don't have conditional statements to
    // avoid complications during the code motion.
    if (L0->getBlocks().size() > 3 || L1->getBlocks().size() > 3) {
      errs() << "Loops have more than 3 blocks (conditional statements).\n";
      return false;
    }

    // Moving the body of the second loop right after the body of the first loop, and
    // changing the exit of the first loop with the exit of the second loop. Since we
    // are assuming the absence of internal conditional statements or early exits
    // within the loop body, this implies that the body of the loop is composed of
    // exactly one BB. Therefore, we can move the instruction from the body of the
    // second right into the body of the first, without implementing additional
    // control logic.
    BasicBlock *Latch0 = L0->getLoopLatch();
    BasicBlock *Latch1 = L1->getLoopLatch();
    BasicBlock *Body0 = Latch0->getSinglePredecessor();
    BasicBlock *Body1 = Latch1->getSinglePredecessor();

    // Getting the insert point of where to moving the instruction of the body of the
    // second loop.
    Instruction *InsertPoint = Body0->getTerminator();
    // Getting the increment instruction for the second loop (we don't want to move
    // it). Also, we want to change the uses of the second with the first.
    Value *IncValue0 = IV0->getIncomingValueForBlock(Latch0);
    Value *IncValue1 = IV1->getIncomingValueForBlock(Latch1);

    // Identify the compare instruction that controls the loop exit.
    // We look at the terminator of the exiting block. If it's a conditional branch,
    // its condition is the exact ICmpInst we want to skip.
    Instruction *LoopCondition = nullptr;
    if (BasicBlock *Exiting1 = L1->getExitingBlock())
      if (BranchInst *BI = dyn_cast<BranchInst>(Exiting1->getTerminator()))
        if (BI->isConditional())
          LoopCondition = dyn_cast<Instruction>(BI->getCondition());

    // Code motion.
    for (auto iter = Body1->begin(); iter != Body1->end();) {
      Instruction &Inst = *iter++;
      if (Inst.isTerminator())
        break;
      if (isa<PHINode>(&Inst) ||
          &Inst == IncValue1 ||
          &Inst == LoopCondition)
        continue;
      Inst.replaceUsesOfWith(IV1, IV0); // We replace the uses only of the
                                        // instruction we effectively move.
      Inst.moveBefore(InsertPoint);
    }

    // Replacing uses outside the loops.
    for (auto iter = IV1->use_begin(); iter != IV1->use_end();) {
      Use &U = *iter++; // Advancing the iterator before it is modified.
      Instruction *UserInst = dyn_cast<Instruction>(U.getUser());
      // Ignoring uses inside the "skeleton" of the second loop.
      if (UserInst && L1->contains(UserInst)) 
        continue;
      U.set(IV0);
    }

    // Replacing the uses of the incremented variable of the second loop, with the
    // incremented variable of the first.
    for (auto iter = IncValue1->use_begin(); iter != IncValue1->use_end();) {
      Use &U = *iter++;
      Instruction *UserInst = dyn_cast<Instruction>(U.getUser());
      if (UserInst && L1->contains(UserInst))
        continue;
      U.set(IncValue0);
    }

    // Changing the exit block of the first loop with the exit block of the second.
    BasicBlock *Exiting0 = L0->getExitingBlock();
    BasicBlock *Exiting1 = L1->getExitingBlock();
    BasicBlock *Exit0 = L0->getExitBlock();
    BasicBlock *Exit1 = L1->getExitBlock();

    // Since the terminator instruction of the exiting block of L0 is a branch
    // instruction, we can change its successor from Exit0 to Exit1.
    BranchInst *Term0 = dyn_cast<BranchInst>(Exiting0->getTerminator());
    if (Term0->getSuccessor(0) == Exit0)
      Term0->setSuccessor(0, Exit1);
    else
      Term0->setSuccessor(1, Exit1);

    // Even if L1 is a dead loop, the CFG relations remain valid. Since the new exit
    // block of L0 (Exit1) will have two predecessors (Exiting0 and Exiting1), L0
    // will no longer be in canonical form.
    // To restore the canonical form, we remove Exiting1 from the predecessors of
    // Exit1, and we replace the terminator of Exiting1 with an unconditional branch
    // to L1's header.
    Exit1->removePredecessor(Exiting1);
    BranchInst *Term1 = cast<BranchInst>(Exiting1->getTerminator());
    BasicBlock *HeaderSuccessor = (Term1->getSuccessor(0) == Exit1) ?
                                   Term1->getSuccessor(1) :
                                   Term1->getSuccessor(0);
    BranchInst::Create(HeaderSuccessor, Term1); // Insert before Term1.
    Term1->eraseFromParent();

    return true;
  }

  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {

    errs() << "Starting pass for " << F.getName() << "...\n";

    bool changed = false;

    LoopInfo &LI = FAM.getResult<LoopAnalysis>(F);
    DominatorTree &DT = FAM.getResult<DominatorTreeAnalysis>(F);
    PostDominatorTree &PDT = FAM.getResult<PostDominatorTreeAnalysis>(F);
    ScalarEvolution &SE = FAM.getResult<ScalarEvolutionAnalysis>(F);
    DependenceInfo &DI = FAM.getResult<DependenceAnalysis>(F);

    SmallVector<Loop*, 8> Loops;
    // Top-level loops are visited in the same order they appear in the source code,
    // but reversed.
    // Note:
    // - We only visit the innermost loops.
    // - We want sibling innermost loops to be visited in the same way as top-level
    //   loops.
    for (Loop *TLL : LI) {
      SmallVector<Loop*, 8> LoopSiblings;
      for (Loop *L : depth_first(TLL))
        if (L->isInnermost())
          LoopSiblings.push_back(L);
      std::reverse(LoopSiblings.begin(), LoopSiblings.end());
      Loops.append(LoopSiblings.begin(), LoopSiblings.end());
    }

    errs() << "Loop order: ";
    for (int i = 0; i < Loops.size(); i++) {
      Loops[i]->getHeader()->printAsOperand(errs(), false);
      errs() << " ";
    }
    errs() << "\n";

    for (int i = 0; i < Loops.size() - 1; i++) {
      // By reversing the indices, we are guaranteed that LA is always the one that
      // dominates LB.
      Loop *LA = Loops[i+1];
      Loop *LB = Loops[i];
      if (!LA->isLoopSimplifyForm())
        continue;
      if (!LB->isLoopSimplifyForm())
        continue;
      if (LA->getParentLoop() != LB->getParentLoop())
        continue;
      errs() << "Evaluating ";
      LA->getHeader()->printAsOperand(errs(), false);
      errs() << " and ";
      LB->getHeader()->printAsOperand(errs(), false);
      errs() << ":\n";
      if (!areLoopsFuseable(LA, LB, DT, PDT, SE, DI)) {
        errs() << "Not suitable for Loop Fusion.\n";
        continue;
      }
      errs() << "Suitable for Loop Fusion.\n";
      if (loopFusion(LA, LB, SE)) {
        errs() << "Loops merged.\n";
        changed = true;
      }
      else
        errs() << "Loops not merged.\n";
    }

    errs() << "Ending pass for " << F.getName() << "...\n\n";

    return changed ? PreservedAnalyses::none() : PreservedAnalyses::all();
  }

  static bool isRequired() {
    return true;
  }

};

} // namespace

// PM Registration
llvm::PassPluginLibraryInfo getMyLoopFusionPassPluginInfo() {
  return {
    LLVM_PLUGIN_API_VERSION,
    "MyLoopFusionPass",
    LLVM_VERSION_STRING,
    [](PassBuilder &PB) {
      PB.registerPipelineParsingCallback(
        [](StringRef Name, FunctionPassManager &FPM,
          ArrayRef<PassBuilder::PipelineElement>) {
          // Command-line pipeline name.
          if (Name == "my-loop-fusion") {
            FPM.addPass(MyLoopFusionPass());
            return true;
          }
          return false;
        }
      );
    }
  };
}

// This is the core interface for pass plugins. It guarantees that 'opt' will be able
// to recognize TestPass when added to the pass pipeline on the command line, i.e.
// via '-passes=test-pass'.
extern "C" LLVM_ATTRIBUTE_WEAK ::llvm::PassPluginLibraryInfo
llvmGetPassPluginInfo() {
  return getMyLoopFusionPassPluginInfo();
}