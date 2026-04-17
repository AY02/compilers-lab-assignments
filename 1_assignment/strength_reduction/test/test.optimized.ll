; ModuleID = 'test.m2r.ll'
source_filename = "test.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_mul(i32 noundef %0) #0 {
  %2 = mul nsw i32 %0, 8
  %3 = shl i32 %0, 3
  %4 = mul nsw i32 %0, 9
  %5 = shl i32 %0, 3
  %6 = add i32 %5, %0
  %7 = mul nsw i32 %0, 7
  %8 = shl i32 %0, 3
  %9 = sub i32 %8, %0
  %10 = mul nsw i32 15, %0
  %11 = shl i32 %0, 4
  %12 = sub i32 %11, %0
  %13 = mul nsw i32 %0, 6
  %14 = add nsw i32 %3, %6
  %15 = add nsw i32 %14, %9
  %16 = add nsw i32 %15, %12
  %17 = add nsw i32 %16, %13
  ret i32 %17
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_udiv(i32 noundef %0) #0 {
  %2 = udiv i32 %0, 4
  %3 = lshr i32 %0, 2
  %4 = udiv i32 %0, 7
  %5 = add i32 %3, %4
  ret i32 %5
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_sdiv(i32 noundef %0) #0 {
  %2 = sdiv i32 %0, 16
  %3 = icmp slt i32 %0, 0
  %4 = select i1 %3, i32 15, i32 0
  %5 = add i32 %0, %4
  %6 = ashr i32 %5, 4
  %7 = sdiv i32 %0, 3
  %8 = add nsw i32 %6, %7
  ret i32 %8
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_limit_cases(i32 noundef %0) #0 {
  %2 = mul nsw i32 %0, -8
  %3 = sdiv i32 %0, -4
  %4 = mul nsw i32 %0, 1
  %5 = shl i32 %0, 0
  %6 = add nsw i32 %2, %3
  %7 = add nsw i32 %6, %5
  ret i32 %7
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
