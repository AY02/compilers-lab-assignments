#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"

#include "llvm/Analysis/LoopInfo.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Argument.h"
#include "llvm/Analysis/ValueTracking.h"
#include "llvm/IR/Dominators.h"
#include "llvm/ADT/DepthFirstIterator.h"

using namespace llvm;


namespace {


struct MyLoopInvariant: PassInfoMixin<MyLoopInvariant> {

  bool isOperandLoopInvariant(Value *V, Loop *L, SmallPtrSetImpl<Instruction*> &InvariantSet) {
    if (isa<Constant>(V) || isa<Argument>(V) || isa<GlobalValue>(V))
      return true;
    if (Instruction *I = dyn_cast<Instruction>(V)) {
      // Uses of definitions outside the loop are loop-invariant.
      if (!L->contains(I->getParent()))
        return true;
      // Uses of definitions inside the loop that has already been marked as loop-invariant are also loop-invariant.
      if (InvariantSet.count(I))
        return true;
      return false;
    }
    // Conservative choice for any cases not considered.
    return false;
  }

  // We can think of LoopInfo as a forest of top-level loops.
  // Consequently, we can perform a Post-Order DFS traversal on each top-level loop.
  void DFS(Loop *L, LoopInfo &LI, DominatorTree &DT) {
    // We iterate over the children of the current L.
    for (Loop *SubLoop : *L)
      DFS(SubLoop, LI, DT);

    errs() << "Loop with header ";
    L->getHeader()->printAsOperand(errs(), false);
    errs() << "\nLoop Depth " << L->getLoopDepth() << "\n";

    // Optimized LLVM set data structure.
    SmallPtrSet<Instruction*, 16> InvariantSet;
    DomTreeNode *Header = DT.getNode(L->getHeader());

    // L->blocks() does not guarantee a meaningful order.
    // Definitions might be visited after their uses, potentially causing us to miss some invariants.
    // We should use Reverse Post-Order or Dominator Tree.
    for (DomTreeNode *Node : depth_first(Header)) {
      BasicBlock *BB = Node->getBlock();
      // We ignore nodes of the dominator tree which are outside the loop (exit nodes).
      if (!L->contains(BB))
        continue;
      // Skip blocks belonging to subloops.
      if (LI.getLoopFor(BB) != L)
        continue;
      for (Instruction &I : *BB) {
        // Phi, Branch, Switch and Return are not loop-invariant by construction.
        if (I.isTerminator() || isa<PHINode>(&I))
          continue;
        //We do not move instructions that might have side effects.
        if (I.mayHaveSideEffects() || I.mayReadFromMemory()) {
          continue;
        }
        // We do not move unsafe instructions (e.g., division by zero, overflow, etc.)
        if (!isSafeToSpeculativelyExecute(&I)) {
          continue;
        }
        bool isInvariant = true;
        for (Value *V : I.operand_values()) {
          if (!isOperandLoopInvariant(V, L, InvariantSet)) {
            isInvariant = false;
            break;
          }
        }
        if (isInvariant) {
          errs() << "Invariant: " << I << "\n";
          InvariantSet.insert(&I);
        }
      }
    }
  }

  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {

    errs() << "Function name: " << F.getName() << "\n";

    LoopInfo &LI = FAM.getResult<LoopAnalysis>(F);
    DominatorTree &DT = FAM.getResult<DominatorTreeAnalysis>(F);

    // Iteration on top-level loops.
    for (Loop *L : LI) {
      DFS(L, LI, DT);
    }

    errs() << "Ending analysis for " << F.getName() << "\n";

    return PreservedAnalyses::all();
  }
  static bool isRequired() { return true; }
};


}


llvm::PassPluginLibraryInfo getMyLoopInvariantPluginInfo() {
  return {
    LLVM_PLUGIN_API_VERSION,
    "MyLoopInvariant",
    LLVM_VERSION_STRING,
    [](PassBuilder &PB) {
      PB.registerPipelineParsingCallback(
        [](
          StringRef Name,
          FunctionPassManager &FPM,
          ArrayRef<PassBuilder::PipelineElement>
        ) {
          if (Name == "my-loop-invariant") {
            FPM.addPass(MyLoopInvariant());
            return true;
          }
          return false;
        }
      );
    }
  };
}


extern "C" LLVM_ATTRIBUTE_WEAK ::llvm::PassPluginLibraryInfo
llvmGetPassPluginInfo() {
  return getMyLoopInvariantPluginInfo();
}