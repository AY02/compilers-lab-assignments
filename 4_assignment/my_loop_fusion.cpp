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
  bool checking_conditions(Loop* LA, Loop* LB, DominatorTree &DT, PostDominatorTree &PDT) {

    // First pruning: If one loop is guarded while the other is unguarded, then they cannot merge
    // because they do not satisfy condition 3.
    BranchInst *GuardA = LA->getLoopGuardBranch();
    BranchInst *GuardB = LB->getLoopGuardBranch();
    bool isLAGuarded = (GuardA != nullptr);
    bool isLBGuarded = (GuardB != nullptr);
    if (isLAGuarded != isLBGuarded) {
      return false;
    }

    // Second pruning: If both loops are guarded and have a logically different guard condition,
    // then they cannot merge because they do not satisfy condition 3.
    if (isLAGuarded && isLBGuarded) {
      Value *CA = GuardA->getCondition();
      Value *CB = GuardB->getCondition();
      // The two loops use different registers for comparison.
      if (CA != CB) {
        auto *IA = dyn_cast<Instruction>(CA);
        auto *IB = dyn_cast<Instruction>(CB);
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


    // QUI FINISCONO LE MIE MODIFICHE

    /*
    // 1) adjacency condition

    // Note 1: because of the 3rd condition, it is useless to verify whether the two loops are adjacent 
    // loops if they are guarded and unguarded, or both guarded: they will always result in false for 
    // the 3rd condition (since they are not control flow (CF) equivalent). Therefore, we only analize
    // the case in which they are both unguarded (check Note 2 for more details)

    // Note 2: despite Note 1 and what we told about the case where both the loops are guarded, 
    // the loops can still be CF equivalent but only if the guard conditions are the same. 
    // Therefore, in the adjacency analysis we can check that case aswell.
    // Nota di Alessio: Non e' una cosa banale in quanto siamo in SSA. Anche se i due loop avessero una condizione
    // di guardia logicamente corretta, in SSA utilizzerebbero registri diversi.

    // Note 3: considering that we don't allow instructions to be between the two loops,
    // if there are more exit blocks it is guaranteed that the 3rd condition is not
    // satisfied, therefore we just analize the case with just one exit block.
    // Nota di Alessio: In realta', il primo loop deve avere un solo exiting block perche' dobbiamo avere la garanzia
    // che i due loop abbiano lo stesso trip count.
    // Se il secondo loop non avesse un'uscita anticipata, allora i due loop avrebbero un trip count diverso e quindi
    // la condizione 2 non verrebbe rispettata.
    // Quindi, il pruning e' il seguente: il primo loop deve avere un solo exiting block (e quindi un solo exit block).

    bool adjacent = false;

    // CASE: both loops are guarded
    // The loops are adjacent if:
    // - the guard of the first points to the guard of the second
    // - the guard conditions are the same
    // - the guard of the second only contains that control statement
    // - the preheader of the second loop only contains the branch 
    if (isL0Guarded && isL1Guarded){
      if ( (Guard0->getSuccessor(0) == Guard1->getParent()     // 1st ...
            || Guard0->getSuccessor(1) == Guard1->getParent()) // ... 1st
          // && Guard0->getCondition() == Guard1->getCondition()  // 2nd 
          && Guard1->getParent()->size() == 1                  // 3rd
          && L1->getLoopPreheader()->size() == 1){             // 4th
          adjacent = true;
        }
    }

    // CASE: both loops are not guarded
    // The loops are adjacent if:
    // - the exit block of the first is the preheader of the second
    // - the preheader of the second loop only contains the branch
    else if (!L0->isGuarded() && !L1->isGuarded()){
      if (L0->getExitBlock() == L1->getLoopPreheader() 
          && L0->getExitBlock() != nullptr
          && L1->getLoopPreheader()->size() == 1){
            adjacent = true;
      }
    }   

    // 2) Same number of iterations



    // 3) Control Flow equivalence
    
    // Two loops are CF equivalent if the loops are always executed together, when executed,
    // and the first executed is the first loop and the second executed is the second loop.
    // This means that the first loop needs to dominate the second loop, and the second loop
    // is post-dominated by the first loop.

    // This transaltes in LLVM by checking that the header of the first loop
    // dominates the header of the second (entering the first loop always brings 
    // to the second loop), and that the header of the second is post-dominated 
    // by the header of the first (every time the header of the second is executed,
    // you always executed the first loop). 

    // If the loops are both guarded but have the same condition...

    bool cf_equivalent = false;

    BasicBlock *Header0 = L0->getHeader();
    BasicBlock *Header1 = L1->getHeader();

    if (DT.dominates(Header0, Header1) 
        && PDT.dominates(Header1, Header0))
        cf_equivalent = true;
    
    // Relaxed condition for both loops guarded.
    // Note that this relaxation assumes that L0 is 
    // the loop that executes first 
    if (L0->isGuarded() && L1->isGuarded()){
      if (L0->getLoopGuardBranch()->getCondition() 
        == L1->getLoopGuardBranch()->getCondition()){
          cf_equivalent = true;
      }
    }
    
    // 4) 

    errs() << "Adjacency condition: " << adjacent << "\n";
    errs() << "CF equivalence condition: " << cf_equivalent << "\n";
    return adjacent && cf_equivalent;
    */
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
