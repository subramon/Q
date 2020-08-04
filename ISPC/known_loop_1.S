	.text
	.file	"f1f2opf3.ispc"
	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4               # -- Begin function ispc_vvadd_F4_F4_F4___un_3C_unf_3E_un_3C_unf_3E_uniun_3C_unf_3E_
.LCPI0_0:
	.long	0                       # 0x0
	.long	1                       # 0x1
	.long	2                       # 0x2
	.long	3                       # 0x3
.LCPI0_1:
	.long	4                       # 0x4
	.long	5                       # 0x5
	.long	6                       # 0x6
	.long	7                       # 0x7
	.text
	.globl	ispc_vvadd_F4_F4_F4___un_3C_unf_3E_un_3C_unf_3E_uniun_3C_unf_3E_
	.p2align	4, 0x90
	.type	ispc_vvadd_F4_F4_F4___un_3C_unf_3E_un_3C_unf_3E_uniun_3C_unf_3E_,@function
ispc_vvadd_F4_F4_F4___un_3C_unf_3E_un_3C_unf_3E_uniun_3C_unf_3E_: # @ispc_vvadd_F4_F4_F4___un_3C_unf_3E_un_3C_unf_3E_uniun_3C_unf_3E_
# %bb.0:                                # %allocas
                                        # kill: def $edx killed $edx def $rdx
	leal	7(%rdx), %r8d
	testl	%edx, %edx
	cmovnsl	%edx, %r8d
	andl	$-8, %r8d
	testl	%r8d, %r8d
	jle	.LBB0_1
# %bb.2:                                # %foreach_full_body.lr.ph
	xorl	%eax, %eax
	xorl	%r9d, %r9d
	.p2align	4, 0x90
.LBB0_3:                                # %foreach_full_body
                                        # =>This Inner Loop Header: Depth=1
	cltq
	vmovups	(%rdi,%rax), %xmm0
	vinsertf128	$1, 16(%rdi,%rax), %ymm0, %ymm0
	vmovups	(%rsi,%rax), %xmm1
	vinsertf128	$1, 16(%rsi,%rax), %ymm1, %ymm1
	vaddps	%ymm1, %ymm0, %ymm0
	vextractf128	$1, %ymm0, 16(%rcx,%rax)
	vmovups	%xmm0, (%rcx,%rax)
	addl	$8, %r9d
	addl	$32, %eax
	cmpl	%r8d, %r9d
	jl	.LBB0_3
# %bb.4:                                # %partial_inner_all_outer
	cmpl	%edx, %r9d
	jge	.LBB0_6
.LBB0_5:                                # %partial_inner_only
	vmovd	%r9d, %xmm0
	vpshufd	$0, %xmm0, %xmm0        # xmm0 = xmm0[0,0,0,0]
	vpaddd	.LCPI0_0(%rip), %xmm0, %xmm1
	vpaddd	.LCPI0_1(%rip), %xmm0, %xmm0
	vmovd	%edx, %xmm2
	vpshufd	$0, %xmm2, %xmm2        # xmm2 = xmm2[0,0,0,0]
	vpcmpgtd	%xmm0, %xmm2, %xmm0
	vpcmpgtd	%xmm1, %xmm2, %xmm1
	vinsertf128	$1, %xmm0, %ymm1, %ymm0
	shll	$2, %r9d
	movslq	%r9d, %rax
	vmaskmovps	(%rdi,%rax), %ymm0, %ymm1
	vmaskmovps	(%rsi,%rax), %ymm0, %ymm2
	vaddps	%ymm2, %ymm1, %ymm1
	vmaskmovps	%ymm1, %ymm0, (%rcx,%rax)
.LBB0_6:                                # %foreach_reset
	vzeroupper
	retq
.LBB0_1:
	xorl	%r9d, %r9d
	cmpl	%edx, %r9d
	jl	.LBB0_5
	jmp	.LBB0_6
.Lfunc_end0:
	.size	ispc_vvadd_F4_F4_F4___un_3C_unf_3E_un_3C_unf_3E_uniun_3C_unf_3E_, .Lfunc_end0-ispc_vvadd_F4_F4_F4___un_3C_unf_3E_un_3C_unf_3E_uniun_3C_unf_3E_
                                        # -- End function
	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4               # -- Begin function ispc_vvadd_F4_F4_F4
.LCPI1_0:
	.long	0                       # 0x0
	.long	1                       # 0x1
	.long	2                       # 0x2
	.long	3                       # 0x3
.LCPI1_1:
	.long	4                       # 0x4
	.long	5                       # 0x5
	.long	6                       # 0x6
	.long	7                       # 0x7
	.text
	.globl	ispc_vvadd_F4_F4_F4
	.p2align	4, 0x90
	.type	ispc_vvadd_F4_F4_F4,@function
ispc_vvadd_F4_F4_F4:                    # @ispc_vvadd_F4_F4_F4
# %bb.0:                                # %allocas
                                        # kill: def $edx killed $edx def $rdx
	leal	7(%rdx), %r8d
	testl	%edx, %edx
	cmovnsl	%edx, %r8d
	andl	$-8, %r8d
	testl	%r8d, %r8d
	jle	.LBB1_1
# %bb.2:                                # %foreach_full_body.lr.ph
	xorl	%eax, %eax
	xorl	%r9d, %r9d
	.p2align	4, 0x90
.LBB1_3:                                # %foreach_full_body
                                        # =>This Inner Loop Header: Depth=1
	cltq
	vmovups	(%rdi,%rax), %xmm0
	vinsertf128	$1, 16(%rdi,%rax), %ymm0, %ymm0
	vmovups	(%rsi,%rax), %xmm1
	vinsertf128	$1, 16(%rsi,%rax), %ymm1, %ymm1
	vaddps	%ymm1, %ymm0, %ymm0
	vextractf128	$1, %ymm0, 16(%rcx,%rax)
	vmovups	%xmm0, (%rcx,%rax)
	addl	$8, %r9d
	addl	$32, %eax
	cmpl	%r8d, %r9d
	jl	.LBB1_3
# %bb.4:                                # %partial_inner_all_outer
	cmpl	%edx, %r9d
	jge	.LBB1_6
.LBB1_5:                                # %partial_inner_only
	vmovd	%r9d, %xmm0
	vpshufd	$0, %xmm0, %xmm0        # xmm0 = xmm0[0,0,0,0]
	vpaddd	.LCPI1_0(%rip), %xmm0, %xmm1
	vpaddd	.LCPI1_1(%rip), %xmm0, %xmm0
	vmovd	%edx, %xmm2
	vpshufd	$0, %xmm2, %xmm2        # xmm2 = xmm2[0,0,0,0]
	vpcmpgtd	%xmm0, %xmm2, %xmm0
	vpcmpgtd	%xmm1, %xmm2, %xmm1
	vinsertf128	$1, %xmm0, %ymm1, %ymm0
	shll	$2, %r9d
	movslq	%r9d, %rax
	vmaskmovps	(%rdi,%rax), %ymm0, %ymm1
	vmaskmovps	(%rsi,%rax), %ymm0, %ymm2
	vaddps	%ymm2, %ymm1, %ymm1
	vmaskmovps	%ymm1, %ymm0, (%rcx,%rax)
.LBB1_6:                                # %foreach_reset
	vzeroupper
	retq
.LBB1_1:
	xorl	%r9d, %r9d
	cmpl	%edx, %r9d
	jl	.LBB1_5
	jmp	.LBB1_6
.Lfunc_end1:
	.size	ispc_vvadd_F4_F4_F4, .Lfunc_end1-ispc_vvadd_F4_F4_F4
                                        # -- End function
	.ident	"clang version 10.0.0 (/usr/local/src/llvm/llvm-10.0/clang d32170dbd5b0d54436537b6b75beaf44324e0c28)"
	.section	".note.GNU-stack","",@progbits
