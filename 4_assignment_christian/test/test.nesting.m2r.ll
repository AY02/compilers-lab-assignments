; ModuleID = 'test/alessio_tests/test.nesting.O0.ll'
source_filename = "test/alessio_tests/test_multiple_loops.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_deep_nesting(ptr noalias noundef %0, ptr noalias noundef %1, i32 noundef %2) #0 {
  br label %4

4:                                                ; preds = %107, %3
  %.03 = phi i32 [ 0, %3 ], [ %108, %107 ]
  %5 = icmp slt i32 %.03, %2
  br i1 %5, label %6, label %109

6:                                                ; preds = %4
  br label %7

7:                                                ; preds = %54, %6
  %.04 = phi i32 [ 0, %6 ], [ %55, %54 ]
  %8 = icmp slt i32 %.04, %2
  br i1 %8, label %9, label %56

9:                                                ; preds = %7
  br label %10

10:                                               ; preds = %29, %9
  %.05 = phi i32 [ 0, %9 ], [ %30, %29 ]
  %11 = icmp slt i32 %.05, %2
  br i1 %11, label %12, label %31

12:                                               ; preds = %10
  br label %13

13:                                               ; preds = %18, %12
  %.06 = phi i32 [ 0, %12 ], [ %19, %18 ]
  %14 = icmp slt i32 %.06, %2
  br i1 %14, label %15, label %20

15:                                               ; preds = %13
  %16 = sext i32 %.06 to i64
  %17 = getelementptr inbounds i32, ptr %0, i64 %16
  store i32 8, ptr %17, align 4
  br label %18

18:                                               ; preds = %15
  %19 = add nsw i32 %.06, 1
  br label %13, !llvm.loop !6

20:                                               ; preds = %13
  br label %21

21:                                               ; preds = %26, %20
  %.07 = phi i32 [ 0, %20 ], [ %27, %26 ]
  %22 = icmp slt i32 %.07, %2
  br i1 %22, label %23, label %28

23:                                               ; preds = %21
  %24 = sext i32 %.07 to i64
  %25 = getelementptr inbounds i32, ptr %1, i64 %24
  store i32 9, ptr %25, align 4
  br label %26

26:                                               ; preds = %23
  %27 = add nsw i32 %.07, 1
  br label %21, !llvm.loop !8

28:                                               ; preds = %21
  br label %29

29:                                               ; preds = %28
  %30 = add nsw i32 %.05, 1
  br label %10, !llvm.loop !9

31:                                               ; preds = %10
  br label %32

32:                                               ; preds = %51, %31
  %.08 = phi i32 [ 0, %31 ], [ %52, %51 ]
  %33 = icmp slt i32 %.08, %2
  br i1 %33, label %34, label %53

34:                                               ; preds = %32
  br label %35

35:                                               ; preds = %40, %34
  %.09 = phi i32 [ 0, %34 ], [ %41, %40 ]
  %36 = icmp slt i32 %.09, %2
  br i1 %36, label %37, label %42

37:                                               ; preds = %35
  %38 = sext i32 %.09 to i64
  %39 = getelementptr inbounds i32, ptr %0, i64 %38
  store i32 10, ptr %39, align 4
  br label %40

40:                                               ; preds = %37
  %41 = add nsw i32 %.09, 1
  br label %35, !llvm.loop !10

42:                                               ; preds = %35
  br label %43

43:                                               ; preds = %48, %42
  %.010 = phi i32 [ 0, %42 ], [ %49, %48 ]
  %44 = icmp slt i32 %.010, %2
  br i1 %44, label %45, label %50

45:                                               ; preds = %43
  %46 = sext i32 %.010 to i64
  %47 = getelementptr inbounds i32, ptr %1, i64 %46
  store i32 11, ptr %47, align 4
  br label %48

48:                                               ; preds = %45
  %49 = add nsw i32 %.010, 1
  br label %43, !llvm.loop !11

50:                                               ; preds = %43
  br label %51

51:                                               ; preds = %50
  %52 = add nsw i32 %.08, 1
  br label %32, !llvm.loop !12

53:                                               ; preds = %32
  br label %54

54:                                               ; preds = %53
  %55 = add nsw i32 %.04, 1
  br label %7, !llvm.loop !13

56:                                               ; preds = %7
  br label %57

57:                                               ; preds = %104, %56
  %.011 = phi i32 [ 0, %56 ], [ %105, %104 ]
  %58 = icmp slt i32 %.011, %2
  br i1 %58, label %59, label %106

59:                                               ; preds = %57
  br label %60

60:                                               ; preds = %79, %59
  %.012 = phi i32 [ 0, %59 ], [ %80, %79 ]
  %61 = icmp slt i32 %.012, %2
  br i1 %61, label %62, label %81

62:                                               ; preds = %60
  br label %63

63:                                               ; preds = %68, %62
  %.013 = phi i32 [ 0, %62 ], [ %69, %68 ]
  %64 = icmp slt i32 %.013, %2
  br i1 %64, label %65, label %70

65:                                               ; preds = %63
  %66 = sext i32 %.013 to i64
  %67 = getelementptr inbounds i32, ptr %0, i64 %66
  store i32 12, ptr %67, align 4
  br label %68

68:                                               ; preds = %65
  %69 = add nsw i32 %.013, 1
  br label %63, !llvm.loop !14

70:                                               ; preds = %63
  br label %71

71:                                               ; preds = %76, %70
  %.014 = phi i32 [ 0, %70 ], [ %77, %76 ]
  %72 = icmp slt i32 %.014, %2
  br i1 %72, label %73, label %78

73:                                               ; preds = %71
  %74 = sext i32 %.014 to i64
  %75 = getelementptr inbounds i32, ptr %1, i64 %74
  store i32 13, ptr %75, align 4
  br label %76

76:                                               ; preds = %73
  %77 = add nsw i32 %.014, 1
  br label %71, !llvm.loop !15

78:                                               ; preds = %71
  br label %79

79:                                               ; preds = %78
  %80 = add nsw i32 %.012, 1
  br label %60, !llvm.loop !16

81:                                               ; preds = %60
  br label %82

82:                                               ; preds = %101, %81
  %.02 = phi i32 [ 0, %81 ], [ %102, %101 ]
  %83 = icmp slt i32 %.02, %2
  br i1 %83, label %84, label %103

84:                                               ; preds = %82
  br label %85

85:                                               ; preds = %90, %84
  %.01 = phi i32 [ 0, %84 ], [ %91, %90 ]
  %86 = icmp slt i32 %.01, %2
  br i1 %86, label %87, label %92

87:                                               ; preds = %85
  %88 = sext i32 %.01 to i64
  %89 = getelementptr inbounds i32, ptr %0, i64 %88
  store i32 14, ptr %89, align 4
  br label %90

90:                                               ; preds = %87
  %91 = add nsw i32 %.01, 1
  br label %85, !llvm.loop !17

92:                                               ; preds = %85
  br label %93

93:                                               ; preds = %98, %92
  %.0 = phi i32 [ 0, %92 ], [ %99, %98 ]
  %94 = icmp slt i32 %.0, %2
  br i1 %94, label %95, label %100

95:                                               ; preds = %93
  %96 = sext i32 %.0 to i64
  %97 = getelementptr inbounds i32, ptr %1, i64 %96
  store i32 15, ptr %97, align 4
  br label %98

98:                                               ; preds = %95
  %99 = add nsw i32 %.0, 1
  br label %93, !llvm.loop !18

100:                                              ; preds = %93
  br label %101

101:                                              ; preds = %100
  %102 = add nsw i32 %.02, 1
  br label %82, !llvm.loop !19

103:                                              ; preds = %82
  br label %104

104:                                              ; preds = %103
  %105 = add nsw i32 %.011, 1
  br label %57, !llvm.loop !20

106:                                              ; preds = %57
  br label %107

107:                                              ; preds = %106
  %108 = add nsw i32 %.03, 1
  br label %4, !llvm.loop !21

109:                                              ; preds = %4
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_four_siblings(ptr noalias noundef %0, ptr noalias noundef %1, ptr noalias noundef %2, ptr noalias noundef %3, i32 noundef %4) #0 {
  br label %6

6:                                                ; preds = %11, %5
  %.03 = phi i32 [ 0, %5 ], [ %12, %11 ]
  %7 = icmp slt i32 %.03, %4
  br i1 %7, label %8, label %13

8:                                                ; preds = %6
  %9 = sext i32 %.03 to i64
  %10 = getelementptr inbounds i32, ptr %0, i64 %9
  store i32 1, ptr %10, align 4
  br label %11

11:                                               ; preds = %8
  %12 = add nsw i32 %.03, 1
  br label %6, !llvm.loop !22

13:                                               ; preds = %6
  br label %14

14:                                               ; preds = %19, %13
  %.02 = phi i32 [ 0, %13 ], [ %20, %19 ]
  %15 = icmp slt i32 %.02, %4
  br i1 %15, label %16, label %21

16:                                               ; preds = %14
  %17 = sext i32 %.02 to i64
  %18 = getelementptr inbounds i32, ptr %1, i64 %17
  store i32 2, ptr %18, align 4
  br label %19

19:                                               ; preds = %16
  %20 = add nsw i32 %.02, 1
  br label %14, !llvm.loop !23

21:                                               ; preds = %14
  br label %22

22:                                               ; preds = %27, %21
  %.01 = phi i32 [ 0, %21 ], [ %28, %27 ]
  %23 = icmp slt i32 %.01, %4
  br i1 %23, label %24, label %29

24:                                               ; preds = %22
  %25 = sext i32 %.01 to i64
  %26 = getelementptr inbounds i32, ptr %2, i64 %25
  store i32 3, ptr %26, align 4
  br label %27

27:                                               ; preds = %24
  %28 = add nsw i32 %.01, 1
  br label %22, !llvm.loop !24

29:                                               ; preds = %22
  br label %30

30:                                               ; preds = %35, %29
  %.0 = phi i32 [ 0, %29 ], [ %36, %35 ]
  %31 = icmp slt i32 %.0, %4
  br i1 %31, label %32, label %37

32:                                               ; preds = %30
  %33 = sext i32 %.0 to i64
  %34 = getelementptr inbounds i32, ptr %3, i64 %33
  store i32 4, ptr %34, align 4
  br label %35

35:                                               ; preds = %32
  %36 = add nsw i32 %.0, 1
  br label %30, !llvm.loop !25

37:                                               ; preds = %30
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
