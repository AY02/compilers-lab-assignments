; ModuleID = 'test/test.c'
source_filename = "test/test.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx16.0.0"

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_simple_positive_step(ptr noalias noundef %0, i32 noundef %1, i64 noundef %2) #0 {
  %4 = alloca ptr, align 8
  %5 = alloca i32, align 4
  %6 = alloca i64, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store i32 %1, ptr %5, align 4
  store i64 %2, ptr %6, align 8
  store i64 0, ptr %7, align 8
  br label %9

9:                                                ; preds = %19, %3
  %10 = load i64, ptr %7, align 8
  %11 = load i64, ptr %6, align 8
  %12 = icmp ult i64 %10, %11
  br i1 %12, label %13, label %22

13:                                               ; preds = %9
  %14 = load i64, ptr %7, align 8
  %15 = trunc i64 %14 to i32
  %16 = load ptr, ptr %4, align 8
  %17 = load i64, ptr %7, align 8
  %18 = getelementptr inbounds i32, ptr %16, i64 %17
  store i32 %15, ptr %18, align 4
  br label %19

19:                                               ; preds = %13
  %20 = load i64, ptr %7, align 8
  %21 = add i64 %20, 1
  store i64 %21, ptr %7, align 8
  br label %9, !llvm.loop !5

22:                                               ; preds = %9
  store i64 0, ptr %8, align 8
  br label %23

23:                                               ; preds = %32, %22
  %24 = load i64, ptr %8, align 8
  %25 = load i64, ptr %6, align 8
  %26 = icmp ult i64 %24, %25
  br i1 %26, label %27, label %35

27:                                               ; preds = %23
  %28 = load ptr, ptr %4, align 8
  %29 = load i64, ptr %8, align 8
  %30 = getelementptr inbounds i32, ptr %28, i64 %29
  %31 = load i32, ptr %30, align 4
  store i32 %31, ptr %5, align 4
  br label %32

32:                                               ; preds = %27
  %33 = load i64, ptr %8, align 8
  %34 = add i64 %33, 1
  store i64 %34, ptr %8, align 8
  br label %23, !llvm.loop !7

35:                                               ; preds = %23
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_simple_negative_step(ptr noalias noundef %0, i32 noundef %1, i64 noundef %2) #0 {
  %4 = alloca ptr, align 8
  %5 = alloca i32, align 4
  %6 = alloca i64, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store i32 %1, ptr %5, align 4
  store i64 %2, ptr %6, align 8
  %9 = load i64, ptr %6, align 8
  store i64 %9, ptr %7, align 8
  br label %10

10:                                               ; preds = %19, %3
  %11 = load i64, ptr %7, align 8
  %12 = icmp ugt i64 %11, 0
  br i1 %12, label %13, label %22

13:                                               ; preds = %10
  %14 = load i64, ptr %7, align 8
  %15 = trunc i64 %14 to i32
  %16 = load ptr, ptr %4, align 8
  %17 = load i64, ptr %7, align 8
  %18 = getelementptr inbounds i32, ptr %16, i64 %17
  store i32 %15, ptr %18, align 4
  br label %19

19:                                               ; preds = %13
  %20 = load i64, ptr %7, align 8
  %21 = add i64 %20, -1
  store i64 %21, ptr %7, align 8
  br label %10, !llvm.loop !8

22:                                               ; preds = %10
  %23 = load i64, ptr %6, align 8
  store i64 %23, ptr %8, align 8
  br label %24

24:                                               ; preds = %32, %22
  %25 = load i64, ptr %8, align 8
  %26 = icmp ugt i64 %25, 0
  br i1 %26, label %27, label %35

27:                                               ; preds = %24
  %28 = load ptr, ptr %4, align 8
  %29 = load i64, ptr %8, align 8
  %30 = getelementptr inbounds i32, ptr %28, i64 %29
  %31 = load i32, ptr %30, align 4
  store i32 %31, ptr %5, align 4
  br label %32

32:                                               ; preds = %27
  %33 = load i64, ptr %8, align 8
  %34 = add i64 %33, -1
  store i64 %34, ptr %8, align 8
  br label %24, !llvm.loop !9

35:                                               ; preds = %24
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_negative_dependence_positive_step(ptr noalias noundef %0, i32 noundef %1, i64 noundef %2) #0 {
  %4 = alloca ptr, align 8
  %5 = alloca i32, align 4
  %6 = alloca i64, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store i32 %1, ptr %5, align 4
  store i64 %2, ptr %6, align 8
  store i64 0, ptr %7, align 8
  br label %9

9:                                                ; preds = %19, %3
  %10 = load i64, ptr %7, align 8
  %11 = load i64, ptr %6, align 8
  %12 = icmp ult i64 %10, %11
  br i1 %12, label %13, label %22

13:                                               ; preds = %9
  %14 = load i64, ptr %7, align 8
  %15 = trunc i64 %14 to i32
  %16 = load ptr, ptr %4, align 8
  %17 = load i64, ptr %7, align 8
  %18 = getelementptr inbounds i32, ptr %16, i64 %17
  store i32 %15, ptr %18, align 4
  br label %19

19:                                               ; preds = %13
  %20 = load i64, ptr %7, align 8
  %21 = add i64 %20, 1
  store i64 %21, ptr %7, align 8
  br label %9, !llvm.loop !10

22:                                               ; preds = %9
  store i64 0, ptr %8, align 8
  br label %23

23:                                               ; preds = %33, %22
  %24 = load i64, ptr %8, align 8
  %25 = load i64, ptr %6, align 8
  %26 = icmp ult i64 %24, %25
  br i1 %26, label %27, label %36

27:                                               ; preds = %23
  %28 = load ptr, ptr %4, align 8
  %29 = load i64, ptr %8, align 8
  %30 = add i64 %29, 1
  %31 = getelementptr inbounds i32, ptr %28, i64 %30
  %32 = load i32, ptr %31, align 4
  store i32 %32, ptr %5, align 4
  br label %33

33:                                               ; preds = %27
  %34 = load i64, ptr %8, align 8
  %35 = add i64 %34, 1
  store i64 %35, ptr %8, align 8
  br label %23, !llvm.loop !11

36:                                               ; preds = %23
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_positive_dependence_negative_step(ptr noalias noundef %0, i32 noundef %1, i64 noundef %2) #0 {
  %4 = alloca ptr, align 8
  %5 = alloca i32, align 4
  %6 = alloca i64, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store i32 %1, ptr %5, align 4
  store i64 %2, ptr %6, align 8
  %9 = load i64, ptr %6, align 8
  store i64 %9, ptr %7, align 8
  br label %10

10:                                               ; preds = %19, %3
  %11 = load i64, ptr %7, align 8
  %12 = icmp ugt i64 %11, 0
  br i1 %12, label %13, label %22

13:                                               ; preds = %10
  %14 = load i64, ptr %7, align 8
  %15 = trunc i64 %14 to i32
  %16 = load ptr, ptr %4, align 8
  %17 = load i64, ptr %7, align 8
  %18 = getelementptr inbounds i32, ptr %16, i64 %17
  store i32 %15, ptr %18, align 4
  br label %19

19:                                               ; preds = %13
  %20 = load i64, ptr %7, align 8
  %21 = add i64 %20, -1
  store i64 %21, ptr %7, align 8
  br label %10, !llvm.loop !12

22:                                               ; preds = %10
  %23 = load i64, ptr %6, align 8
  store i64 %23, ptr %8, align 8
  br label %24

24:                                               ; preds = %33, %22
  %25 = load i64, ptr %8, align 8
  %26 = icmp ugt i64 %25, 0
  br i1 %26, label %27, label %36

27:                                               ; preds = %24
  %28 = load ptr, ptr %4, align 8
  %29 = load i64, ptr %8, align 8
  %30 = sub i64 %29, 1
  %31 = getelementptr inbounds i32, ptr %28, i64 %30
  %32 = load i32, ptr %31, align 4
  store i32 %32, ptr %5, align 4
  br label %33

33:                                               ; preds = %27
  %34 = load i64, ptr %8, align 8
  %35 = add i64 %34, -1
  store i64 %35, ptr %8, align 8
  br label %24, !llvm.loop !13

36:                                               ; preds = %24
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_positive_dependence_positive_step(ptr noalias noundef %0, i32 noundef %1, i64 noundef %2) #0 {
  %4 = alloca ptr, align 8
  %5 = alloca i32, align 4
  %6 = alloca i64, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store i32 %1, ptr %5, align 4
  store i64 %2, ptr %6, align 8
  store i64 0, ptr %7, align 8
  br label %9

9:                                                ; preds = %19, %3
  %10 = load i64, ptr %7, align 8
  %11 = load i64, ptr %6, align 8
  %12 = icmp ult i64 %10, %11
  br i1 %12, label %13, label %22

13:                                               ; preds = %9
  %14 = load i64, ptr %7, align 8
  %15 = trunc i64 %14 to i32
  %16 = load ptr, ptr %4, align 8
  %17 = load i64, ptr %7, align 8
  %18 = getelementptr inbounds i32, ptr %16, i64 %17
  store i32 %15, ptr %18, align 4
  br label %19

19:                                               ; preds = %13
  %20 = load i64, ptr %7, align 8
  %21 = add i64 %20, 1
  store i64 %21, ptr %7, align 8
  br label %9, !llvm.loop !14

22:                                               ; preds = %9
  store i64 0, ptr %8, align 8
  br label %23

23:                                               ; preds = %33, %22
  %24 = load i64, ptr %8, align 8
  %25 = load i64, ptr %6, align 8
  %26 = icmp ult i64 %24, %25
  br i1 %26, label %27, label %36

27:                                               ; preds = %23
  %28 = load ptr, ptr %4, align 8
  %29 = load i64, ptr %8, align 8
  %30 = sub i64 %29, 1
  %31 = getelementptr inbounds i32, ptr %28, i64 %30
  %32 = load i32, ptr %31, align 4
  store i32 %32, ptr %5, align 4
  br label %33

33:                                               ; preds = %27
  %34 = load i64, ptr %8, align 8
  %35 = add i64 %34, 1
  store i64 %35, ptr %8, align 8
  br label %23, !llvm.loop !15

36:                                               ; preds = %23
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_negative_dependence_negative_step(ptr noalias noundef %0, i32 noundef %1, i64 noundef %2) #0 {
  %4 = alloca ptr, align 8
  %5 = alloca i32, align 4
  %6 = alloca i64, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store i32 %1, ptr %5, align 4
  store i64 %2, ptr %6, align 8
  %9 = load i64, ptr %6, align 8
  store i64 %9, ptr %7, align 8
  br label %10

10:                                               ; preds = %19, %3
  %11 = load i64, ptr %7, align 8
  %12 = icmp ugt i64 %11, 0
  br i1 %12, label %13, label %22

13:                                               ; preds = %10
  %14 = load i64, ptr %7, align 8
  %15 = trunc i64 %14 to i32
  %16 = load ptr, ptr %4, align 8
  %17 = load i64, ptr %7, align 8
  %18 = getelementptr inbounds i32, ptr %16, i64 %17
  store i32 %15, ptr %18, align 4
  br label %19

19:                                               ; preds = %13
  %20 = load i64, ptr %7, align 8
  %21 = add i64 %20, -1
  store i64 %21, ptr %7, align 8
  br label %10, !llvm.loop !16

22:                                               ; preds = %10
  %23 = load i64, ptr %6, align 8
  store i64 %23, ptr %8, align 8
  br label %24

24:                                               ; preds = %33, %22
  %25 = load i64, ptr %8, align 8
  %26 = icmp ugt i64 %25, 0
  br i1 %26, label %27, label %36

27:                                               ; preds = %24
  %28 = load ptr, ptr %4, align 8
  %29 = load i64, ptr %8, align 8
  %30 = add i64 %29, 1
  %31 = getelementptr inbounds i32, ptr %28, i64 %30
  %32 = load i32, ptr %31, align 4
  store i32 %32, ptr %5, align 4
  br label %33

33:                                               ; preds = %27
  %34 = load i64, ptr %8, align 8
  %35 = add i64 %34, -1
  store i64 %35, ptr %8, align 8
  br label %24, !llvm.loop !17

36:                                               ; preds = %24
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_different_trip_count(i32 noundef %0, i32 noundef %1, i64 noundef %2, i64 noundef %3) #0 {
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  %9 = alloca i64, align 8
  %10 = alloca i64, align 8
  store i32 %0, ptr %5, align 4
  store i32 %1, ptr %6, align 4
  store i64 %2, ptr %7, align 8
  store i64 %3, ptr %8, align 8
  store i64 0, ptr %9, align 8
  br label %11

11:                                               ; preds = %16, %4
  %12 = load i64, ptr %9, align 8
  %13 = load i64, ptr %7, align 8
  %14 = icmp ult i64 %12, %13
  br i1 %14, label %15, label %19

15:                                               ; preds = %11
  store i32 1, ptr %5, align 4
  br label %16

16:                                               ; preds = %15
  %17 = load i64, ptr %9, align 8
  %18 = add i64 %17, 1
  store i64 %18, ptr %9, align 8
  br label %11, !llvm.loop !18

19:                                               ; preds = %11
  store i64 0, ptr %10, align 8
  br label %20

20:                                               ; preds = %25, %19
  %21 = load i64, ptr %10, align 8
  %22 = load i64, ptr %8, align 8
  %23 = icmp ult i64 %21, %22
  br i1 %23, label %24, label %28

24:                                               ; preds = %20
  store i32 2, ptr %6, align 4
  br label %25

25:                                               ; preds = %24
  %26 = load i64, ptr %10, align 8
  %27 = add i64 %26, 1
  store i64 %27, ptr %10, align 8
  br label %20, !llvm.loop !19

28:                                               ; preds = %20
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_interleaved_code(i32 noundef %0, i32 noundef %1, i32 noundef %2, i64 noundef %3) #0 {
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i64, align 8
  %9 = alloca i64, align 8
  %10 = alloca i64, align 8
  store i32 %0, ptr %5, align 4
  store i32 %1, ptr %6, align 4
  store i32 %2, ptr %7, align 4
  store i64 %3, ptr %8, align 8
  store i64 0, ptr %9, align 8
  br label %11

11:                                               ; preds = %16, %4
  %12 = load i64, ptr %9, align 8
  %13 = load i64, ptr %8, align 8
  %14 = icmp ult i64 %12, %13
  br i1 %14, label %15, label %19

15:                                               ; preds = %11
  store i32 1, ptr %5, align 4
  br label %16

16:                                               ; preds = %15
  %17 = load i64, ptr %9, align 8
  %18 = add i64 %17, 1
  store i64 %18, ptr %9, align 8
  br label %11, !llvm.loop !20

19:                                               ; preds = %11
  %20 = load i32, ptr %5, align 4
  %21 = load i32, ptr %6, align 4
  %22 = add nsw i32 %20, %21
  store i32 %22, ptr %7, align 4
  store i64 0, ptr %10, align 8
  br label %23

23:                                               ; preds = %28, %19
  %24 = load i64, ptr %10, align 8
  %25 = load i64, ptr %8, align 8
  %26 = icmp ult i64 %24, %25
  br i1 %26, label %27, label %31

27:                                               ; preds = %23
  store i32 2, ptr %6, align 4
  br label %28

28:                                               ; preds = %27
  %29 = load i64, ptr %10, align 8
  %30 = add i64 %29, 1
  store i64 %30, ptr %10, align 8
  br label %23, !llvm.loop !21

31:                                               ; preds = %23
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_different_step(ptr noalias noundef %0, i64 noundef %1) #0 {
  %3 = alloca ptr, align 8
  %4 = alloca i64, align 8
  %5 = alloca i64, align 8
  %6 = alloca i64, align 8
  store ptr %0, ptr %3, align 8
  store i64 %1, ptr %4, align 8
  store i64 0, ptr %5, align 8
  br label %7

7:                                                ; preds = %15, %2
  %8 = load i64, ptr %5, align 8
  %9 = load i64, ptr %4, align 8
  %10 = icmp ult i64 %8, %9
  br i1 %10, label %11, label %18

11:                                               ; preds = %7
  %12 = load ptr, ptr %3, align 8
  %13 = load i64, ptr %5, align 8
  %14 = getelementptr inbounds i32, ptr %12, i64 %13
  store i32 1, ptr %14, align 4
  br label %15

15:                                               ; preds = %11
  %16 = load i64, ptr %5, align 8
  %17 = add i64 %16, 1
  store i64 %17, ptr %5, align 8
  br label %7, !llvm.loop !22

18:                                               ; preds = %7
  store i64 0, ptr %6, align 8
  br label %19

19:                                               ; preds = %28, %18
  %20 = load i64, ptr %6, align 8
  %21 = load i64, ptr %4, align 8
  %22 = icmp ult i64 %20, %21
  br i1 %22, label %23, label %31

23:                                               ; preds = %19
  %24 = load ptr, ptr %3, align 8
  %25 = load i64, ptr %6, align 8
  %26 = mul i64 %25, 2
  %27 = getelementptr inbounds i32, ptr %24, i64 %26
  store i32 2, ptr %27, align 4
  br label %28

28:                                               ; preds = %23
  %29 = load i64, ptr %6, align 8
  %30 = add i64 %29, 1
  store i64 %30, ptr %6, align 8
  br label %19, !llvm.loop !23

31:                                               ; preds = %19
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_read_after_read(ptr noalias noundef %0, i32 noundef %1, i32 noundef %2, i64 noundef %3) #0 {
  %5 = alloca ptr, align 8
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i64, align 8
  %9 = alloca i64, align 8
  %10 = alloca i64, align 8
  store ptr %0, ptr %5, align 8
  store i32 %1, ptr %6, align 4
  store i32 %2, ptr %7, align 4
  store i64 %3, ptr %8, align 8
  store i64 0, ptr %9, align 8
  br label %11

11:                                               ; preds = %20, %4
  %12 = load i64, ptr %9, align 8
  %13 = load i64, ptr %8, align 8
  %14 = icmp ult i64 %12, %13
  br i1 %14, label %15, label %23

15:                                               ; preds = %11
  %16 = load ptr, ptr %5, align 8
  %17 = load i64, ptr %9, align 8
  %18 = getelementptr inbounds i32, ptr %16, i64 %17
  %19 = load i32, ptr %18, align 4
  store i32 %19, ptr %6, align 4
  br label %20

20:                                               ; preds = %15
  %21 = load i64, ptr %9, align 8
  %22 = add i64 %21, 1
  store i64 %22, ptr %9, align 8
  br label %11, !llvm.loop !24

23:                                               ; preds = %11
  store i64 0, ptr %10, align 8
  br label %24

24:                                               ; preds = %34, %23
  %25 = load i64, ptr %10, align 8
  %26 = load i64, ptr %8, align 8
  %27 = icmp ult i64 %25, %26
  br i1 %27, label %28, label %37

28:                                               ; preds = %24
  %29 = load ptr, ptr %5, align 8
  %30 = load i64, ptr %10, align 8
  %31 = add i64 %30, 1
  %32 = getelementptr inbounds i32, ptr %29, i64 %31
  %33 = load i32, ptr %32, align 4
  store i32 %33, ptr %7, align 4
  br label %34

34:                                               ; preds = %28
  %35 = load i64, ptr %10, align 8
  %36 = add i64 %35, 1
  store i64 %36, ptr %10, align 8
  br label %24, !llvm.loop !25

37:                                               ; preds = %24
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_write_after_read(ptr noalias noundef %0, i32 noundef %1, i32 noundef %2, i64 noundef %3) #0 {
  %5 = alloca ptr, align 8
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i64, align 8
  %9 = alloca i64, align 8
  %10 = alloca i64, align 8
  store ptr %0, ptr %5, align 8
  store i32 %1, ptr %6, align 4
  store i32 %2, ptr %7, align 4
  store i64 %3, ptr %8, align 8
  store i64 0, ptr %9, align 8
  br label %11

11:                                               ; preds = %20, %4
  %12 = load i64, ptr %9, align 8
  %13 = load i64, ptr %8, align 8
  %14 = icmp ult i64 %12, %13
  br i1 %14, label %15, label %23

15:                                               ; preds = %11
  %16 = load ptr, ptr %5, align 8
  %17 = load i64, ptr %9, align 8
  %18 = getelementptr inbounds i32, ptr %16, i64 %17
  %19 = load i32, ptr %18, align 4
  store i32 %19, ptr %6, align 4
  br label %20

20:                                               ; preds = %15
  %21 = load i64, ptr %9, align 8
  %22 = add i64 %21, 1
  store i64 %22, ptr %9, align 8
  br label %11, !llvm.loop !26

23:                                               ; preds = %11
  store i64 0, ptr %10, align 8
  br label %24

24:                                               ; preds = %34, %23
  %25 = load i64, ptr %10, align 8
  %26 = load i64, ptr %8, align 8
  %27 = icmp ult i64 %25, %26
  br i1 %27, label %28, label %37

28:                                               ; preds = %24
  %29 = load i32, ptr %7, align 4
  %30 = load ptr, ptr %5, align 8
  %31 = load i64, ptr %10, align 8
  %32 = add i64 %31, 1
  %33 = getelementptr inbounds i32, ptr %30, i64 %32
  store i32 %29, ptr %33, align 4
  br label %34

34:                                               ; preds = %28
  %35 = load i64, ptr %10, align 8
  %36 = add i64 %35, 1
  store i64 %36, ptr %10, align 8
  br label %24, !llvm.loop !27

37:                                               ; preds = %24
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_write_after_write(ptr noalias noundef %0, i32 noundef %1, i32 noundef %2, i64 noundef %3) #0 {
  %5 = alloca ptr, align 8
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i64, align 8
  %9 = alloca i64, align 8
  %10 = alloca i64, align 8
  store ptr %0, ptr %5, align 8
  store i32 %1, ptr %6, align 4
  store i32 %2, ptr %7, align 4
  store i64 %3, ptr %8, align 8
  store i64 0, ptr %9, align 8
  br label %11

11:                                               ; preds = %20, %4
  %12 = load i64, ptr %9, align 8
  %13 = load i64, ptr %8, align 8
  %14 = icmp ult i64 %12, %13
  br i1 %14, label %15, label %23

15:                                               ; preds = %11
  %16 = load i32, ptr %6, align 4
  %17 = load ptr, ptr %5, align 8
  %18 = load i64, ptr %9, align 8
  %19 = getelementptr inbounds i32, ptr %17, i64 %18
  store i32 %16, ptr %19, align 4
  br label %20

20:                                               ; preds = %15
  %21 = load i64, ptr %9, align 8
  %22 = add i64 %21, 1
  store i64 %22, ptr %9, align 8
  br label %11, !llvm.loop !28

23:                                               ; preds = %11
  store i64 0, ptr %10, align 8
  br label %24

24:                                               ; preds = %34, %23
  %25 = load i64, ptr %10, align 8
  %26 = load i64, ptr %8, align 8
  %27 = icmp ult i64 %25, %26
  br i1 %27, label %28, label %37

28:                                               ; preds = %24
  %29 = load i32, ptr %7, align 4
  %30 = load ptr, ptr %5, align 8
  %31 = load i64, ptr %10, align 8
  %32 = add i64 %31, 1
  %33 = getelementptr inbounds i32, ptr %30, i64 %32
  store i32 %29, ptr %33, align 4
  br label %34

34:                                               ; preds = %28
  %35 = load i64, ptr %10, align 8
  %36 = add i64 %35, 1
  store i64 %36, ptr %10, align 8
  br label %24, !llvm.loop !29

37:                                               ; preds = %24
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_complex_access(ptr noalias noundef %0, i32 noundef %1, ptr noalias noundef %2, i64 noundef %3) #0 {
  %5 = alloca ptr, align 8
  %6 = alloca i32, align 4
  %7 = alloca ptr, align 8
  %8 = alloca i64, align 8
  %9 = alloca i64, align 8
  %10 = alloca i64, align 8
  store ptr %0, ptr %5, align 8
  store i32 %1, ptr %6, align 4
  store ptr %2, ptr %7, align 8
  store i64 %3, ptr %8, align 8
  store i64 0, ptr %9, align 8
  br label %11

11:                                               ; preds = %22, %4
  %12 = load i64, ptr %9, align 8
  %13 = load i64, ptr %8, align 8
  %14 = icmp ult i64 %12, %13
  br i1 %14, label %15, label %25

15:                                               ; preds = %11
  %16 = load ptr, ptr %5, align 8
  %17 = load ptr, ptr %7, align 8
  %18 = load i64, ptr %9, align 8
  %19 = getelementptr inbounds i64, ptr %17, i64 %18
  %20 = load i64, ptr %19, align 8
  %21 = getelementptr inbounds i32, ptr %16, i64 %20
  store i32 1, ptr %21, align 4
  br label %22

22:                                               ; preds = %15
  %23 = load i64, ptr %9, align 8
  %24 = add i64 %23, 1
  store i64 %24, ptr %9, align 8
  br label %11, !llvm.loop !30

25:                                               ; preds = %11
  store i64 0, ptr %10, align 8
  br label %26

26:                                               ; preds = %35, %25
  %27 = load i64, ptr %10, align 8
  %28 = load i64, ptr %8, align 8
  %29 = icmp ult i64 %27, %28
  br i1 %29, label %30, label %38

30:                                               ; preds = %26
  %31 = load ptr, ptr %5, align 8
  %32 = load i64, ptr %10, align 8
  %33 = getelementptr inbounds i32, ptr %31, i64 %32
  %34 = load i32, ptr %33, align 4
  store i32 %34, ptr %6, align 4
  br label %35

35:                                               ; preds = %30
  %36 = load i64, ptr %10, align 8
  %37 = add i64 %36, 1
  store i64 %37, ptr %10, align 8
  br label %26, !llvm.loop !31

38:                                               ; preds = %26
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_constant_access_1(ptr noalias noundef %0, i32 noundef %1, i64 noundef %2) #0 {
  %4 = alloca ptr, align 8
  %5 = alloca i32, align 4
  %6 = alloca i64, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store i32 %1, ptr %5, align 4
  store i64 %2, ptr %6, align 8
  store i64 0, ptr %7, align 8
  br label %9

9:                                                ; preds = %16, %3
  %10 = load i64, ptr %7, align 8
  %11 = load i64, ptr %6, align 8
  %12 = icmp ult i64 %10, %11
  br i1 %12, label %13, label %19

13:                                               ; preds = %9
  %14 = load ptr, ptr %4, align 8
  %15 = getelementptr inbounds i32, ptr %14, i64 0
  store i32 1, ptr %15, align 4
  br label %16

16:                                               ; preds = %13
  %17 = load i64, ptr %7, align 8
  %18 = add i64 %17, 1
  store i64 %18, ptr %7, align 8
  br label %9, !llvm.loop !32

19:                                               ; preds = %9
  store i64 0, ptr %8, align 8
  br label %20

20:                                               ; preds = %28, %19
  %21 = load i64, ptr %8, align 8
  %22 = load i64, ptr %6, align 8
  %23 = icmp ult i64 %21, %22
  br i1 %23, label %24, label %31

24:                                               ; preds = %20
  %25 = load ptr, ptr %4, align 8
  %26 = getelementptr inbounds i32, ptr %25, i64 1
  %27 = load i32, ptr %26, align 4
  store i32 %27, ptr %5, align 4
  br label %28

28:                                               ; preds = %24
  %29 = load i64, ptr %8, align 8
  %30 = add i64 %29, 1
  store i64 %30, ptr %8, align 8
  br label %20, !llvm.loop !33

31:                                               ; preds = %20
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_constant_access_2(ptr noalias noundef %0, i32 noundef %1, i64 noundef %2) #0 {
  %4 = alloca ptr, align 8
  %5 = alloca i32, align 4
  %6 = alloca i64, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store i32 %1, ptr %5, align 4
  store i64 %2, ptr %6, align 8
  store i64 0, ptr %7, align 8
  br label %9

9:                                                ; preds = %16, %3
  %10 = load i64, ptr %7, align 8
  %11 = load i64, ptr %6, align 8
  %12 = icmp ult i64 %10, %11
  br i1 %12, label %13, label %19

13:                                               ; preds = %9
  %14 = load ptr, ptr %4, align 8
  %15 = getelementptr inbounds i32, ptr %14, i64 0
  store i32 1, ptr %15, align 4
  br label %16

16:                                               ; preds = %13
  %17 = load i64, ptr %7, align 8
  %18 = add i64 %17, 1
  store i64 %18, ptr %7, align 8
  br label %9, !llvm.loop !34

19:                                               ; preds = %9
  store i64 0, ptr %8, align 8
  br label %20

20:                                               ; preds = %28, %19
  %21 = load i64, ptr %8, align 8
  %22 = load i64, ptr %6, align 8
  %23 = icmp ult i64 %21, %22
  br i1 %23, label %24, label %31

24:                                               ; preds = %20
  %25 = load ptr, ptr %4, align 8
  %26 = getelementptr inbounds i32, ptr %25, i64 0
  %27 = load i32, ptr %26, align 4
  store i32 %27, ptr %5, align 4
  br label %28

28:                                               ; preds = %24
  %29 = load i64, ptr %8, align 8
  %30 = add i64 %29, 1
  store i64 %30, ptr %8, align 8
  br label %20, !llvm.loop !35

31:                                               ; preds = %20
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_mixed_access(ptr noalias noundef %0, i32 noundef %1, i64 noundef %2) #0 {
  %4 = alloca ptr, align 8
  %5 = alloca i32, align 4
  %6 = alloca i64, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store i32 %1, ptr %5, align 4
  store i64 %2, ptr %6, align 8
  store i64 0, ptr %7, align 8
  br label %9

9:                                                ; preds = %16, %3
  %10 = load i64, ptr %7, align 8
  %11 = load i64, ptr %6, align 8
  %12 = icmp ult i64 %10, %11
  br i1 %12, label %13, label %19

13:                                               ; preds = %9
  %14 = load ptr, ptr %4, align 8
  %15 = getelementptr inbounds i32, ptr %14, i64 0
  store i32 1, ptr %15, align 4
  br label %16

16:                                               ; preds = %13
  %17 = load i64, ptr %7, align 8
  %18 = add i64 %17, 1
  store i64 %18, ptr %7, align 8
  br label %9, !llvm.loop !36

19:                                               ; preds = %9
  store i64 0, ptr %8, align 8
  br label %20

20:                                               ; preds = %29, %19
  %21 = load i64, ptr %8, align 8
  %22 = load i64, ptr %6, align 8
  %23 = icmp ult i64 %21, %22
  br i1 %23, label %24, label %32

24:                                               ; preds = %20
  %25 = load ptr, ptr %4, align 8
  %26 = load i64, ptr %8, align 8
  %27 = getelementptr inbounds i32, ptr %25, i64 %26
  %28 = load i32, ptr %27, align 4
  store i32 %28, ptr %5, align 4
  br label %29

29:                                               ; preds = %24
  %30 = load i64, ptr %8, align 8
  %31 = add i64 %30, 1
  store i64 %31, ptr %8, align 8
  br label %20, !llvm.loop !37

32:                                               ; preds = %20
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_same_guard(ptr noalias noundef %0, ptr noalias noundef %1, i64 noundef %2) #0 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store i64 %2, ptr %6, align 8
  %9 = load i64, ptr %6, align 8
  %10 = icmp ugt i64 %9, 0
  br i1 %10, label %11, label %23

11:                                               ; preds = %3
  store i64 0, ptr %7, align 8
  br label %12

12:                                               ; preds = %18, %11
  %13 = load ptr, ptr %4, align 8
  %14 = load i64, ptr %7, align 8
  %15 = getelementptr inbounds i32, ptr %13, i64 %14
  store i32 1, ptr %15, align 4
  %16 = load i64, ptr %7, align 8
  %17 = add i64 %16, 1
  store i64 %17, ptr %7, align 8
  br label %18

18:                                               ; preds = %12
  %19 = load i64, ptr %7, align 8
  %20 = load i64, ptr %6, align 8
  %21 = icmp ult i64 %19, %20
  br i1 %21, label %12, label %22, !llvm.loop !38

22:                                               ; preds = %18
  br label %23

23:                                               ; preds = %22, %3
  %24 = load i64, ptr %6, align 8
  %25 = icmp ugt i64 %24, 0
  br i1 %25, label %26, label %38

26:                                               ; preds = %23
  store i64 0, ptr %8, align 8
  br label %27

27:                                               ; preds = %33, %26
  %28 = load ptr, ptr %5, align 8
  %29 = load i64, ptr %8, align 8
  %30 = getelementptr inbounds i32, ptr %28, i64 %29
  store i32 1, ptr %30, align 4
  %31 = load i64, ptr %8, align 8
  %32 = add i64 %31, 1
  store i64 %32, ptr %8, align 8
  br label %33

33:                                               ; preds = %27
  %34 = load i64, ptr %8, align 8
  %35 = load i64, ptr %6, align 8
  %36 = icmp ult i64 %34, %35
  br i1 %36, label %27, label %37, !llvm.loop !39

37:                                               ; preds = %33
  br label %38

38:                                               ; preds = %37, %23
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_different_guards(ptr noalias noundef %0, ptr noalias noundef %1, i64 noundef %2, i64 noundef %3) #0 {
  %5 = alloca ptr, align 8
  %6 = alloca ptr, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  %9 = alloca i64, align 8
  %10 = alloca i64, align 8
  store ptr %0, ptr %5, align 8
  store ptr %1, ptr %6, align 8
  store i64 %2, ptr %7, align 8
  store i64 %3, ptr %8, align 8
  %11 = load i64, ptr %7, align 8
  %12 = icmp ugt i64 %11, 0
  br i1 %12, label %13, label %25

13:                                               ; preds = %4
  store i64 0, ptr %9, align 8
  br label %14

14:                                               ; preds = %20, %13
  %15 = load ptr, ptr %5, align 8
  %16 = load i64, ptr %9, align 8
  %17 = getelementptr inbounds i32, ptr %15, i64 %16
  store i32 1, ptr %17, align 4
  %18 = load i64, ptr %9, align 8
  %19 = add i64 %18, 1
  store i64 %19, ptr %9, align 8
  br label %20

20:                                               ; preds = %14
  %21 = load i64, ptr %9, align 8
  %22 = load i64, ptr %7, align 8
  %23 = icmp ult i64 %21, %22
  br i1 %23, label %14, label %24, !llvm.loop !40

24:                                               ; preds = %20
  br label %25

25:                                               ; preds = %24, %4
  %26 = load i64, ptr %8, align 8
  %27 = icmp ugt i64 %26, 0
  br i1 %27, label %28, label %40

28:                                               ; preds = %25
  store i64 0, ptr %10, align 8
  br label %29

29:                                               ; preds = %35, %28
  %30 = load ptr, ptr %6, align 8
  %31 = load i64, ptr %10, align 8
  %32 = getelementptr inbounds i32, ptr %30, i64 %31
  store i32 1, ptr %32, align 4
  %33 = load i64, ptr %10, align 8
  %34 = add i64 %33, 1
  store i64 %34, ptr %10, align 8
  br label %35

35:                                               ; preds = %29
  %36 = load i64, ptr %10, align 8
  %37 = load i64, ptr %8, align 8
  %38 = icmp ult i64 %36, %37
  br i1 %38, label %29, label %39, !llvm.loop !41

39:                                               ; preds = %35
  br label %40

40:                                               ; preds = %39, %25
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_iv_use_outside_loops_1(ptr noalias noundef %0, ptr noalias noundef %1, i64 noundef %2) #0 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  %9 = alloca i64, align 8
  %10 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store i64 %2, ptr %6, align 8
  store i64 0, ptr %7, align 8
  br label %11

11:                                               ; preds = %17, %3
  %12 = load ptr, ptr %4, align 8
  %13 = load i64, ptr %7, align 8
  %14 = getelementptr inbounds i32, ptr %12, i64 %13
  store i32 1, ptr %14, align 4
  %15 = load i64, ptr %7, align 8
  %16 = add i64 %15, 1
  store i64 %16, ptr %7, align 8
  br label %17

17:                                               ; preds = %11
  %18 = load i64, ptr %7, align 8
  %19 = load i64, ptr %6, align 8
  %20 = icmp ult i64 %18, %19
  br i1 %20, label %11, label %21, !llvm.loop !42

21:                                               ; preds = %17
  store i64 0, ptr %8, align 8
  br label %22

22:                                               ; preds = %28, %21
  %23 = load ptr, ptr %5, align 8
  %24 = load i64, ptr %8, align 8
  %25 = getelementptr inbounds i32, ptr %23, i64 %24
  store i32 1, ptr %25, align 4
  %26 = load i64, ptr %8, align 8
  %27 = add i64 %26, 1
  store i64 %27, ptr %8, align 8
  br label %28

28:                                               ; preds = %22
  %29 = load i64, ptr %8, align 8
  %30 = load i64, ptr %6, align 8
  %31 = icmp ult i64 %29, %30
  br i1 %31, label %22, label %32, !llvm.loop !43

32:                                               ; preds = %28
  %33 = load i64, ptr %7, align 8
  %34 = add i64 %33, 1
  store i64 %34, ptr %9, align 8
  %35 = load i64, ptr %8, align 8
  %36 = add i64 %35, 1
  store i64 %36, ptr %10, align 8
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_iv_use_outside_loops_2(ptr noalias noundef %0, ptr noalias noundef %1, i64 noundef %2) #0 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  %9 = alloca i64, align 8
  %10 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store i64 %2, ptr %6, align 8
  store i64 0, ptr %7, align 8
  br label %11

11:                                               ; preds = %15, %3
  %12 = load i64, ptr %7, align 8
  %13 = load i64, ptr %6, align 8
  %14 = icmp ult i64 %12, %13
  br i1 %14, label %15, label %21

15:                                               ; preds = %11
  %16 = load ptr, ptr %4, align 8
  %17 = load i64, ptr %7, align 8
  %18 = getelementptr inbounds i32, ptr %16, i64 %17
  store i32 1, ptr %18, align 4
  %19 = load i64, ptr %7, align 8
  %20 = add i64 %19, 1
  store i64 %20, ptr %7, align 8
  br label %11, !llvm.loop !44

21:                                               ; preds = %11
  store i64 0, ptr %8, align 8
  br label %22

22:                                               ; preds = %26, %21
  %23 = load i64, ptr %8, align 8
  %24 = load i64, ptr %6, align 8
  %25 = icmp ult i64 %23, %24
  br i1 %25, label %26, label %32

26:                                               ; preds = %22
  %27 = load ptr, ptr %5, align 8
  %28 = load i64, ptr %8, align 8
  %29 = getelementptr inbounds i32, ptr %27, i64 %28
  store i32 1, ptr %29, align 4
  %30 = load i64, ptr %8, align 8
  %31 = add i64 %30, 1
  store i64 %31, ptr %8, align 8
  br label %22, !llvm.loop !45

32:                                               ; preds = %22
  %33 = load i64, ptr %7, align 8
  %34 = add i64 %33, 1
  store i64 %34, ptr %9, align 8
  %35 = load i64, ptr %8, align 8
  %36 = add i64 %35, 1
  store i64 %36, ptr %10, align 8
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
!44 = distinct !{!44, !6}
!45 = distinct !{!45, !6}
