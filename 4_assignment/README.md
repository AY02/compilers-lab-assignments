The getSCEVAtScope(Value *V, Loop *L) function gets the algebraic expression of V using L as scope.
It is useful to derive the expression of a memory access in an inner loop, using the outer loop as scope.
However, for our purposes, this function is of no use to us.
In fact, we merge adjacent loops, not nested loops.
Example:
Value *Ptr0 = getLoadStorePointerOperand(I0);
Value *Ptr1 = getLoadStorePointerOperand(I1);
const SCEV *S0 = SE.getSCEVAtScope(Ptr0, L0);
const SCEV *S1 = SE.getSCEVAtScope(Ptr1, L0);
Since our intention is to check whether I can merge from L1 to L0, one might think that we need to compute the expression of Ptr1 with the scope of L0.
However, the two loops belong to a completely different space.
Therefore, the distance S0 - S1 yields to a non-statically determinable expression.



Negative dependence example:
// Load-Store:
    // 0: B[i] = A[i]
    // 1: A[i+1] = 3
    // no fusion: [old_A,old_A,...,old_A]  
    // vs  
    // fusion: [old_A,3,3,...,3]

// Store-Load:
    // 0: A[i] = 3
    // 1: B[i] = A[i+1]
    // no fusion: [old_B,3,3,...,3]
    // vs
    // fusion: [old_B,old_A,...,old_A]

// Store-Store:
    // 0: A[i] = 3
    // 1: A[i+1] = 4
    // no fusion: [4,4,4,...,4]
    // vs
    // fusion: [3,3,3,...,4]
