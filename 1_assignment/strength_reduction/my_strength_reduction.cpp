#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"


using namespace llvm;


namespace {


struct MyStrengthReduction: PassInfoMixin<MyStrengthReduction> {
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &) {

    return PreservedAnalyses::all();
  }
  static bool isRequired() { return true; }
};
}


llvm::PassPluginLibraryInfo getMyStrengthReductionPluginInfo() {
  return {
    LLVM_PLUGIN_API_VERSION,
    "MyStrengthReduction",
    LLVM_VERSION_STRING,
    [](PassBuilder &PB) {
      PB.registerPipelineParsingCallback(
        [](
          StringRef Name,
          FunctionPassManager &FPM,
          ArrayRef<PassBuilder::PipelineElement>
        ) {
          if (Name == "my-strength-reduction") {
            FPM.addPass(MyStrengthReduction());
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
  return getMyStrengthReductionPluginInfo();
}