; ModuleID = 'test/test.m2r.ll'
source_filename = "test/test.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx16.0.0"

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_simple_positive_step(ptr noalias noundef %0, i32 noundef %1, i64 noundef %2) #0 {
  br label %4

4:                                                ; preds = %11, %3
  %.01 = phi i64 [ 0, %3 ], [ %12, %11 ]
  %5 = icmp ult i64 %.01, %2
  br i1 %5, label %6, label %19

6:                                                ; preds = %4
  %7 = trunc i64 %.01 to i32
  %8 = getelementptr inbounds i32, ptr %0, i64 %.01
  store i32 %7, ptr %8, align 4
  %9 = getelementptr inbounds i32, ptr %0, i64 %.01
  %10 = load i32, ptr %9, align 4
  br label %11

11:                                               ; preds = %6
  %12 = add i64 %.01, 1
  br label %4, !llvm.loop !5

13:                                               ; No predecessors!
  br label %14

14:                                               ; preds = %17, %13
  %.0 = phi i64 [ 0, %13 ], [ %18, %17 ]
  %15 = icmp ult i64 %.0, %2
  br label %16

16:                                               ; preds = %14
  br label %17

17:                                               ; preds = %16
  %18 = add i64 %.0, 1
  br label %14, !llvm.loop !7

19:                                               ; preds = %4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_simple_negative_step(ptr noalias noundef %0, i32 noundef %1, i64 noundef %2) #0 {
  br label %4

4:                                                ; preds = %11, %3
  %.01 = phi i64 [ %2, %3 ], [ %12, %11 ]
  %5 = icmp ugt i64 %.01, 0
  br i1 %5, label %6, label %19

6:                                                ; preds = %4
  %7 = trunc i64 %.01 to i32
  %8 = getelementptr inbounds i32, ptr %0, i64 %.01
  store i32 %7, ptr %8, align 4
  %9 = getelementptr inbounds i32, ptr %0, i64 %.01
  %10 = load i32, ptr %9, align 4
  br label %11

11:                                               ; preds = %6
  %12 = add i64 %.01, -1
  br label %4, !llvm.loop !8

13:                                               ; No predecessors!
  br label %14

14:                                               ; preds = %17, %13
  %.0 = phi i64 [ %2, %13 ], [ %18, %17 ]
  %15 = icmp ugt i64 %.0, 0
  br label %16

16:                                               ; preds = %14
  br label %17

17:                                               ; preds = %16
  %18 = add i64 %.0, -1
  br label %14, !llvm.loop !9

19:                                               ; preds = %4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_negative_dependence_positive_step(ptr noalias noundef %0, i32 noundef %1, i64 noundef %2) #0 {
  br label %4

4:                                                ; preds = %9, %3
  %.01 = phi i64 [ 0, %3 ], [ %10, %9 ]
  %5 = icmp ult i64 %.01, %2
  br i1 %5, label %6, label %11

6:                                                ; preds = %4
  %7 = trunc i64 %.01 to i32
  %8 = getelementptr inbounds i32, ptr %0, i64 %.01
  store i32 %7, ptr %8, align 4
  br label %9

9:                                                ; preds = %6
  %10 = add i64 %.01, 1
  br label %4, !llvm.loop !10

11:                                               ; preds = %4
  br label %12

12:                                               ; preds = %18, %11
  %.0 = phi i64 [ 0, %11 ], [ %19, %18 ]
  %13 = icmp ult i64 %.0, %2
  br i1 %13, label %14, label %20

14:                                               ; preds = %12
  %15 = add i64 %.0, 1
  %16 = getelementptr inbounds i32, ptr %0, i64 %15
  %17 = load i32, ptr %16, align 4
  br label %18

18:                                               ; preds = %14
  %19 = add i64 %.0, 1
  br label %12, !llvm.loop !11

20:                                               ; preds = %12
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_positive_dependence_negative_step(ptr noalias noundef %0, i32 noundef %1, i64 noundef %2) #0 {
  br label %4

4:                                                ; preds = %9, %3
  %.01 = phi i64 [ %2, %3 ], [ %10, %9 ]
  %5 = icmp ugt i64 %.01, 0
  br i1 %5, label %6, label %11

6:                                                ; preds = %4
  %7 = trunc i64 %.01 to i32
  %8 = getelementptr inbounds i32, ptr %0, i64 %.01
  store i32 %7, ptr %8, align 4
  br label %9

9:                                                ; preds = %6
  %10 = add i64 %.01, -1
  br label %4, !llvm.loop !12

11:                                               ; preds = %4
  br label %12

12:                                               ; preds = %18, %11
  %.0 = phi i64 [ %2, %11 ], [ %19, %18 ]
  %13 = icmp ugt i64 %.0, 0
  br i1 %13, label %14, label %20

14:                                               ; preds = %12
  %15 = sub i64 %.0, 1
  %16 = getelementptr inbounds i32, ptr %0, i64 %15
  %17 = load i32, ptr %16, align 4
  br label %18

18:                                               ; preds = %14
  %19 = add i64 %.0, -1
  br label %12, !llvm.loop !13

20:                                               ; preds = %12
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_positive_dependence_positive_step(ptr noalias noundef %0, i32 noundef %1, i64 noundef %2) #0 {
  br label %4

4:                                                ; preds = %12, %3
  %.01 = phi i64 [ 0, %3 ], [ %13, %12 ]
  %5 = icmp ult i64 %.01, %2
  br i1 %5, label %6, label %20

6:                                                ; preds = %4
  %7 = trunc i64 %.01 to i32
  %8 = getelementptr inbounds i32, ptr %0, i64 %.01
  store i32 %7, ptr %8, align 4
  %9 = sub i64 %.01, 1
  %10 = getelementptr inbounds i32, ptr %0, i64 %9
  %11 = load i32, ptr %10, align 4
  br label %12

12:                                               ; preds = %6
  %13 = add i64 %.01, 1
  br label %4, !llvm.loop !14

14:                                               ; No predecessors!
  br label %15

15:                                               ; preds = %18, %14
  %.0 = phi i64 [ 0, %14 ], [ %19, %18 ]
  %16 = icmp ult i64 %.0, %2
  br label %17

17:                                               ; preds = %15
  br label %18

18:                                               ; preds = %17
  %19 = add i64 %.0, 1
  br label %15, !llvm.loop !15

20:                                               ; preds = %4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_negative_dependence_negative_step(ptr noalias noundef %0, i32 noundef %1, i64 noundef %2) #0 {
  br label %4

4:                                                ; preds = %12, %3
  %.01 = phi i64 [ %2, %3 ], [ %13, %12 ]
  %5 = icmp ugt i64 %.01, 0
  br i1 %5, label %6, label %20

6:                                                ; preds = %4
  %7 = trunc i64 %.01 to i32
  %8 = getelementptr inbounds i32, ptr %0, i64 %.01
  store i32 %7, ptr %8, align 4
  %9 = add i64 %.01, 1
  %10 = getelementptr inbounds i32, ptr %0, i64 %9
  %11 = load i32, ptr %10, align 4
  br label %12

12:                                               ; preds = %6
  %13 = add i64 %.01, -1
  br label %4, !llvm.loop !16

14:                                               ; No predecessors!
  br label %15

15:                                               ; preds = %18, %14
  %.0 = phi i64 [ %2, %14 ], [ %19, %18 ]
  %16 = icmp ugt i64 %.0, 0
  br label %17

17:                                               ; preds = %15
  br label %18

18:                                               ; preds = %17
  %19 = add i64 %.0, -1
  br label %15, !llvm.loop !17

20:                                               ; preds = %4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_different_trip_count(i32 noundef %0, i32 noundef %1, i64 noundef %2, i64 noundef %3) #0 {
  br label %5

5:                                                ; preds = %8, %4
  %.01 = phi i64 [ 0, %4 ], [ %9, %8 ]
  %6 = icmp ult i64 %.01, %2
  br i1 %6, label %7, label %10

7:                                                ; preds = %5
  br label %8

8:                                                ; preds = %7
  %9 = add i64 %.01, 1
  br label %5, !llvm.loop !18

10:                                               ; preds = %5
  br label %11

11:                                               ; preds = %14, %10
  %.0 = phi i64 [ 0, %10 ], [ %15, %14 ]
  %12 = icmp ult i64 %.0, %3
  br i1 %12, label %13, label %16

13:                                               ; preds = %11
  br label %14

14:                                               ; preds = %13
  %15 = add i64 %.0, 1
  br label %11, !llvm.loop !19

16:                                               ; preds = %11
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_interleaved_code(i32 noundef %0, i32 noundef %1, i32 noundef %2, i64 noundef %3) #0 {
  br label %5

5:                                                ; preds = %8, %4
  %.02 = phi i64 [ 0, %4 ], [ %9, %8 ]
  %.0 = phi i32 [ %0, %4 ], [ 1, %8 ]
  %6 = icmp ult i64 %.02, %3
  br i1 %6, label %7, label %10

7:                                                ; preds = %5
  br label %8

8:                                                ; preds = %7
  %9 = add i64 %.02, 1
  br label %5, !llvm.loop !20

10:                                               ; preds = %5
  %11 = add nsw i32 %.0, %1
  br label %12

12:                                               ; preds = %15, %10
  %.01 = phi i64 [ 0, %10 ], [ %16, %15 ]
  %13 = icmp ult i64 %.01, %3
  br i1 %13, label %14, label %17

14:                                               ; preds = %12
  br label %15

15:                                               ; preds = %14
  %16 = add i64 %.01, 1
  br label %12, !llvm.loop !21

17:                                               ; preds = %12
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_different_step(ptr noalias noundef %0, i64 noundef %1) #0 {
  br label %3

3:                                                ; preds = %7, %2
  %.01 = phi i64 [ 0, %2 ], [ %8, %7 ]
  %4 = icmp ult i64 %.01, %1
  br i1 %4, label %5, label %9

5:                                                ; preds = %3
  %6 = getelementptr inbounds i32, ptr %0, i64 %.01
  store i32 1, ptr %6, align 4
  br label %7

7:                                                ; preds = %5
  %8 = add i64 %.01, 1
  br label %3, !llvm.loop !22

9:                                                ; preds = %3
  br label %10

10:                                               ; preds = %15, %9
  %.0 = phi i64 [ 0, %9 ], [ %16, %15 ]
  %11 = icmp ult i64 %.0, %1
  br i1 %11, label %12, label %17

12:                                               ; preds = %10
  %13 = mul i64 %.0, 2
  %14 = getelementptr inbounds i32, ptr %0, i64 %13
  store i32 2, ptr %14, align 4
  br label %15

15:                                               ; preds = %12
  %16 = add i64 %.0, 1
  br label %10, !llvm.loop !23

17:                                               ; preds = %10
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_read_after_read(ptr noalias noundef %0, i32 noundef %1, i32 noundef %2, i64 noundef %3) #0 {
  br label %5

5:                                                ; preds = %13, %4
  %.01 = phi i64 [ 0, %4 ], [ %14, %13 ]
  %6 = icmp ult i64 %.01, %3
  br i1 %6, label %7, label %21

7:                                                ; preds = %5
  %8 = getelementptr inbounds i32, ptr %0, i64 %.01
  %9 = load i32, ptr %8, align 4
  %10 = add i64 %.01, 1
  %11 = getelementptr inbounds i32, ptr %0, i64 %10
  %12 = load i32, ptr %11, align 4
  br label %13

13:                                               ; preds = %7
  %14 = add i64 %.01, 1
  br label %5, !llvm.loop !24

15:                                               ; No predecessors!
  br label %16

16:                                               ; preds = %19, %15
  %.0 = phi i64 [ 0, %15 ], [ %20, %19 ]
  %17 = icmp ult i64 %.0, %3
  br label %18

18:                                               ; preds = %16
  br label %19

19:                                               ; preds = %18
  %20 = add i64 %.0, 1
  br label %16, !llvm.loop !25

21:                                               ; preds = %5
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_write_after_read(ptr noalias noundef %0, i32 noundef %1, i32 noundef %2, i64 noundef %3) #0 {
  br label %5

5:                                                ; preds = %10, %4
  %.01 = phi i64 [ 0, %4 ], [ %11, %10 ]
  %6 = icmp ult i64 %.01, %3
  br i1 %6, label %7, label %12

7:                                                ; preds = %5
  %8 = getelementptr inbounds i32, ptr %0, i64 %.01
  %9 = load i32, ptr %8, align 4
  br label %10

10:                                               ; preds = %7
  %11 = add i64 %.01, 1
  br label %5, !llvm.loop !26

12:                                               ; preds = %5
  br label %13

13:                                               ; preds = %18, %12
  %.0 = phi i64 [ 0, %12 ], [ %19, %18 ]
  %14 = icmp ult i64 %.0, %3
  br i1 %14, label %15, label %20

15:                                               ; preds = %13
  %16 = add i64 %.0, 1
  %17 = getelementptr inbounds i32, ptr %0, i64 %16
  store i32 %2, ptr %17, align 4
  br label %18

18:                                               ; preds = %15
  %19 = add i64 %.0, 1
  br label %13, !llvm.loop !27

20:                                               ; preds = %13
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_write_after_write(ptr noalias noundef %0, i32 noundef %1, i32 noundef %2, i64 noundef %3) #0 {
  br label %5

5:                                                ; preds = %9, %4
  %.01 = phi i64 [ 0, %4 ], [ %10, %9 ]
  %6 = icmp ult i64 %.01, %3
  br i1 %6, label %7, label %11

7:                                                ; preds = %5
  %8 = getelementptr inbounds i32, ptr %0, i64 %.01
  store i32 %1, ptr %8, align 4
  br label %9

9:                                                ; preds = %7
  %10 = add i64 %.01, 1
  br label %5, !llvm.loop !28

11:                                               ; preds = %5
  br label %12

12:                                               ; preds = %17, %11
  %.0 = phi i64 [ 0, %11 ], [ %18, %17 ]
  %13 = icmp ult i64 %.0, %3
  br i1 %13, label %14, label %19

14:                                               ; preds = %12
  %15 = add i64 %.0, 1
  %16 = getelementptr inbounds i32, ptr %0, i64 %15
  store i32 %2, ptr %16, align 4
  br label %17

17:                                               ; preds = %14
  %18 = add i64 %.0, 1
  br label %12, !llvm.loop !29

19:                                               ; preds = %12
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_complex_access(ptr noalias noundef %0, i32 noundef %1, ptr noalias noundef %2, i64 noundef %3) #0 {
  br label %5

5:                                                ; preds = %11, %4
  %.01 = phi i64 [ 0, %4 ], [ %12, %11 ]
  %6 = icmp ult i64 %.01, %3
  br i1 %6, label %7, label %13

7:                                                ; preds = %5
  %8 = getelementptr inbounds i64, ptr %2, i64 %.01
  %9 = load i64, ptr %8, align 8
  %10 = getelementptr inbounds i32, ptr %0, i64 %9
  store i32 1, ptr %10, align 4
  br label %11

11:                                               ; preds = %7
  %12 = add i64 %.01, 1
  br label %5, !llvm.loop !30

13:                                               ; preds = %5
  br label %14

14:                                               ; preds = %19, %13
  %.0 = phi i64 [ 0, %13 ], [ %20, %19 ]
  %15 = icmp ult i64 %.0, %3
  br i1 %15, label %16, label %21

16:                                               ; preds = %14
  %17 = getelementptr inbounds i32, ptr %0, i64 %.0
  %18 = load i32, ptr %17, align 4
  br label %19

19:                                               ; preds = %16
  %20 = add i64 %.0, 1
  br label %14, !llvm.loop !31

21:                                               ; preds = %14
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_constant_access_1(ptr noalias noundef %0, i32 noundef %1, i64 noundef %2) #0 {
  br label %4

4:                                                ; preds = %10, %3
  %.01 = phi i64 [ 0, %3 ], [ %11, %10 ]
  %5 = icmp ult i64 %.01, %2
  br i1 %5, label %6, label %18

6:                                                ; preds = %4
  %7 = getelementptr inbounds i32, ptr %0, i64 0
  store i32 1, ptr %7, align 4
  %8 = getelementptr inbounds i32, ptr %0, i64 1
  %9 = load i32, ptr %8, align 4
  br label %10

10:                                               ; preds = %6
  %11 = add i64 %.01, 1
  br label %4, !llvm.loop !32

12:                                               ; No predecessors!
  br label %13

13:                                               ; preds = %16, %12
  %.0 = phi i64 [ 0, %12 ], [ %17, %16 ]
  %14 = icmp ult i64 %.0, %2
  br label %15

15:                                               ; preds = %13
  br label %16

16:                                               ; preds = %15
  %17 = add i64 %.0, 1
  br label %13, !llvm.loop !33

18:                                               ; preds = %4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_constant_access_2(ptr noalias noundef %0, i32 noundef %1, i64 noundef %2) #0 {
  br label %4

4:                                                ; preds = %10, %3
  %.01 = phi i64 [ 0, %3 ], [ %11, %10 ]
  %5 = icmp ult i64 %.01, %2
  br i1 %5, label %6, label %18

6:                                                ; preds = %4
  %7 = getelementptr inbounds i32, ptr %0, i64 0
  store i32 1, ptr %7, align 4
  %8 = getelementptr inbounds i32, ptr %0, i64 0
  %9 = load i32, ptr %8, align 4
  br label %10

10:                                               ; preds = %6
  %11 = add i64 %.01, 1
  br label %4, !llvm.loop !34

12:                                               ; No predecessors!
  br label %13

13:                                               ; preds = %16, %12
  %.0 = phi i64 [ 0, %12 ], [ %17, %16 ]
  %14 = icmp ult i64 %.0, %2
  br label %15

15:                                               ; preds = %13
  br label %16

16:                                               ; preds = %15
  %17 = add i64 %.0, 1
  br label %13, !llvm.loop !35

18:                                               ; preds = %4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_mixed_access(ptr noalias noundef %0, i32 noundef %1, i64 noundef %2) #0 {
  br label %4

4:                                                ; preds = %8, %3
  %.01 = phi i64 [ 0, %3 ], [ %9, %8 ]
  %5 = icmp ult i64 %.01, %2
  br i1 %5, label %6, label %10

6:                                                ; preds = %4
  %7 = getelementptr inbounds i32, ptr %0, i64 0
  store i32 1, ptr %7, align 4
  br label %8

8:                                                ; preds = %6
  %9 = add i64 %.01, 1
  br label %4, !llvm.loop !36

10:                                               ; preds = %4
  br label %11

11:                                               ; preds = %16, %10
  %.0 = phi i64 [ 0, %10 ], [ %17, %16 ]
  %12 = icmp ult i64 %.0, %2
  br i1 %12, label %13, label %18

13:                                               ; preds = %11
  %14 = getelementptr inbounds i32, ptr %0, i64 %.0
  %15 = load i32, ptr %14, align 4
  br label %16

16:                                               ; preds = %13
  %17 = add i64 %.0, 1
  br label %11, !llvm.loop !37

18:                                               ; preds = %11
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_same_guard(ptr noalias noundef %0, ptr noalias noundef %1, i64 noundef %2) #0 {
  %4 = icmp ugt i64 %2, 0
  br i1 %4, label %5, label %13

5:                                                ; preds = %3
  br label %6

6:                                                ; preds = %10, %5
  %.01 = phi i64 [ 0, %5 ], [ %8, %10 ]
  %7 = getelementptr inbounds i32, ptr %0, i64 %.01
  store i32 1, ptr %7, align 4
  %8 = add i64 %.01, 1
  %9 = getelementptr inbounds i32, ptr %1, i64 %.01
  store i32 1, ptr %9, align 4
  br label %10

10:                                               ; preds = %6
  %11 = icmp ult i64 %8, %2
  br i1 %11, label %6, label %20, !llvm.loop !38

12:                                               ; No predecessors!
  br label %13

13:                                               ; preds = %12, %3
  %14 = icmp ugt i64 %2, 0
  br i1 %14, label %15, label %21

15:                                               ; preds = %13
  br label %16

16:                                               ; preds = %18, %15
  %.0 = phi i64 [ 0, %15 ], [ %17, %18 ]
  %17 = add i64 %.0, 1
  br label %18

18:                                               ; preds = %16
  %19 = icmp ult i64 %17, %2
  br label %16

20:                                               ; preds = %10
  br label %21

21:                                               ; preds = %20, %13
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_different_guards(ptr noalias noundef %0, ptr noalias noundef %1, i64 noundef %2, i64 noundef %3) #0 {
  %5 = icmp ugt i64 %2, 0
  br i1 %5, label %6, label %13

6:                                                ; preds = %4
  br label %7

7:                                                ; preds = %10, %6
  %.01 = phi i64 [ 0, %6 ], [ %9, %10 ]
  %8 = getelementptr inbounds i32, ptr %0, i64 %.01
  store i32 1, ptr %8, align 4
  %9 = add i64 %.01, 1
  br label %10

10:                                               ; preds = %7
  %11 = icmp ult i64 %9, %2
  br i1 %11, label %7, label %12, !llvm.loop !39

12:                                               ; preds = %10
  br label %13

13:                                               ; preds = %12, %4
  %14 = icmp ugt i64 %3, 0
  br i1 %14, label %15, label %22

15:                                               ; preds = %13
  br label %16

16:                                               ; preds = %19, %15
  %.0 = phi i64 [ 0, %15 ], [ %18, %19 ]
  %17 = getelementptr inbounds i32, ptr %1, i64 %.0
  store i32 1, ptr %17, align 4
  %18 = add i64 %.0, 1
  br label %19

19:                                               ; preds = %16
  %20 = icmp ult i64 %18, %3
  br i1 %20, label %16, label %21, !llvm.loop !40

21:                                               ; preds = %19
  br label %22

22:                                               ; preds = %21, %13
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_iv_use_outside_loops_1(ptr noalias noundef %0, ptr noalias noundef %1, i64 noundef %2) #0 {
  br label %4

4:                                                ; preds = %8, %3
  %.01 = phi i64 [ 0, %3 ], [ %6, %8 ]
  %5 = getelementptr inbounds i32, ptr %0, i64 %.01
  store i32 1, ptr %5, align 4
  %6 = add i64 %.01, 1
  %7 = getelementptr inbounds i32, ptr %1, i64 %.01
  store i32 1, ptr %7, align 4
  br label %8

8:                                                ; preds = %4
  %9 = icmp ult i64 %6, %2
  br i1 %9, label %4, label %15, !llvm.loop !41

10:                                               ; No predecessors!
  br label %11

11:                                               ; preds = %13, %10
  %.0 = phi i64 [ 0, %10 ], [ %12, %13 ]
  %12 = add i64 %.0, 1
  br label %13

13:                                               ; preds = %11
  %14 = icmp ult i64 %12, %2
  br label %11

15:                                               ; preds = %8
  %16 = add i64 %6, 1
  %17 = add i64 %6, 1
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_iv_use_outside_loops_2(ptr noalias noundef %0, ptr noalias noundef %1, i64 noundef %2) #0 {
  br label %4

4:                                                ; preds = %6, %3
  %.01 = phi i64 [ 0, %3 ], [ %8, %6 ]
  %5 = icmp ult i64 %.01, %2
  br i1 %5, label %6, label %15

6:                                                ; preds = %4
  %7 = getelementptr inbounds i32, ptr %0, i64 %.01
  store i32 1, ptr %7, align 4
  %8 = add i64 %.01, 1
  br label %4, !llvm.loop !42

9:                                                ; No predecessors!
  br label %10

10:                                               ; preds = %12, %9
  %.0 = phi i64 [ 0, %9 ], [ %14, %12 ]
  %11 = icmp ult i64 %.0, %2
  br label %12

12:                                               ; preds = %10
  %13 = getelementptr inbounds i32, ptr %1, i64 %.0
  store i32 1, ptr %13, align 4
  %14 = add i64 %.0, 1
  br label %10, !llvm.loop !43

15:                                               ; preds = %4
  %16 = add i64 %.01, 1
  %17 = add i64 %.01, 1
  ret void
}

attributes #0 = { noinline nounwind ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a,+zcm,+zcz" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 1}
!4 = !{!"clang version 19.1.7 (/Users/runner/work/llvm-project/llvm-project/clang cd708029e0b2869e80abe31ddb175f7c35361f90)"}
!5 = distinct !{!5, !6}
!6 = !{!"llvm.loop.mustprogress"}
!7 = distinct !{!7, !6}
!8 = distinct !{!8, !6}
!9 = distinct !{!9, !6}
!10 = distinct !{!10, !6}
!11 = distinct !{!11, !6}
!12 = distinct !{!12, !6}
!13 = distinct !{!13, !6}
!14 = distinct !{!14, !6}
!15 = distinct !{!15, !6}
!16 = distinct !{!16, !6}
!17 = distinct !{!17, !6}
!18 = distinct !{!18, !6}
!19 = distinct !{!19, !6}
!20 = distinct !{!20, !6}
!21 = distinct !{!21, !6}
!22 = distinct !{!22, !6}
!23 = distinct !{!23, !6}
!24 = distinct !{!24, !6}
!25 = distinct !{!25, !6}
!26 = distinct !{!26, !6}
!27 = distinct !{!27, !6}
!28 = distinct !{!28, !6}
!29 = distinct !{!29, !6}
!30 = distinct !{!30, !6}
!31 = distinct !{!31, !6}
!32 = distinct !{!32, !6}
!33 = distinct !{!33, !6}
!34 = distinct !{!34, !6}
!35 = distinct !{!35, !6}
!36 = distinct !{!36, !6}
!37 = distinct !{!37, !6}
!38 = distinct !{!38, !6}
!39 = distinct !{!39, !6}
!40 = distinct !{!40, !6}
!41 = distinct !{!41, !6}
!42 = distinct !{!42, !6}
!43 = distinct !{!43, !6}
