; ModuleID = 'test/test.m2r.ll'
source_filename = "test/test.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_simple(ptr noalias noundef %0, ptr noalias noundef %1, i32 noundef %2) #0 {
  br label %4

4:                                                ; preds = %16, %3
  %.01 = phi i32 [ 0, %3 ], [ %17, %16 ]
  %5 = icmp slt i32 %.01, %2
  br i1 %5, label %6, label %24

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
  br label %16

16:                                               ; preds = %6
  %17 = add nsw i32 %.01, 1
  br label %4, !llvm.loop !6

18:                                               ; No predecessors!
  br label %19

19:                                               ; preds = %22, %18
  %.0 = phi i32 [ 0, %18 ], [ %23, %22 ]
  %20 = icmp slt i32 %.0, %2
  br i1 %20, label %21, label %24

21:                                               ; preds = %19
  br label %22

22:                                               ; preds = %21
  %23 = add nsw i32 %.0, 1
  br label %19, !llvm.loop !8

24:                                               ; preds = %4, %19
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_negative_step_loop(ptr noalias noundef %0, ptr noalias noundef %1) #0 {
  br label %3

3:                                                ; preds = %8, %2
  %.01 = phi i32 [ 100, %2 ], [ %9, %8 ]
  %4 = icmp sgt i32 %.01, 0
  br i1 %4, label %5, label %10

5:                                                ; preds = %3
  %6 = sext i32 %.01 to i64
  %7 = getelementptr inbounds i32, ptr %0, i64 %6
  store i32 1, ptr %7, align 4
  br label %8

8:                                                ; preds = %5
  %9 = add nsw i32 %.01, -1
  br label %3, !llvm.loop !9

10:                                               ; preds = %3
  br label %11

11:                                               ; preds = %19, %10
  %.0 = phi i32 [ 100, %10 ], [ %20, %19 ]
  %12 = icmp sgt i32 %.0, 0
  br i1 %12, label %13, label %21

13:                                               ; preds = %11
  %14 = sext i32 %.0 to i64
  %15 = getelementptr inbounds i32, ptr %0, i64 %14
  %16 = load i32, ptr %15, align 4
  %17 = sext i32 %.0 to i64
  %18 = getelementptr inbounds i32, ptr %1, i64 %17
  store i32 %16, ptr %18, align 4
  br label %19

19:                                               ; preds = %13
  %20 = add nsw i32 %.0, -1
  br label %11, !llvm.loop !10

21:                                               ; preds = %11
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_negative_dependence(ptr noalias noundef %0, ptr noalias noundef %1) #0 {
  br label %3

3:                                                ; preds = %8, %2
  %.01 = phi i32 [ 0, %2 ], [ %9, %8 ]
  %4 = icmp slt i32 %.01, 100
  br i1 %4, label %5, label %10

5:                                                ; preds = %3
  %6 = sext i32 %.01 to i64
  %7 = getelementptr inbounds i32, ptr %0, i64 %6
  store i32 10, ptr %7, align 4
  br label %8

8:                                                ; preds = %5
  %9 = add nsw i32 %.01, 1
  br label %3, !llvm.loop !11

10:                                               ; preds = %3
  br label %11

11:                                               ; preds = %20, %10
  %.0 = phi i32 [ 0, %10 ], [ %21, %20 ]
  %12 = icmp slt i32 %.0, 100
  br i1 %12, label %13, label %22

13:                                               ; preds = %11
  %14 = add nsw i32 %.0, 2
  %15 = sext i32 %14 to i64
  %16 = getelementptr inbounds i32, ptr %0, i64 %15
  %17 = load i32, ptr %16, align 4
  %18 = sext i32 %.0 to i64
  %19 = getelementptr inbounds i32, ptr %1, i64 %18
  store i32 %17, ptr %19, align 4
  br label %20

20:                                               ; preds = %13
  %21 = add nsw i32 %.0, 1
  br label %11, !llvm.loop !12

22:                                               ; preds = %11
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_negative_dependece_2(ptr noalias noundef %0, ptr noalias noundef %1) #0 {
  br label %3

3:                                                ; preds = %8, %2
  %.01 = phi i32 [ 100, %2 ], [ %9, %8 ]
  %4 = icmp sgt i32 %.01, 0
  br i1 %4, label %5, label %10

5:                                                ; preds = %3
  %6 = sext i32 %.01 to i64
  %7 = getelementptr inbounds i32, ptr %0, i64 %6
  store i32 1, ptr %7, align 4
  br label %8

8:                                                ; preds = %5
  %9 = add nsw i32 %.01, -1
  br label %3, !llvm.loop !13

10:                                               ; preds = %3
  br label %11

11:                                               ; preds = %20, %10
  %.0 = phi i32 [ 100, %10 ], [ %21, %20 ]
  %12 = icmp sgt i32 %.0, 0
  br i1 %12, label %13, label %22

13:                                               ; preds = %11
  %14 = sub nsw i32 %.0, 1
  %15 = sext i32 %14 to i64
  %16 = getelementptr inbounds i32, ptr %0, i64 %15
  %17 = load i32, ptr %16, align 4
  %18 = sext i32 %.0 to i64
  %19 = getelementptr inbounds i32, ptr %1, i64 %18
  store i32 %17, ptr %19, align 4
  br label %20

20:                                               ; preds = %13
  %21 = add nsw i32 %.0, -1
  br label %11, !llvm.loop !14

22:                                               ; preds = %11
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_positive_dependence(ptr noalias noundef %0, ptr noalias noundef %1) #0 {
  br label %3

3:                                                ; preds = %14, %2
  %.01 = phi i32 [ 0, %2 ], [ %15, %14 ]
  %4 = icmp slt i32 %.01, 100
  br i1 %4, label %5, label %22

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
  br label %14

14:                                               ; preds = %5
  %15 = add nsw i32 %.01, 1
  br label %3, !llvm.loop !15

16:                                               ; No predecessors!
  br label %17

17:                                               ; preds = %20, %16
  %.0 = phi i32 [ 0, %16 ], [ %21, %20 ]
  %18 = icmp slt i32 %.0, 100
  br i1 %18, label %19, label %22

19:                                               ; preds = %17
  br label %20

20:                                               ; preds = %19
  %21 = add nsw i32 %.0, 1
  br label %17, !llvm.loop !16

22:                                               ; preds = %3, %17
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_different_trip_count(ptr noalias noundef %0, ptr noalias noundef %1, i32 noundef %2, i32 noundef %3) #0 {
  br label %5

5:                                                ; preds = %10, %4
  %.01 = phi i32 [ 0, %4 ], [ %11, %10 ]
  %6 = icmp slt i32 %.01, %2
  br i1 %6, label %7, label %12

7:                                                ; preds = %5
  %8 = sext i32 %.01 to i64
  %9 = getelementptr inbounds i32, ptr %0, i64 %8
  store i32 1, ptr %9, align 4
  br label %10

10:                                               ; preds = %7
  %11 = add nsw i32 %.01, 1
  br label %5, !llvm.loop !17

12:                                               ; preds = %5
  br label %13

13:                                               ; preds = %18, %12
  %.0 = phi i32 [ 0, %12 ], [ %19, %18 ]
  %14 = icmp slt i32 %.0, %3
  br i1 %14, label %15, label %20

15:                                               ; preds = %13
  %16 = sext i32 %.0 to i64
  %17 = getelementptr inbounds i32, ptr %1, i64 %16
  store i32 2, ptr %17, align 4
  br label %18

18:                                               ; preds = %15
  %19 = add nsw i32 %.0, 1
  br label %13, !llvm.loop !18

20:                                               ; preds = %13
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_interleaved_code(ptr noalias noundef %0, ptr noalias noundef %1, i32 noundef %2) #0 {
  br label %4

4:                                                ; preds = %9, %3
  %.01 = phi i32 [ 0, %3 ], [ %10, %9 ]
  %5 = icmp slt i32 %.01, 100
  br i1 %5, label %6, label %11

6:                                                ; preds = %4
  %7 = sext i32 %.01 to i64
  %8 = getelementptr inbounds i32, ptr %0, i64 %7
  store i32 1, ptr %8, align 4
  br label %9

9:                                                ; preds = %6
  %10 = add nsw i32 %.01, 1
  br label %4, !llvm.loop !19

11:                                               ; preds = %4
  %12 = getelementptr inbounds i32, ptr %0, i64 0
  store i32 %2, ptr %12, align 4
  br label %13

13:                                               ; preds = %18, %11
  %.0 = phi i32 [ 0, %11 ], [ %19, %18 ]
  %14 = icmp slt i32 %.0, 100
  br i1 %14, label %15, label %20

15:                                               ; preds = %13
  %16 = sext i32 %.0 to i64
  %17 = getelementptr inbounds i32, ptr %1, i64 %16
  store i32 2, ptr %17, align 4
  br label %18

18:                                               ; preds = %15
  %19 = add nsw i32 %.0, 1
  br label %13, !llvm.loop !20

20:                                               ; preds = %13
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_different_step(ptr noalias noundef %0, ptr noalias noundef %1) #0 {
  br label %3

3:                                                ; preds = %8, %2
  %.01 = phi i32 [ 0, %2 ], [ %9, %8 ]
  %4 = icmp slt i32 %.01, 100
  br i1 %4, label %5, label %10

5:                                                ; preds = %3
  %6 = sext i32 %.01 to i64
  %7 = getelementptr inbounds i32, ptr %0, i64 %6
  store i32 1, ptr %7, align 4
  br label %8

8:                                                ; preds = %5
  %9 = add nsw i32 %.01, 1
  br label %3, !llvm.loop !21

10:                                               ; preds = %3
  br label %11

11:                                               ; preds = %17, %10
  %.0 = phi i32 [ 0, %10 ], [ %18, %17 ]
  %12 = icmp slt i32 %.0, 100
  br i1 %12, label %13, label %19

13:                                               ; preds = %11
  %14 = mul nsw i32 %.0, 2
  %15 = sext i32 %14 to i64
  %16 = getelementptr inbounds i32, ptr %0, i64 %15
  store i32 2, ptr %16, align 4
  br label %17

17:                                               ; preds = %13
  %18 = add nsw i32 %.0, 1
  br label %11, !llvm.loop !22

19:                                               ; preds = %11
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_read_after_read(ptr noalias noundef %0, ptr noalias noundef %1, ptr noalias noundef %2) #0 {
  br label %4

4:                                                ; preds = %18, %3
  %.01 = phi i32 [ 0, %3 ], [ %19, %18 ]
  %5 = icmp slt i32 %.01, 100
  br i1 %5, label %6, label %26

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
  br label %18

18:                                               ; preds = %6
  %19 = add nsw i32 %.01, 1
  br label %4, !llvm.loop !23

20:                                               ; No predecessors!
  br label %21

21:                                               ; preds = %24, %20
  %.0 = phi i32 [ 0, %20 ], [ %25, %24 ]
  %22 = icmp slt i32 %.0, 100
  br i1 %22, label %23, label %26

23:                                               ; preds = %21
  br label %24

24:                                               ; preds = %23
  %25 = add nsw i32 %.0, 1
  br label %21, !llvm.loop !24

26:                                               ; preds = %4, %21
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_non_affine_access(ptr noalias noundef %0, ptr noalias noundef %1, ptr noalias noundef %2) #0 {
  br label %4

4:                                                ; preds = %12, %3
  %.01 = phi i32 [ 0, %3 ], [ %13, %12 ]
  %5 = icmp slt i32 %.01, 100
  br i1 %5, label %6, label %14

6:                                                ; preds = %4
  %7 = sext i32 %.01 to i64
  %8 = getelementptr inbounds i32, ptr %2, i64 %7
  %9 = load i32, ptr %8, align 4
  %10 = sext i32 %9 to i64
  %11 = getelementptr inbounds i32, ptr %0, i64 %10
  store i32 1, ptr %11, align 4
  br label %12

12:                                               ; preds = %6
  %13 = add nsw i32 %.01, 1
  br label %4, !llvm.loop !25

14:                                               ; preds = %4
  br label %15

15:                                               ; preds = %23, %14
  %.0 = phi i32 [ 0, %14 ], [ %24, %23 ]
  %16 = icmp slt i32 %.0, 100
  br i1 %16, label %17, label %25

17:                                               ; preds = %15
  %18 = sext i32 %.0 to i64
  %19 = getelementptr inbounds i32, ptr %0, i64 %18
  %20 = load i32, ptr %19, align 4
  %21 = sext i32 %.0 to i64
  %22 = getelementptr inbounds i32, ptr %1, i64 %21
  store i32 %20, ptr %22, align 4
  br label %23

23:                                               ; preds = %17
  %24 = add nsw i32 %.0, 1
  br label %15, !llvm.loop !26

25:                                               ; preds = %15
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_same_guard(ptr noalias noundef %0, ptr noalias noundef %1, i32 noundef %2) #0 {
  %4 = icmp sgt i32 %2, 0
  br i1 %4, label %5, label %15

5:                                                ; preds = %3
  br label %6

6:                                                ; preds = %12, %5
  %.01 = phi i32 [ 0, %5 ], [ %9, %12 ]
  %7 = sext i32 %.01 to i64
  %8 = getelementptr inbounds i32, ptr %0, i64 %7
  store i32 1, ptr %8, align 4
  %9 = add nsw i32 %.01, 1
  %10 = sext i32 %.01 to i64
  %11 = getelementptr inbounds i32, ptr %1, i64 %10
  store i32 2, ptr %11, align 4
  br label %12

12:                                               ; preds = %6
  %13 = icmp slt i32 %9, %2
  br i1 %13, label %6, label %22, !llvm.loop !27

14:                                               ; No predecessors!
  br label %15

15:                                               ; preds = %14, %3
  %16 = icmp sgt i32 %2, 0
  br i1 %16, label %17, label %23

17:                                               ; preds = %15
  br label %18

18:                                               ; preds = %20, %17
  %.0 = phi i32 [ 0, %17 ], [ %19, %20 ]
  %19 = add nsw i32 %.0, 1
  br label %20

20:                                               ; preds = %18
  %21 = icmp slt i32 %19, %2
  br i1 %21, label %18, label %22, !llvm.loop !28

22:                                               ; preds = %12, %20
  br label %23

23:                                               ; preds = %22, %15
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_different_guards(ptr noalias noundef %0, ptr noalias noundef %1, i32 noundef %2, i32 noundef %3) #0 {
  %5 = icmp sgt i32 %2, 0
  br i1 %5, label %6, label %14

6:                                                ; preds = %4
  br label %7

7:                                                ; preds = %11, %6
  %.01 = phi i32 [ 0, %6 ], [ %10, %11 ]
  %8 = sext i32 %.01 to i64
  %9 = getelementptr inbounds i32, ptr %0, i64 %8
  store i32 1, ptr %9, align 4
  %10 = add nsw i32 %.01, 1
  br label %11

11:                                               ; preds = %7
  %12 = icmp slt i32 %10, %2
  br i1 %12, label %7, label %13, !llvm.loop !29

13:                                               ; preds = %11
  br label %14

14:                                               ; preds = %13, %4
  %15 = icmp sgt i32 %3, 0
  br i1 %15, label %16, label %24

16:                                               ; preds = %14
  br label %17

17:                                               ; preds = %21, %16
  %.0 = phi i32 [ 0, %16 ], [ %20, %21 ]
  %18 = sext i32 %.0 to i64
  %19 = getelementptr inbounds i32, ptr %1, i64 %18
  store i32 2, ptr %19, align 4
  %20 = add nsw i32 %.0, 1
  br label %21

21:                                               ; preds = %17
  %22 = icmp slt i32 %20, %3
  br i1 %22, label %17, label %23, !llvm.loop !30

23:                                               ; preds = %21
  br label %24

24:                                               ; preds = %23, %14
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_IV1_use_outside_loops(ptr noalias noundef %0, ptr noalias noundef %1, i32 noundef %2) #0 {
  br label %4

4:                                                ; preds = %10, %3
  %.01 = phi i32 [ 0, %3 ], [ %7, %10 ]
  %5 = sext i32 %.01 to i64
  %6 = getelementptr inbounds i32, ptr %0, i64 %5
  store i32 1, ptr %6, align 4
  %7 = add nsw i32 %.01, 1
  %8 = sext i32 %.01 to i64
  %9 = getelementptr inbounds i32, ptr %1, i64 %8
  store i32 2, ptr %9, align 4
  br label %10

10:                                               ; preds = %4
  %11 = icmp slt i32 %7, %2
  br i1 %11, label %4, label %17, !llvm.loop !31

12:                                               ; No predecessors!
  br label %13

13:                                               ; preds = %15, %12
  %.0 = phi i32 [ 0, %12 ], [ %14, %15 ]
  %14 = add nsw i32 %.0, 1
  br label %15

15:                                               ; preds = %13
  %16 = icmp slt i32 %14, %2
  br i1 %16, label %13, label %17, !llvm.loop !32

17:                                               ; preds = %10, %15
  %18 = add nsw i32 %7, 5
  %19 = add nsw i32 %7, 1
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_IV1_use_outside_loops_2(ptr noalias noundef %0, ptr noalias noundef %1, i32 noundef %2) #0 {
  br label %4

4:                                                ; preds = %7, %3
  %.01 = phi i32 [ 0, %3 ], [ %10, %7 ]
  %5 = icmp slt i32 %.01, %2
  %6 = icmp slt i32 %.01, %2
  br i1 %5, label %7, label %17

7:                                                ; preds = %4
  %8 = sext i32 %.01 to i64
  %9 = getelementptr inbounds i32, ptr %0, i64 %8
  store i32 1, ptr %9, align 4
  %10 = add nsw i32 %.01, 1
  br label %4, !llvm.loop !33

11:                                               ; No predecessors!
  br label %12

12:                                               ; preds = %13, %11
  %.0 = phi i32 [ 0, %11 ], [ %16, %13 ]
  br i1 %6, label %13, label %17

13:                                               ; preds = %12
  %14 = sext i32 %.0 to i64
  %15 = getelementptr inbounds i32, ptr %1, i64 %14
  store i32 2, ptr %15, align 4
  %16 = add nsw i32 %.0, 1
  br label %12, !llvm.loop !34

17:                                               ; preds = %4, %12
  %18 = add nsw i32 %.01, 5
  %19 = add nsw i32 %.01, 1
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
!23 = distinct !{!23, !7}
!24 = distinct !{!24, !7}
!25 = distinct !{!25, !7}
!26 = distinct !{!26, !7}
!27 = distinct !{!27, !7}
!28 = distinct !{!28, !7}
!29 = distinct !{!29, !7}
!30 = distinct !{!30, !7}
!31 = distinct !{!31, !7}
!32 = distinct !{!32, !7}
!33 = distinct !{!33, !7}
!34 = distinct !{!34, !7}
