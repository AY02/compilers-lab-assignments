#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"


using namespace llvm;


namespace {


struct MyMultiInstruction: PassInfoMixin<MyMultiInstruction> {
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &) {

    // prev_instr -> x = y add k (k add y)
    // curr_instr -> z = x sub k
    //
    // prev_instr -> x = y sub k
    // curr_instr -> z = x add k (k add x)
    for (auto iter = F.begin(); iter != F.end(); iter++) {
      BasicBlock &B = *iter;
      for (auto jter = B.begin(); jter != B.end(); jter++) {
        Instruction &curr_instr = *jter;
        unsigned curr_op_code = curr_instr.getOpcode();
        // For basic arithmetic operators only.
        if (
          curr_op_code != Instruction::Add && curr_op_code != Instruction::Sub &&
          curr_op_code != Instruction::Mul && curr_op_code != Instruction::UDiv &&
          curr_op_code != Instruction::SDiv
        ) {
          continue;
        }

        Value *curr_op0 = curr_instr.getOperand(0);
        Value *curr_op1 = curr_instr.getOperand(1);

        ConstantInt *curr_const_op = nullptr;
        Value *curr_op = nullptr;

        if (auto *curr_c1 = dyn_cast<ConstantInt>(curr_op1)) {
          curr_const_op = curr_c1;
          curr_op = curr_op0;
        }
        else if (auto *curr_c0 = dyn_cast<ConstantInt>(curr_op0)) {
          // Sum and product are commutative
          if (curr_op_code == Instruction::Add || curr_op_code == Instruction::Mul) {
            curr_const_op = curr_c0;
            curr_op = curr_op1;
          }
          else {
            // Subtractions and divisions with constants in the first operand
            // cannot be solved linearly.
            continue;
          }
        }
        else {
          // There are no constants.
          continue;
        }

        // The current operand must be a lhs of a previous instruction
        Instruction *prev_instr = dyn_cast<Instruction>(curr_op);
        if (!prev_instr) {
          continue;
        }

        unsigned prev_op_code = prev_instr->getOpcode();
        bool is_opposite = false;
        if (curr_op_code == Instruction::Sub && prev_op_code == Instruction::Add) {
          // (x + k) - k
          is_opposite = true;
        }
        else if (curr_op_code == Instruction::Add && prev_op_code == Instruction::Sub) {
          // (x - k) + k
          is_opposite = true;
        }
        else if ((curr_op_code == Instruction::UDiv || curr_op_code == Instruction::SDiv) && prev_op_code == Instruction::Mul) {
          // (x * k) / k
          is_opposite = true;
        }
        else if (curr_op_code == Instruction::Mul && (prev_op_code == Instruction::UDiv || prev_op_code == Instruction::SDiv)) {
          // (x / k) * k, only if the remainder is zero.
          if (cast<BinaryOperator>(prev_instr)->isExact())
            is_opposite = true;
        }

        if (!is_opposite) {
          continue;
        }

        Value *prev_op0 = prev_instr->getOperand(0);
        Value *prev_op1 = prev_instr->getOperand(1);    

        ConstantInt *prev_const_op = nullptr;
        Value *prev_op = nullptr;

        if (auto *prev_c1 = dyn_cast<ConstantInt>(prev_op1)) {
          prev_const_op = prev_c1;
          prev_op = prev_op0;
        } 
        else if (auto *prev_c0 = dyn_cast<ConstantInt>(prev_op0)) {
          if (prev_op_code == Instruction::Add || prev_op_code == Instruction::Mul) {
            prev_const_op = prev_c0;
            prev_op = prev_op1;
          }
          else {
            // Subtractions and divisions with constants in the first operand
            // cannot be solved linearly.
            continue;
          }
        }
        else {
          // There are no constants.
          continue;
        }

        if (prev_const_op == curr_const_op) {
          // There is no DCE, therefore we must ignore dead instructions.
          if (!curr_instr.use_empty()) {
            curr_instr.replaceAllUsesWith(prev_op);
          }
        }

      }
    }

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