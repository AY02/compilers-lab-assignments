; ModuleID = 'test/alessio_tests/test.nesting.m2r.ll'
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

13:                                               ; preds = %20, %12
  %.06 = phi i32 [ 0, %12 ], [ %21, %20 ]
  %14 = icmp slt i32 %.06, %2
  br i1 %14, label %15, label %28

15:                                               ; preds = %13
  %16 = sext i32 %.06 to i64
  %17 = getelementptr inbounds i32, ptr %0, i64 %16
  store i32 8, ptr %17, align 4
  %18 = sext i32 %.06 to i64
  %19 = getelementptr inbounds i32, ptr %1, i64 %18
  store i32 9, ptr %19, align 4
  br label %20

20:                                               ; preds = %15
  %21 = add nsw i32 %.06, 1
  br label %13, !llvm.loop !6

22:                                               ; No predecessors!
  br label %23

23:                                               ; preds = %26, %22
  %.07 = phi i32 [ 0, %22 ], [ %27, %26 ]
  %24 = icmp slt i32 %.07, %2
  br i1 %24, label %25, label %28

25:                                               ; preds = %23
  br label %26

26:                                               ; preds = %25
  %27 = add nsw i32 %.07, 1
  br label %23, !llvm.loop !8

28:                                               ; preds = %13, %23
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

35:                                               ; preds = %42, %34
  %.09 = phi i32 [ 0, %34 ], [ %43, %42 ]
  %36 = icmp slt i32 %.09, %2
  br i1 %36, label %37, label %50

37:                                               ; preds = %35
  %38 = sext i32 %.09 to i64
  %39 = getelementptr inbounds i32, ptr %0, i64 %38
  store i32 10, ptr %39, align 4
  %40 = sext i32 %.09 to i64
  %41 = getelementptr inbounds i32, ptr %1, i64 %40
  store i32 11, ptr %41, align 4
  br label %42

42:                                               ; preds = %37
  %43 = add nsw i32 %.09, 1
  br label %35, !llvm.loop !10

44:                                               ; No predecessors!
  br label %45

45:                                               ; preds = %48, %44
  %.010 = phi i32 [ 0, %44 ], [ %49, %48 ]
  %46 = icmp slt i32 %.010, %2
  br i1 %46, label %47, label %50

47:                                               ; preds = %45
  br label %48

48:                                               ; preds = %47
  %49 = add nsw i32 %.010, 1
  br label %45, !llvm.loop !11

50:                                               ; preds = %35, %45
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

63:                                               ; preds = %70, %62
  %.013 = phi i32 [ 0, %62 ], [ %71, %70 ]
  %64 = icmp slt i32 %.013, %2
  br i1 %64, label %65, label %78

65:                                               ; preds = %63
  %66 = sext i32 %.013 to i64
  %67 = getelementptr inbounds i32, ptr %0, i64 %66
  store i32 12, ptr %67, align 4
  %68 = sext i32 %.013 to i64
  %69 = getelementptr inbounds i32, ptr %1, i64 %68
  store i32 13, ptr %69, align 4
  br label %70

70:                                               ; preds = %65
  %71 = add nsw i32 %.013, 1
  br label %63, !llvm.loop !14

72:                                               ; No predecessors!
  br label %73

73:                                               ; preds = %76, %72
  %.014 = phi i32 [ 0, %72 ], [ %77, %76 ]
  %74 = icmp slt i32 %.014, %2
  br i1 %74, label %75, label %78

75:                                               ; preds = %73
  br label %76

76:                                               ; preds = %75
  %77 = add nsw i32 %.014, 1
  br label %73, !llvm.loop !15

78:                                               ; preds = %63, %73
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

85:                                               ; preds = %92, %84
  %.01 = phi i32 [ 0, %84 ], [ %93, %92 ]
  %86 = icmp slt i32 %.01, %2
  br i1 %86, label %87, label %100

87:                                               ; preds = %85
  %88 = sext i32 %.01 to i64
  %89 = getelementptr inbounds i32, ptr %0, i64 %88
  store i32 14, ptr %89, align 4
  %90 = sext i32 %.01 to i64
  %91 = getelementptr inbounds i32, ptr %1, i64 %90
  store i32 15, ptr %91, align 4
  br label %92

92:                                               ; preds = %87
  %93 = add nsw i32 %.01, 1
  br label %85, !llvm.loop !17

94:                                               ; No predecessors!
  br label %95

95:                                               ; preds = %98, %94
  %.0 = phi i32 [ 0, %94 ], [ %99, %98 ]
  %96 = icmp slt i32 %.0, %2
  br i1 %96, label %97, label %100

97:                                               ; preds = %95
  br label %98

98:                                               ; preds = %97
  %99 = add nsw i32 %.0, 1
  br label %95, !llvm.loop !18

100:                                              ; preds = %85, %95
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

6:                                                ; preds = %17, %5
  %.03 = phi i32 [ 0, %5 ], [ %18, %17 ]
  %7 = icmp slt i32 %.03, %4
  br i1 %7, label %8, label %37

8:                                                ; preds = %6
  %9 = sext i32 %.03 to i64
  %10 = getelementptr inbounds i32, ptr %0, i64 %9
  store i32 1, ptr %10, align 4
  %11 = sext i32 %.03 to i64
  %12 = getelementptr inbounds i32, ptr %1, i64 %11
  store i32 2, ptr %12, align 4
  %13 = sext i32 %.03 to i64
  %14 = getelementptr inbounds i32, ptr %2, i64 %13
  store i32 3, ptr %14, align 4
  %15 = sext i32 %.03 to i64
  %16 = getelementptr inbounds i32, ptr %3, i64 %15
  store i32 4, ptr %16, align 4
  br label %17

17:                                               ; preds = %8
  %18 = add nsw i32 %.03, 1
  br label %6, !llvm.loop !22

19:                                               ; No predecessors!
  br label %20

20:                                               ; preds = %23, %19
  %.02 = phi i32 [ 0, %19 ], [ %24, %23 ]
  %21 = icmp slt i32 %.02, %4
  br i1 %21, label %22, label %31

22:                                               ; preds = %20
  br label %23

23:                                               ; preds = %22
  %24 = add nsw i32 %.02, 1
  br label %20, !llvm.loop !23

25:                                               ; No predecessors!
  br label %26

26:                                               ; preds = %29, %25
  %.01 = phi i32 [ 0, %25 ], [ %30, %29 ]
  %27 = icmp slt i32 %.01, %4
  br i1 %27, label %28, label %31

28:                                               ; preds = %26
  br label %29

29:                                               ; preds = %28
  %30 = add nsw i32 %.01, 1
  br label %26, !llvm.loop !24

31:                                               ; preds = %20, %26
  br label %32

32:                                               ; preds = %35, %31
  %.0 = phi i32 [ 0, %31 ], [ %36, %35 ]
  %33 = icmp slt i32 %.0, %4
  br i1 %33, label %34, label %37

34:                                               ; preds = %32
  br label %35

35:                                               ; preds = %34
  %36 = add nsw i32 %.0, 1
  br label %32, !llvm.loop !25

37:                                               ; preds = %6, %32
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
