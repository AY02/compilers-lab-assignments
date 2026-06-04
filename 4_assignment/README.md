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
