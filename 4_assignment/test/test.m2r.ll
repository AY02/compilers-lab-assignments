; ModuleID = 'test.ll'
source_filename = "test.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local void @fun_base(i32 noundef %0, i32 noundef %1, i32 noundef %2) #0 {
  br label %4

4:                                                ; preds = %8, %3
  %.02 = phi i32 [ 0, %3 ], [ %9, %8 ]
  %.01 = phi i32 [ %1, %3 ], [ %7, %8 ]
  %5 = icmp slt i32 %.02, %0
  br i1 %5, label %6, label %10

6:                                                ; preds = %4
  %7 = add nsw i32 %2, %.02
  br label %8

8:                                                ; preds = %6
  %9 = add nsw i32 %.02, 1
  br label %4, !llvm.loop !6

10:                                               ; preds = %4
  br label %11

11:                                               ; preds = %15, %10
  %.0 = phi i32 [ 0, %10 ], [ %16, %15 ]
  %12 = icmp slt i32 %.0, %0
  br i1 %12, label %13, label %17

13:                                               ; preds = %11
  %14 = add nsw i32 %.01, %.0
  br label %15

15:                                               ; preds = %13
  %16 = add nsw i32 %.0, 1
  br label %11, !llvm.loop !8

17:                                               ; preds = %11
  ret void
}

attributes #0 = { noinline nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"clang version 19.1.7 (/home/runner/work/llvm-project/llvm-project/clang cd708029e0b2869e80abe31ddb175f7c35361f90)"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
!8 = distinct !{!8, !7}
