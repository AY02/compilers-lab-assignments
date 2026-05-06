; test_phi_invariant.ll
define void @test_phi_invariant(i32 %a, i32 %b) {
entry:
  %val = add nsw i32 %a, %b
  br label %loop.header

loop.header:                                      ; preds = %loop.latch, %entry
  %i = phi i32 [ 0, %entry ], [ %i.next, %loop.latch ]
  %sum = phi i32 [ 0, %entry ], [ %sum.next, %loop.latch ]
  
  %cmp = icmp slt i32 %i, 10
  br i1 %cmp, label %loop.body, label %exit

loop.body:                                        ; preds = %loop.header
  %rem = srem i32 %i, 2
  %is_even = icmp eq i32 %rem, 0
  br i1 %is_even, label %if.then, label %if.else

if.then:                                          ; preds = %loop.body
  br label %if.end

if.else:                                          ; preds = %loop.body
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  %x = phi i32 [ %val, %if.then ], [ %val, %if.else ]
  %sum.next = add nsw i32 %sum, %x
  br label %loop.latch

loop.latch:                                       ; preds = %if.end
  %i.next = add nsw i32 %i, 1
  br label %loop.header

exit:                                             ; preds = %loop.header
  ret void
}