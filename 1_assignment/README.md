# Algebraic Identity Optimization

Le operazioni binarie algebriche, applicate con i rispettivi elementi neutri (o assorbenti) producono risultati identici a uno degli operandi, rendendole computazionalmente inutili. Questo passo di ottimizzazione individua le *algebraic identities* nelle istruzioni binarie di ogni funzione e sostituisce tutti gli usi del risultato direttamente con il valore equivalente, eliminando il costo dell'operazione stessa.

Nota: Le istruzioni originali rese dead code dalla sostituzione degli usi a seguito delle ottimizzazioni non sono rimosse da questo passo, il cui scopo è esclusivamente quello di identificare e propagare le semplificazioni algebriche, lasciando a un ipotetico passo successivo il compito di ripulire il dead code risultante.
---

## Casi coperti

**ADD** — Sono ottimizzati `a + 0` e `0 + a`, entrambi sostituiti con `a`.

**SUB** — Viene ottimizzato solo `a - 0`, sostituito con `a`. Il caso `0 - a` non viene ottimizzato (il risultato non è equivalente a nessuno degli operandi originali).

**MUL** — Sono ottimizzati sia i casi con elemento neutro (`a * 1`, `1 * a` --> `a`) sia i casi con elemento assorbente (`a * 0`, `0 * a` --> `0`).

**DIV** — Sono ottimizzati `a / 1` (--> `a`) e `0 / a` con `a ≠ 0` (--> `0`). Non vengono ottimizzati né il caso generico `1 / a`, né `a / 0` e `0 / 0` (divisione per zero, comportamento indefinito).

Nota: In nessuno di essi viene coperto il caso generale `a ⊕ b` privo di costanti numeriche esplicite.

---

## Esempi di test e risultati

### ADD
| Espressione | Risultato |
|-------------|-----------|
| `x = a + 0` | Ottimizzato: gli usi di `x` vengono sostituiti con `a`; l'istruzione diventa dead code |
| `x = a + b` | Non ottimizzato |

### SUB
| Espressione | Risultato |
|-------------|-----------|
| `x = a - 0` | Ottimizzato: gli usi di `x` vengono sostituiti con `a`; l'istruzione diventa dead code |
| `x = 0 - a` | Non ottimizzato: il risultato non è equivalente ad alcuno degli operandi |

### MUL
| Espressione | Risultato |
|-------------|-----------|
| `x = a * 1` | Ottimizzato: gli usi di `x` vengono sostituiti con `a`; l'istruzione diventa dead code |
| `x = a * 0` | Ottimizzato: gli usi di `x` vengono sostituiti con la costante `0`; l'istruzione diventa dead code |
| `x = a * b` | Non ottimizzato |

### DIV
| Espressione | Risultato |
|-------------|-----------|
| `x = a / 1` | Ottimizzato: gli usi di `x` vengono sostituiti con `a`; l'istruzione diventa dead code |
| `x = 0 / a` (con `a ≠ 0`) | Ottimizzato: gli usi di `x` vengono sostituiti con la costante `0`; l'istruzione diventa dead code |
| `x = a / 0` | Non ottimizzato: divisione per zero, comportamento indefinito |

---

## Note conclusive

Se necessarie