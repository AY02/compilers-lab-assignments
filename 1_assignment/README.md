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

