#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"


using namespace llvm;


namespace {


struct MyAlgebraicIdentity: PassInfoMixin<MyAlgebraicIdentity> {
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &) {

    // cycling on instructions
    for (auto Iter = F.begin(); Iter != F.end(); ++Iter) {
      BasicBlock &B = *Iter;

      for (auto I = B.begin(); I != B.end(); ++I) {
        Instruction &Inst = *I;

        // If it is a binary operation
        BinaryOperator *BinOp = dyn_cast<BinaryOperator>(&Inst);
        if (!BinOp) continue;
        Value *Op0 = BinOp->getOperand(0);
        Value *Op1 = BinOp->getOperand(1);
        
        // ADD CASE: 
        // possible tests: x = 0 + 0, x = y + 0, x = 0 + y, x = t + y
        if (BinOp->getOpcode() == Instruction::Add){
          ConstantInt *C = dyn_cast<ConstantInt>(Op0);
          Value *Other = Op1;

          if (!C) {
            C = dyn_cast<ConstantInt>(Op1);
            Other = Op0;
            // If both the operands are not constants, continue
            if (!C) continue;
          }          
          
          // if the constant is equal to zero, then the uses of the BinOp can
          // be replaced with the value of the Other operator
          if (C->getValue().isZero()){
            BinOp->replaceAllUsesWith(Other);
          }
        }

        // SUB CASE:
        // possible tests: x = 0 - 0, x = y - 0, x = 0 - y, x = t - y
        if (BinOp->getOpcode() == Instruction::Sub){
          // the second operator needs to be zero to apply the optimization
          ConstantInt *C = dyn_cast<ConstantInt>(Op1);
          if (C && C->isZero()){
              BinOp->replaceAllUsesWith(Op0);
          }
        }

        // MUL CASE
        // possible tests: x = 1 * 4, x = y * 1, x = 1 * y, x = t * y
        if (BinOp->getOpcode() == Instruction::Mul){
          ConstantInt *C = dyn_cast<ConstantInt>(Op0);
          Value *Other = Op1;

          if (!C) {
            C = dyn_cast<ConstantInt>(Op1);
            Other = Op0;
            // If both the operands are not constants, continue
            if (!C) continue;
          } 
          
          if (C->getValue().isOne()){
            BinOp->replaceAllUsesWith(Other);
          }
        }

        // DIV CASE
        // possible tests: x = 1 / 4, x = 4 / 1, x = y / 1, x = 1 / y, x = t / y
        if (BinOp->getOpcode() == Instruction::SDiv || BinOp->getOpcode() == Instruction::UDiv){
          // the second operator needs to be equal to one
          ConstantInt *C = dyn_cast<ConstantInt>(Op1);
          if (C && C->isOne()){
              BinOp->replaceAllUsesWith(Op0);
          }
        }

      }
    }
    return PreservedAnalyses::all();
  }
  static bool isRequired() { return true; }
};
}


llvm::PassPluginLibraryInfo getMyAlgebraicIdentityPluginInfo() {
  return {
    LLVM_PLUGIN_API_VERSION,
    "MyAlgebraicIdentity",
    LLVM_VERSION_STRING,
    [](PassBuilder &PB) {
      PB.registerPipelineParsingCallback(
        [](
          StringRef Name,
          FunctionPassManager &FPM,
          ArrayRef<PassBuilder::PipelineElement>
        ) {
          if (Name == "my-algebraic-identity") {
            FPM.addPass(MyAlgebraicIdentity());
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
  return getMyAlgebraicIdentityPluginInfo();
}