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
        // possible tests: x = a + 0, x = 0 + a --> Ok | x = a + b --> no opt
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
        // possible tests: x = a - 0 --> Ok | x = 0 - a, x = a - b --> no opt
        if (BinOp->getOpcode() == Instruction::Sub){
          // the second operator needs to be zero to apply the optimization
          ConstantInt *C = dyn_cast<ConstantInt>(Op1);
          if (C && C->getValue().isZero()){
              BinOp->replaceAllUsesWith(Op0);
          }
        }

        // MUL CASE
        // possible tests: x = a * 1, x = 1 * a, x = 0 * a, x = a * 0 --> Ok 
        // x = a * b --> no opt
        if (BinOp->getOpcode() == Instruction::Mul){
          ConstantInt *C = dyn_cast<ConstantInt>(Op0);
          Value *Other = Op1;

          if (!C) {
            C = dyn_cast<ConstantInt>(Op1);
            Other = Op0;
            // If both the operands are not constants, continue
            if (!C) continue;
          } 
          
          if (C->getValue().isZero()){
            BinOp->replaceAllUsesWith(C);
          }
          else if (C->getValue().isOne()){
            BinOp->replaceAllUsesWith(Other);
          }
        }

        // DIV CASE
        // possible tests: x = a / 1,  x = 0 / a --> Ok 
        // x = 1 / a,  x = 0 / 0,  x = a / 0,  x = a / b --> no opt
        if (BinOp->getOpcode() == Instruction::SDiv || BinOp->getOpcode() == Instruction::UDiv){
          ConstantInt *C0 = dyn_cast<ConstantInt>(Op0);
          ConstantInt *C1 = dyn_cast<ConstantInt>(Op1);

          // Case 0 / y (with y != 0)
          // if the first operand is equal to zero (and the second is not) --> second operand
          if (C0 && C0->getValue().isZero() && !(C1 && C1->getValue().isZero())) {
              BinOp->replaceAllUsesWith(Op0);
              continue;
          }

          // Case y / 1
          // if the second operand is equal to one --> first operand
          if (C1 && C1->getValue().isOne()) {
              BinOp->replaceAllUsesWith(Op0);
              continue;
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