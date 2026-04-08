#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"


using namespace llvm;


namespace {


struct MyMultiInstruction: PassInfoMixin<MyMultiInstruction> {
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &) {

    return PreservedAnalyses::all();
  }
  static bool isRequired() { return true; }
};


}


llvm::PassPluginLibraryInfo getMyMultiInstructionPluginInfo() {
  return {
    LLVM_PLUGIN_API_VERSION,
    "MyMultiInstruction",
    LLVM_VERSION_STRING,
    [](PassBuilder &PB) {
      PB.registerPipelineParsingCallback(
        [](
          StringRef Name,
          FunctionPassManager &FPM,
          ArrayRef<PassBuilder::PipelineElement>
        ) {
          if (Name == "my-multi-instruction") {
            FPM.addPass(MyMultiInstruction());
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
  return getMyMultiInstructionPluginInfo();
}