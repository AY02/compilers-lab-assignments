; ModuleID = 'example.c'
source_filename = "example.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local void @example() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  store i32 4, ptr %3, align 4
  store i32 0, ptr %4, align 4
  store i32 0, ptr %1, align 4
  %5 = load i32, ptr %3, align 4
  %6 = add nsw i32 %5, 0
  store i32 %6, ptr %1, align 4
  %7 = load i32, ptr %3, align 4
  %8 = add nsw i32 0, %7
  store i32 %8, ptr %1, align 4
  %9 = load i32, ptr %1, align 4
  %10 = add nsw i32 %9, 5
  store i32 %10, ptr %2, align 4
  %11 = load i32, ptr %4, align 4
  %12 = load i32, ptr %3, align 4
  %13 = add nsw i32 %11, %12
  store i32 %13, ptr %1, align 4
  %14 = load i32, ptr %1, align 4
  %15 = add nsw i32 %14, 5
  store i32 %15, ptr %2, align 4
  store i32 0, ptr %1, align 4
  %16 = load i32, ptr %3, align 4
  %17 = sub nsw i32 %16, 0
  store i32 %17, ptr %1, align 4
  %18 = load i32, ptr %1, align 4
  %19 = add nsw i32 %18, 5
  store i32 %19, ptr %2, align 4
  %20 = load i32, ptr %3, align 4
  %21 = sub nsw i32 0, %20
  store i32 %21, ptr %1, align 4
  %22 = load i32, ptr %1, align 4
  %23 = add nsw i32 %22, 5
  store i32 %23, ptr %2, align 4
  %24 = load i32, ptr %4, align 4
  %25 = load i32, ptr %3, align 4
  %26 = sub nsw i32 %24, %25
  store i32 %26, ptr %1, align 4
  store i32 4, ptr %1, align 4
  %27 = load i32, ptr %3, align 4
  %28 = mul nsw i32 %27, 1
  store i32 %28, ptr %1, align 4
  %29 = load i32, ptr %3, align 4
  %30 = mul nsw i32 1, %29
  store i32 %30, ptr %1, align 4
  %31 = load i32, ptr %1, align 4
  %32 = add nsw i32 %31, 5
  store i32 %32, ptr %2, align 4
  %33 = load i32, ptr %4, align 4
  %34 = load i32, ptr %3, align 4
  %35 = mul nsw i32 %33, %34
  store i32 %35, ptr %1, align 4
  %36 = load i32, ptr %1, align 4
  %37 = add nsw i32 %36, 5
  store i32 %37, ptr %2, align 4
  store i32 0, ptr %1, align 4
  %38 = load i32, ptr %1, align 4
  %39 = add nsw i32 %38, 5
  store i32 %39, ptr %2, align 4
  store i32 4, ptr %1, align 4
  %40 = load i32, ptr %3, align 4
  %41 = sdiv i32 %40, 1
  store i32 %41, ptr %1, align 4
  %42 = load i32, ptr %1, align 4
  %43 = add nsw i32 %42, 5
  store i32 %43, ptr %2, align 4
  %44 = load i32, ptr %3, align 4
  %45 = sdiv i32 1, %44
  store i32 %45, ptr %1, align 4
  %46 = load i32, ptr %4, align 4
  %47 = load i32, ptr %3, align 4
  %48 = sdiv i32 %46, %47
  store i32 %48, ptr %1, align 4
  %49 = load i32, ptr %1, align 4
  %50 = add nsw i32 %49, 5
  store i32 %50, ptr %2, align 4
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
