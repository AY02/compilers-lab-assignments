; ModuleID = 'test.m2r.ll'
source_filename = "test.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_basic_hoisting(i32 noundef %0, i32 noundef %1, i32 noundef %2) #0 {
  %4 = mul nsw i32 %0, %1
  br label %5

5:                                                ; preds = %11, %3
  %.01 = phi i32 [ 0, %3 ], [ %10, %11 ]
  %.0 = phi i32 [ 0, %3 ], [ %12, %11 ]
  %6 = icmp slt i32 %.0, %2
  br i1 %6, label %7, label %13

7:                                                ; preds = %5
  %8 = sdiv i32 %0, %1
  %9 = add nsw i32 %4, %.0
  %10 = add nsw i32 %.01, %9
  br label %11

11:                                               ; preds = %7
  %12 = add nsw i32 %.0, 1
  br label %5, !llvm.loop !6

13:                                               ; preds = %5
  ret i32 %.01
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_dominance_needed(i32 noundef %0, i32 noundef %1, i32 noundef %2) #0 {
  %4 = sdiv i32 %0, %1
  %5 = add nsw i32 %0, %1
  br label %6

6:                                                ; preds = %10, %3
  %.01 = phi i32 [ 0, %3 ], [ %8, %10 ]
  %.0 = phi i32 [ 0, %3 ], [ %9, %10 ]
  %7 = add nsw i32 %4, %.0
  %8 = add nsw i32 %.01, %7
  %9 = add nsw i32 %.0, 1
  br label %10

10:                                               ; preds = %6
  %11 = icmp slt i32 %9, %2
  br i1 %11, label %6, label %12, !llvm.loop !8

12:                                               ; preds = %10
  ret i32 %8
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_nested_hoisting(i32 noundef %0, i32 noundef %1, i32 noundef %2) #0 {
  %4 = add nsw i32 %0, %1
  br label %5

5:                                                ; preds = %16, %3
  %.02 = phi i32 [ 0, %3 ], [ %.1, %16 ]
  %.01 = phi i32 [ 0, %3 ], [ %17, %16 ]
  %6 = icmp slt i32 %.01, %2
  br i1 %6, label %7, label %18

7:                                                ; preds = %5
  br label %8

8:                                                ; preds = %13, %7
  %.1 = phi i32 [ %.02, %7 ], [ %12, %13 ]
  %.0 = phi i32 [ 0, %7 ], [ %14, %13 ]
  %9 = icmp slt i32 %.0, %2
  br i1 %9, label %10, label %15

10:                                               ; preds = %8
  %11 = add nsw i32 %4, %.0
  %12 = add nsw i32 %.1, %11
  br label %13

13:                                               ; preds = %10
  %14 = add nsw i32 %.0, 1
  br label %8, !llvm.loop !9

15:                                               ; preds = %8
  br label %16

16:                                               ; preds = %15
  %17 = add nsw i32 %.01, 1
  br label %5, !llvm.loop !10

18:                                               ; preds = %5
  ret i32 %.02
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_memory_no_hoist(ptr noundef %0, i32 noundef %1) #0 {
  br label %3

3:                                                ; preds = %7, %2
  %.0 = phi i32 [ 0, %2 ], [ %8, %7 ]
  %4 = icmp slt i32 %.0, %1
  br i1 %4, label %5, label %9

5:                                                ; preds = %3
  %6 = load i32, ptr %0, align 4
  store i32 42, ptr %0, align 4
  br label %7

7:                                                ; preds = %5
  %8 = add nsw i32 %.0, 1
  br label %3, !llvm.loop !11

9:                                                ; preds = %3
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_invariants_chain(i32 noundef %0, i32 noundef %1, i32 noundef %2) #0 {
  %4 = add nsw i32 %0, %1
  %5 = mul nsw i32 %4, 42
  br label %6

6:                                                ; preds = %11, %3
  %.01 = phi i32 [ 0, %3 ], [ %10, %11 ]
  %.0 = phi i32 [ 0, %3 ], [ %12, %11 ]
  %7 = icmp slt i32 %.0, %2
  br i1 %7, label %8, label %13

8:                                                ; preds = %6
  %9 = add nsw i32 %5, %.0
  %10 = add nsw i32 %.01, %9
  br label %11

11:                                               ; preds = %8
  %12 = add nsw i32 %.0, 1
  br label %6, !llvm.loop !12

13:                                               ; preds = %6
  ret i32 %.01
}

attributes #0 = { noinline nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Ubuntu clang version 19.1.7 (++20250114103238+cd708029e0b2-1~exp1~20250114103342.77)"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
!8 = distinct !{!8, !7}
!9 = distinct !{!9, !7}
!10 = distinct !{!10, !7}
!11 = distinct !{!11, !7}
!12 = distinct !{!12, !7}
