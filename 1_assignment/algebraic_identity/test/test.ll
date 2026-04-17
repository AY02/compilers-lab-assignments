; ModuleID = 'test.c'
source_filename = "test.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @add(i32 noundef %0, i32 noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  store i32 %0, ptr %3, align 4
  store i32 %1, ptr %4, align 4
  %9 = load i32, ptr %3, align 4
  %10 = add nsw i32 %9, 0
  store i32 %10, ptr %5, align 4
  %11 = load i32, ptr %3, align 4
  %12 = add nsw i32 0, %11
  store i32 %12, ptr %6, align 4
  %13 = load i32, ptr %3, align 4
  %14 = load i32, ptr %4, align 4
  %15 = add nsw i32 %13, %14
  store i32 %15, ptr %7, align 4
  %16 = load i32, ptr %5, align 4
  %17 = load i32, ptr %6, align 4
  %18 = add nsw i32 %16, %17
  %19 = load i32, ptr %7, align 4
  %20 = add nsw i32 %18, %19
  store i32 %20, ptr %8, align 4
  %21 = load i32, ptr %8, align 4
  ret i32 %21
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @sub(i32 noundef %0, i32 noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  store i32 %0, ptr %3, align 4
  store i32 %1, ptr %4, align 4
  %9 = load i32, ptr %3, align 4
  %10 = sub nsw i32 %9, 0
  store i32 %10, ptr %5, align 4
  %11 = load i32, ptr %3, align 4
  %12 = sub nsw i32 0, %11
  store i32 %12, ptr %6, align 4
  %13 = load i32, ptr %3, align 4
  %14 = load i32, ptr %4, align 4
  %15 = sub nsw i32 %13, %14
  store i32 %15, ptr %7, align 4
  %16 = load i32, ptr %5, align 4
  %17 = load i32, ptr %6, align 4
  %18 = add nsw i32 %16, %17
  %19 = load i32, ptr %7, align 4
  %20 = add nsw i32 %18, %19
  store i32 %20, ptr %8, align 4
  %21 = load i32, ptr %8, align 4
  ret i32 %21
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @mul(i32 noundef %0, i32 noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  store i32 %0, ptr %3, align 4
  store i32 %1, ptr %4, align 4
  %10 = load i32, ptr %3, align 4
  %11 = mul nsw i32 %10, 1
  store i32 %11, ptr %5, align 4
  %12 = load i32, ptr %3, align 4
  %13 = mul nsw i32 1, %12
  store i32 %13, ptr %6, align 4
  %14 = load i32, ptr %3, align 4
  %15 = mul nsw i32 %14, 0
  store i32 %15, ptr %7, align 4
  %16 = load i32, ptr %3, align 4
  %17 = load i32, ptr %4, align 4
  %18 = mul nsw i32 %16, %17
  store i32 %18, ptr %8, align 4
  %19 = load i32, ptr %5, align 4
  %20 = load i32, ptr %6, align 4
  %21 = add nsw i32 %19, %20
  %22 = load i32, ptr %7, align 4
  %23 = add nsw i32 %21, %22
  %24 = load i32, ptr %8, align 4
  %25 = add nsw i32 %23, %24
  store i32 %25, ptr %9, align 4
  %26 = load i32, ptr %9, align 4
  ret i32 %26
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @div(i32 noundef %0, i32 noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  store i32 %0, ptr %3, align 4
  store i32 %1, ptr %4, align 4
  %11 = load i32, ptr %3, align 4
  %12 = sdiv i32 %11, 1
  store i32 %12, ptr %5, align 4
  %13 = load i32, ptr %3, align 4
  %14 = sdiv i32 0, %13
  store i32 %14, ptr %6, align 4
  %15 = load i32, ptr %3, align 4
  %16 = sdiv i32 1, %15
  store i32 %16, ptr %7, align 4
  %17 = load i32, ptr %3, align 4
  %18 = load i32, ptr %4, align 4
  %19 = sdiv i32 %17, %18
  store i32 %19, ptr %8, align 4
  %20 = load i32, ptr %3, align 4
  %21 = sdiv i32 %20, 0
  store i32 %21, ptr %9, align 4
  %22 = load i32, ptr %5, align 4
  %23 = load i32, ptr %6, align 4
  %24 = add nsw i32 %22, %23
  %25 = load i32, ptr %7, align 4
  %26 = add nsw i32 %24, %25
  %27 = load i32, ptr %8, align 4
  %28 = add nsw i32 %26, %27
  %29 = load i32, ptr %9, align 4
  %30 = add nsw i32 %28, %29
  store i32 %30, ptr %10, align 4
  %31 = load i32, ptr %10, align 4
  ret i32 %31
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @nested(i32 noundef %0) #0 {
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  store i32 %0, ptr %2, align 4
  %6 = load i32, ptr %2, align 4
  %7 = add nsw i32 %6, 0
  store i32 %7, ptr %3, align 4
  %8 = load i32, ptr %3, align 4
  %9 = add nsw i32 %8, 0
  store i32 %9, ptr %4, align 4
  %10 = load i32, ptr %4, align 4
  %11 = add nsw i32 %10, 0
  store i32 %11, ptr %5, align 4
  %12 = load i32, ptr %5, align 4
  ret i32 %12
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
