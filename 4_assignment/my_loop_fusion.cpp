#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"

#include "llvm/Analysis/LoopInfo.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Dominators.h"
#include "llvm/Analysis/PostDominators.h"

using namespace llvm;
  
namespace {

struct MyLoopFusionPass: PassInfoMixin<MyLoopFusionPass> {

  // Assumptions:
  // - LA and LB are siblings.
  // - Both loops are in canonical form.
  bool checking_conditions(Loop* LA, Loop* LB, DominatorTree &DT, PostDominatorTree &PDT, ScalarEvolution &SE, DependenceInfo *DI) {

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
          if (!IA->isIdenticalTo(IB))
            return false;
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
    if (!ExitingBlockA || !ExitingBlockB)
      return false;
    
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
    if (DT->dominates(EntryA, EntryB) && PDT->dominates(EntryB, EntryA)) {
      L0 = LA; L1 = LB;
      Entry0 = EntryA; Entry1 = EntryB;
    } else if (DT->dominates(EntryB, EntryA) && PDT->dominates(EntryA, EntryB)) {
      L0 = LB; L1 = LA;
      Entry0 = EntryB; Entry1 = EntryA;
    } else {
      // Condition 3 is not met.
      return false;
    }

    // Condition 1: Adjacency
    // The exit block of the first loop must be the entry block of the second loop.
    BasicBlock *ExitBlock0 = L0->getExitBlock();
    if (ExitBlock0 != Entry1)
      return false;
    // The pre-header of the second loop must not contain any instructions other
    // than the unconditional jump to the header.
    BasicBlock *Preheader1 = L1->getLoopPreheader();
    if (Preheader1 && Preheader1->size() != 1)
      return false;
    // The guard of the second loop (if it exists) must have only the comparison instruction
    // and the conditional branch.
    BranchInst *Guard1 = L1->getLoopGuardBranch();
    if (Guard1 && Guard1->getParent()->size() > 2)
      return false;
    
    // Condition 2: Trip Count Equivalence
    const SCEV *TripCount0 = SE->getBackedgeTakenCount(L0);
    const SCEV *TripCount1 = SE->getBackedgeTakenCount(L1);
    // If at least one of the two algebraic expressions of the trip count could not be calculated,
    // then the two loops cannot be merged.
    if (isa<SCEVCouldNotCompute>(TripCount0) || isa<SCEVCouldNotCompute>(TripCount1))
      return false;
    // If the algebraic expressions of the trip counts are different, then they cannot be merged.
    if (TripCount0 != TripCount1)
      return false;

    // Condition 4: Absence of Negative Dependencies
    // First loop memory access instructions.
    SmallVector<Instruction*, 16> MemInsts0;
    for (BasicBlock *BB : L0->blocks()) {
      for (Instruction &I : *BB) {
        if (I.mayReadOrWriteMemory())
          MemInsts0.push_back(&I);
      }
    }
    // Second loop memory access instructions.
    SmallVector<Instruction*, 16> MemInsts1;
    for (BasicBlock *BB : L1->blocks()) {
      for (Instruction &I : *BB) {
        if (I.mayReadOrWriteMemory())
          MemInsts1.push_back(&I);
      }
    }
    // Negative dependence check for each pair of (I0, I1).
    for (Instruction *I0 : MemInsts0) {
      for (Instruction *I1 : MemInsts1) {
        // If both instructions are load statements, then they have no negative dependencies.
        if (isa<LoadInst>(I0) && isa<LoadInst>(I1))
          continue;
        if (auto Dep = DI->depends(I0, I1, true)) {
          unsigned Direction = Dep->getDirection(1);
          // If the two instructions have a negative dependency, then the two loops cannot be
          // merged.
          if (Direction & Dependence::DVEntry::GT)
            return false;
        }
      }
    }

    return true;
  }

  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {
    errs() << "\n";

    errs() << "Starting analysis for " << F.getName() << "...\n";

    LoopInfo &LI = FAM.getResult<LoopAnalysis>(F);
    DominatorTree &DT = FAM.getResult<DominatorTreeAnalysis>(F);
    PostDominatorTree &PDT = FAM.getResult<PostDominatorTreeAnalysis>(F);

    auto it = LI.begin();
    Loop *L0 = *it;
    auto next_it = it;
    next_it++;
    Loop *L1 = *next_it;

    bool value = checking_conditions(L1, L0, DT, PDT);
    errs() << "\nConditions value for test:" << value <<"\n";

    errs() << "\n";

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
                  if (Name == "my-loop-fusion") { // flag da terminale
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
