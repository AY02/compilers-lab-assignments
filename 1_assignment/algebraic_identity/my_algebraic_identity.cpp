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
        
        // ADD CASE
        if (BinOp->getOpcode() == Instruction::Add){
          ConstantInt *C = dyn_cast<ConstantInt>(Op0);
          Value *Other = Op1;

          if (!C) {
            C = dyn_cast<ConstantInt>(Op1);
            Other = Op0;
          }

          // If there are no constants, continue
          if (!C) continue;
          
          // C->getValue().isZero() is the same as C->getValue() == 0
          if (C->getValue() == 0){
            BinOp->replaceAllUsesWith(Other);
          }
        }

        // SUB CASE
        if (BinOp->getOpcode() == Instruction::Sub){
          // first operator is not a constant, second operator is a constant
          if (!dyn_cast<ConstantInt>(Op0) && dyn_cast<ConstantInt>(Op1)){
            Value *First = Op0;
            ConstantInt *Second = dyn_cast<ConstantInt>(Op1);
            if (Second->getValue().isZero()){
              BinOp->replaceAllUsesWith(First);
            }
          }
        }

        // MUL CASE
        if (BinOp->getOpcode() == Instruction::Mul){
          ConstantInt *C = dyn_cast<ConstantInt>(Op0);
          Value *Other = Op1;

          if (!C) {
            C = dyn_cast<ConstantInt>(Op1);
            Other = Op0;
          }

          // If there are no constants, continue
          if (!C) continue;
          
          if (C->getValue().isOne()){
            BinOp->replaceAllUsesWith(Other);
          }
        }

        // DIV CASE
        if (BinOp->getOpcode() == Instruction::Div){
          // first operator is not a constant, second operator is a constant
          if (!dyn_cast<ConstantInt>(Op0) && dyn_cast<ConstantInt>(Op1)){
            Value *First = Op0;
            ConstantInt *Second = dyn_cast<ConstantInt>(Op1);
            if (Second->getValue().isOne()){
              BinOp->replaceAllUsesWith(First);
            }
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