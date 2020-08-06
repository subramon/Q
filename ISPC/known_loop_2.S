	.text
	.file	"f1f2opf3.ispc"
	.globl	ispc_vvadd_F4_F4_F4___un_3C_unf_3E_un_3C_unf_3E_un_3C_unf_3E_ # -- Begin function ispc_vvadd_F4_F4_F4___un_3C_unf_3E_un_3C_unf_3E_un_3C_unf_3E_
	.p2align	4, 0x90
	.type	ispc_vvadd_F4_F4_F4___un_3C_unf_3E_un_3C_unf_3E_un_3C_unf_3E_,@function
ispc_vvadd_F4_F4_F4___un_3C_unf_3E_un_3C_unf_3E_un_3C_unf_3E_: # @ispc_vvadd_F4_F4_F4___un_3C_unf_3E_un_3C_unf_3E_un_3C_unf_3E_
# %bb.0:                                # %allocas
	movq	$-32, %rax
	.p2align	4, 0x90
.LBB0_1:                                # %foreach_full_body
                                        # =>This Inner Loop Header: Depth=1
	vmovups	128(%rdi,%rax,4), %xmm0
	vinsertf128	$1, 144(%rdi,%rax,4), %ymm0, %ymm0
	vmovups	128(%rsi,%rax,4), %xmm1
	vinsertf128	$1, 144(%rsi,%rax,4), %ymm1, %ymm1
	vaddps	%ymm1, %ymm0, %ymm0
	vmovups	160(%rdi,%rax,4), %xmm1
	vinsertf128	$1, 176(%rdi,%rax,4), %ymm1, %ymm1
	vextractf128	$1, %ymm0, 144(%rdx,%rax,4)
	vmovups	160(%rsi,%rax,4), %xmm2
	vinsertf128	$1, 176(%rsi,%rax,4), %ymm2, %ymm2
	vmovups	%xmm0, 128(%rdx,%rax,4)
	vaddps	%ymm2, %ymm1, %ymm0
	vextractf128	$1, %ymm0, 176(%rdx,%rax,4)
	vmovups	%xmm0, 160(%rdx,%rax,4)
	vmovups	192(%rdi,%rax,4), %xmm0
	vinsertf128	$1, 208(%rdi,%rax,4), %ymm0, %ymm0
	vmovups	192(%rsi,%rax,4), %xmm1
	vinsertf128	$1, 208(%rsi,%rax,4), %ymm1, %ymm1
	vaddps	%ymm1, %ymm0, %ymm0
	vextractf128	$1, %ymm0, 208(%rdx,%rax,4)
	vmovups	%xmm0, 192(%rdx,%rax,4)
	vmovups	224(%rdi,%rax,4), %xmm0
	vinsertf128	$1, 240(%rdi,%rax,4), %ymm0, %ymm0
	vmovups	224(%rsi,%rax,4), %xmm1
	vinsertf128	$1, 240(%rsi,%rax,4), %ymm1, %ymm1
	vaddps	%ymm1, %ymm0, %ymm0
	vextractf128	$1, %ymm0, 240(%rdx,%rax,4)
	vmovups	%xmm0, 224(%rdx,%rax,4)
	addq	$32, %rax
	cmpq	$992, %rax              # imm = 0x3E0
	jb	.LBB0_1
# %bb.2:                                # %partial_inner_all_outer
	vzeroupper
	retq
.Lfunc_end0:
	.size	ispc_vvadd_F4_F4_F4___un_3C_unf_3E_un_3C_unf_3E_un_3C_unf_3E_, .Lfunc_end0-ispc_vvadd_F4_F4_F4___un_3C_unf_3E_un_3C_unf_3E_un_3C_unf_3E_
                                        # -- End function
	.globl	ispc_vvadd_F4_F4_F4     # -- Begin function ispc_vvadd_F4_F4_F4
	.p2align	4, 0x90
	.type	ispc_vvadd_F4_F4_F4,@function
ispc_vvadd_F4_F4_F4:                    # @ispc_vvadd_F4_F4_F4
# %bb.0:                                # %allocas
	movq	$-32, %rax
	.p2align	4, 0x90
.LBB1_1:                                # %foreach_full_body
                                        # =>This Inner Loop Header: Depth=1
	vmovups	128(%rdi,%rax,4), %xmm0
	vinsertf128	$1, 144(%rdi,%rax,4), %ymm0, %ymm0
	vmovups	128(%rsi,%rax,4), %xmm1
	vinsertf128	$1, 144(%rsi,%rax,4), %ymm1, %ymm1
	vaddps	%ymm1, %ymm0, %ymm0
	vmovups	160(%rdi,%rax,4), %xmm1
	vinsertf128	$1, 176(%rdi,%rax,4), %ymm1, %ymm1
	vextractf128	$1, %ymm0, 144(%rdx,%rax,4)
	vmovups	160(%rsi,%rax,4), %xmm2
	vinsertf128	$1, 176(%rsi,%rax,4), %ymm2, %ymm2
	vmovups	%xmm0, 128(%rdx,%rax,4)
	vaddps	%ymm2, %ymm1, %ymm0
	vextractf128	$1, %ymm0, 176(%rdx,%rax,4)
	vmovups	%xmm0, 160(%rdx,%rax,4)
	vmovups	192(%rdi,%rax,4), %xmm0
	vinsertf128	$1, 208(%rdi,%rax,4), %ymm0, %ymm0
	vmovups	192(%rsi,%rax,4), %xmm1
	vinsertf128	$1, 208(%rsi,%rax,4), %ymm1, %ymm1
	vaddps	%ymm1, %ymm0, %ymm0
	vextractf128	$1, %ymm0, 208(%rdx,%rax,4)
	vmovups	%xmm0, 192(%rdx,%rax,4)
	vmovups	224(%rdi,%rax,4), %xmm0
	vinsertf128	$1, 240(%rdi,%rax,4), %ymm0, %ymm0
	vmovups	224(%rsi,%rax,4), %xmm1
	vinsertf128	$1, 240(%rsi,%rax,4), %ymm1, %ymm1
	vaddps	%ymm1, %ymm0, %ymm0
	vextractf128	$1, %ymm0, 240(%rdx,%rax,4)
	vmovups	%xmm0, 224(%rdx,%rax,4)
	addq	$32, %rax
	cmpq	$992, %rax              # imm = 0x3E0
	jb	.LBB1_1
# %bb.2:                                # %partial_inner_all_outer
	vzeroupper
	retq
.Lfunc_end1:
	.size	ispc_vvadd_F4_F4_F4, .Lfunc_end1-ispc_vvadd_F4_F4_F4
                                        # -- End function
	.ident	"clang version 10.0.0 (/usr/local/src/llvm/llvm-10.0/clang d32170dbd5b0d54436537b6b75beaf44324e0c28)"
	.section	".note.GNU-stack","",@progbits
