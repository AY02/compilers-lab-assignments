; ModuleID = 'test/alessio_tests/test_multiple_loops.c'
source_filename = "test/alessio_tests/test_multiple_loops.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_deep_nesting(ptr noalias noundef %0, ptr noalias noundef %1, i32 noundef %2) #0 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  %11 = alloca i32, align 4
  %12 = alloca i32, align 4
  %13 = alloca i32, align 4
  %14 = alloca i32, align 4
  %15 = alloca i32, align 4
  %16 = alloca i32, align 4
  %17 = alloca i32, align 4
  %18 = alloca i32, align 4
  %19 = alloca i32, align 4
  %20 = alloca i32, align 4
  %21 = alloca i32, align 4
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store i32 %2, ptr %6, align 4
  store i32 0, ptr %7, align 4
  br label %22

22:                                               ; preds = %185, %3
  %23 = load i32, ptr %7, align 4
  %24 = load i32, ptr %6, align 4
  %25 = icmp slt i32 %23, %24
  br i1 %25, label %26, label %188

26:                                               ; preds = %22
  store i32 0, ptr %8, align 4
  br label %27

27:                                               ; preds = %102, %26
  %28 = load i32, ptr %8, align 4
  %29 = load i32, ptr %6, align 4
  %30 = icmp slt i32 %28, %29
  br i1 %30, label %31, label %105

31:                                               ; preds = %27
  store i32 0, ptr %9, align 4
  br label %32

32:                                               ; preds = %63, %31
  %33 = load i32, ptr %9, align 4
  %34 = load i32, ptr %6, align 4
  %35 = icmp slt i32 %33, %34
  br i1 %35, label %36, label %66

36:                                               ; preds = %32
  store i32 0, ptr %10, align 4
  br label %37

37:                                               ; preds = %46, %36
  %38 = load i32, ptr %10, align 4
  %39 = load i32, ptr %6, align 4
  %40 = icmp slt i32 %38, %39
  br i1 %40, label %41, label %49

41:                                               ; preds = %37
  %42 = load ptr, ptr %4, align 8
  %43 = load i32, ptr %10, align 4
  %44 = sext i32 %43 to i64
  %45 = getelementptr inbounds i32, ptr %42, i64 %44
  store i32 8, ptr %45, align 4
  br label %46

46:                                               ; preds = %41
  %47 = load i32, ptr %10, align 4
  %48 = add nsw i32 %47, 1
  store i32 %48, ptr %10, align 4
  br label %37, !llvm.loop !6

49:                                               ; preds = %37
  store i32 0, ptr %11, align 4
  br label %50

50:                                               ; preds = %59, %49
  %51 = load i32, ptr %11, align 4
  %52 = load i32, ptr %6, align 4
  %53 = icmp slt i32 %51, %52
  br i1 %53, label %54, label %62

54:                                               ; preds = %50
  %55 = load ptr, ptr %5, align 8
  %56 = load i32, ptr %11, align 4
  %57 = sext i32 %56 to i64
  %58 = getelementptr inbounds i32, ptr %55, i64 %57
  store i32 9, ptr %58, align 4
  br label %59

59:                                               ; preds = %54
  %60 = load i32, ptr %11, align 4
  %61 = add nsw i32 %60, 1
  store i32 %61, ptr %11, align 4
  br label %50, !llvm.loop !8

62:                                               ; preds = %50
  br label %63

63:                                               ; preds = %62
  %64 = load i32, ptr %9, align 4
  %65 = add nsw i32 %64, 1
  store i32 %65, ptr %9, align 4
  br label %32, !llvm.loop !9

66:                                               ; preds = %32
  store i32 0, ptr %12, align 4
  br label %67

67:                                               ; preds = %98, %66
  %68 = load i32, ptr %12, align 4
  %69 = load i32, ptr %6, align 4
  %70 = icmp slt i32 %68, %69
  br i1 %70, label %71, label %101

71:                                               ; preds = %67
  store i32 0, ptr %13, align 4
  br label %72

72:                                               ; preds = %81, %71
  %73 = load i32, ptr %13, align 4
  %74 = load i32, ptr %6, align 4
  %75 = icmp slt i32 %73, %74
  br i1 %75, label %76, label %84

76:                                               ; preds = %72
  %77 = load ptr, ptr %4, align 8
  %78 = load i32, ptr %13, align 4
  %79 = sext i32 %78 to i64
  %80 = getelementptr inbounds i32, ptr %77, i64 %79
  store i32 10, ptr %80, align 4
  br label %81

81:                                               ; preds = %76
  %82 = load i32, ptr %13, align 4
  %83 = add nsw i32 %82, 1
  store i32 %83, ptr %13, align 4
  br label %72, !llvm.loop !10

84:                                               ; preds = %72
  store i32 0, ptr %14, align 4
  br label %85

85:                                               ; preds = %94, %84
  %86 = load i32, ptr %14, align 4
  %87 = load i32, ptr %6, align 4
  %88 = icmp slt i32 %86, %87
  br i1 %88, label %89, label %97

89:                                               ; preds = %85
  %90 = load ptr, ptr %5, align 8
  %91 = load i32, ptr %14, align 4
  %92 = sext i32 %91 to i64
  %93 = getelementptr inbounds i32, ptr %90, i64 %92
  store i32 11, ptr %93, align 4
  br label %94

94:                                               ; preds = %89
  %95 = load i32, ptr %14, align 4
  %96 = add nsw i32 %95, 1
  store i32 %96, ptr %14, align 4
  br label %85, !llvm.loop !11

97:                                               ; preds = %85
  br label %98

98:                                               ; preds = %97
  %99 = load i32, ptr %12, align 4
  %100 = add nsw i32 %99, 1
  store i32 %100, ptr %12, align 4
  br label %67, !llvm.loop !12

101:                                              ; preds = %67
  br label %102

102:                                              ; preds = %101
  %103 = load i32, ptr %8, align 4
  %104 = add nsw i32 %103, 1
  store i32 %104, ptr %8, align 4
  br label %27, !llvm.loop !13

105:                                              ; preds = %27
  store i32 0, ptr %15, align 4
  br label %106

106:                                              ; preds = %181, %105
  %107 = load i32, ptr %15, align 4
  %108 = load i32, ptr %6, align 4
  %109 = icmp slt i32 %107, %108
  br i1 %109, label %110, label %184

110:                                              ; preds = %106
  store i32 0, ptr %16, align 4
  br label %111

111:                                              ; preds = %142, %110
  %112 = load i32, ptr %16, align 4
  %113 = load i32, ptr %6, align 4
  %114 = icmp slt i32 %112, %113
  br i1 %114, label %115, label %145

115:                                              ; preds = %111
  store i32 0, ptr %17, align 4
  br label %116

116:                                              ; preds = %125, %115
  %117 = load i32, ptr %17, align 4
  %118 = load i32, ptr %6, align 4
  %119 = icmp slt i32 %117, %118
  br i1 %119, label %120, label %128

120:                                              ; preds = %116
  %121 = load ptr, ptr %4, align 8
  %122 = load i32, ptr %17, align 4
  %123 = sext i32 %122 to i64
  %124 = getelementptr inbounds i32, ptr %121, i64 %123
  store i32 12, ptr %124, align 4
  br label %125

125:                                              ; preds = %120
  %126 = load i32, ptr %17, align 4
  %127 = add nsw i32 %126, 1
  store i32 %127, ptr %17, align 4
  br label %116, !llvm.loop !14

128:                                              ; preds = %116
  store i32 0, ptr %18, align 4
  br label %129

129:                                              ; preds = %138, %128
  %130 = load i32, ptr %18, align 4
  %131 = load i32, ptr %6, align 4
  %132 = icmp slt i32 %130, %131
  br i1 %132, label %133, label %141

133:                                              ; preds = %129
  %134 = load ptr, ptr %5, align 8
  %135 = load i32, ptr %18, align 4
  %136 = sext i32 %135 to i64
  %137 = getelementptr inbounds i32, ptr %134, i64 %136
  store i32 13, ptr %137, align 4
  br label %138

138:                                              ; preds = %133
  %139 = load i32, ptr %18, align 4
  %140 = add nsw i32 %139, 1
  store i32 %140, ptr %18, align 4
  br label %129, !llvm.loop !15

141:                                              ; preds = %129
  br label %142

142:                                              ; preds = %141
  %143 = load i32, ptr %16, align 4
  %144 = add nsw i32 %143, 1
  store i32 %144, ptr %16, align 4
  br label %111, !llvm.loop !16

145:                                              ; preds = %111
  store i32 0, ptr %19, align 4
  br label %146

146:                                              ; preds = %177, %145
  %147 = load i32, ptr %19, align 4
  %148 = load i32, ptr %6, align 4
  %149 = icmp slt i32 %147, %148
  br i1 %149, label %150, label %180

150:                                              ; preds = %146
  store i32 0, ptr %20, align 4
  br label %151

151:                                              ; preds = %160, %150
  %152 = load i32, ptr %20, align 4
  %153 = load i32, ptr %6, align 4
  %154 = icmp slt i32 %152, %153
  br i1 %154, label %155, label %163

155:                                              ; preds = %151
  %156 = load ptr, ptr %4, align 8
  %157 = load i32, ptr %20, align 4
  %158 = sext i32 %157 to i64
  %159 = getelementptr inbounds i32, ptr %156, i64 %158
  store i32 14, ptr %159, align 4
  br label %160

160:                                              ; preds = %155
  %161 = load i32, ptr %20, align 4
  %162 = add nsw i32 %161, 1
  store i32 %162, ptr %20, align 4
  br label %151, !llvm.loop !17

163:                                              ; preds = %151
  store i32 0, ptr %21, align 4
  br label %164

164:                                              ; preds = %173, %163
  %165 = load i32, ptr %21, align 4
  %166 = load i32, ptr %6, align 4
  %167 = icmp slt i32 %165, %166
  br i1 %167, label %168, label %176

168:                                              ; preds = %164
  %169 = load ptr, ptr %5, align 8
  %170 = load i32, ptr %21, align 4
  %171 = sext i32 %170 to i64
  %172 = getelementptr inbounds i32, ptr %169, i64 %171
  store i32 15, ptr %172, align 4
  br label %173

173:                                              ; preds = %168
  %174 = load i32, ptr %21, align 4
  %175 = add nsw i32 %174, 1
  store i32 %175, ptr %21, align 4
  br label %164, !llvm.loop !18

176:                                              ; preds = %164
  br label %177

177:                                              ; preds = %176
  %178 = load i32, ptr %19, align 4
  %179 = add nsw i32 %178, 1
  store i32 %179, ptr %19, align 4
  br label %146, !llvm.loop !19

180:                                              ; preds = %146
  br label %181

181:                                              ; preds = %180
  %182 = load i32, ptr %15, align 4
  %183 = add nsw i32 %182, 1
  store i32 %183, ptr %15, align 4
  br label %106, !llvm.loop !20

184:                                              ; preds = %106
  br label %185

185:                                              ; preds = %184
  %186 = load i32, ptr %7, align 4
  %187 = add nsw i32 %186, 1
  store i32 %187, ptr %7, align 4
  br label %22, !llvm.loop !21

188:                                              ; preds = %22
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_four_siblings(ptr noalias noundef %0, ptr noalias noundef %1, ptr noalias noundef %2, ptr noalias noundef %3, i32 noundef %4) #0 {
  %6 = alloca ptr, align 8
  %7 = alloca ptr, align 8
  %8 = alloca ptr, align 8
  %9 = alloca ptr, align 8
  %10 = alloca i32, align 4
  %11 = alloca i32, align 4
  %12 = alloca i32, align 4
  %13 = alloca i32, align 4
  %14 = alloca i32, align 4
  store ptr %0, ptr %6, align 8
  store ptr %1, ptr %7, align 8
  store ptr %2, ptr %8, align 8
  store ptr %3, ptr %9, align 8
  store i32 %4, ptr %10, align 4
  store i32 0, ptr %11, align 4
  br label %15

15:                                               ; preds = %24, %5
  %16 = load i32, ptr %11, align 4
  %17 = load i32, ptr %10, align 4
  %18 = icmp slt i32 %16, %17
  br i1 %18, label %19, label %27

19:                                               ; preds = %15
  %20 = load ptr, ptr %6, align 8
  %21 = load i32, ptr %11, align 4
  %22 = sext i32 %21 to i64
  %23 = getelementptr inbounds i32, ptr %20, i64 %22
  store i32 1, ptr %23, align 4
  br label %24

24:                                               ; preds = %19
  %25 = load i32, ptr %11, align 4
  %26 = add nsw i32 %25, 1
  store i32 %26, ptr %11, align 4
  br label %15, !llvm.loop !22

27:                                               ; preds = %15
  store i32 0, ptr %12, align 4
  br label %28

28:                                               ; preds = %37, %27
  %29 = load i32, ptr %12, align 4
  %30 = load i32, ptr %10, align 4
  %31 = icmp slt i32 %29, %30
  br i1 %31, label %32, label %40

32:                                               ; preds = %28
  %33 = load ptr, ptr %7, align 8
  %34 = load i32, ptr %12, align 4
  %35 = sext i32 %34 to i64
  %36 = getelementptr inbounds i32, ptr %33, i64 %35
  store i32 2, ptr %36, align 4
  br label %37

37:                                               ; preds = %32
  %38 = load i32, ptr %12, align 4
  %39 = add nsw i32 %38, 1
  store i32 %39, ptr %12, align 4
  br label %28, !llvm.loop !23

40:                                               ; preds = %28
  store i32 0, ptr %13, align 4
  br label %41

41:                                               ; preds = %50, %40
  %42 = load i32, ptr %13, align 4
  %43 = load i32, ptr %10, align 4
  %44 = icmp slt i32 %42, %43
  br i1 %44, label %45, label %53

45:                                               ; preds = %41
  %46 = load ptr, ptr %8, align 8
  %47 = load i32, ptr %13, align 4
  %48 = sext i32 %47 to i64
  %49 = getelementptr inbounds i32, ptr %46, i64 %48
  store i32 3, ptr %49, align 4
  br label %50

50:                                               ; preds = %45
  %51 = load i32, ptr %13, align 4
  %52 = add nsw i32 %51, 1
  store i32 %52, ptr %13, align 4
  br label %41, !llvm.loop !24

53:                                               ; preds = %41
  store i32 0, ptr %14, align 4
  br label %54

54:                                               ; preds = %63, %53
  %55 = load i32, ptr %14, align 4
  %56 = load i32, ptr %10, align 4
  %57 = icmp slt i32 %55, %56
  br i1 %57, label %58, label %66

58:                                               ; preds = %54
  %59 = load ptr, ptr %9, align 8
  %60 = load i32, ptr %14, align 4
  %61 = sext i32 %60 to i64
  %62 = getelementptr inbounds i32, ptr %59, i64 %61
  store i32 4, ptr %62, align 4
  br label %63

63:                                               ; preds = %58
  %64 = load i32, ptr %14, align 4
  %65 = add nsw i32 %64, 1
  store i32 %65, ptr %14, align 4
  br label %54, !llvm.loop !25

66:                                               ; preds = %54
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
