; ModuleID = 'test/test_nested_loops.c'
source_filename = "test/test_nested_loops.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx16.0.0"

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test_nested_loops(ptr noalias noundef %0, ptr noalias noundef %1, i64 noundef %2) #0 {
  %4 = alloca ptr, align 8
  %5 = alloca ptr, align 8
  %6 = alloca i64, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  %9 = alloca i64, align 8
  %10 = alloca i64, align 8
  %11 = alloca i64, align 8
  %12 = alloca i64, align 8
  %13 = alloca i64, align 8
  %14 = alloca i64, align 8
  %15 = alloca i64, align 8
  %16 = alloca i64, align 8
  %17 = alloca i64, align 8
  %18 = alloca i64, align 8
  %19 = alloca i64, align 8
  %20 = alloca i64, align 8
  %21 = alloca i64, align 8
  store ptr %0, ptr %4, align 8
  store ptr %1, ptr %5, align 8
  store i64 %2, ptr %6, align 8
  store i64 0, ptr %7, align 8
  br label %22

22:                                               ; preds = %177, %3
  %23 = load i64, ptr %7, align 8
  %24 = load i64, ptr %6, align 8
  %25 = icmp ult i64 %23, %24
  br i1 %25, label %26, label %180

26:                                               ; preds = %22
  store i64 0, ptr %8, align 8
  br label %27

27:                                               ; preds = %98, %26
  %28 = load i64, ptr %8, align 8
  %29 = load i64, ptr %6, align 8
  %30 = icmp ult i64 %28, %29
  br i1 %30, label %31, label %101

31:                                               ; preds = %27
  store i64 0, ptr %9, align 8
  br label %32

32:                                               ; preds = %61, %31
  %33 = load i64, ptr %9, align 8
  %34 = load i64, ptr %6, align 8
  %35 = icmp ult i64 %33, %34
  br i1 %35, label %36, label %64

36:                                               ; preds = %32
  store i64 0, ptr %10, align 8
  br label %37

37:                                               ; preds = %45, %36
  %38 = load i64, ptr %10, align 8
  %39 = load i64, ptr %6, align 8
  %40 = icmp ult i64 %38, %39
  br i1 %40, label %41, label %48

41:                                               ; preds = %37
  %42 = load ptr, ptr %4, align 8
  %43 = load i64, ptr %10, align 8
  %44 = getelementptr inbounds i32, ptr %42, i64 %43
  store i32 8, ptr %44, align 4
  br label %45

45:                                               ; preds = %41
  %46 = load i64, ptr %10, align 8
  %47 = add i64 %46, 1
  store i64 %47, ptr %10, align 8
  br label %37, !llvm.loop !5

48:                                               ; preds = %37
  store i64 0, ptr %11, align 8
  br label %49

49:                                               ; preds = %57, %48
  %50 = load i64, ptr %11, align 8
  %51 = load i64, ptr %6, align 8
  %52 = icmp ult i64 %50, %51
  br i1 %52, label %53, label %60

53:                                               ; preds = %49
  %54 = load ptr, ptr %5, align 8
  %55 = load i64, ptr %11, align 8
  %56 = getelementptr inbounds i32, ptr %54, i64 %55
  store i32 9, ptr %56, align 4
  br label %57

57:                                               ; preds = %53
  %58 = load i64, ptr %11, align 8
  %59 = add i64 %58, 1
  store i64 %59, ptr %11, align 8
  br label %49, !llvm.loop !7

60:                                               ; preds = %49
  br label %61

61:                                               ; preds = %60
  %62 = load i64, ptr %9, align 8
  %63 = add i64 %62, 1
  store i64 %63, ptr %9, align 8
  br label %32, !llvm.loop !8

64:                                               ; preds = %32
  store i64 0, ptr %12, align 8
  br label %65

65:                                               ; preds = %94, %64
  %66 = load i64, ptr %12, align 8
  %67 = load i64, ptr %6, align 8
  %68 = icmp ult i64 %66, %67
  br i1 %68, label %69, label %97

69:                                               ; preds = %65
  store i64 0, ptr %13, align 8
  br label %70

70:                                               ; preds = %78, %69
  %71 = load i64, ptr %13, align 8
  %72 = load i64, ptr %6, align 8
  %73 = icmp ult i64 %71, %72
  br i1 %73, label %74, label %81

74:                                               ; preds = %70
  %75 = load ptr, ptr %4, align 8
  %76 = load i64, ptr %13, align 8
  %77 = getelementptr inbounds i32, ptr %75, i64 %76
  store i32 10, ptr %77, align 4
  br label %78

78:                                               ; preds = %74
  %79 = load i64, ptr %13, align 8
  %80 = add i64 %79, 1
  store i64 %80, ptr %13, align 8
  br label %70, !llvm.loop !9

81:                                               ; preds = %70
  store i64 0, ptr %14, align 8
  br label %82

82:                                               ; preds = %90, %81
  %83 = load i64, ptr %14, align 8
  %84 = load i64, ptr %6, align 8
  %85 = icmp ult i64 %83, %84
  br i1 %85, label %86, label %93

86:                                               ; preds = %82
  %87 = load ptr, ptr %5, align 8
  %88 = load i64, ptr %14, align 8
  %89 = getelementptr inbounds i32, ptr %87, i64 %88
  store i32 11, ptr %89, align 4
  br label %90

90:                                               ; preds = %86
  %91 = load i64, ptr %14, align 8
  %92 = add i64 %91, 1
  store i64 %92, ptr %14, align 8
  br label %82, !llvm.loop !10

93:                                               ; preds = %82
  br label %94

94:                                               ; preds = %93
  %95 = load i64, ptr %12, align 8
  %96 = add i64 %95, 1
  store i64 %96, ptr %12, align 8
  br label %65, !llvm.loop !11

97:                                               ; preds = %65
  br label %98

98:                                               ; preds = %97
  %99 = load i64, ptr %8, align 8
  %100 = add i64 %99, 1
  store i64 %100, ptr %8, align 8
  br label %27, !llvm.loop !12

101:                                              ; preds = %27
  store i64 0, ptr %15, align 8
  br label %102

102:                                              ; preds = %173, %101
  %103 = load i64, ptr %15, align 8
  %104 = load i64, ptr %6, align 8
  %105 = icmp ult i64 %103, %104
  br i1 %105, label %106, label %176

106:                                              ; preds = %102
  store i64 0, ptr %16, align 8
  br label %107

107:                                              ; preds = %136, %106
  %108 = load i64, ptr %16, align 8
  %109 = load i64, ptr %6, align 8
  %110 = icmp ult i64 %108, %109
  br i1 %110, label %111, label %139

111:                                              ; preds = %107
  store i64 0, ptr %17, align 8
  br label %112

112:                                              ; preds = %120, %111
  %113 = load i64, ptr %17, align 8
  %114 = load i64, ptr %6, align 8
  %115 = icmp ult i64 %113, %114
  br i1 %115, label %116, label %123

116:                                              ; preds = %112
  %117 = load ptr, ptr %4, align 8
  %118 = load i64, ptr %17, align 8
  %119 = getelementptr inbounds i32, ptr %117, i64 %118
  store i32 12, ptr %119, align 4
  br label %120

120:                                              ; preds = %116
  %121 = load i64, ptr %17, align 8
  %122 = add i64 %121, 1
  store i64 %122, ptr %17, align 8
  br label %112, !llvm.loop !13

123:                                              ; preds = %112
  store i64 0, ptr %18, align 8
  br label %124

124:                                              ; preds = %132, %123
  %125 = load i64, ptr %18, align 8
  %126 = load i64, ptr %6, align 8
  %127 = icmp ult i64 %125, %126
  br i1 %127, label %128, label %135

128:                                              ; preds = %124
  %129 = load ptr, ptr %5, align 8
  %130 = load i64, ptr %18, align 8
  %131 = getelementptr inbounds i32, ptr %129, i64 %130
  store i32 13, ptr %131, align 4
  br label %132

132:                                              ; preds = %128
  %133 = load i64, ptr %18, align 8
  %134 = add i64 %133, 1
  store i64 %134, ptr %18, align 8
  br label %124, !llvm.loop !14

135:                                              ; preds = %124
  br label %136

136:                                              ; preds = %135
  %137 = load i64, ptr %16, align 8
  %138 = add i64 %137, 1
  store i64 %138, ptr %16, align 8
  br label %107, !llvm.loop !15

139:                                              ; preds = %107
  store i64 0, ptr %19, align 8
  br label %140

140:                                              ; preds = %169, %139
  %141 = load i64, ptr %19, align 8
  %142 = load i64, ptr %6, align 8
  %143 = icmp ult i64 %141, %142
  br i1 %143, label %144, label %172

144:                                              ; preds = %140
  store i64 0, ptr %20, align 8
  br label %145

145:                                              ; preds = %153, %144
  %146 = load i64, ptr %20, align 8
  %147 = load i64, ptr %6, align 8
  %148 = icmp ult i64 %146, %147
  br i1 %148, label %149, label %156

149:                                              ; preds = %145
  %150 = load ptr, ptr %4, align 8
  %151 = load i64, ptr %20, align 8
  %152 = getelementptr inbounds i32, ptr %150, i64 %151
  store i32 14, ptr %152, align 4
  br label %153

153:                                              ; preds = %149
  %154 = load i64, ptr %20, align 8
  %155 = add i64 %154, 1
  store i64 %155, ptr %20, align 8
  br label %145, !llvm.loop !16

156:                                              ; preds = %145
  store i64 0, ptr %21, align 8
  br label %157

157:                                              ; preds = %165, %156
  %158 = load i64, ptr %21, align 8
  %159 = load i64, ptr %6, align 8
  %160 = icmp ult i64 %158, %159
  br i1 %160, label %161, label %168

161:                                              ; preds = %157
  %162 = load ptr, ptr %5, align 8
  %163 = load i64, ptr %21, align 8
  %164 = getelementptr inbounds i32, ptr %162, i64 %163
  store i32 15, ptr %164, align 4
  br label %165

165:                                              ; preds = %161
  %166 = load i64, ptr %21, align 8
  %167 = add i64 %166, 1
  store i64 %167, ptr %21, align 8
  br label %157, !llvm.loop !17

168:                                              ; preds = %157
  br label %169

169:                                              ; preds = %168
  %170 = load i64, ptr %19, align 8
  %171 = add i64 %170, 1
  store i64 %171, ptr %19, align 8
  br label %140, !llvm.loop !18

172:                                              ; preds = %140
  br label %173

173:                                              ; preds = %172
  %174 = load i64, ptr %15, align 8
  %175 = add i64 %174, 1
  store i64 %175, ptr %15, align 8
  br label %102, !llvm.loop !19

176:                                              ; preds = %102
  br label %177

177:                                              ; preds = %176
  %178 = load i64, ptr %7, align 8
  %179 = add i64 %178, 1
  store i64 %179, ptr %7, align 8
  br label %22, !llvm.loop !20

180:                                              ; preds = %22
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
