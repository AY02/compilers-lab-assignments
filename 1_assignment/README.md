# Optimization passes
---

## Note preliminari

Nota 1: Il dead code risultante dalle ottimizzazioni non è rimosso dai passi descritti in seguito, lasciando a un ipotetico passo eseguito successivamente il compito di ripulire il dead code generatosi.  
Note 2: Nella descrizione qui presente dei passi non vengono mostrati i casi di test, presenti nei rispettivi file test.c contenuti nelle cartelle di test per i singoli passi di ottimizzazione.

## 1. Algebraic Identity Optimization

Le operazioni binarie algebriche, applicate con i rispettivi elementi neutri (o assorbenti) producono risultati identici a uno degli operandi, rendendole computazionalmente inutili. Questo passo di ottimizzazione individua le identità algebriche nelle istruzioni binarie di ogni funzione e sostituisce tutti gli usi del risultato direttamente con il valore equivalente, eliminando il costo dell'operazione stessa.

## Casi coperti

**ADD**: Sono ottimizzati `a + 0` e `0 + a`, entrambi sostituiti con `a`.  
**SUB**: Viene ottimizzato solo `a - 0`, sostituito con `a`. Il caso `0 - a` non viene ottimizzato (il risultato non è equivalente a nessuno degli operandi originali).  
**MUL**: Sono ottimizzati sia i casi con elemento neutro (`a * 1`, `1 * a` --> `a`) sia i casi con elemento assorbente (`a * 0`, `0 * a` --> `0`).  
**DIV**: Sono ottimizzati `a / 1` (--> `a`) e `0 / a` con `a ≠ 0` (--> `0`). Non vengono ottimizzati né il caso generico `1 / a`, né `a / 0` e `0 / 0` (divisione per zero, comportamento indefinito).

Nota: In nessuno di essi viene coperto il caso generale `a ⊕ b` privo di costanti numeriche esplicite.

## Note conclusive

L'attuale implementazione si limita alle costanti di tipo ConstantInt, non gestisce identità su valori in virgola mobile ConstantFP.

---

## 2. Strength Reduction Optimization

Questo passo di ottimizzazione individua le operazioni aritmetiche costose come moltiplicazioni e divisioni, quando applicate a costanti intere che sono potenze di due o a esse adiacenti (+-1 potenza di due), così da sostituirle con operazioni di shift e addizione/sottrazione, computazionalmente più leggere.  
Nota: in questo passo di ottimizzazione non si tiene conto del fatto che, su diverse CPU, il costo relativo di operazioni come moltiplicazione e shift possa variare. Si assume invece che, in maniera generale e indipendente dall'architettura, le trasformazioni proposte risultino comunque vantaggiose. 
 
## Casi coperti
 
**MUL**: Vengono ottimizzate le moltiplicazioni per costanti intere positive nei seguenti sottocasi:
- `a * (2^k)` (--> `a << k`): la costante è una potenza esatta di due.
- `a * (2^k + 1)` (--> `(a << k) + a`): la costante è una potenza di due più uno.
- `a * (2^k - 1)` (--> `(a << k) - a`): la costante è una potenza di due meno uno.
 
Non vengono ottimizzate le moltiplicazioni per costanti non riconducibili a nessuno dei tre pattern, né quelle prive di operandi costanti espliciti.
 
**UDIV**: Viene ottimizzata la divisione senza segno `a / (2^k)` (--> `a >> k`), dove il divisore è una costante intera positiva e potenza esatta di due. Non vengono ottimizzate le divisioni per costanti non potenze di due.
 
**SDIV**: Viene ottimizzata la divisione con segno `a / (2^k)` dove il divisore è una costante intera positiva e potenza esatta di due. Poiché in C la divisione intera tronca verso lo zero mentre l'istruzione `AShr` tronca verso meno infinito, è necessaria una correzione per i dividendi negativi. Il pattern generato è `(a + (a < 0 ? 2^k - 1 : 0)) >> k`, che gestisce correttamente entrambi i casi (dividendo multiplo e non multiplo del divisore). Non vengono ottimizzate le divisioni per costanti non potenze di due.
 
## Note conclusive
L'attuale implementazione si limita a costanti di tipo ConstantInt strettamente positive, non gestisce costanti negative né valori in virgola mobile ConstantFP. Il caso della moltiplicazione copre i tre pattern più comuni legati alle potenze di due, ma non applica decomposizioni più generali per costanti arbitrarie.

---

## 3. Multi Instruction Optimization

Alcune sequenze di due istruzioni consecutive applicano e poi annullano la stessa operazione con la stessa costante, producendo un risultato equivalente all'operando originale. Questo passo di ottimizzazione individua tali coppie di istruzioni inverse all'interno di ogni basic block e sostituisce tutti gli usi del risultato della seconda istruzione direttamente con l'operando originale della prima, eliminando il costo della seconda operazione.
 
Nota: poiché non è presente un passo di DCE, il passo verifica esplicitamente che l'istruzione corrente abbia ancora degli usi attivi prima di procedere con la sostituzione, per evitare di operare su istruzioni già rese dead code da ottimizzazioni precedenti.
 
## Casi coperti
 
**ADD dopo SUB / SUB dopo ADD**: Vengono ottimizzati i pattern `(a - k) + k` e `(a + k) - k`, sostituendo gli usi del risultato finale (solo della seconda istruzione) con `a`. Notare che nella sottrazione la costante deve comparire come secondo operando. I casi con la costante come primo operando (`k - a`, `k + a` nella seconda istruzione) non sono coperti in quanto non linearmente risolvibili in forma simmetrica.
 
**MUL dopo DIV / DIV dopo MUL**: Viene ottimizzato il pattern `(a * k) / k` (--> `a`), sia per divisione con segno (SDIV) che senza segno (UDIV). Viene ottimizzato anche il pattern `(a / k) * k` (--> `a`), ma solo se la divisione originale è marcata come esatta (`isExact()`, il resto è garantito essere zero), mentre in caso contrario la moltiplicazione non annulla la divisione e non si procede.
 
Nota: In tutti i casi, la costante delle due istruzioni deve essere il medesimo oggetto ConstantInt nel grafo IR (confronto per puntatore), ossia costanti con lo stesso valore numerico ma rappresentate da oggetti distinti non vengono riconosciute come uguali.
 
## Note conclusive
L'attuale implementazione effettua l'ottimizzazione in una sola esecuzione del passo, che scorre le istruzioni e, per le istruzioni che si annullano, sostituisce gli usi della seconda istruzione con l'operando originale della prima nelle istruzioni ancora da analizzare.
Inoltre, opera esclusivamente all'interno del singolo basic block, non propaga l'analisi tra blocchi distinti. Si limita inoltre a costanti di tipo ConstantInt e a operatori aritmetici di base (ADD, SUB, MUL, UDIV, SDIV), non gestisce operazioni su valori in virgola mobile né operatori bitwise.
