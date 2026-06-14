; ModuleID = 'test/test_multiple_siblings.c'
source_filename = "test/test_multiple_siblings.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx16.0.0"

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_multiple_siblings(ptr noalias noundef %0, ptr noalias noundef %1, ptr noalias noundef %2, ptr noalias noundef %3, i64 noundef %4) #0 {
  %6 = alloca ptr, align 8
  %7 = alloca ptr, align 8
  %8 = alloca ptr, align 8
  %9 = alloca ptr, align 8
  %10 = alloca i64, align 8
  %11 = alloca i64, align 8
  %12 = alloca i64, align 8
  %13 = alloca i64, align 8
  %14 = alloca i64, align 8
  store ptr %0, ptr %6, align 8
  store ptr %1, ptr %7, align 8
  store ptr %2, ptr %8, align 8
  store ptr %3, ptr %9, align 8
  store i64 %4, ptr %10, align 8
  store i64 0, ptr %11, align 8
  br label %15

15:                                               ; preds = %23, %5
  %16 = load i64, ptr %11, align 8
  %17 = load i64, ptr %10, align 8
  %18 = icmp ult i64 %16, %17
  br i1 %18, label %19, label %26

19:                                               ; preds = %15
  %20 = load ptr, ptr %6, align 8
  %21 = load i64, ptr %11, align 8
  %22 = getelementptr inbounds i32, ptr %20, i64 %21
  store i32 1, ptr %22, align 4
  br label %23

23:                                               ; preds = %19
  %24 = load i64, ptr %11, align 8
  %25 = add i64 %24, 1
  store i64 %25, ptr %11, align 8
  br label %15, !llvm.loop !5

26:                                               ; preds = %15
  store i64 0, ptr %12, align 8
  br label %27

27:                                               ; preds = %35, %26
  %28 = load i64, ptr %12, align 8
  %29 = load i64, ptr %10, align 8
  %30 = icmp ult i64 %28, %29
  br i1 %30, label %31, label %38

31:                                               ; preds = %27
  %32 = load ptr, ptr %7, align 8
  %33 = load i64, ptr %12, align 8
  %34 = getelementptr inbounds i32, ptr %32, i64 %33
  store i32 2, ptr %34, align 4
  br label %35

35:                                               ; preds = %31
  %36 = load i64, ptr %12, align 8
  %37 = add i64 %36, 1
  store i64 %37, ptr %12, align 8
  br label %27, !llvm.loop !7

38:                                               ; preds = %27
  store i64 0, ptr %13, align 8
  br label %39

39:                                               ; preds = %47, %38
  %40 = load i64, ptr %13, align 8
  %41 = load i64, ptr %10, align 8
  %42 = icmp ult i64 %40, %41
  br i1 %42, label %43, label %50

43:                                               ; preds = %39
  %44 = load ptr, ptr %8, align 8
  %45 = load i64, ptr %13, align 8
  %46 = getelementptr inbounds i32, ptr %44, i64 %45
  store i32 3, ptr %46, align 4
  br label %47

47:                                               ; preds = %43
  %48 = load i64, ptr %13, align 8
  %49 = add i64 %48, 1
  store i64 %49, ptr %13, align 8
  br label %39, !llvm.loop !8

50:                                               ; preds = %39
  store i64 0, ptr %14, align 8
  br label %51

51:                                               ; preds = %59, %50
  %52 = load i64, ptr %14, align 8
  %53 = load i64, ptr %10, align 8
  %54 = icmp ult i64 %52, %53
  br i1 %54, label %55, label %62

55:                                               ; preds = %51
  %56 = load ptr, ptr %9, align 8
  %57 = load i64, ptr %14, align 8
  %58 = getelementptr inbounds i32, ptr %56, i64 %57
  store i32 4, ptr %58, align 4
  br label %59

59:                                               ; preds = %55
  %60 = load i64, ptr %14, align 8
  %61 = add i64 %60, 1
  store i64 %61, ptr %14, align 8
  br label %51, !llvm.loop !9

62:                                               ; preds = %51
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
