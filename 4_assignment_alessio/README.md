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