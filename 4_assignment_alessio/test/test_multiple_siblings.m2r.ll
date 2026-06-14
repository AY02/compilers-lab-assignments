; ModuleID = 'test/test_multiple_siblings.O0.ll'
source_filename = "test/test_multiple_siblings.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx16.0.0"

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_multiple_siblings(ptr noalias noundef %0, ptr noalias noundef %1, ptr noalias noundef %2, ptr noalias noundef %3, i64 noundef %4) #0 {
  br label %6

6:                                                ; preds = %10, %5
  %.03 = phi i64 [ 0, %5 ], [ %11, %10 ]
  %7 = icmp ult i64 %.03, %4
  br i1 %7, label %8, label %12

8:                                                ; preds = %6
  %9 = getelementptr inbounds i32, ptr %0, i64 %.03
  store i32 1, ptr %9, align 4
  br label %10

10:                                               ; preds = %8
  %11 = add i64 %.03, 1
  br label %6, !llvm.loop !5

12:                                               ; preds = %6
  br label %13

13:                                               ; preds = %17, %12
  %.02 = phi i64 [ 0, %12 ], [ %18, %17 ]
  %14 = icmp ult i64 %.02, %4
  br i1 %14, label %15, label %19

15:                                               ; preds = %13
  %16 = getelementptr inbounds i32, ptr %1, i64 %.02
  store i32 2, ptr %16, align 4
  br label %17

17:                                               ; preds = %15
  %18 = add i64 %.02, 1
  br label %13, !llvm.loop !7

19:                                               ; preds = %13
  br label %20

20:                                               ; preds = %24, %19
  %.01 = phi i64 [ 0, %19 ], [ %25, %24 ]
  %21 = icmp ult i64 %.01, %4
  br i1 %21, label %22, label %26

22:                                               ; preds = %20
  %23 = getelementptr inbounds i32, ptr %2, i64 %.01
  store i32 3, ptr %23, align 4
  br label %24

24:                                               ; preds = %22
  %25 = add i64 %.01, 1
  br label %20, !llvm.loop !8

26:                                               ; preds = %20
  br label %27

27:                                               ; preds = %31, %26
  %.0 = phi i64 [ 0, %26 ], [ %32, %31 ]
  %28 = icmp ult i64 %.0, %4
  br i1 %28, label %29, label %33

29:                                               ; preds = %27
  %30 = getelementptr inbounds i32, ptr %3, i64 %.0
  store i32 4, ptr %30, align 4
  br label %31

31:                                               ; preds = %29
  %32 = add i64 %.0, 1
  br label %27, !llvm.loop !9

33:                                               ; preds = %27
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
