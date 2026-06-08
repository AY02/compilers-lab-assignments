; ModuleID = 'test/alessio_tests/test.nesting.optimized.m2r.ll'
source_filename = "test/alessio_tests/test_multiple_loops.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_deep_nesting(ptr noalias noundef %0, ptr noalias noundef %1, i32 noundef %2) #0 {
  br label %4

4:                                                ; preds = %62, %3
  %.03 = phi i32 [ 0, %3 ], [ %63, %62 ]
  %5 = icmp slt i32 %.03, %2
  br i1 %5, label %6, label %64

6:                                                ; preds = %4, %32
  %.04 = phi i32 [ %33, %32 ], [ 0, %4 ]
  %7 = icmp slt i32 %.04, %2
  br i1 %7, label %8, label %34

8:                                                ; preds = %6, %18
  %.05 = phi i32 [ %19, %18 ], [ 0, %6 ]
  %9 = icmp slt i32 %.05, %2
  br i1 %9, label %10, label %20

10:                                               ; preds = %8, %12
  %.06 = phi i32 [ %17, %12 ], [ 0, %8 ]
  %11 = icmp slt i32 %.06, %2
  br i1 %11, label %12, label %18

12:                                               ; preds = %10
  %13 = sext i32 %.06 to i64
  %14 = getelementptr inbounds i32, ptr %0, i64 %13
  store i32 8, ptr %14, align 4
  %15 = sext i32 %.06 to i64
  %16 = getelementptr inbounds i32, ptr %1, i64 %15
  store i32 9, ptr %16, align 4
  %17 = add nsw i32 %.06, 1
  br label %10, !llvm.loop !6

18:                                               ; preds = %10
  %19 = add nsw i32 %.05, 1
  br label %8, !llvm.loop !8

20:                                               ; preds = %8, %30
  %.08 = phi i32 [ %31, %30 ], [ 0, %8 ]
  %21 = icmp slt i32 %.08, %2
  br i1 %21, label %22, label %32

22:                                               ; preds = %20, %24
  %.09 = phi i32 [ %29, %24 ], [ 0, %20 ]
  %23 = icmp slt i32 %.09, %2
  br i1 %23, label %24, label %30

24:                                               ; preds = %22
  %25 = sext i32 %.09 to i64
  %26 = getelementptr inbounds i32, ptr %0, i64 %25
  store i32 10, ptr %26, align 4
  %27 = sext i32 %.09 to i64
  %28 = getelementptr inbounds i32, ptr %1, i64 %27
  store i32 11, ptr %28, align 4
  %29 = add nsw i32 %.09, 1
  br label %22, !llvm.loop !9

30:                                               ; preds = %22
  %31 = add nsw i32 %.08, 1
  br label %20, !llvm.loop !10

32:                                               ; preds = %20
  %33 = add nsw i32 %.04, 1
  br label %6, !llvm.loop !11

34:                                               ; preds = %6, %60
  %.011 = phi i32 [ %61, %60 ], [ 0, %6 ]
  %35 = icmp slt i32 %.011, %2
  br i1 %35, label %36, label %62

36:                                               ; preds = %34, %46
  %.012 = phi i32 [ %47, %46 ], [ 0, %34 ]
  %37 = icmp slt i32 %.012, %2
  br i1 %37, label %38, label %48

38:                                               ; preds = %36, %40
  %.013 = phi i32 [ %45, %40 ], [ 0, %36 ]
  %39 = icmp slt i32 %.013, %2
  br i1 %39, label %40, label %46

40:                                               ; preds = %38
  %41 = sext i32 %.013 to i64
  %42 = getelementptr inbounds i32, ptr %0, i64 %41
  store i32 12, ptr %42, align 4
  %43 = sext i32 %.013 to i64
  %44 = getelementptr inbounds i32, ptr %1, i64 %43
  store i32 13, ptr %44, align 4
  %45 = add nsw i32 %.013, 1
  br label %38, !llvm.loop !12

46:                                               ; preds = %38
  %47 = add nsw i32 %.012, 1
  br label %36, !llvm.loop !13

48:                                               ; preds = %36, %58
  %.02 = phi i32 [ %59, %58 ], [ 0, %36 ]
  %49 = icmp slt i32 %.02, %2
  br i1 %49, label %50, label %60

50:                                               ; preds = %48, %52
  %.01 = phi i32 [ %57, %52 ], [ 0, %48 ]
  %51 = icmp slt i32 %.01, %2
  br i1 %51, label %52, label %58

52:                                               ; preds = %50
  %53 = sext i32 %.01 to i64
  %54 = getelementptr inbounds i32, ptr %0, i64 %53
  store i32 14, ptr %54, align 4
  %55 = sext i32 %.01 to i64
  %56 = getelementptr inbounds i32, ptr %1, i64 %55
  store i32 15, ptr %56, align 4
  %57 = add nsw i32 %.01, 1
  br label %50, !llvm.loop !14

58:                                               ; preds = %50
  %59 = add nsw i32 %.02, 1
  br label %48, !llvm.loop !15

60:                                               ; preds = %48
  %61 = add nsw i32 %.011, 1
  br label %34, !llvm.loop !16

62:                                               ; preds = %34
  %63 = add nsw i32 %.03, 1
  br label %4, !llvm.loop !17

64:                                               ; preds = %4
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_four_siblings(ptr noalias noundef %0, ptr noalias noundef %1, ptr noalias noundef %2, ptr noalias noundef %3, i32 noundef %4) #0 {
  br label %6

6:                                                ; preds = %8, %5
  %.03 = phi i32 [ 0, %5 ], [ %17, %8 ]
  %7 = icmp slt i32 %.03, %4
  br i1 %7, label %8, label %18

8:                                                ; preds = %6
  %9 = sext i32 %.03 to i64
  %10 = getelementptr inbounds i32, ptr %0, i64 %9
  store i32 1, ptr %10, align 4
  %11 = sext i32 %.03 to i64
  %12 = getelementptr inbounds i32, ptr %1, i64 %11
  store i32 2, ptr %12, align 4
  %13 = sext i32 %.03 to i64
  %14 = getelementptr inbounds i32, ptr %2, i64 %13
  store i32 3, ptr %14, align 4
  %15 = sext i32 %.03 to i64
  %16 = getelementptr inbounds i32, ptr %3, i64 %15
  store i32 4, ptr %16, align 4
  %17 = add nsw i32 %.03, 1
  br label %6, !llvm.loop !18

18:                                               ; preds = %6
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
!5 = !{!"Ubuntu clang version 19.1.7 (++20250114103238+cd708029e0b2-1~exp1~20250114103342.77)"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
!8 = distinct !{!8, !7}
!9 = distinct !{!9, !7}
!10 = distinct !{!10, !7}
!11 = distinct !{!11, !7}
!12 = distinct !{!12, !7}
!13 = distinct !{!13, !7}
!14 = distinct !{!14, !7}
!15 = distinct !{!15, !7}
!16 = distinct !{!16, !7}
!17 = distinct !{!17, !7}
!18 = distinct !{!18, !7}
