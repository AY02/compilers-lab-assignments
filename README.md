# compilers-lab-assignments

Assignment 1

Algebraic identity
Se esiste una somma o sottrazione del tipo y = x + 0, y = 0 + x, oppure y = x - 0, allora sostituisci tutti gli usi di y con x stesso.
Se esiste un prodotto o divisione del tipo y = x * 1, y = 1 * x, oppure y = x / 1, allora sostituisci tutti gli usi di y con x stesso.

Strength reduction
Si considerano esclusivamente esponenti k positivi.
Se esiste un'istruzione del tipo y = x * (2 ^ k +- 1), allora:
- inserisci come istruzioni successive y1 = 2 << k e y2 = y1 +- x
- sostituisci tutti gli usi di y con y2
- in caso di potenze perfette di 2, allora non si costruisce y2 e si sostituisce direttamente con y1
Se esiste un'istruzione del tipo y = x / (2 ^ k), allora:
- inserisci come istruzione successiva y1 = 2 >> k
- sostituisci tutti gli usi di y con y1
Per le divisioni con segno, bisogna fare attenzione quando il dividendo e' negativo (leggere i commenti nel codice sorgente).


Multi Instruction
Si considerano istruzioni opposte le coppie add-sub e mul-(udiv, sdiv).
Data un'istruzione del tipo y = a +- k, se esiste un user x = y -+ k, allora sostituisci tutti gli usi di x con a.
E se tra "y = a +- k" e "x = y -+ k" la y viene ridefinita? Non e' possibile in quanto siamo in SSA.
Data un'istruzione del tipo y = a */ k, se esiste un user x = y /* k, allora sostituisci tutti gli usi di x con a.