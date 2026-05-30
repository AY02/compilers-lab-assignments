; ModuleID = 'test_art.ll'
source_filename = "test_guarded_manual.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"

define void @test_perfect_guarded(i32 %n, ptr %a, ptr %b) {
entry:
  %cmp = icmp sgt i32 %n, 0
  %p = icmp sgt i32 %n, 0
  br label %guard0_block

guard0_block:                                     ; preds = %entry
  br i1 %cmp, label %preheader0, label %guard1_block

preheader0:                                       ; preds = %guard0_block
  br label %header0

header0:                                          ; preds = %latch0, %preheader0
  %i = phi i32 [ 0, %preheader0 ], [ %inc0, %latch0 ]
  br label %body0

body0:                                            ; preds = %header0
  %idx0 = sext i32 %i to i64
  %ptr0 = getelementptr inbounds i32, ptr %a, i64 %idx0
  store i32 %i, ptr %ptr0, align 4
  br label %latch0

latch0:                                           ; preds = %body0
  %inc0 = add nsw i32 %i, 1
  %exitcond0 = icmp slt i32 %inc0, %n
  br i1 %exitcond0, label %header0, label %exit0

exit0:                                            ; preds = %latch0
  br label %guard1_block

guard1_block:                                     ; preds = %exit0, %guard0_block
  br i1 %p, label %preheader1, label %end

preheader1:                                       ; preds = %guard1_block
  br label %header1

header1:                                          ; preds = %latch1, %preheader1
  %j = phi i32 [ 0, %preheader1 ], [ %inc1, %latch1 ]
  br label %body1

body1:                                            ; preds = %header1
  %idx1 = sext i32 %j to i64
  %ptr1 = getelementptr inbounds i32, ptr %b, i64 %idx1
  store i32 %j, ptr %ptr1, align 4
  br label %latch1

latch1:                                           ; preds = %body1
  %inc1 = add nsw i32 %j, 1
  %exitcond1 = icmp slt i32 %inc1, %n
  br i1 %exitcond1, label %header1, label %exit1

exit1:                                            ; preds = %latch1
  br label %end

end:                                              ; preds = %exit1, %guard1_block
  ret void
}
