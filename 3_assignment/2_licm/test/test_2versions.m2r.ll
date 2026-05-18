; ModuleID = 'test_2versions.O0.ll'
source_filename = "test_2versions.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_2versions(i32 noundef %0, i32 noundef %1, i32 noundef %2) #0 {
  br label %4

4:                                                ; preds = %8, %3
  %.01 = phi i32 [ 10, %3 ], [ %7, %8 ]
  %.0 = phi i32 [ 0, %3 ], [ %9, %8 ]
  %5 = icmp slt i32 %.0, %2
  br i1 %5, label %6, label %10

6:                                                ; preds = %4
  %7 = add nsw i32 %0, %1
  br label %8

8:                                                ; preds = %6
  %9 = add nsw i32 %.0, 1
  br label %4, !llvm.loop !6

10:                                               ; preds = %4
  %11 = add nsw i32 %.01, 1
  ret i32 %11
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_with_do_while(i32 noundef %0, i32 noundef %1, i32 noundef %2) #0 {
  br label %4

4:                                                ; preds = %7, %3
  %.0 = phi i32 [ 0, %3 ], [ %6, %7 ]
  %5 = add nsw i32 %0, %1
  %6 = add nsw i32 %.0, 1
  br label %7

7:                                                ; preds = %4
  %8 = icmp slt i32 %6, %2
  br i1 %8, label %4, label %9, !llvm.loop !8

9:                                                ; preds = %7
  %10 = add nsw i32 %5, 1
  ret i32 %10
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_with_do_while_early_exits(i32 noundef %0, i32 noundef %1, i32 noundef %2) #0 {
  br label %4

4:                                                ; preds = %10, %3
  %5 = add nsw i32 %0, %1
  %6 = icmp ne i32 %2, 0
  br i1 %6, label %7, label %8

7:                                                ; preds = %4
  br label %13

8:                                                ; preds = %4
  %9 = add nsw i32 %0, %1
  br label %10

10:                                               ; preds = %8
  %11 = icmp ne i32 %2, 0
  %12 = xor i1 %11, true
  br i1 %12, label %4, label %13, !llvm.loop !9

13:                                               ; preds = %10, %7
  %.0 = phi i32 [ %5, %7 ], [ %9, %10 ]
  %14 = add nsw i32 %.0, 1
  ret i32 %14
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
