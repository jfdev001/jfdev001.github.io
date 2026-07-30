; ModuleID = 'opt_test_enzyme.o'
source_filename = "test_enzyme.f90"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@strlit = internal unnamed_addr constant [12 x i8] c"Test failed!", !llfort.type_idx !0
@strlit.2 = internal unnamed_addr constant [12 x i8] c"Test passed!", !llfort.type_idx !0
@strlit.4 = internal unnamed_addr constant [4 x i8] c"dx: ", !llfort.type_idx !1
@anon.683d156384c4d8ff1f15ab56c70728f5.0 = internal unnamed_addr constant i32 65536
@anon.683d156384c4d8ff1f15ab56c70728f5.1 = internal unnamed_addr constant i32 2

; Function Attrs: nounwind uwtable
define void @MAIN__() local_unnamed_addr #0 !llfort.type_idx !4 {
alloca_0:
  %"$io_ctx" = alloca [8 x i64], align 16, !llfort.type_idx !5
  %"test_enzyme_$DX" = alloca float, align 8, !llfort.type_idx !6
  %"test_enzyme_$X" = alloca float, align 8, !llfort.type_idx !7
  %"(&)val$" = alloca [4 x i8], align 1, !llfort.type_idx !8
  %argblock = alloca <{ i64, i8* }>, align 8, !llfort.type_idx !9
  %"(&)val$5" = alloca [4 x i8], align 1, !llfort.type_idx !10
  %argblock6 = alloca <{ i64 }>, align 8, !llfort.type_idx !11
  %"(&)val$13" = alloca [4 x i8], align 1, !llfort.type_idx !12
  %argblock14 = alloca <{ i64, i8* }>, align 8, !llfort.type_idx !9
  %"(&)val$21" = alloca [4 x i8], align 1, !llfort.type_idx !13
  %argblock22 = alloca <{ i64, i8* }>, align 8, !llfort.type_idx !9
  %func_result = tail call i32 @for_set_fpe_(i32* nonnull @anon.683d156384c4d8ff1f15ab56c70728f5.0) #5, !llfort.type_idx !14
  %func_result2 = tail call i32 @for_set_reentrancy(i32* nonnull @anon.683d156384c4d8ff1f15ab56c70728f5.1) #5, !llfort.type_idx !14
  store float 3.000000e+00, float* %"test_enzyme_$X", align 8, !tbaa !15
  store float 0.000000e+00, float* %"test_enzyme_$DX", align 8, !tbaa !20
  call void @diffetest_enzyme_IP_square_(float* %"test_enzyme_$X", float* %"test_enzyme_$DX", float 1.000000e+00)
  %"(i64*)$io_ctx$" = getelementptr inbounds [8 x i64], [8 x i64]* %"$io_ctx", i64 0, i64 0
  store i64 0, i64* %"(i64*)$io_ctx$", align 16, !tbaa !22
  %.fca.0.gep41 = getelementptr inbounds [4 x i8], [4 x i8]* %"(&)val$", i64 0, i64 0
  store i8 56, i8* %.fca.0.gep41, align 1, !tbaa !22
  %.fca.1.gep42 = getelementptr inbounds [4 x i8], [4 x i8]* %"(&)val$", i64 0, i64 1
  store i8 4, i8* %.fca.1.gep42, align 1, !tbaa !22
  %.fca.2.gep43 = getelementptr inbounds [4 x i8], [4 x i8]* %"(&)val$", i64 0, i64 2
  store i8 2, i8* %.fca.2.gep43, align 1, !tbaa !22
  %.fca.3.gep44 = getelementptr inbounds [4 x i8], [4 x i8]* %"(&)val$", i64 0, i64 3
  store i8 0, i8* %.fca.3.gep44, align 1, !tbaa !22
  %BLKFIELD_i64_ = getelementptr inbounds <{ i64, i8* }>, <{ i64, i8* }>* %argblock, i64 0, i32 0, !llfort.type_idx !23
  store i64 4, i64* %BLKFIELD_i64_, align 8, !tbaa !24
  %"BLKFIELD_i8*_" = getelementptr inbounds <{ i64, i8* }>, <{ i64, i8* }>* %argblock, i64 0, i32 1, !llfort.type_idx !26
  store i8* getelementptr inbounds ([4 x i8], [4 x i8]* @strlit.4, i64 0, i64 0), i8** %"BLKFIELD_i8*_", align 8, !tbaa !27
  %"(i8*)$io_ctx$" = bitcast [8 x i64]* %"$io_ctx" to i8*, !llfort.type_idx !29
  %"(i8*)argblock$" = bitcast <{ i64, i8* }>* %argblock to i8*, !llfort.type_idx !29
  %func_result4 = call i32 (i8*, i32, i64, i8*, i8*, ...) @for_write_seq_lis(i8* nonnull %"(i8*)$io_ctx$", i32 -1, i64 2253038970797824, i8* nonnull %.fca.0.gep41, i8* nonnull %"(i8*)argblock$") #5, !llfort.type_idx !14
  %"test_enzyme_$DX_fetch.2" = load float, float* %"test_enzyme_$DX", align 8, !tbaa !20, !llfort.type_idx !6
  %.fca.0.gep37 = getelementptr inbounds [4 x i8], [4 x i8]* %"(&)val$5", i64 0, i64 0
  store i8 26, i8* %.fca.0.gep37, align 1, !tbaa !22
  %.fca.1.gep38 = getelementptr inbounds [4 x i8], [4 x i8]* %"(&)val$5", i64 0, i64 1
  store i8 1, i8* %.fca.1.gep38, align 1, !tbaa !22
  %.fca.2.gep39 = getelementptr inbounds [4 x i8], [4 x i8]* %"(&)val$5", i64 0, i64 2
  store i8 1, i8* %.fca.2.gep39, align 1, !tbaa !22
  %.fca.3.gep40 = getelementptr inbounds [4 x i8], [4 x i8]* %"(&)val$5", i64 0, i64 3
  store i8 0, i8* %.fca.3.gep40, align 1, !tbaa !22
  %bitcast = bitcast <{ i64 }>* %argblock6 to float*, !llfort.type_idx !30
  store float %"test_enzyme_$DX_fetch.2", float* %bitcast, align 8, !tbaa !31
  %"(i8*)argblock6$" = bitcast <{ i64 }>* %argblock6 to i8*, !llfort.type_idx !29
  %func_result10 = call i32 @for_write_seq_lis_xmit(i8* nonnull %"(i8*)$io_ctx$", i8* nonnull %.fca.0.gep37, i8* nonnull %"(i8*)argblock6$") #5, !llfort.type_idx !14
  %"test_enzyme_$DX_fetch.3" = load float, float* %"test_enzyme_$DX", align 8, !tbaa !20, !llfort.type_idx !6
  %sub = fadd reassoc ninf nsz arcp contract afn float %"test_enzyme_$DX_fetch.3", -6.000000e+00
  %abs.4 = call reassoc ninf nsz arcp contract afn float @llvm.fabs.f32(float %sub), !llfort.type_idx !33
  %rel = fcmp reassoc ninf nsz arcp contract afn olt float %abs.4, 0x3EB0C6F7A0000000
  store i64 0, i64* %"(i64*)$io_ctx$", align 16, !tbaa !22
  br i1 %rel, label %bb_new22_then, label %bb_new25_else

bb_new22_then:                                    ; preds = %alloca_0
  %argblock14.sroa.gep = getelementptr inbounds <{ i64, i8* }>, <{ i64, i8* }>* %argblock14, i64 0, i32 1
  %.fca.0.gep33 = getelementptr inbounds [4 x i8], [4 x i8]* %"(&)val$13", i64 0, i64 0
  store i8 56, i8* %.fca.0.gep33, align 1, !tbaa !22
  %.fca.1.gep34 = getelementptr inbounds [4 x i8], [4 x i8]* %"(&)val$13", i64 0, i64 1
  store i8 4, i8* %.fca.1.gep34, align 1, !tbaa !22
  %.fca.2.gep35 = getelementptr inbounds [4 x i8], [4 x i8]* %"(&)val$13", i64 0, i64 2
  store i8 1, i8* %.fca.2.gep35, align 1, !tbaa !22
  %.fca.3.gep36 = getelementptr inbounds [4 x i8], [4 x i8]* %"(&)val$13", i64 0, i64 3
  store i8 0, i8* %.fca.3.gep36, align 1, !tbaa !22
  %BLKFIELD_i64_15 = getelementptr inbounds <{ i64, i8* }>, <{ i64, i8* }>* %argblock14, i64 0, i32 0, !llfort.type_idx !34
  store i64 12, i64* %BLKFIELD_i64_15, align 8, !tbaa !35
  br label %bb4_endif

bb_new25_else:                                    ; preds = %alloca_0
  %argblock22.sroa.gep = getelementptr inbounds <{ i64, i8* }>, <{ i64, i8* }>* %argblock22, i64 0, i32 1
  %.fca.0.gep = getelementptr inbounds [4 x i8], [4 x i8]* %"(&)val$21", i64 0, i64 0
  store i8 56, i8* %.fca.0.gep, align 1, !tbaa !22
  %.fca.1.gep = getelementptr inbounds [4 x i8], [4 x i8]* %"(&)val$21", i64 0, i64 1
  store i8 4, i8* %.fca.1.gep, align 1, !tbaa !22
  %.fca.2.gep = getelementptr inbounds [4 x i8], [4 x i8]* %"(&)val$21", i64 0, i64 2
  store i8 1, i8* %.fca.2.gep, align 1, !tbaa !22
  %.fca.3.gep = getelementptr inbounds [4 x i8], [4 x i8]* %"(&)val$21", i64 0, i64 3
  store i8 0, i8* %.fca.3.gep, align 1, !tbaa !22
  %BLKFIELD_i64_23 = getelementptr inbounds <{ i64, i8* }>, <{ i64, i8* }>* %argblock22, i64 0, i32 0, !llfort.type_idx !37
  store i64 12, i64* %BLKFIELD_i64_23, align 8, !tbaa !38
  br label %bb4_endif

bb4_endif:                                        ; preds = %bb_new25_else, %bb_new22_then
  %argblock22.sink45 = phi <{ i64, i8* }>* [ %argblock22, %bb_new25_else ], [ %argblock14, %bb_new22_then ]
  %.sink = phi i8* [ getelementptr inbounds ([12 x i8], [12 x i8]* @strlit, i64 0, i64 0), %bb_new25_else ], [ getelementptr inbounds ([12 x i8], [12 x i8]* @strlit.2, i64 0, i64 0), %bb_new22_then ]
  %.fca.0.gep.sink = phi i8* [ %.fca.0.gep, %bb_new25_else ], [ %.fca.0.gep33, %bb_new22_then ]
  %argblock22.sink45.sroa.phi = phi i8** [ %argblock22.sroa.gep, %bb_new25_else ], [ %argblock14.sroa.gep, %bb_new22_then ]
  store i8* %.sink, i8** %argblock22.sink45.sroa.phi, align 8, !tbaa !22
  %"(i8*)argblock22$" = bitcast <{ i64, i8* }>* %argblock22.sink45 to i8*
  %func_result28 = call i32 (i8*, i32, i64, i8*, i8*, ...) @for_write_seq_lis(i8* nonnull %"(i8*)$io_ctx$", i32 -1, i64 2253038970797824, i8* nonnull %.fca.0.gep.sink, i8* nonnull %"(i8*)argblock22$") #5
  ret void
}

; Function Attrs: argmemonly mustprogress nofree norecurse nosync nounwind readonly willreturn uwtable
define float @test_enzyme_IP_square_(float* noalias nocapture readonly dereferenceable(4) %X) #1 !llfort.type_idx !40 {
alloca_1:
  %X_fetch.7 = load float, float* %X, align 1, !tbaa !41, !llfort.type_idx !46
  %mul = fmul reassoc ninf nsz arcp contract afn float %X_fetch.7, %X_fetch.7
  ret float %mul
}

declare !llfort.intrin_id !47 !llfort.type_idx !48 i32 @for_set_fpe_(i32* nocapture readonly) local_unnamed_addr

; Function Attrs: nofree
declare !llfort.intrin_id !49 !llfort.type_idx !50 i32 @for_set_reentrancy(i32* nocapture readonly) local_unnamed_addr #2

; Function Attrs: nofree
declare !llfort.intrin_id !51 !llfort.type_idx !52 i32 @for_write_seq_lis(i8*, i32, i64, i8*, i8*, ...) local_unnamed_addr #2

; Function Attrs: nofree
declare !llfort.intrin_id !53 !llfort.type_idx !54 i32 @for_write_seq_lis_xmit(i8* nocapture readonly, i8* nocapture readonly, i8*) local_unnamed_addr #2

; Function Attrs: nocallback nofree nosync nounwind readnone speculatable willreturn
declare !llfort.intrin_id !55 !llfort.type_idx !56 float @llvm.fabs.f32(float) #3

declare !llfort.type_idx !57 void @f__enzyme_autodiff_(...) local_unnamed_addr

; Function Attrs: argmemonly mustprogress nofree norecurse nosync nounwind uwtable
define internal void @diffetest_enzyme_IP_square_(float* noalias nocapture readonly dereferenceable(4) %X, float* nocapture %"X'", float %differeturn) #4 !llfort.type_idx !40 {
alloca_1:
  %"mul'de" = alloca float, align 4
  store float 0.000000e+00, float* %"mul'de", align 4
  %"X_fetch.7'de" = alloca float, align 4
  store float 0.000000e+00, float* %"X_fetch.7'de", align 4
  %X_fetch.7 = load float, float* %X, align 1, !tbaa !41, !alias.scope !58, !noalias !61, !llfort.type_idx !46
  br label %invertalloca_1

invertalloca_1:                                   ; preds = %alloca_1
  store float %differeturn, float* %"mul'de", align 4
  %0 = load float, float* %"mul'de", align 4
  store float 0.000000e+00, float* %"mul'de", align 4
  %1 = fmul fast float %0, %X_fetch.7
  %2 = load float, float* %"X_fetch.7'de", align 4
  %3 = fadd fast float %2, %1
  store float %3, float* %"X_fetch.7'de", align 4
  %4 = fmul fast float %0, %X_fetch.7
  %5 = load float, float* %"X_fetch.7'de", align 4
  %6 = fadd fast float %5, %4
  store float %6, float* %"X_fetch.7'de", align 4
  %7 = load float, float* %"X_fetch.7'de", align 4
  store float 0.000000e+00, float* %"X_fetch.7'de", align 4
  %8 = load float, float* %"X'", align 1, !tbaa !41, !alias.scope !61, !noalias !58
  %9 = fadd fast float %8, %7
  store float %9, float* %"X'", align 1, !tbaa !41, !alias.scope !61, !noalias !58
  ret void
}

attributes #0 = { nounwind uwtable "denormal-fp-math"="preserve_sign" "frame-pointer"="none" "intel-lang"="fortran" "loopopt-pipeline"="light" "min-legal-vector-width"="0" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" }
attributes #1 = { argmemonly mustprogress nofree norecurse nosync nounwind readonly willreturn uwtable "denormal-fp-math"="preserve_sign" "frame-pointer"="none" "intel-lang"="fortran" "loopopt-pipeline"="light" "min-legal-vector-width"="0" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" }
attributes #2 = { nofree "intel-lang"="fortran" }
attributes #3 = { nocallback nofree nosync nounwind readnone speculatable willreturn }
attributes #4 = { argmemonly mustprogress nofree norecurse nosync nounwind uwtable "denormal-fp-math"="preserve_sign" "frame-pointer"="none" "intel-lang"="fortran" "loopopt-pipeline"="light" "min-legal-vector-width"="0" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" }
attributes #5 = { nounwind }

!omp_offload.info = !{}
!llvm.module.flags = !{!2, !3}

!0 = !{i64 26}
!1 = !{i64 27}
!2 = !{i32 1, !"ThinLTO", i32 0}
!3 = !{i32 1, !"EnableSplitLTOUnit", i32 1}
!4 = !{i64 25}
!5 = !{i64 21}
!6 = !{i64 28}
!7 = !{i64 29}
!8 = !{i64 48}
!9 = !{i64 50}
!10 = !{i64 53}
!11 = !{i64 55}
!12 = !{i64 61}
!13 = !{i64 65}
!14 = !{i64 2}
!15 = !{!16, !16, i64 0}
!16 = !{!"ifx$unique_sym$1", !17, i64 0}
!17 = !{!"Fortran Data Symbol", !18, i64 0}
!18 = !{!"Generic Fortran Symbol", !19, i64 0}
!19 = !{!"ifx$root$1$MAIN__"}
!20 = !{!21, !21, i64 0}
!21 = !{!"ifx$unique_sym$2", !17, i64 0}
!22 = !{!17, !17, i64 0}
!23 = !{i64 51}
!24 = !{!25, !25, i64 0}
!25 = !{!"ifx$unique_sym$4", !17, i64 0}
!26 = !{i64 52}
!27 = !{!28, !28, i64 0}
!28 = !{!"ifx$unique_sym$5", !17, i64 0}
!29 = !{i64 11}
!30 = !{i64 57}
!31 = !{!32, !32, i64 0}
!32 = !{!"ifx$unique_sym$6", !17, i64 0}
!33 = !{i64 5}
!34 = !{i64 62}
!35 = !{!36, !36, i64 0}
!36 = !{!"ifx$unique_sym$8", !17, i64 0}
!37 = !{i64 66}
!38 = !{!39, !39, i64 0}
!39 = !{!"ifx$unique_sym$11", !17, i64 0}
!40 = !{i64 34}
!41 = !{!42, !42, i64 0}
!42 = !{!"ifx$unique_sym$13", !43, i64 0}
!43 = !{!"Fortran Data Symbol", !44, i64 0}
!44 = !{!"Generic Fortran Symbol", !45, i64 0}
!45 = !{!"ifx$root$2$test_enzyme_IP_square_"}
!46 = !{i64 74}
!47 = !{i32 100}
!48 = !{i64 36}
!49 = !{i32 101}
!50 = !{i64 38}
!51 = !{i32 335}
!52 = !{i64 49}
!53 = !{i32 337}
!54 = !{i64 54}
!55 = !{i32 338}
!56 = !{i64 58}
!57 = !{i64 75}
!58 = !{!59}
!59 = distinct !{!59, !60, !"primal"}
!60 = distinct !{!60, !" diff: %X"}
!61 = !{!62}
!62 = distinct !{!62, !60, !"shadow_0"}
