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
    SmallSetVector<Instruction*, 16> &InvariantSet) {
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
      // Uses of definitions inside the loop that has already been marked as
      // loop-invariant are also loop-invariant.
      if (InvariantSet.count(I))
        return true;
      return false;
    }
    // Conservative choice
    return false;
  }

  bool isInstructionLoopInvariant(Instruction &I, Loop *L,
    SmallSetVector<Instruction*, 16> &InvariantSet) {

    // Each basic block ends with a Terminator instruction, which specifies
    // the next basic block to be executed.
    // Examples of terminators: Return (ret), Branch (br), Switch (switch).
    // By definition, Terminator instructions are not loop-invariant.
    if (I.isTerminator())
      return false;

    // A phi instruction is loop-invariant only if the values associated with
    // the incoming blocks are the same and that value is itself loop-invariant.
    if (auto *PN = dyn_cast<PHINode>(&I)) {
      // FV (First Value)
      Value *FV = PN->getIncomingValue(0);
      for (unsigned i = 1; i < PN->getNumIncomingValues(); i++) {
        if (PN->getIncomingValue(i) != FV) {
          return false;
        }
      }
      return isOperandLoopInvariant(FV, L, InvariantSet);
    }

    /*
    These filters are not part of the definition of ‘loop-invariant’, but they
    are part of the definition of ‘hoistable instruction’
    
    // Examples of instructions with side effects: store operations and function
    // calls that alter the state of the program (e.g., printf).
    // Examples of instructions that read from memory: load instructions and
    // function calls that read from memory (e.g., strlen or printf).
    if (I.mayHaveSideEffects() || I.mayReadFromMemory())
      return false;

    // Examples of unsafe instructions: If we move a division by zero to the
    // pre-header and print some messages in the loop before the division by zero
    // is executed, we are altering the program's behaviour (previously it would
    // print and terminate with an error; now it terminates with an error
    // without printing).
    if (!isSafeToSpeculativelyExecute(&I)) {
      continue;
    */

    // An instruction is loop-invariant if its operands are also loop-invariant.
    for (Value *V : I.operand_values()) {
      if (!isOperandLoopInvariant(V, L, InvariantSet))
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
    // As long as the SetVector contains fewer than 16 elements, it is stored
    // on the stack (which is faster). Once it exceeds 16 elements, it is moved
    // to the heap (with a slight overhead).
    SmallSetVector<Instruction*, 16> InvariantSet;

    // The order in which the blocks of a loop are visited via L->blocks() is not
    // meaningful. This means that there is a risk that instructions which use
    // loop-invariant definitions, but have not yet been labelled as such, may be
    // mistakenly considered loop-variant.
    // Example:
    // s1: x = a + b <-- Loop-invariant
    // s2: y = x + 2
    // If we were to visit the block containing s2 first, then y would not be
    // considered loop-invariant as it uses x, which has not yet been labelled
    // as such.
    // We need to sort the nodes in the loop using Reverse Post-Order DFS
    // Traversal (RPO DFS Traversal): we visit the predecessors (which contain
    // the definitions) first, and then the successors (which contain the uses).
    LoopBlocksRPO LBRPO(L);
    LBRPO.perform(&LI); // Traverse the loop blocks and store the DFS result.

    // We could also have used a Pre-Order DFS traversal on the Dominator Tree,
    // as in SSA form we are guaranteed that every use is dominated by its
    // (single) definition. However, the order of sibling nodes, i.e., the
    // children of a parent node, is not guaranteed. This is a problem for
    // branches because there is a risk that the phi node will be visited before
    // the branches.
    // Since we have not evaluated the input values of the phi instruction, it
    // will always be labelled as a variant.
    // Example (pseudo-code):
    // %if.header A
    // val = 10;
    // if (cond) {
    //   // %if.then B
    // }
    // else {
    //   // %if.else C
    // }
    // %if.merge D
    // x = phi([val, %B], [val, %C])
    // Dominator Tree:
    // A -> {B, C, D}
    // Let us assume that we have the following traversal order:
    // A -> D -> C -> B
    // The input values are the same, but that value is not in the set of
    // invariants. Consequently, the phi statement is also a variant.

    for (BasicBlock *BB : LBRPO) {

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
        if (isInstructionLoopInvariant(I, L, InvariantSet)) {
          errs() << "\tInvariant: " << I << "\n";
          InvariantSet.insert(&I);
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
