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

  // ale proposes to make prooning before the the function (e.g. removing the 
  // loops that have more exit blocks, etc.)
  // order of conditions can be modified
  bool checking_conditions(Loop* L0, Loop* L1, DominatorTree &DT, PostDominatorTree &PDT){

    // 1) adjacency condition

    // Note 1: because of the 3rd condition, it is useless to verify whether the two loops are adjacent 
    // loops if they are guarded and unguarded, or both guarded: they will always result in false for 
    // the 3rd condition (since they are not control flow (CF) equivalent). Therefore, we only analize
    // the case in which they are both unguarded (check Note 2 for more details)

    // Note 2: despite Note 1 and what we told about the case where both the loops are guarded, 
    // the loops can still be CF equivalent but only if the guard conditions are the same. 
    // Therefore, in the adjacency analysis we can check that case aswell.

    // Note 3: considering that we don't allow instructions to be between the two loops,
    // if there are more exit blocks it is guaranteed that the 3rd condition is not
    // satisfied, therefore we just analize the case with just one exit block.  
    // 
    // should I check that EVERY exit block of the loops converges on the pre-header 
    // of the second loop or for its guard? 
    // I think that's already given, because of the 3rd condition if there are more
    // exit blocks and we doesn't want to have instrusctions between the two loops

    
    bool adjacent = false;

    // CASE: both loops are guarded
    // The loops are adjacent if:
    // - the guard of the first points to the guard of the second
    // - the guard conditions are the same
    // - the guard of the second only contains that control statement
    // - the preheader of the second loop only contains the branch 
    if (L0->isGuarded() && L1->isGuarded()){
      BranchInst *Guard0 = L0->getLoopGuardBranch();
      BranchInst *Guard1 = L1->getLoopGuardBranch();
      if ( (Guard0->getSuccessor(0) == Guard1->getParent()     // 1st ...
            || Guard0->getSuccessor(1) == Guard1->getParent()) // ... 1st
          && Guard0->getCondition() == Guard1->getCondition()  // 2nd 
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

    /**************/
    // 2) Same number of iterations



    /**************/
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
    

    /**************/
    // 4) 


    return adjacent && cf_equivalent;
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

    bool value = checking_conditions(L0, L1, DT, PDT);
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
