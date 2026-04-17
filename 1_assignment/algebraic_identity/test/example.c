// Per produrre la IR che sarà l'input del nostro ottimizzatore:
//
// 	clang -O2 -S -emit-llvm -c FILENAME.cpp -o FILENAME.ll
//
// Per lanciare il nostro passo di analisi come unico passo dell'ottimizzatore:
//
//	opt -load-pass-plugin=lib/libTestPass.so -passes=test-pass -disable-output FILENAME.ll
//
// Il flag `-disable-output` evita la generazione di bytecode in output (non ci serve,
// il nostro passo non trasforma la IR e non genera output)
//

void example() {
    int x, z;
    int y = 4;
    int t = 0; // I am using zero to show the 
               // limitations of the current version


    // ADD EXAMPLES
    x = 0 + 0; 
    x = y + 0;

    x = 0 + y; 
    // showing the uses replacement
    z = x + 5; 

    x = t + y; // no opts
    // showing the lack of uses replacement
    z = x + 5; 
    

    // SUB EXAMPLES
    x = 0 - 0;

    x = y - 0;
    // showing the uses replacement
    z = x + 5; 

    x = 0 - y; // no opts
    // showing the lack of uses replacement
    z = x + 5; 

    x = t - y; // no opts


    // MUL EXAMPLES
    x = 1 * 4;
    x = y * 1;

    x = 1 * y; 
    // showing the uses replacement
    z = x + 5; 

    x = t * y; // no opts
    // showing the lack of uses replacement
    z = x + 5; 


    // DIV EXAMPLES
    x = 1 / 4; // no opts
    // showing the uses replacement
    z = x + 5; 

    x = 4 / 1;

    x = y / 1;
    // showing the uses replacement
    z = x + 5;

    x = 1 / y; // no opts

    x = t / y; // no opts
    // showing the lack of uses replacement
    z = x + 5; 
}
