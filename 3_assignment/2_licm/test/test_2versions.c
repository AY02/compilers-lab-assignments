// Test that shows the PHI node quirk we were not expecting:
// we initially designed this test expecting the my_licm_base.cpp version
// (isDeadOutsideLoop implementation) to fail to hoist x = a + b. Since x
// is used outside the loop, we assumed it wouldn't be considered "dead".
// However, we discovered an interesting quirk in how clang/LLVM generates SSA:
// the phi node that collects the value of x to allow to the outside the loop
// instruction to use the variable "it wants" (based on the execution flow taken)
// is placed inside the loop header, not in the exit block where we expected it to be.
// Because the instruction's only user is this internal phi node,
// isDeadOutsideLoop inadvertently returns true. As a result, both the my_licm_base.cpp 
// version and the my_licm.cpp version successfully hoist the instruction.
int test_liveness_vs_safety(int a, int b, int n) {
  int x = 10; 
  for (int i = 0; i < n; i++) {
    x = a + b; 
  }
  return x + 1;
}