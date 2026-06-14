; ModuleID = 'test/test_nested_loops.m2r.ll'
source_filename = "test/test_nested_loops.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx16.0.0"

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_nested_loops(ptr noalias noundef %0, ptr noalias noundef %1, i64 noundef %2) #0 {
  br label %4

4:                                                ; preds = %99, %3
  %.03 = phi i64 [ 0, %3 ], [ %100, %99 ]
  %5 = icmp ult i64 %.03, %2
  br i1 %5, label %6, label %101

6:                                                ; preds = %4
  br label %7

7:                                                ; preds = %50, %6
  %.04 = phi i64 [ 0, %6 ], [ %51, %50 ]
  %8 = icmp ult i64 %.04, %2
  br i1 %8, label %9, label %52

9:                                                ; preds = %7
  br label %10

10:                                               ; preds = %27, %9
  %.05 = phi i64 [ 0, %9 ], [ %28, %27 ]
  %11 = icmp ult i64 %.05, %2
  br i1 %11, label %12, label %29

12:                                               ; preds = %10
  br label %13

13:                                               ; preds = %18, %12
  %.06 = phi i64 [ 0, %12 ], [ %19, %18 ]
  %14 = icmp ult i64 %.06, %2
  br i1 %14, label %15, label %26

15:                                               ; preds = %13
  %16 = getelementptr inbounds i32, ptr %0, i64 %.06
  store i32 8, ptr %16, align 4
  %17 = getelementptr inbounds i32, ptr %1, i64 %.06
  store i32 9, ptr %17, align 4
  br label %18

18:                                               ; preds = %15
  %19 = add i64 %.06, 1
  br label %13, !llvm.loop !5

20:                                               ; No predecessors!
  br label %21

21:                                               ; preds = %24, %20
  %.07 = phi i64 [ 0, %20 ], [ %25, %24 ]
  %22 = icmp ult i64 %.07, %2
  br label %23

23:                                               ; preds = %21
  br label %24

24:                                               ; preds = %23
  %25 = add i64 %.07, 1
  br label %21, !llvm.loop !7

26:                                               ; preds = %13
  br label %27

27:                                               ; preds = %26
  %28 = add i64 %.05, 1
  br label %10, !llvm.loop !8

29:                                               ; preds = %10
  br label %30

30:                                               ; preds = %47, %29
  %.08 = phi i64 [ 0, %29 ], [ %48, %47 ]
  %31 = icmp ult i64 %.08, %2
  br i1 %31, label %32, label %49

32:                                               ; preds = %30
  br label %33

33:                                               ; preds = %38, %32
  %.09 = phi i64 [ 0, %32 ], [ %39, %38 ]
  %34 = icmp ult i64 %.09, %2
  br i1 %34, label %35, label %46

35:                                               ; preds = %33
  %36 = getelementptr inbounds i32, ptr %0, i64 %.09
  store i32 10, ptr %36, align 4
  %37 = getelementptr inbounds i32, ptr %1, i64 %.09
  store i32 11, ptr %37, align 4
  br label %38

38:                                               ; preds = %35
  %39 = add i64 %.09, 1
  br label %33, !llvm.loop !9

40:                                               ; No predecessors!
  br label %41

41:                                               ; preds = %44, %40
  %.010 = phi i64 [ 0, %40 ], [ %45, %44 ]
  %42 = icmp ult i64 %.010, %2
  br label %43

43:                                               ; preds = %41
  br label %44

44:                                               ; preds = %43
  %45 = add i64 %.010, 1
  br label %41, !llvm.loop !10

46:                                               ; preds = %33
  br label %47

47:                                               ; preds = %46
  %48 = add i64 %.08, 1
  br label %30, !llvm.loop !11

49:                                               ; preds = %30
  br label %50

50:                                               ; preds = %49
  %51 = add i64 %.04, 1
  br label %7, !llvm.loop !12

52:                                               ; preds = %7
  br label %53

53:                                               ; preds = %96, %52
  %.011 = phi i64 [ 0, %52 ], [ %97, %96 ]
  %54 = icmp ult i64 %.011, %2
  br i1 %54, label %55, label %98

55:                                               ; preds = %53
  br label %56

56:                                               ; preds = %73, %55
  %.012 = phi i64 [ 0, %55 ], [ %74, %73 ]
  %57 = icmp ult i64 %.012, %2
  br i1 %57, label %58, label %75

58:                                               ; preds = %56
  br label %59

59:                                               ; preds = %64, %58
  %.013 = phi i64 [ 0, %58 ], [ %65, %64 ]
  %60 = icmp ult i64 %.013, %2
  br i1 %60, label %61, label %72

61:                                               ; preds = %59
  %62 = getelementptr inbounds i32, ptr %0, i64 %.013
  store i32 12, ptr %62, align 4
  %63 = getelementptr inbounds i32, ptr %1, i64 %.013
  store i32 13, ptr %63, align 4
  br label %64

64:                                               ; preds = %61
  %65 = add i64 %.013, 1
  br label %59, !llvm.loop !13

66:                                               ; No predecessors!
  br label %67

67:                                               ; preds = %70, %66
  %.014 = phi i64 [ 0, %66 ], [ %71, %70 ]
  %68 = icmp ult i64 %.014, %2
  br label %69

69:                                               ; preds = %67
  br label %70

70:                                               ; preds = %69
  %71 = add i64 %.014, 1
  br label %67, !llvm.loop !14

72:                                               ; preds = %59
  br label %73

73:                                               ; preds = %72
  %74 = add i64 %.012, 1
  br label %56, !llvm.loop !15

75:                                               ; preds = %56
  br label %76

76:                                               ; preds = %93, %75
  %.02 = phi i64 [ 0, %75 ], [ %94, %93 ]
  %77 = icmp ult i64 %.02, %2
  br i1 %77, label %78, label %95

78:                                               ; preds = %76
  br label %79

79:                                               ; preds = %84, %78
  %.01 = phi i64 [ 0, %78 ], [ %85, %84 ]
  %80 = icmp ult i64 %.01, %2
  br i1 %80, label %81, label %92

81:                                               ; preds = %79
  %82 = getelementptr inbounds i32, ptr %0, i64 %.01
  store i32 14, ptr %82, align 4
  %83 = getelementptr inbounds i32, ptr %1, i64 %.01
  store i32 15, ptr %83, align 4
  br label %84

84:                                               ; preds = %81
  %85 = add i64 %.01, 1
  br label %79, !llvm.loop !16

86:                                               ; No predecessors!
  br label %87

87:                                               ; preds = %90, %86
  %.0 = phi i64 [ 0, %86 ], [ %91, %90 ]
  %88 = icmp ult i64 %.0, %2
  br label %89

89:                                               ; preds = %87
  br label %90

90:                                               ; preds = %89
  %91 = add i64 %.0, 1
  br label %87, !llvm.loop !17

92:                                               ; preds = %79
  br label %93

93:                                               ; preds = %92
  %94 = add i64 %.02, 1
  br label %76, !llvm.loop !18

95:                                               ; preds = %76
  br label %96

96:                                               ; preds = %95
  %97 = add i64 %.011, 1
  br label %53, !llvm.loop !19

98:                                               ; preds = %53
  br label %99

99:                                               ; preds = %98
  %100 = add i64 %.03, 1
  br label %4, !llvm.loop !20

101:                                              ; preds = %4
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
