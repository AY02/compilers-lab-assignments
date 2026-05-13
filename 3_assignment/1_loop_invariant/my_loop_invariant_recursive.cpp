#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"

#include "llvm/Analysis/LoopInfo.h"
#include "llvm/ADT/SetVector.h"
#include "llvm/Analysis/LoopIterator.h"

using namespace llvm;


namespace {


struct MyLoopInvariant: PassInfoMixin<MyLoopInvariant> {

  bool isOperandLoopInvariant(Value *V, Loop *L,
    SmallSetVector<Instruction*, 16> &InvariantSet,
    SmallSetVector<Instruction*, 16> &VariantSet) {
    // In LLVM IR, global variables are pointers, and the load and store
    // instructions are used to read or modify them. Consequently, they are
    // loop-invariant by construction.
    if (isa<Constant>(V) || isa<Argument>(V) || isa<GlobalValue>(V))
      return true;
    if (Instruction *I = dyn_cast<Instruction>(V)) {
      // Uses of definitions outside the loop are loop-invariant.
      // I->getParent() is the basic block containing I.
      if (!L->contains(I->getParent()))
        return true;
      // Uses of definitions inside the loop that have already been marked as
      // loop-invariant are also loop-invariant.
      // It is no longer guaranteed as we may be visiting the use before its
      // definition.
      if (InvariantSet.count(I))
        return true;
      
      // Uses of definitions inside the loop that have already been marked as
      // loop-variant are also loop-variant.
      if (VariantSet.count(I))
        return false;
      
      // This is a necessary condition, as there is no longer a traversal order.
      if (isInstructionLoopInvariant(*I, L, InvariantSet, VariantSet)) {
        InvariantSet.insert(I);
        return true;
      }

      // If the instruction is not loop-invariant, then we save it in the
      // VariantSet.
      VariantSet.insert(I);
      return false;
    }
    // Conservative choice
    return false;
  }

  bool isInstructionLoopInvariant(Instruction &I, Loop *L,
    SmallSetVector<Instruction*, 16> &InvariantSet,
    SmallSetVector<Instruction*, 16> &VariantSet) {

    // Each basic block ends with a Terminator instruction, which specifies the
    // next basic block to be executed.
    // Examples of terminators: Return (ret), Branch (br), Switch (switch).
    // By definition, Terminator instructions are not loop-invariant.
    if (I.isTerminator())
      return false;

    // Phi instructions cannot be considered loop-invariant, as they would cause
    // an infinite loop in the recursion. In fact, by ignoring them in our
    // analysis, we would also be ignoring the check on the latch operand of the
    // phi, and would therefore be traversing the CFG without taking back-edges
    // into account, effectively turning it into a DAG.
    if (isa<PHINode>(I)) {
      return false;
    }

    /*
    These filters are not part of the definition of loop-invariant, but they are
    part of the definition of hoistable instruction.
    
    // Examples of instructions with side effects: store operations and function
    // calls that alter the state of the program (e.g., printf).
    // Examples of instructions that read from memory: load instructions and
    // function calls that read from memory (e.g., strlen or printf).
    if (I.mayHaveSideEffects() || I.mayReadFromMemory())
      return false;
    */

    // An instruction is loop-invariant if its operands are also loop-invariant.
    for (Value *V : I.operand_values()) {
      if (!isOperandLoopInvariant(V, L, InvariantSet, VariantSet))
        return false;
    }

    return true;

  }

  void printLoopInvariantsInLoop(Loop *L, LoopInfo &LI) {

    errs() << "Loop Header: ";
    L->getHeader()->printAsOperand(errs(), false);
    errs() << "\nDepth: " << L->getLoopDepth() << "\n";

    // An LLVM data structure that combines the advantages of sets and vectors:
    // - Vector: It is an ordered collection, i.e., the iteration sequence is
    // deterministic.
    // - Set: The elements are unique, i.e., a search takes O(1) time.
    // As long as the SetVector contains fewer than 16 elements, it is stored on
    // the stack (which is faster). Once it exceeds 16 elements, it is moved to
    // the heap (with a slight overhead).
    SmallSetVector<Instruction*, 16> InvariantSet;

    // In the recursive algorithm, the InvariantSet set vector is used solely to
    // prevent the program from re-executing recursive visits to the same
    // instruction that lead to the conclusion that the instruction is
    // loop-invariant.
    // We must do the same for instructions that we are certain are loop-variant,
    // again to avoid unnecessary recursive visits to the same variant instruction.
    SmallSetVector<Instruction*, 16> VariantSet;
    
    // We no longer use a meaningful visit order, but instead apply recursion to
    // the operands of instructions that have not yet been labelled as
    // loop-invariants.
    for (BasicBlock *BB : L->blocks()) {

      // LI.getLoopFor(BB) returns the innermost loop to which BB belongs.
      // If we are in an outer loop, then we skip the blocks belonging to the
      // inner loops.
      // These two lines should be commented out if only Loop-Invariant Analysis
      // is being performed (without Code Motion).
      // Otherwise, instructions considered loop-invariant within an inner loop
      // will never be considered loop-invariant with respect to the outer loop
      // (see the test cases).
      // In other words, we analyse the instructions only in relation to the
      // innermost loop to which they belong.
      if (LI.getLoopFor(BB) != L)
        continue;

      // Loop-Invariant Analysis
      for (Instruction &I : *BB) {
        // If the statement has already been classified during a previous
        // recursive traversal, then we skip the analysis.
        if (InvariantSet.count(&I) || VariantSet.count(&I))
          continue;
        if (isInstructionLoopInvariant(I, L, InvariantSet, VariantSet)) {
          errs() << "\tInvariant: " << I << "\n";
          InvariantSet.insert(&I);
        } else {
          // If it is loop-variant, we save it in VariantSet.
          VariantSet.insert(&I);
        }
      }

    }

  }

  // We perform a Post-Order DFS traversal as a preliminary step for code motion,
  // using a bottom-up algorithm. By performing code motion starting from an
  // inner loop, we move the loop-invariant instructions to the pre-header,
  // incorporating them into the outer loop. In this way, by the next iteration,
  // the outer loop will be ready for full analysis.
  // If we were to use the native function LoopInfo->getLoopsInPreorder(), we
  // would have to iterate the analysis step until convergence (for a number of
  // times equal to the depth of the nested loop + 1).
  void PostOrderDFS(Loop *L, LoopInfo &LI) {
    // SL (Sub-Loop)
    for (Loop *SL : *L)
      PostOrderDFS(SL, LI);
    printLoopInvariantsInLoop(L, LI);
  }

  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {

    errs() << "Starting analysis for " << F.getName() << "...\n";

    LoopInfo &LI = FAM.getResult<LoopAnalysis>(F);

    if (LI.empty()) {
      errs() << "There are no loops.\n";
      return PreservedAnalyses::all();
    }

    // TLL (Top-Level Loop)
    for (Loop *TLL : LI) {
      PostOrderDFS(TLL, LI);
    }

    errs() << "Ending analysis for " << F.getName() << ".\n\n";

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
