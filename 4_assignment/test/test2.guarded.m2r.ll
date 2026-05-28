; ModuleID = 'test2.ll'
source_filename = "test2.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_perfect_fusion(i32 noundef %0, ptr noundef %1, ptr noundef %2, ptr noundef %3) #0 {
  %5 = icmp slt i32 0, %0
  br i1 %5, label %.lr.ph, label %16

.lr.ph:                                           ; preds = %4
  br label %6

6:                                                ; preds = %.lr.ph, %13
  %.012 = phi i32 [ 0, %.lr.ph ], [ %14, %13 ]
  %7 = sext i32 %.012 to i64
  %8 = getelementptr inbounds i32, ptr %2, i64 %7
  %9 = load i32, ptr %8, align 4
  %10 = add nsw i32 %9, 1
  %11 = sext i32 %.012 to i64
  %12 = getelementptr inbounds i32, ptr %1, i64 %11
  store i32 %10, ptr %12, align 4
  br label %13

13:                                               ; preds = %6
  %14 = add nsw i32 %.012, 1
  %15 = icmp slt i32 %14, %0
  br i1 %15, label %6, label %._crit_edge, !llvm.loop !6

._crit_edge:                                      ; preds = %13
  br label %16

16:                                               ; preds = %._crit_edge, %4
  %17 = icmp slt i32 0, %0
  br i1 %17, label %.lr.ph5, label %28

.lr.ph5:                                          ; preds = %16
  br label %18

18:                                               ; preds = %.lr.ph5, %25
  %.03 = phi i32 [ 0, %.lr.ph5 ], [ %26, %25 ]
  %19 = sext i32 %.03 to i64
  %20 = getelementptr inbounds i32, ptr %1, i64 %19
  %21 = load i32, ptr %20, align 4
  %22 = mul nsw i32 %21, 2
  %23 = sext i32 %.03 to i64
  %24 = getelementptr inbounds i32, ptr %3, i64 %23
  store i32 %22, ptr %24, align 4
  br label %25

25:                                               ; preds = %18
  %26 = add nsw i32 %.03, 1
  %27 = icmp slt i32 %26, %0
  br i1 %27, label %18, label %._crit_edge6, !llvm.loop !8

._crit_edge6:                                     ; preds = %25
  br label %28

28:                                               ; preds = %._crit_edge6, %16
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_non_adjacent(i32 noundef %0, ptr noundef %1, ptr noundef %2) #0 {
  %4 = icmp slt i32 0, %0
  br i1 %4, label %.lr.ph, label %11

.lr.ph:                                           ; preds = %3
  br label %5

5:                                                ; preds = %.lr.ph, %8
  %.012 = phi i32 [ 0, %.lr.ph ], [ %9, %8 ]
  %6 = sext i32 %.012 to i64
  %7 = getelementptr inbounds i32, ptr %1, i64 %6
  store i32 %.012, ptr %7, align 4
  br label %8

8:                                                ; preds = %5
  %9 = add nsw i32 %.012, 1
  %10 = icmp slt i32 %9, %0
  br i1 %10, label %5, label %._crit_edge, !llvm.loop !9

._crit_edge:                                      ; preds = %8
  br label %11

11:                                               ; preds = %._crit_edge, %3
  %12 = getelementptr inbounds i32, ptr %2, i64 0
  store i32 99, ptr %12, align 4
  %13 = icmp slt i32 0, %0
  br i1 %13, label %.lr.ph5, label %23

.lr.ph5:                                          ; preds = %11
  br label %14

14:                                               ; preds = %.lr.ph5, %20
  %.03 = phi i32 [ 0, %.lr.ph5 ], [ %21, %20 ]
  %15 = sext i32 %.03 to i64
  %16 = getelementptr inbounds i32, ptr %1, i64 %15
  %17 = load i32, ptr %16, align 4
  %18 = sext i32 %.03 to i64
  %19 = getelementptr inbounds i32, ptr %2, i64 %18
  store i32 %17, ptr %19, align 4
  br label %20

20:                                               ; preds = %14
  %21 = add nsw i32 %.03, 1
  %22 = icmp slt i32 %21, %0
  br i1 %22, label %14, label %._crit_edge6, !llvm.loop !10

._crit_edge6:                                     ; preds = %20
  br label %23

23:                                               ; preds = %._crit_edge6, %11
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_not_cf_equivalent(i32 noundef %0, i32 noundef %1, ptr noundef %2) #0 {
  %4 = icmp slt i32 0, %0
  br i1 %4, label %.lr.ph, label %12

.lr.ph:                                           ; preds = %3
  br label %5

5:                                                ; preds = %.lr.ph, %9
  %.012 = phi i32 [ 0, %.lr.ph ], [ %10, %9 ]
  %6 = mul nsw i32 %.012, 2
  %7 = sext i32 %.012 to i64
  %8 = getelementptr inbounds i32, ptr %2, i64 %7
  store i32 %6, ptr %8, align 4
  br label %9

9:                                                ; preds = %5
  %10 = add nsw i32 %.012, 1
  %11 = icmp slt i32 %10, %0
  br i1 %11, label %5, label %._crit_edge, !llvm.loop !11

._crit_edge:                                      ; preds = %9
  br label %12

12:                                               ; preds = %._crit_edge, %3
  %13 = icmp sgt i32 %1, 0
  br i1 %13, label %14, label %27

14:                                               ; preds = %12
  %15 = icmp slt i32 0, %0
  br i1 %15, label %.lr.ph5, label %26

.lr.ph5:                                          ; preds = %14
  br label %16

16:                                               ; preds = %.lr.ph5, %23
  %.03 = phi i32 [ 0, %.lr.ph5 ], [ %24, %23 ]
  %17 = sext i32 %.03 to i64
  %18 = getelementptr inbounds i32, ptr %2, i64 %17
  %19 = load i32, ptr %18, align 4
  %20 = add nsw i32 %19, 1
  %21 = sext i32 %.03 to i64
  %22 = getelementptr inbounds i32, ptr %2, i64 %21
  store i32 %20, ptr %22, align 4
  br label %23

23:                                               ; preds = %16
  %24 = add nsw i32 %.03, 1
  %25 = icmp slt i32 %24, %0
  br i1 %25, label %16, label %._crit_edge6, !llvm.loop !12

._crit_edge6:                                     ; preds = %23
  br label %26

26:                                               ; preds = %._crit_edge6, %14
  br label %27

27:                                               ; preds = %26, %12
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local void @test_different_guards(i32 noundef %0, i32 noundef %1, ptr noundef %2, ptr noundef %3) #0 {
  %5 = icmp slt i32 0, %0
  br i1 %5, label %.lr.ph, label %12

.lr.ph:                                           ; preds = %4
  br label %6

6:                                                ; preds = %.lr.ph, %9
  %.012 = phi i32 [ 0, %.lr.ph ], [ %10, %9 ]
  %7 = sext i32 %.012 to i64
  %8 = getelementptr inbounds i32, ptr %2, i64 %7
  store i32 %.012, ptr %8, align 4
  br label %9

9:                                                ; preds = %6
  %10 = add nsw i32 %.012, 1
  %11 = icmp slt i32 %10, %0
  br i1 %11, label %6, label %._crit_edge, !llvm.loop !13

._crit_edge:                                      ; preds = %9
  br label %12

12:                                               ; preds = %._crit_edge, %4
  %13 = icmp slt i32 0, %1
  br i1 %13, label %.lr.ph5, label %20

.lr.ph5:                                          ; preds = %12
  br label %14

14:                                               ; preds = %.lr.ph5, %17
  %.03 = phi i32 [ 0, %.lr.ph5 ], [ %18, %17 ]
  %15 = sext i32 %.03 to i64
  %16 = getelementptr inbounds i32, ptr %3, i64 %15
  store i32 %.03, ptr %16, align 4
  br label %17

17:                                               ; preds = %14
  %18 = add nsw i32 %.03, 1
  %19 = icmp slt i32 %18, %1
  br i1 %19, label %14, label %._crit_edge6, !llvm.loop !14

._crit_edge6:                                     ; preds = %17
  br label %20

20:                                               ; preds = %._crit_edge6, %12
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
