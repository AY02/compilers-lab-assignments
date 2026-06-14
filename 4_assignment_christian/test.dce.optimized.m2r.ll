; ModuleID = 'test.optimized.m2r.ll'
source_filename = "test/alessio_tests/test.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_simple(ptr noalias noundef %0, ptr noalias noundef %1, i32 noundef %2) #0 {
  br label %4

4:                                                ; preds = %6, %3
  %.01 = phi i32 [ 0, %3 ], [ %16, %6 ]
  %5 = icmp slt i32 %.01, %2
  br i1 %5, label %6, label %17

6:                                                ; preds = %4
  %7 = add nsw i32 %.01, 1
  %8 = sext i32 %.01 to i64
  %9 = getelementptr inbounds i32, ptr %0, i64 %8
  store i32 %7, ptr %9, align 4
  %10 = sext i32 %.01 to i64
  %11 = getelementptr inbounds i32, ptr %0, i64 %10
  %12 = load i32, ptr %11, align 4
  %13 = add nsw i32 %12, 1
  %14 = sext i32 %.01 to i64
  %15 = getelementptr inbounds i32, ptr %1, i64 %14
  store i32 %13, ptr %15, align 4
  %16 = add nsw i32 %.01, 1
  br label %4, !llvm.loop !6

17:                                               ; preds = %4
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_negative_step_loop(ptr noalias noundef %0, ptr noalias noundef %1) #0 {
  br label %3

3:                                                ; preds = %5, %2
  %.01 = phi i32 [ 100, %2 ], [ %13, %5 ]
  %4 = icmp sgt i32 %.01, 0
  br i1 %4, label %5, label %14

5:                                                ; preds = %3
  %6 = sext i32 %.01 to i64
  %7 = getelementptr inbounds i32, ptr %0, i64 %6
  store i32 1, ptr %7, align 4
  %8 = sext i32 %.01 to i64
  %9 = getelementptr inbounds i32, ptr %0, i64 %8
  %10 = load i32, ptr %9, align 4
  %11 = sext i32 %.01 to i64
  %12 = getelementptr inbounds i32, ptr %1, i64 %11
  store i32 %10, ptr %12, align 4
  %13 = add nsw i32 %.01, -1
  br label %3, !llvm.loop !8

14:                                               ; preds = %3
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_negative_dependence(ptr noalias noundef %0, ptr noalias noundef %1) #0 {
  br label %3

3:                                                ; preds = %5, %2
  %.01 = phi i32 [ 0, %2 ], [ %8, %5 ]
  %4 = icmp slt i32 %.01, 100
  br i1 %4, label %5, label %9

5:                                                ; preds = %3
  %6 = sext i32 %.01 to i64
  %7 = getelementptr inbounds i32, ptr %0, i64 %6
  store i32 10, ptr %7, align 4
  %8 = add nsw i32 %.01, 1
  br label %3, !llvm.loop !9

9:                                                ; preds = %3, %11
  %.0 = phi i32 [ %18, %11 ], [ 0, %3 ]
  %10 = icmp slt i32 %.0, 100
  br i1 %10, label %11, label %19

11:                                               ; preds = %9
  %12 = add nsw i32 %.0, 2
  %13 = sext i32 %12 to i64
  %14 = getelementptr inbounds i32, ptr %0, i64 %13
  %15 = load i32, ptr %14, align 4
  %16 = sext i32 %.0 to i64
  %17 = getelementptr inbounds i32, ptr %1, i64 %16
  store i32 %15, ptr %17, align 4
  %18 = add nsw i32 %.0, 1
  br label %9, !llvm.loop !10

19:                                               ; preds = %9
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_positive_dependence(ptr noalias noundef %0, ptr noalias noundef %1) #0 {
  br label %3

3:                                                ; preds = %5, %2
  %.01 = phi i32 [ 0, %2 ], [ %14, %5 ]
  %4 = icmp slt i32 %.01, 100
  br i1 %4, label %5, label %15

5:                                                ; preds = %3
  %6 = add nsw i32 %.01, 2
  %7 = sext i32 %6 to i64
  %8 = getelementptr inbounds i32, ptr %0, i64 %7
  store i32 10, ptr %8, align 4
  %9 = sext i32 %.01 to i64
  %10 = getelementptr inbounds i32, ptr %0, i64 %9
  %11 = load i32, ptr %10, align 4
  %12 = sext i32 %.01 to i64
  %13 = getelementptr inbounds i32, ptr %1, i64 %12
  store i32 %11, ptr %13, align 4
  %14 = add nsw i32 %.01, 1
  br label %3, !llvm.loop !11

15:                                               ; preds = %3
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_different_trip_count(ptr noalias noundef %0, ptr noalias noundef %1, i32 noundef %2, i32 noundef %3) #0 {
  br label %5

5:                                                ; preds = %7, %4
  %.01 = phi i32 [ 0, %4 ], [ %10, %7 ]
  %6 = icmp slt i32 %.01, %2
  br i1 %6, label %7, label %11

7:                                                ; preds = %5
  %8 = sext i32 %.01 to i64
  %9 = getelementptr inbounds i32, ptr %0, i64 %8
  store i32 1, ptr %9, align 4
  %10 = add nsw i32 %.01, 1
  br label %5, !llvm.loop !12

11:                                               ; preds = %5, %13
  %.0 = phi i32 [ %16, %13 ], [ 0, %5 ]
  %12 = icmp slt i32 %.0, %3
  br i1 %12, label %13, label %17

13:                                               ; preds = %11
  %14 = sext i32 %.0 to i64
  %15 = getelementptr inbounds i32, ptr %1, i64 %14
  store i32 2, ptr %15, align 4
  %16 = add nsw i32 %.0, 1
  br label %11, !llvm.loop !13

17:                                               ; preds = %11
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_interleaved_code(ptr noalias noundef %0, ptr noalias noundef %1, i32 noundef %2) #0 {
  br label %4

4:                                                ; preds = %6, %3
  %.01 = phi i32 [ 0, %3 ], [ %9, %6 ]
  %5 = icmp slt i32 %.01, 100
  br i1 %5, label %6, label %10

6:                                                ; preds = %4
  %7 = sext i32 %.01 to i64
  %8 = getelementptr inbounds i32, ptr %0, i64 %7
  store i32 1, ptr %8, align 4
  %9 = add nsw i32 %.01, 1
  br label %4, !llvm.loop !14

10:                                               ; preds = %4
  %11 = getelementptr inbounds i32, ptr %0, i64 0
  store i32 %2, ptr %11, align 4
  br label %12

12:                                               ; preds = %14, %10
  %.0 = phi i32 [ 0, %10 ], [ %17, %14 ]
  %13 = icmp slt i32 %.0, 100
  br i1 %13, label %14, label %18

14:                                               ; preds = %12
  %15 = sext i32 %.0 to i64
  %16 = getelementptr inbounds i32, ptr %1, i64 %15
  store i32 2, ptr %16, align 4
  %17 = add nsw i32 %.0, 1
  br label %12, !llvm.loop !15

18:                                               ; preds = %12
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_different_step(ptr noalias noundef %0, ptr noalias noundef %1) #0 {
  br label %3

3:                                                ; preds = %5, %2
  %.01 = phi i32 [ 0, %2 ], [ %8, %5 ]
  %4 = icmp slt i32 %.01, 100
  br i1 %4, label %5, label %9

5:                                                ; preds = %3
  %6 = sext i32 %.01 to i64
  %7 = getelementptr inbounds i32, ptr %0, i64 %6
  store i32 1, ptr %7, align 4
  %8 = add nsw i32 %.01, 1
  br label %3, !llvm.loop !16

9:                                                ; preds = %3, %11
  %.0 = phi i32 [ %15, %11 ], [ 0, %3 ]
  %10 = icmp slt i32 %.0, 100
  br i1 %10, label %11, label %16

11:                                               ; preds = %9
  %12 = mul nsw i32 %.0, 2
  %13 = sext i32 %12 to i64
  %14 = getelementptr inbounds i32, ptr %0, i64 %13
  store i32 2, ptr %14, align 4
  %15 = add nsw i32 %.0, 1
  br label %9, !llvm.loop !17

16:                                               ; preds = %9
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_read_after_read(ptr noalias noundef %0, ptr noalias noundef %1, ptr noalias noundef %2) #0 {
  br label %4

4:                                                ; preds = %6, %3
  %.01 = phi i32 [ 0, %3 ], [ %18, %6 ]
  %5 = icmp slt i32 %.01, 100
  br i1 %5, label %6, label %19

6:                                                ; preds = %4
  %7 = sext i32 %.01 to i64
  %8 = getelementptr inbounds i32, ptr %0, i64 %7
  %9 = load i32, ptr %8, align 4
  %10 = sext i32 %.01 to i64
  %11 = getelementptr inbounds i32, ptr %1, i64 %10
  store i32 %9, ptr %11, align 4
  %12 = add nsw i32 %.01, 2
  %13 = sext i32 %12 to i64
  %14 = getelementptr inbounds i32, ptr %0, i64 %13
  %15 = load i32, ptr %14, align 4
  %16 = sext i32 %.01 to i64
  %17 = getelementptr inbounds i32, ptr %2, i64 %16
  store i32 %15, ptr %17, align 4
  %18 = add nsw i32 %.01, 1
  br label %4, !llvm.loop !18

19:                                               ; preds = %4
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_non_affine_access(ptr noalias noundef %0, ptr noalias noundef %1, ptr noalias noundef %2) #0 {
  br label %4

4:                                                ; preds = %6, %3
  %.01 = phi i32 [ 0, %3 ], [ %12, %6 ]
  %5 = icmp slt i32 %.01, 100
  br i1 %5, label %6, label %13

6:                                                ; preds = %4
  %7 = sext i32 %.01 to i64
  %8 = getelementptr inbounds i32, ptr %2, i64 %7
  %9 = load i32, ptr %8, align 4
  %10 = sext i32 %9 to i64
  %11 = getelementptr inbounds i32, ptr %0, i64 %10
  store i32 1, ptr %11, align 4
  %12 = add nsw i32 %.01, 1
  br label %4, !llvm.loop !19

13:                                               ; preds = %4, %15
  %.0 = phi i32 [ %21, %15 ], [ 0, %4 ]
  %14 = icmp slt i32 %.0, 100
  br i1 %14, label %15, label %22

15:                                               ; preds = %13
  %16 = sext i32 %.0 to i64
  %17 = getelementptr inbounds i32, ptr %0, i64 %16
  %18 = load i32, ptr %17, align 4
  %19 = sext i32 %.0 to i64
  %20 = getelementptr inbounds i32, ptr %1, i64 %19
  store i32 %18, ptr %20, align 4
  %21 = add nsw i32 %.0, 1
  br label %13, !llvm.loop !20

22:                                               ; preds = %13
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_same_guard(ptr noalias noundef %0, ptr noalias noundef %1, i32 noundef %2) #0 {
  %4 = icmp sgt i32 %2, 0
  br i1 %4, label %5, label %12

5:                                                ; preds = %3, %5
  %.01 = phi i32 [ %8, %5 ], [ 0, %3 ]
  %6 = sext i32 %.01 to i64
  %7 = getelementptr inbounds i32, ptr %0, i64 %6
  store i32 1, ptr %7, align 4
  %8 = add nsw i32 %.01, 1
  %9 = sext i32 %.01 to i64
  %10 = getelementptr inbounds i32, ptr %1, i64 %9
  store i32 2, ptr %10, align 4
  %11 = icmp slt i32 %8, %2
  br i1 %11, label %5, label %12, !llvm.loop !21

12:                                               ; preds = %5, %3
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_different_guards(ptr noalias noundef %0, ptr noalias noundef %1, i32 noundef %2, i32 noundef %3) #0 {
  %5 = icmp sgt i32 %2, 0
  br i1 %5, label %6, label %11

6:                                                ; preds = %4, %6
  %.01 = phi i32 [ %9, %6 ], [ 0, %4 ]
  %7 = sext i32 %.01 to i64
  %8 = getelementptr inbounds i32, ptr %0, i64 %7
  store i32 1, ptr %8, align 4
  %9 = add nsw i32 %.01, 1
  %10 = icmp slt i32 %9, %2
  br i1 %10, label %6, label %11, !llvm.loop !22

11:                                               ; preds = %6, %4
  %12 = icmp sgt i32 %3, 0
  br i1 %12, label %13, label %18

13:                                               ; preds = %11, %13
  %.0 = phi i32 [ %16, %13 ], [ 0, %11 ]
  %14 = sext i32 %.0 to i64
  %15 = getelementptr inbounds i32, ptr %1, i64 %14
  store i32 2, ptr %15, align 4
  %16 = add nsw i32 %.0, 1
  %17 = icmp slt i32 %16, %3
  br i1 %17, label %13, label %18, !llvm.loop !23

18:                                               ; preds = %13, %11
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
!13 = distinct !{!13, !7}
!14 = distinct !{!14, !7}
!15 = distinct !{!15, !7}
!16 = distinct !{!16, !7}
!17 = distinct !{!17, !7}
!18 = distinct !{!18, !7}
!19 = distinct !{!19, !7}
!20 = distinct !{!20, !7}
!21 = distinct !{!21, !7}
!22 = distinct !{!22, !7}
!23 = distinct !{!23, !7}
