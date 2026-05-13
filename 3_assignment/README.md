# Loop-Invariant Code Motion (LICM)

This document provides a technical overview of the implemented Loop-Invariant Code Motion (LICM) optimization pass in the third assignment.

---

## Preliminary Notes (Common Constraints)

* **Note 1: 



Approccio ricorsivo:

bool isOperandLoopInvariant(Value *V, Loop *L,
  SmallSetVector<Instruction*, 16> &InvariantSet) {
  // In LLVM IR, global variables are pointers, and the load and store
  // instructions are used to read or modify them. Consequently, they are
  // loop-invariant by construction.
  if (isa<Constant>(V) || isa<Argument>(V) || isa<GlobalValue>(V))
    return true;
  if (Instruction *I = dyn_cast<Instruction>(V)) {
    // Uses of definitions outside the loop are loop-invariant.
    // I->getParent() is the basic block containing I.
    if (!L->contains(I->getParent()))
      return true;
    // Uses of definitions inside the loop that has already been marked as
    // loop-invariant are also loop-invariant.
    // NON E' PIU' GARANTITO.
    if (InvariantSet.count(I))
      return true;
    
    // CONDIZIONE NECESSARIA IN QUANTO NON ESISTE PIU' UN ORDINE DI VISITA.
    if (isInstructionLoopInvariant(*I, L, InvariantSet)) {
      InvariantSet.insert(I);
      return true;
    }

    return false;
  }
  // Conservative choice
  return false;
}

Usare L->blocks() al posto della RPO Traversal.


Vincoli dell'approccio ricorsivo: Le phi non devono essere considerati
loop-invariant.

if (I.isTerminator() || isa<PHINode>(I)) {
  return false;
}

Rimuovendo dalla valutazione le phi, praticamente rendo il CFG un DAG.
E' come se visitassimo il CFG senza considerare i back-edge in quanto
saltiamo direttamente il controllo dell'operando latch del phi.
