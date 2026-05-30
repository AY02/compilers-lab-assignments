; ModuleID = 'test_guarded_manual.c'
source_filename = "test_guarded_manual.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"

define void @test_perfect_guarded(i32 %n, i32* %a, i32* %b) {
entry:
  ; Calcoliamo la condizione UNA SOLA VOLTA. 
  ; Questo sarà il "Value*" che le due guardie condivideranno.
  %cmp = icmp sgt i32 %n, 0
  %p = icmp sgt i32 %n, 0
  br label %guard0_block

guard0_block:
  ; GUARDIA 0
  ; Se %cmp è vero entra nel Loop 0, altrimenti salta alla guardia 1.
  ; Il successore(0) è preheader0, il successore(1) è guard1_block.
  br i1 %cmp, label %preheader0, label %guard1_block

preheader0:
  br label %header0

header0:
  %i = phi i32 [ 0, %preheader0 ], [ %inc0, %latch0 ]
  br label %body0

body0:
  ; Corpo del Loop 0: a[i] = i
  %idx0 = sext i32 %i to i64
  %ptr0 = getelementptr inbounds i32, i32* %a, i64 %idx0
  store i32 %i, i32* %ptr0, align 4
  br label %latch0

latch0:
  %inc0 = add nsw i32 %i, 1
  %exitcond0 = icmp slt i32 %inc0, %n
  br i1 %exitcond0, label %header0, label %exit0

exit0:
  ; Uscita dal Loop 0. Va dritta alla guardia del Loop 1.
  br label %guard1_block

guard1_block:
  ; GUARDIA 1
  ; Usa ESATTAMENTE la stessa %cmp definita all'inizio!
  br i1 %p, label %preheader1, label %end

preheader1:
  br label %header1

header1:
  %j = phi i32 [ 0, %preheader1 ], [ %inc1, %latch1 ]
  br label %body1

body1:
  ; Corpo del Loop 1: b[j] = j
  %idx1 = sext i32 %j to i64
  %ptr1 = getelementptr inbounds i32, i32* %b, i64 %idx1
  store i32 %j, i32* %ptr1, align 4
  br label %latch1

latch1:
  %inc1 = add nsw i32 %j, 1
  %exitcond1 = icmp slt i32 %inc1, %n
  br i1 %exitcond1, label %header1, label %exit1

exit1:
  br label %end

end:
  ret void
}