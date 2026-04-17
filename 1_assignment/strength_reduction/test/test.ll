; ModuleID = 'test.c'
source_filename = "test.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_mul(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  store i32 %0, ptr %2, align 4
  %8 = load i32, ptr %2, align 4
  %9 = mul nsw i32 %8, 8
  store i32 %9, ptr %3, align 4
  %10 = load i32, ptr %2, align 4
  %11 = mul nsw i32 %10, 9
  store i32 %11, ptr %4, align 4
  %12 = load i32, ptr %2, align 4
  %13 = mul nsw i32 %12, 7
  store i32 %13, ptr %5, align 4
  %14 = load i32, ptr %2, align 4
  %15 = mul nsw i32 15, %14
  store i32 %15, ptr %6, align 4
  %16 = load i32, ptr %2, align 4
  %17 = mul nsw i32 %16, 6
  store i32 %17, ptr %7, align 4
  %18 = load i32, ptr %3, align 4
  %19 = load i32, ptr %4, align 4
  %20 = add nsw i32 %18, %19
  %21 = load i32, ptr %5, align 4
  %22 = add nsw i32 %20, %21
  %23 = load i32, ptr %6, align 4
  %24 = add nsw i32 %22, %23
  %25 = load i32, ptr %7, align 4
  %26 = add nsw i32 %24, %25
  ret i32 %26
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_udiv(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  store i32 %0, ptr %2, align 4
  %5 = load i32, ptr %2, align 4
  %6 = udiv i32 %5, 4
  store i32 %6, ptr %3, align 4
  %7 = load i32, ptr %2, align 4
  %8 = udiv i32 %7, 7
  store i32 %8, ptr %4, align 4
  %9 = load i32, ptr %3, align 4
  %10 = load i32, ptr %4, align 4
  %11 = add i32 %9, %10
  ret i32 %11
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_sdiv(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  store i32 %0, ptr %2, align 4
  %5 = load i32, ptr %2, align 4
  %6 = sdiv i32 %5, 16
  store i32 %6, ptr %3, align 4
  %7 = load i32, ptr %2, align 4
  %8 = sdiv i32 %7, 3
  store i32 %8, ptr %4, align 4
  %9 = load i32, ptr %3, align 4
  %10 = load i32, ptr %4, align 4
  %11 = add nsw i32 %9, %10
  ret i32 %11
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_limit_cases(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  store i32 %0, ptr %2, align 4
  %6 = load i32, ptr %2, align 4
  %7 = mul nsw i32 %6, -8
  store i32 %7, ptr %3, align 4
  %8 = load i32, ptr %2, align 4
  %9 = sdiv i32 %8, -4
  store i32 %9, ptr %4, align 4
  %10 = load i32, ptr %2, align 4
  %11 = mul nsw i32 %10, 1
  store i32 %11, ptr %5, align 4
  %12 = load i32, ptr %3, align 4
  %13 = load i32, ptr %4, align 4
  %14 = add nsw i32 %12, %13
  %15 = load i32, ptr %5, align 4
  %16 = add nsw i32 %14, %15
  ret i32 %16
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
