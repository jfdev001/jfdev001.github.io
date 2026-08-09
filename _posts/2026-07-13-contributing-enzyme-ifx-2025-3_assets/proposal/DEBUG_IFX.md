# ifx + llvm combinations

|IFX       | LLVM      | WORKS      | NOTES |
|----------|-----------|------------|-------|
2023.0.0   | 15.0.7    | yes, CI    | N/A 
2023.0.0   | 16.0.6    | no         | bin-llvm/llvm-ar (shipped with IFX) is v16.0.0
2023.2.0   | 17.0.6    | yes, CI    | bin-llvm/llvm-ar --version is v17.0.0
2023.2.1   | 17.0.6    | yes        | minor version makes no difference here
2025.2.1   | 20.1.8    | no         | easiest to install via spack, 1/6 passed fortran tests
2025.2.1   | 21.0.0    | no         | bin-llvm/llvm-ar --version is 21.0.0
2025.2.1   | 21.1.1    | no         | 2/6 passed tests 
2025.2.1   | 21.1.8    | no         | latest llvm v21, 2/6 passed tests (**prototype with this?**)
2025.3.2   | 21.1.8    | no         | 1/6 passed tests, **ICON** will use this version, ifx v2025.3.2 lifted from levante spack, llvm 21.1.8 is most stable llvm v21 but not officially supported in spack so did `spack checksum llvm 21.1.8` and updated llvm spack file accordingly...
2025.3.3   | 21.1.8    | no         | ran in docker container, not possible with spack, 2/6 passed fortran tests 

How debugging works for this sort of thing:

* Sometimes you need to debug with llvm dis, see:

https://github.com/EnzymeAD/Enzyme/pull/2809#issuecomment-4491338108

* problems with ifx in general:

https://github.com/EnzymeAD/Enzyme/pull/2809#issuecomment-4509550057

* disabling yaml support for other stuff:

https://github.com/EnzymeAD/Enzyme/pull/2837/changes

* triggering github actions

https://github.com/orgs/community/discussions/169535#discussioncomment-14077926

* Trying to debug ifx 2025.3 build...:

https://github.com/copilot/share/42470228-0ae4-88e3-8003-9a0cc41a605b


## jfrazier/support-ifx-2025-3

**Failed CI initial**
* https://github.com/jfdev001/Enzyme-ICON/actions/runs/29230989723/job/86754976950
* 7d72c4a2acc9fe85b18eec916052d12eb9167f21
* `logs/20260713_github_29230989723_ifx_2025-3_llvm_21/`

Both local spack 2025.3.2 and GH Action 2025.3.3 have the same failing tests
(.e., 4/6 tests) fail... makes sense also given that there are no release notes
for IFX 2025.3.3 and we know already that minor version shouldn't really make
a difference

https://community.intel.com/t5/Intel-Fortran-Compiler/Where-are-the-release-notes-for-2025-3-3/m-p/1742315#M178614

## Intel subscript arg count difference

```llvm
; ifx 2023.0.0 and LLVM 15.0.7
%"X[]" = tail call float* @llvm.intel.subscript.p0f32.i64.i64.p0f32.i64(
    i8 0,                                    ; 0
    i64 1,                                   ; 1
    i64 4,                                   ; 2
    float* nonnull elementtype(float) %X,    ; 3
    i64 1),                                  ; 4
!llfort.type_idx !8                          
arg_size=5
```

```llvm
; ifx 2023.2.0 and LLVM 17.0.6
%"X[]" = tail call ptr @llvm.intel.subscript.p0.i64.i64.p0.i64(
  i8 0,                                ; 0
  i64 1,                               ; 1
  i64 4,                               ; 2
  ptr nonnull elementtype(float) %X,   ; 3
  i64 1),                              ; 4
!llfort.type_idx !2                    
arg_size=5
```

```llvm
; ifx 2025.3.2 and LLVM 21.1.8
%"X[]" = tail call ptr @llvm.intel.subscript.p0.i64.i64.p0.i64.i64(
    i8 0,                               ; 0 
    i64 1,                              ; 1
    i64 4,                              ; 2
    ptr nonnull elementtype(float) %X,  ; 3
    i64 1,                              ; 4
    i64 %int_sext),                     ; 5
!llfort.type_idx !9 
arg_size=6
```

