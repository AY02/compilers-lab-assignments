; ModuleID = 'test/test.O0.ll'
source_filename = "src/test.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_nested_loops(i32 noundef %0, i32 noundef %1) #0 {
  br label %3

3:                                                ; preds = %17, %2
  %.02 = phi i32 [ 0, %2 ], [ %.1, %17 ]
  %.01 = phi i32 [ 0, %2 ], [ %18, %17 ]
  %4 = icmp slt i32 %.01, 10
  br i1 %4, label %5, label %19

5:                                                ; preds = %3
  %6 = add nsw i32 %0, %1
  br label %7

7:                                                ; preds = %14, %5
  %.1 = phi i32 [ %.02, %5 ], [ %13, %14 ]
  %.0 = phi i32 [ 0, %5 ], [ %15, %14 ]
  %8 = icmp slt i32 %.0, 10
  br i1 %8, label %9, label %16

9:                                                ; preds = %7
  %10 = mul nsw i32 %6, 2
  %11 = add nsw i32 %10, %6
  %12 = add nsw i32 %10, %.0
  %13 = add nsw i32 %.1, %12
  br label %14

14:                                               ; preds = %9
  %15 = add nsw i32 %.0, 1
  br label %7, !llvm.loop !6

16:                                               ; preds = %7
  br label %17

17:                                               ; preds = %16
  %18 = add nsw i32 %.01, 1
  br label %3, !llvm.loop !8

19:                                               ; preds = %3
  ret i32 %.02
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_invariants_chain(i32 noundef %0, i32 noundef %1) #0 {
  br label %3

3:                                                ; preds = %11, %2
  %.01 = phi i32 [ 0, %2 ], [ %10, %11 ]
  %.0 = phi i32 [ 0, %2 ], [ %12, %11 ]
  %4 = icmp slt i32 %.0, 10
  br i1 %4, label %5, label %13

5:                                                ; preds = %3
  %6 = add nsw i32 %0, %1
  %7 = mul nsw i32 %6, 42
  %8 = sub nsw i32 %7, 5
  %9 = add nsw i32 %8, %.0
  %10 = add nsw i32 %.01, %9
  br label %11

11:                                               ; preds = %5
  %12 = add nsw i32 %.0, 1
  br label %3, !llvm.loop !9

13:                                               ; preds = %3
  ret i32 %.01
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_branch_phi(i32 noundef %0, i32 noundef %1, i32 noundef %2) #0 {
  br label %4

4:                                                ; preds = %15, %3
  %.02 = phi i32 [ 0, %3 ], [ %14, %15 ]
  %.0 = phi i32 [ 0, %3 ], [ %16, %15 ]
  %5 = icmp slt i32 %.0, 10
  br i1 %5, label %6, label %17

6:                                                ; preds = %4
  %7 = icmp ne i32 %2, 0
  br i1 %7, label %8, label %10

8:                                                ; preds = %6
  %9 = add nsw i32 %0, %1
  br label %12

10:                                               ; preds = %6
  %11 = add nsw i32 %0, %1
  br label %12

12:                                               ; preds = %10, %8
  %.01 = phi i32 [ %9, %8 ], [ %11, %10 ]
  %13 = mul nsw i32 %.01, 2
  %14 = add nsw i32 %.02, %13
  br label %15

15:                                               ; preds = %12
  %16 = add nsw i32 %.0, 1
  br label %4, !llvm.loop !10

17:                                               ; preds = %4
  ret i32 %.02
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_conditional_mutation(i32 noundef %0, i32 noundef %1) #0 {
  br label %3

3:                                                ; preds = %11, %2
  %.02 = phi i32 [ %0, %2 ], [ %.1, %11 ]
  %.01 = phi i32 [ 0, %2 ], [ %7, %11 ]
  %.0 = phi i32 [ 0, %2 ], [ %12, %11 ]
  %4 = icmp slt i32 %.0, 10
  br i1 %4, label %5, label %13

5:                                                ; preds = %3
  %6 = add nsw i32 %.02, 5
  %7 = add nsw i32 %.01, %6
  %8 = icmp ne i32 %1, 0
  br i1 %8, label %9, label %10

9:                                                ; preds = %5
  br label %10

10:                                               ; preds = %9, %5
  %.1 = phi i32 [ %.0, %9 ], [ %.02, %5 ]
  br label %11

11:                                               ; preds = %10
  %12 = add nsw i32 %.0, 1
  br label %3, !llvm.loop !11

13:                                               ; preds = %3
  ret i32 %.01
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_phi_invariant(i32 noundef %0, i32 noundef %1) #0 {
  %3 = add nsw i32 %0, %1
  br label %4

4:                                                ; preds = %13, %2
  %.02 = phi i32 [ 0, %2 ], [ %12, %13 ]
  %.01 = phi i32 [ 0, %2 ], [ %14, %13 ]
  %5 = icmp slt i32 %.01, 10
  br i1 %5, label %6, label %15

6:                                                ; preds = %4
  %7 = srem i32 %.01, 2
  %8 = icmp eq i32 %7, 0
  br i1 %8, label %9, label %10

9:                                                ; preds = %6
  br label %11

10:                                               ; preds = %6
  br label %11

11:                                               ; preds = %10, %9
  %12 = add nsw i32 %.02, %3
  br label %13

13:                                               ; preds = %11
  %14 = add nsw i32 %.01, 1
  br label %4, !llvm.loop !12

15:                                               ; preds = %4
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
!9 = distinct !{!9, !7}
!10 = distinct !{!10, !7}
!11 = distinct !{!11, !7}
!12 = distinct !{!12, !7}
