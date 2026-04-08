#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"


using namespace llvm;


namespace {


struct MyStrengthReduction: PassInfoMixin<MyStrengthReduction> {
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &) {

    for (auto iter = F.begin(); iter != F.end(); iter++) {
      BasicBlock &B = *iter;
      for (auto jter = B.begin(); jter != B.end(); jter++) {
        Instruction &instr = *jter;
        if (instr.getOpcode() == Instruction::Mul) {
          Value *op0 = instr.getOperand(0);
          Value *op1 = instr.getOperand(1);
          ConstantInt *const_op = nullptr;
          Value *op = nullptr;
          if (ConstantInt *c0 = dyn_cast<ConstantInt>(op0)) {
            const_op = c0;
            op = op1;
          }
          else if (ConstantInt *c1 = dyn_cast<ConstantInt>(op1)) {
            const_op = c1;
            op = op0;
          }
          if (const_op && const_op->getValue().sgt(0)) {
            APInt val = const_op->getValue();
            if (val.isPowerOf2()) {
              // x = 2 ^ k -> x = x << k
              unsigned exp = val.exactLogBase2();
              ConstantInt *shift_const = cast<ConstantInt>(ConstantInt::get(op->getType(), exp));
              Instruction *new_instr1 = BinaryOperator::Create(Instruction::Shl, op, shift_const);
              new_instr1->insertAfter(&instr);
              instr.replaceAllUsesWith(new_instr1);
              jter++;
            }
            else if ((val - 1).isPowerOf2()) {
              // x = 2 ^ k + 1 -> x = (x << k) + x
              unsigned exp = (val - 1).exactLogBase2();
              ConstantInt *shift_const = cast<ConstantInt>(ConstantInt::get(op->getType(), exp));
              Instruction *new_instr1 = BinaryOperator::Create(Instruction::Shl, op, shift_const);
              new_instr1->insertAfter(&instr);
              Instruction *new_instr2 = BinaryOperator::Create(Instruction::Add, new_instr1, op);
              new_instr2->insertAfter(new_instr1);
              instr.replaceAllUsesWith(new_instr2);
              jter++;
              jter++;
            }
            else if ((val + 1).isPowerOf2()) {
              // x = 2 ^ k - 1 -> x = (x << k) - x
              unsigned exp = (val + 1).exactLogBase2();
              ConstantInt *shift_const = cast<ConstantInt>(ConstantInt::get(op->getType(), exp));
              Instruction *new_instr1 = BinaryOperator::Create(Instruction::Shl, op, shift_const);
              new_instr1->insertAfter(&instr);
              Instruction *new_instr2 = BinaryOperator::Create(Instruction::Sub, new_instr1, op);
              new_instr2->insertAfter(new_instr1);
              instr.replaceAllUsesWith(new_instr2);
              jter++;
              jter++;
            }
          }
        }
        else if (instr.getOpcode() == Instruction::UDiv) {
          Value *dividend = instr.getOperand(0);
          Value *divisor = instr.getOperand(1);
          if (ConstantInt *const_divisor = dyn_cast<ConstantInt>(divisor)) {
            if (const_divisor->getValue().sgt(0)) {
              APInt val = const_divisor->getValue();
              if (val.isPowerOf2()) {
                // x = 2 ^ k -> x = x >> k
                unsigned exp = val.exactLogBase2();
                ConstantInt *shift_const = cast<ConstantInt>(ConstantInt::get(dividend->getType(), exp));
                Instruction *new_instr1 = nullptr;
                new_instr1 = BinaryOperator::Create(Instruction::LShr, dividend, shift_const);
                new_instr1->insertAfter(&instr);
                instr.replaceAllUsesWith(new_instr1);
                jter++;
              }
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