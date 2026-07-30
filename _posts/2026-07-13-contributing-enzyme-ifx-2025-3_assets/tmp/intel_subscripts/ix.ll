; ModuleID = 'ix.o'
source_filename = "ix.f90"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@"test_$X" = internal global [3 x float] zeroinitializer, align 32
@anon.32f8b62980ad51ae43b499bcfb35956d.0 = internal unnamed_addr constant i32 2, align 4
@"var$3" = internal global [3 x i32] [i32 2, i32 3, i32 4], align 16
@anon.32f8b62980ad51ae43b499bcfb35956d.1 = internal unnamed_addr constant i32 3, align 4
@anon.32f8b62980ad51ae43b499bcfb35956d.2 = internal unnamed_addr constant i32 2, align 4

; Function Attrs: noinline nounwind optnone uwtable
define void @MAIN__() #0 {
alloca_0:
  %"$io_ctx" = alloca [8 x i64], align 8, !llfort.type_idx !2
  %"test_$Y" = alloca float, align 4, !llfort.type_idx !3
  %"$loop_ctr" = alloca i64, align 8, !llfort.type_idx !4
  %"var$2" = alloca i64, align 8, !llfort.type_idx !4
  %"var$4" = alloca i32, align 4, !llfort.type_idx !5
  %"(&)val$" = alloca [4 x i8], align 1, !llfort.type_idx !6
  %argblock = alloca <{ i64 }>, align 8, !llfort.type_idx !7
  %func_result = call i32 @for_set_reentrancy(ptr @anon.32f8b62980ad51ae43b499bcfb35956d.0), !llfort.type_idx !5
  store i64 0, ptr %"var$2", align 8
  store i64 1, ptr %"$loop_ctr", align 8
  br label %loop1_test5

loop1_test5:                                      ; preds = %loop1_body6, %alloca_0
  %"$loop_ctr_fetch.4" = load i64, ptr %"$loop_ctr", align 8, !llfort.type_idx !4
  %rel = icmp sle i64 %"$loop_ctr_fetch.4", 3
  br i1 %rel, label %loop1_body6, label %loop1_exit7, !llvm.loop !8

loop1_body6:                                      ; preds = %loop1_test5
  %"$loop_ctr_fetch.2" = load i64, ptr %"$loop_ctr", align 8, !llfort.type_idx !4
  %0 = sub nsw i64 %"$loop_ctr_fetch.2", 1
  %1 = getelementptr inbounds i32, ptr @"var$3", i64 %0
  %"var$3[]_fetch.3" = load i32, ptr %1, align 4, !llfort.type_idx !10
  %"(float)var$3[]_fetch.3$" = sitofp i32 %"var$3[]_fetch.3" to float, !llfort.type_idx !11
  %"$loop_ctr_fetch.1" = load i64, ptr %"$loop_ctr", align 8, !llfort.type_idx !4
  %2 = sub nsw i64 %"$loop_ctr_fetch.1", 1
  %3 = getelementptr inbounds float, ptr @"test_$X", i64 %2
  store float %"(float)var$3[]_fetch.3$", ptr %3, align 4
  %"$loop_ctr_fetch.5" = load i64, ptr %"$loop_ctr", align 8, !llfort.type_idx !4
  %add = add nsw i64 %"$loop_ctr_fetch.5", 1
  store i64 %add, ptr %"$loop_ctr", align 8
  br label %loop1_test5

loop1_exit7:                                      ; preds = %loop1_test5
  call void @test_IP_selectfirst_(ptr @anon.32f8b62980ad51ae43b499bcfb35956d.1, ptr @"test_$X", ptr @anon.32f8b62980ad51ae43b499bcfb35956d.2, ptr %"test_$Y"), !llfort.type_idx !12
  %"test_$Y_fetch.6" = load float, ptr %"test_$Y", align 4, !llfort.type_idx !3
  store i64 0, ptr %"$io_ctx", align 8
  store [4 x i8] c"\1A\01\01\00", ptr %"(&)val$", align 1
  %BLKFIELD_float_ = getelementptr inbounds <{ i64 }>, ptr %argblock, i32 0, i32 0, !llfort.type_idx !13
  store float %"test_$Y_fetch.6", ptr %BLKFIELD_float_, align 4
  %func_result2 = call i32 (ptr, i32, i64, ptr, ptr, ...) @for_write_seq_lis(ptr %"$io_ctx", i32 -1, i64 2253038970797824, ptr %"(&)val$", ptr %argblock), !llfort.type_idx !5
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define void @test_IP_selectfirst_(ptr noalias readonly dereferenceable(4) %N, ptr noalias dereferenceable(4) %X, ptr noalias readonly dereferenceable(4) %I, ptr noalias dereferenceable(4) %Y) #0 {
alloca_1:
  %"$io_ctx" = alloca [8 x i64], align 8, !llfort.type_idx !14
  %"var$5" = alloca i32, align 4, !llfort.type_idx !5
  %N_fetch.7 = load i32, ptr %N, align 1, !llfort.type_idx !15
  store i32 %N_fetch.7, ptr %"var$5", align 4
  %"var$5_fetch.8" = load i32, ptr %"var$5", align 4, !llfort.type_idx !5
  %int_sext = sext i32 %"var$5_fetch.8" to i64, !llfort.type_idx !4
  %I_fetch.9 = load i32, ptr %I, align 1, !llfort.type_idx !16
  %int_sext1 = sext i32 %I_fetch.9 to i64, !llfort.type_idx !4
  %sub = sub nsw i64 %int_sext, 1
  %add = add nsw i64 %sub, 1
  %0 = sub nsw i64 %int_sext1, 1
  %1 = getelementptr inbounds float, ptr %X, i64 %0
  %"X[]_fetch.10" = load float, ptr %1, align 1, !llfort.type_idx !17
  store float %"X[]_fetch.10", ptr %Y, align 1
  ret void
}

declare !llfort.intrin_id !18 i32 @for_set_reentrancy(ptr readonly captures(none))

; Function Attrs: nocallback nofree norecurse nosync nounwind speculatable willreturn memory(none)
; Unknown intrinsic
declare ptr @llvm.intel.subscript.p0.i64.i64.p0.i64.i64(i8, i64, i64, ptr, i64, i64) #1

declare !llfort.intrin_id !19 i32 @for_write_seq_lis(ptr, i32, i64, ptr, ptr, ...)

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "intel-lang"="fortran" "loopopt-pipeline"="light" "min-legal-vector-width"="0" "target-cpu"="x86-64" "target-features"="+cmov,+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" }
attributes #1 = { nocallback nofree norecurse nosync nounwind speculatable willreturn memory(none) }

!omp_offload.info = !{}
!llvm.module.flags = !{!0, !1}
!ifx.types.dv = !{}

!0 = !{i32 1, !"ThinLTO", i32 0}
!1 = !{i32 1, !"EnableSplitLTOUnit", i32 1}
!2 = !{i64 23}
!3 = !{i64 28}
!4 = !{i64 3}
!5 = !{i64 2}
!6 = !{i64 57}
!7 = !{i64 59}
!8 = distinct !{!8, !9}
!9 = !{!"llvm.loop.mustprogress"}
!10 = !{i64 54}
!11 = !{i64 5}
!12 = !{i64 20}
!13 = !{i64 60}
!14 = !{i64 62}
!15 = !{i64 76}
!16 = !{i64 77}
!17 = !{i64 78}
!18 = !{i32 99}
!19 = !{i32 343}

^0 = module: (path: "ix.o", hash: (0, 0, 0, 0, 0))
^1 = gv: (name: "anon.32f8b62980ad51ae43b499bcfb35956d.0", summaries: (variable: (module: ^0, flags: (linkage: internal, visibility: default, notEligibleToImport: 1, live: 0, dsoLocal: 1, canAutoHide: 0, importType: definition), varFlags: (readonly: 1, writeonly: 0, constant: 1)))) ; guid = 283149186239605885
^2 = gv: (name: "for_write_seq_lis") ; guid = 837479164473647211
^3 = gv: (name: "for_set_reentrancy") ; guid = 3026076891513432880
^4 = gv: (name: "test_$X", summaries: (variable: (module: ^0, flags: (linkage: internal, visibility: default, notEligibleToImport: 1, live: 0, dsoLocal: 1, canAutoHide: 0, importType: definition), varFlags: (readonly: 1, writeonly: 1, constant: 0)))) ; guid = 3795975542080051165
^5 = gv: (name: "anon.32f8b62980ad51ae43b499bcfb35956d.1", summaries: (variable: (module: ^0, flags: (linkage: internal, visibility: default, notEligibleToImport: 1, live: 0, dsoLocal: 1, canAutoHide: 0, importType: definition), varFlags: (readonly: 1, writeonly: 0, constant: 1)))) ; guid = 5795505026983641332
^6 = gv: (name: "test_IP_selectfirst_", summaries: (function: (module: ^0, flags: (linkage: external, visibility: default, notEligibleToImport: 1, live: 0, dsoLocal: 0, canAutoHide: 0, importType: definition), insts: 15, funcFlags: (readNone: 0, readOnly: 0, noRecurse: 0, returnDoesNotAlias: 0, noInline: 1, alwaysInline: 0, noUnwind: 1, mayThrow: 0, hasUnknownCall: 0, mustBeUnreachable: 0)))) ; guid = 9465357224640217379
^7 = gv: (name: "anon.32f8b62980ad51ae43b499bcfb35956d.2", summaries: (variable: (module: ^0, flags: (linkage: internal, visibility: default, notEligibleToImport: 1, live: 0, dsoLocal: 1, canAutoHide: 0, importType: definition), varFlags: (readonly: 1, writeonly: 0, constant: 1)))) ; guid = 12620032113229040733
^8 = gv: (name: "llvm.intel.subscript.p0.i64.i64.p0.i64.i64") ; guid = 16137143510673601000
^9 = gv: (name: "MAIN__", summaries: (function: (module: ^0, flags: (linkage: external, visibility: default, notEligibleToImport: 1, live: 0, dsoLocal: 0, canAutoHide: 0, importType: definition), insts: 35, funcFlags: (readNone: 0, readOnly: 0, noRecurse: 0, returnDoesNotAlias: 0, noInline: 1, alwaysInline: 0, noUnwind: 1, mayThrow: 0, hasUnknownCall: 0, mustBeUnreachable: 0), calls: ((callee: ^3), (callee: ^6), (callee: ^2)), refs: (^1, ^10, ^4, ^5, ^7)))) ; guid = 16720960272357440104
^10 = gv: (name: "var$3", summaries: (variable: (module: ^0, flags: (linkage: internal, visibility: default, notEligibleToImport: 1, live: 0, dsoLocal: 1, canAutoHide: 0, importType: definition), varFlags: (readonly: 1, writeonly: 1, constant: 0)))) ; guid = 17597880796506353737
^11 = flags: 8
^12 = blockcount: 0
