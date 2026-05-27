#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/IR/CFG.h"

using namespace llvm;
  
namespace {

// New PM implementation
struct LoopFusionPass: PassInfoMixin<LoopFusionPass> {

  void checking_conditions(Loop* L0, Loop* L1){
    // 1) adjacent loops
    bool adjacent = false;

    // Note: because of the 3rd condition, is useless to verify whether they are adjacent 
    // loops that are guarded and unguarded, or both guarded: they will always result in false for 
    // the 3rd condition (since they are not control flow (CF) equivalent)

    // Note: even if they both are guarded, they could be CF equivalent if the guard condition
    // is the same. Therefore, in the adjacency analysis we can check that case aswell.

    // loops are guarded:
    // they are adjacent if the guard of the first points to the guard
    // of the second, and the guard of the second only contains that
    // control statement. 
    if (L0->isGuarded() && L1->isGuarded()){

    }

    // loops are not guarded
    else {
      if (TLL_0->getExitBlock() == TLL_1->getLoopPreheader() && TLL->getExitBlock() != nullptr){
        if (TLL_1->getLoopPreheader()->size() == 1){
          adjacent = true;
        }
      }
    }   

    /**************/
    // 2)

    /**************/
    // 3) Control Flow equivalence

    /**************/
    // 4)

  }

  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {
    errs() << "\n";

    errs() << "Starting analysis for " << F.getName() << "...\n";

    LoopInfo &LI = FAM.getResult<LoopAnalysis>(F);
    DominatorTree &DT = FAM.getResult<DominatorTreeAnalysis>(F);

    // 1) adjacent loops
    bool adjacent = false;

    // simple case: checking only top level loops
    for (auto it = LI.begin(); it != LI.end(); ++it) {
      Loop *TLL_0 = *it;
      auto next_it = it;
      next_it++;

      // if there is a successive loop
      if (next_it != LI.end()){
        Loop *TLL_1 = *next_it;

        // posso controllare se entrambi sono guarded: nel caso in cui abbiano la stessa condizione
        // chiaramente o eseguono insieme o non esegue nessuno

        // loop 0 is guarded
        if (TLL_0->isGuarded()){
          CondBrInst *Instr_Guard = TLL_0->getLoopGuardBranch();

          BasicBlock *TLL_1_Entry = nullptr;
          if (TLL_1->isGuarded()) {
              TLL_1_Entry = TLL_1->getLoopGuardBranch()->getParent();
          } else {
              TLL_1_Entry = TLL_1->getLoopPreheader();
          }

          if (Instr_Guard->getSuccessor(0) == TLL_1_Entry || Instr_Guard->getSuccessor(1) == TLL_1_Entry){
            if (TLL_1_Entry != nullptr){
              // sono adiacenti se la guardia del primo punta alla guardia del secondo
              // e il secondo contiene solo quello statement di controllo
              adjacent = true;
            }
          }
        }

        // loop 0 is not guarded
        else {
          if (TLL_0->getExitBlock() == TLL_1->getLoopPreheader() && TLL->getExitBlock() != nullptr){
            if (TLL_1->getLoopPreheader()->size() == 1){
              adjacent = true;
            }
          }
        }
      }
    }    

    errs() << "\n";

    return PreservedAnalyses::all();
  }
  static bool isRequired() { return true; }
};
} // namespace

//-----------------------------------------------------------------------------
// New PM Registration
//-----------------------------------------------------------------------------
llvm::PassPluginLibraryInfo getLoopFusionPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "LoopFusionPass", LLVM_VERSION_STRING,
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "loop-fusion-pass") { // flag da terminale
                    FPM.addPass(LoopFusionPass());
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
  return getLoopFusionPassPluginInfo();
}
