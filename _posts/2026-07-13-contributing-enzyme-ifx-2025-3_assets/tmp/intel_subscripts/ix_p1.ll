; ModuleID = 'ix_p1.o'
source_filename = "ix_p1.f90"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"QNCA_a0$float*$rank1$" = type { ptr, i64, i64, i64, i64, i64, [1 x { i64, i64, i64 }] }

; Function Attrs: noinline nounwind optnone uwtable
define void @test_(ptr noalias dereferenceable(72) "assumed_shape" "ptrnoalias" %"test_$X", ptr noalias dereferenceable(4) %"test_$Y", ptr noalias dereferenceable(4) %"test_$I") #0 {
alloca_0:
  %"$io_ctx" = alloca [8 x i64], align 8, !llfort.type_idx !3
  %"test_$X.addr_a0$" = getelementptr inbounds %"QNCA_a0$float*$rank1$", ptr %"test_$X", i32 0, i32 0, !llfort.type_idx !4
  %"test_$X.addr_a0$_fetch.1" = load ptr, ptr %"test_$X.addr_a0$", align 1, !llfort.type_idx !5
  %"test_$X.dim_info$" = getelementptr inbounds %"QNCA_a0$float*$rank1$", ptr %"test_$X", i32 0, i32 6, i32 0, !llfort.type_idx !6
  %"test_$X.dim_info$.spacing$" = getelementptr inbounds { i64, i64, i64 }, ptr %"test_$X.dim_info$", i32 0, i32 1, !llfort.type_idx !7
  %"test_$X.dim_info$.spacing$[]_fetch.2" = load i64, ptr %"test_$X.dim_info$.spacing$", align 1, !llfort.type_idx !7
  %"test_$X.dim_info$1" = getelementptr inbounds %"QNCA_a0$float*$rank1$", ptr %"test_$X", i32 0, i32 6, i32 0, !llfort.type_idx !6
  %"test_$X.dim_info$.extent$" = getelementptr inbounds { i64, i64, i64 }, ptr %"test_$X.dim_info$1", i32 0, i32 0, !llfort.type_idx !8
  %"test_$X.dim_info$.extent$[]_fetch.3" = load i64, ptr %"test_$X.dim_info$.extent$", align 1, !llfort.type_idx !8
  %"test_$I_fetch.4" = load i32, ptr %"test_$I", align 1, !llfort.type_idx !9
  %add = add nsw i32 %"test_$I_fetch.4", 1
  %int_sext = sext i32 %add to i64, !llfort.type_idx !10
  %"test_$X.dim_info$2" = getelementptr inbounds %"QNCA_a0$float*$rank1$", ptr %"test_$X", i32 0, i32 6, i32 0, !llfort.type_idx !6
  %"test_$X.dim_info$.spacing$3" = getelementptr inbounds { i64, i64, i64 }, ptr %"test_$X.dim_info$2", i32 0, i32 1, !llfort.type_idx !7
  %"test_$X.dim_info$.spacing$[]_fetch.5" = load i64, ptr %"test_$X.dim_info$.spacing$3", align 1, !llfort.type_idx !7
  %sub = sub nsw i64 %"test_$X.dim_info$.extent$[]_fetch.3", 1
  %add5 = add nsw i64 %sub, 1
  %0 = sub nsw i64 %int_sext, 1
  %1 = mul nsw i64 %"test_$X.dim_info$.spacing$[]_fetch.2", %0
  %2 = getelementptr inbounds i8, ptr %"test_$X.addr_a0$_fetch.1", i64 %1
  %"test_$X.addr_a0$_fetch.1[]_fetch.6" = load float, ptr %2, align 1, !llfort.type_idx !5
  store float %"test_$X.addr_a0$_fetch.1[]_fetch.6", ptr %"test_$Y", align 1
  ret void
}

; Function Attrs: nocallback nofree norecurse nosync nounwind speculatable willreturn memory(none)
; Unknown intrinsic
declare ptr @llvm.intel.subscript.p0.i64.i32.p0.i32.i64(i8, i64, i32, ptr, i32, i64) #1

; Function Attrs: nocallback nofree norecurse nosync nounwind speculatable willreturn memory(none)
; Unknown intrinsic
declare ptr @llvm.intel.subscript.nonexact.p0.i64.i64.p0.i64.i64(i8, i64, i64, ptr, i64, i64) #1

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "intel-lang"="fortran" "loopopt-pipeline"="light" "min-legal-vector-width"="0" "target-cpu"="x86-64" "target-features"="+cmov,+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="true" }
attributes #1 = { nocallback nofree norecurse nosync nounwind speculatable willreturn memory(none) }

!omp_offload.info = !{}
!llvm.module.flags = !{!0, !1}
!ifx.types.dv = !{!2}

!0 = !{i32 1, !"ThinLTO", i32 0}
!1 = !{i32 1, !"EnableSplitLTOUnit", i32 1}
!2 = !{%"QNCA_a0$float*$rank1$" zeroinitializer, float 0.000000e+00}
!3 = !{i64 40}
!4 = !{i64 56}
!5 = !{i64 5}
!6 = !{i64 62}
!7 = !{i64 19}
!8 = !{i64 18}
!9 = !{i64 90}
!10 = !{i64 3}

^0 = module: (path: "ix_p1.o", hash: (0, 0, 0, 0, 0))
^1 = gv: (name: "test_", summaries: (function: (module: ^0, flags: (linkage: external, visibility: default, notEligibleToImport: 1, live: 0, dsoLocal: 0, canAutoHide: 0, importType: definition), insts: 23, funcFlags: (readNone: 0, readOnly: 0, noRecurse: 0, returnDoesNotAlias: 0, noInline: 1, alwaysInline: 0, noUnwind: 1, mayThrow: 0, hasUnknownCall: 0, mustBeUnreachable: 0)))) ; guid = 1366917672871630551
^2 = gv: (name: "llvm.intel.subscript.p0.i64.i32.p0.i32.i64") ; guid = 4979222510374316329
^3 = gv: (name: "llvm.intel.subscript.nonexact.p0.i64.i64.p0.i64.i64") ; guid = 5092509742162342880
^4 = flags: 8
^5 = blockcount: 0
