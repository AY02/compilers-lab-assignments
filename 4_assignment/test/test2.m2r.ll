; ModuleID = 'test2.ll'
source_filename = "test2.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_perfect_fusion(i32 noundef %0, ptr noundef %1, ptr noundef %2, ptr noundef %3) #0 {
  br label %5

5:                                                ; preds = %14, %4
  %.01 = phi i32 [ 0, %4 ], [ %15, %14 ]
  %6 = icmp slt i32 %.01, %0
  br i1 %6, label %7, label %16

7:                                                ; preds = %5
  %8 = zext nneg i32 %.01 to i64
  %9 = getelementptr inbounds i32, ptr %2, i64 %8
  %10 = load i32, ptr %9, align 4
  %11 = add nsw i32 %10, 1
  %12 = zext nneg i32 %.01 to i64
  %13 = getelementptr inbounds i32, ptr %1, i64 %12
  store i32 %11, ptr %13, align 4
  br label %14

14:                                               ; preds = %7
  %15 = add nuw nsw i32 %.01, 1
  br label %5, !llvm.loop !6

16:                                               ; preds = %5
  br label %17

17:                                               ; preds = %26, %16
  %.0 = phi i32 [ 0, %16 ], [ %27, %26 ]
  %18 = icmp slt i32 %.0, %0
  br i1 %18, label %19, label %28

19:                                               ; preds = %17
  %20 = zext nneg i32 %.0 to i64
  %21 = getelementptr inbounds i32, ptr %1, i64 %20
  %22 = load i32, ptr %21, align 4
  %23 = shl nsw i32 %22, 1
  %24 = zext nneg i32 %.0 to i64
  %25 = getelementptr inbounds i32, ptr %3, i64 %24
  store i32 %23, ptr %25, align 4
  br label %26

26:                                               ; preds = %19
  %27 = add nuw nsw i32 %.0, 1
  br label %17, !llvm.loop !8

28:                                               ; preds = %17
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_non_adjacent(i32 noundef %0, ptr noundef %1, ptr noundef %2) #0 {
  br label %4

4:                                                ; preds = %9, %3
  %.01 = phi i32 [ 0, %3 ], [ %10, %9 ]
  %5 = icmp slt i32 %.01, %0
  br i1 %5, label %6, label %11

6:                                                ; preds = %4
  %7 = zext nneg i32 %.01 to i64
  %8 = getelementptr inbounds i32, ptr %1, i64 %7
  store i32 %.01, ptr %8, align 4
  br label %9

9:                                                ; preds = %6
  %10 = add nuw nsw i32 %.01, 1
  br label %4, !llvm.loop !9

11:                                               ; preds = %4
  store i32 99, ptr %2, align 4
  br label %12

12:                                               ; preds = %20, %11
  %.0 = phi i32 [ 0, %11 ], [ %21, %20 ]
  %13 = icmp slt i32 %.0, %0
  br i1 %13, label %14, label %22

14:                                               ; preds = %12
  %15 = zext nneg i32 %.0 to i64
  %16 = getelementptr inbounds i32, ptr %1, i64 %15
  %17 = load i32, ptr %16, align 4
  %18 = zext nneg i32 %.0 to i64
  %19 = getelementptr inbounds i32, ptr %2, i64 %18
  store i32 %17, ptr %19, align 4
  br label %20

20:                                               ; preds = %14
  %21 = add nuw nsw i32 %.0, 1
  br label %12, !llvm.loop !10

22:                                               ; preds = %12
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_not_cf_equivalent(i32 noundef %0, i32 noundef %1, ptr noundef %2) #0 {
  br label %4

4:                                                ; preds = %10, %3
  %.01 = phi i32 [ 0, %3 ], [ %11, %10 ]
  %5 = icmp slt i32 %.01, %0
  br i1 %5, label %6, label %12

6:                                                ; preds = %4
  %7 = shl nuw nsw i32 %.01, 1
  %8 = zext nneg i32 %.01 to i64
  %9 = getelementptr inbounds i32, ptr %2, i64 %8
  store i32 %7, ptr %9, align 4
  br label %10

10:                                               ; preds = %6
  %11 = add nuw nsw i32 %.01, 1
  br label %4, !llvm.loop !11

12:                                               ; preds = %4
  %13 = icmp sgt i32 %1, 0
  br i1 %13, label %14, label %27

14:                                               ; preds = %12
  br label %15

15:                                               ; preds = %24, %14
  %.0 = phi i32 [ 0, %14 ], [ %25, %24 ]
  %16 = icmp slt i32 %.0, %0
  br i1 %16, label %17, label %26

17:                                               ; preds = %15
  %18 = zext nneg i32 %.0 to i64
  %19 = getelementptr inbounds i32, ptr %2, i64 %18
  %20 = load i32, ptr %19, align 4
  %21 = add nsw i32 %20, 1
  %22 = zext nneg i32 %.0 to i64
  %23 = getelementptr inbounds i32, ptr %2, i64 %22
  store i32 %21, ptr %23, align 4
  br label %24

24:                                               ; preds = %17
  %25 = add nuw nsw i32 %.0, 1
  br label %15, !llvm.loop !12

26:                                               ; preds = %15
  br label %27

27:                                               ; preds = %26, %12
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_different_guards(i32 noundef %0, i32 noundef %1, ptr noundef %2, ptr noundef %3) #0 {
  br label %5

5:                                                ; preds = %10, %4
  %.01 = phi i32 [ 0, %4 ], [ %11, %10 ]
  %6 = icmp slt i32 %.01, %0
  br i1 %6, label %7, label %12

7:                                                ; preds = %5
  %8 = zext nneg i32 %.01 to i64
  %9 = getelementptr inbounds i32, ptr %2, i64 %8
  store i32 %.01, ptr %9, align 4
  br label %10

10:                                               ; preds = %7
  %11 = add nuw nsw i32 %.01, 1
  br label %5, !llvm.loop !13

12:                                               ; preds = %5
  br label %13

13:                                               ; preds = %18, %12
  %.0 = phi i32 [ 0, %12 ], [ %19, %18 ]
  %14 = icmp slt i32 %.0, %1
  br i1 %14, label %15, label %20

15:                                               ; preds = %13
  %16 = zext nneg i32 %.0 to i64
  %17 = getelementptr inbounds i32, ptr %3, i64 %16
  store i32 %.0, ptr %17, align 4
  br label %18

18:                                               ; preds = %15
  %19 = add nuw nsw i32 %.0, 1
  br label %13, !llvm.loop !14

20:                                               ; preds = %13
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_mixed_guards(i32 noundef %0, ptr noundef %1) #0 {
  %3 = icmp sgt i32 %0, 0
  br i1 %3, label %4, label %12

4:                                                ; preds = %2
  br label %5

5:                                                ; preds = %8, %4
  %.01 = phi i32 [ 0, %4 ], [ %9, %8 ]
  %6 = zext nneg i32 %.01 to i64
  %7 = getelementptr inbounds i32, ptr %1, i64 %6
  store i32 %.01, ptr %7, align 4
  br label %8

8:                                                ; preds = %5
  %9 = add nuw nsw i32 %.01, 1
  %10 = icmp slt i32 %9, %0
  br i1 %10, label %5, label %11, !llvm.loop !15

11:                                               ; preds = %8
  br label %12

12:                                               ; preds = %11, %2
  br label %13

13:                                               ; preds = %20, %12
  %.0 = phi i32 [ 0, %12 ], [ %21, %20 ]
  %14 = zext nneg i32 %.0 to i64
  %15 = getelementptr inbounds i32, ptr %1, i64 %14
  %16 = load i32, ptr %15, align 4
  %17 = add nsw i32 %16, 1
  %18 = zext nneg i32 %.0 to i64
  %19 = getelementptr inbounds i32, ptr %1, i64 %18
  store i32 %17, ptr %19, align 4
  br label %20

20:                                               ; preds = %13
  %21 = add nuw nsw i32 %.0, 1
  %22 = icmp ult i32 %.0, 9
  br i1 %22, label %13, label %23, !llvm.loop !16

23:                                               ; preds = %20
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_both_guarded_pass(i32 noundef %0, ptr noundef %1, ptr noundef %2) #0 {
  %4 = icmp sgt i32 %0, 0
  br i1 %4, label %5, label %14

5:                                                ; preds = %3
  br label %6

6:                                                ; preds = %10, %5
  %.01 = phi i32 [ 0, %5 ], [ %11, %10 ]
  %7 = shl nuw nsw i32 %.01, 1
  %8 = zext nneg i32 %.01 to i64
  %9 = getelementptr inbounds i32, ptr %1, i64 %8
  store i32 %7, ptr %9, align 4
  br label %10

10:                                               ; preds = %6
  %11 = add nuw nsw i32 %.01, 1
  %12 = icmp slt i32 %11, %0
  br i1 %12, label %6, label %13, !llvm.loop !17

13:                                               ; preds = %10
  br label %14

14:                                               ; preds = %13, %3
  %15 = icmp sgt i32 %0, 0
  br i1 %15, label %16, label %25

16:                                               ; preds = %14
  br label %17

17:                                               ; preds = %21, %16
  %.0 = phi i32 [ 0, %16 ], [ %22, %21 ]
  %18 = shl nuw nsw i32 %.0, 1
  %19 = zext nneg i32 %.0 to i64
  %20 = getelementptr inbounds i32, ptr %2, i64 %19
  store i32 %18, ptr %20, align 4
  br label %21

21:                                               ; preds = %17
  %22 = add nuw nsw i32 %.0, 1
  %23 = icmp slt i32 %22, %0
  br i1 %23, label %17, label %24, !llvm.loop !18

24:                                               ; preds = %21
  br label %25

25:                                               ; preds = %24, %14
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_both_guarded_fail_adj(i32 noundef %0, ptr noundef %1, ptr noundef %2) #0 {
  %4 = icmp sgt i32 %0, 0
  br i1 %4, label %5, label %14

5:                                                ; preds = %3
  br label %6

6:                                                ; preds = %10, %5
  %.01 = phi i32 [ 0, %5 ], [ %11, %10 ]
  %7 = shl nuw nsw i32 %.01, 1
  %8 = zext nneg i32 %.01 to i64
  %9 = getelementptr inbounds i32, ptr %1, i64 %8
  store i32 %7, ptr %9, align 4
  br label %10

10:                                               ; preds = %6
  %11 = add nuw nsw i32 %.01, 1
  %12 = icmp slt i32 %11, %0
  br i1 %12, label %6, label %13, !llvm.loop !19

13:                                               ; preds = %10
  br label %14

14:                                               ; preds = %13, %3
  store i32 999, ptr %1, align 4
  %15 = icmp sgt i32 %0, 0
  br i1 %15, label %16, label %25

16:                                               ; preds = %14
  br label %17

17:                                               ; preds = %21, %16
  %.0 = phi i32 [ 0, %16 ], [ %22, %21 ]
  %18 = shl nuw nsw i32 %.0, 1
  %19 = zext nneg i32 %.0 to i64
  %20 = getelementptr inbounds i32, ptr %2, i64 %19
  store i32 %18, ptr %20, align 4
  br label %21

21:                                               ; preds = %17
  %22 = add nuw nsw i32 %.0, 1
  %23 = icmp slt i32 %22, %0
  br i1 %23, label %17, label %24, !llvm.loop !20

24:                                               ; preds = %21
  br label %25

25:                                               ; preds = %24, %14
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_both_guarded_fail_cfe(i32 noundef %0, i32 noundef %1, ptr noundef %2, ptr noundef %3) #0 {
  %5 = icmp sgt i32 %0, 0
  br i1 %5, label %6, label %15

6:                                                ; preds = %4
  br label %7

7:                                                ; preds = %11, %6
  %.01 = phi i32 [ 0, %6 ], [ %12, %11 ]
  %8 = shl nuw nsw i32 %.01, 1
  %9 = zext nneg i32 %.01 to i64
  %10 = getelementptr inbounds i32, ptr %2, i64 %9
  store i32 %8, ptr %10, align 4
  br label %11

11:                                               ; preds = %7
  %12 = add nuw nsw i32 %.01, 1
  %13 = icmp slt i32 %12, %0
  br i1 %13, label %7, label %14, !llvm.loop !21

14:                                               ; preds = %11
  br label %15

15:                                               ; preds = %14, %4
  %16 = icmp sgt i32 %1, 0
  br i1 %16, label %17, label %29

17:                                               ; preds = %15
  %18 = icmp sgt i32 %0, 0
  br i1 %18, label %19, label %28

19:                                               ; preds = %17
  br label %20

20:                                               ; preds = %24, %19
  %.0 = phi i32 [ 0, %19 ], [ %25, %24 ]
  %21 = shl nuw nsw i32 %.0, 1
  %22 = zext nneg i32 %.0 to i64
  %23 = getelementptr inbounds i32, ptr %3, i64 %22
  store i32 %21, ptr %23, align 4
  br label %24

24:                                               ; preds = %20
  %25 = add nuw nsw i32 %.0, 1
  %26 = icmp slt i32 %25, %0
  br i1 %26, label %20, label %27, !llvm.loop !22

27:                                               ; preds = %24
  br label %28

28:                                               ; preds = %27, %17
  br label %29

29:                                               ; preds = %28, %15
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
!19 = distinct !{!19, !7}
!20 = distinct !{!20, !7}
!21 = distinct !{!21, !7}
!22 = distinct !{!22, !7}
