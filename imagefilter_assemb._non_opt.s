	.file	"imagefilter.s"
	.comm	image1,64256,32 #array declaration to hold image
	.comm	image2,64256,32
	.comm	h,4,4 #loop control variables:
	.comm	i,4,4
	.comm	j,4,4
	.comm	k,4,4
	.comm	l,4,4
	.comm	sum,4,4
	.comm	iterations,4,4
	.section	.rodata
.LC0:
	.string	"rb"
.LC1:
	.string	"roller1.raw" #file name
.LC2:
	.string	"wb"
.LC3:
	.string	"roller2.raw" #file names
.LC4:
	.string	"Impossible to open file in read mode!" # If file can't be opened in read mode
	.align 8
.LC5:
	.string	"Impossible to open file in write mode!" # If file can't be opened in write mode
	.align 8
.LC6:
	.string	"Enter the number of iterations: " get the blur factor value
.LC7:
	.string	"%d"
.LC8:
	.string	"computing results.. "
.LC9:
	.string	"Writing result "
	.text
	.globl	main
	.type	main, @function
main:
.LFB2:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16 # copying data from input array to output array
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movl	%edi, -20(%rbp)
	movq	%rsi, -32(%rbp)
	movl	$.LC0, %esi
	movl	$.LC1, %edi
	call	fopen
	movq	%rax, -16(%rbp)
	movl	$.LC2, %esi
	movl	$.LC3, %edi
	call	fopen
	movq	%rax, -8(%rbp)
	cmpq	$0, -16(%rbp)
	jne	.L2
	movl	$.LC4, %edi
	movl	$0, %eax
	call	printf
	movl	$1, %edi
	call	exit
.L2:
	cmpq	$0, -8(%rbp)
	jne	.L3
	movl	$.LC5, %edi
	movl	$0, %eax
	call	printf
	movl	$1, %edi
	call	exit
.L3:
	movq	-16(%rbp), %rax
	movq	%rax, %rcx
	movl	$1, %edx
	movl	$63750, %esi
	movl	$image1, %edi # reading file data in long
	call	fread
	movl	$.LC6, %edi
	call	puts
	movl	$iterations, %esi
	movl	$.LC7, %edi
	movl	$0, %eax
	call	__isoc99_scanf
	movl	$.LC8, %edi
	call	puts
	movl	$0, i(%rip)
	jmp	.L4
.L7:
	movl	$0, j(%rip)
	jmp	.L5
.L6:
	movl	i(%rip), %ecx # For each element in row and column ,compute a new value
	movl	j(%rip), %edx
	movl	i(%rip), %esi
	movl	j(%rip), %eax
	cltq
	movslq	%esi, %rsi
	salq	$8, %rsi
	addq	%rsi, %rax
	addq	$image1, %rax # copying data file to array in quad word
	movzbl	(%rax), %eax
	movslq	%edx, %rdx
	movslq	%ecx, %rcx
	salq	$8, %rcx
	addq	%rcx, %rdx
	addq	$image2, %rdx  # copying data to second array
	movb	%al, (%rdx)
	movl	j(%rip), %eax
	addl	$1, %eax
	movl	%eax, j(%rip)
.L5:
	movl	j(%rip), %eax
	cmpl	$255, %eax
	jle	.L6
	movl	i(%rip), %eax
	addl	$1, %eax
	movl	%eax, i(%rip)
.L4:
	movl	i(%rip), %eax
	cmpl	$250, %eax
	jle	.L7
	movl	$1, h(%rip)
	jmp	.L8
.L21:
	movl	$1, i(%rip)
	jmp	.L9
.L16:
	movl	$1, j(%rip)
	jmp	.L10
.L15:
	movl	$0, 
(%rip) #computing a new value of sum
	movl	$-1, k(%rip)
	jmp	.L11
.L14:
	movl	$-1, l(%rip)
	jmp	.L12
.L13:
	movl	i(%rip), %edx
	movl	k(%rip), %eax
	leal	(%rdx,%rax), %ecx
	movl	j(%rip), %edx
	movl	l(%rip), %eax
	addl	%edx, %eax
	cltq
	movslq	%ecx, %rdx
	salq	$8, %rdx
	addq	%rdx, %rax
	addq	$image1, %rax
	movzbl	(%rax), %eax
	movzbl	%al, %edx
	movl	sum(%rip), %eax # use new value of sum in calculating the new element to be copied
	addl	%edx, %eax
	movl	%eax, sum(%rip)
	movl	l(%rip), %eax #Inner most loop using l variable
	addl	$1, %eax
	movl	%eax, l(%rip)
.L12:
	movl	l(%rip), %eax
	cmpl	$1, %eax
	jle	.L13
	movl	k(%rip), %eax #The inner most loop using k variable
	addl	$1, %eax
	movl	%eax, k(%rip)
.L11:
	movl	k(%rip), %eax
	cmpl	$1, %eax
	jle	.L14
	movl	i(%rip), %ecx
	movl	j(%rip), %esi
	movl	i(%rip), %edx
	movl	j(%rip), %eax
	cltq
	movslq	%edx, %rdx
	salq	$8, %rdx
	addq	%rdx, %rax
	addq	$image1, %rax #copying data from first array for processing
	movzbl	(%rax), %eax
	movzbl	%al, %edx
	movl	%edx, %eax
	sall	$3, %eax
	subl	%edx, %eax
	movl	%eax, %edx
	movl	sum(%rip), %eax
	addl	%edx, %eax
	leal	15(%rax), %edx
	testl	%eax, %eax
	cmovs	%edx, %eax
	sarl	$4, %eax
	movl	%eax, %edi
	movslq	%esi, %rax
	movslq	%ecx, %rdx
	salq	$8, %rdx
	addq	%rdx, %rax
	addq	$image2, %rax # copying data from second array
	movb	%dil, (%rax)
	movl	j(%rip), %eax
	addl	$1, %eax
	movl	%eax, j(%rip)
.L10:
	movl	j(%rip), %eax
	cmpl	$254, %eax
	jle	.L15
	movl	i(%rip), %eax
	addl	$1, %eax
	movl	%eax, i(%rip)
.L9:
	movl	i(%rip), %eax
	cmpl	$249, %eax
	jle	.L16
	movl	$0, i(%rip)
	jmp	.L17
.L20:
	movl	$0, j(%rip)
	jmp	.L18
.L19:
	movl	i(%rip), %ecx
	movl	j(%rip), %edx
	movl	i(%rip), %esi
	movl	j(%rip), %eax
	cltq
	movslq	%esi, %rsi
	salq	$8, %rsi
	addq	%rsi, %rax
	addq	$image2, %rax # copying data from second array
	movzbl	(%rax), %eax
	movslq	%edx, %rdx
	movslq	%ecx, %rcx
	salq	$8, %rcx
	addq	%rcx, %rdx
	addq	$image1, %rdx
	movb	%al, (%rdx)
	movl	j(%rip), %eax # copying input cell values back to output cell 
	addl	$1, %eax
	movl	%eax, j(%rip)
.L18:
	movl	j(%rip), %eax
	cmpl	$255, %eax
	jle	.L19
	movl	i(%rip), %eax # copying input cell values back to output cell 
	addl	$1, %eax
	movl	%eax, i(%rip)
.L17:
	movl	i(%rip), %eax
	cmpl	$250, %eax
	jle	.L20
	movl	h(%rip), %eax #Outside loop iterating the number specified by the user
	addl	$1, %eax
	movl	%eax, h(%rip)
.L8:
	movl	h(%rip), %edx
	movl	iterations(%rip), %eax
	cmpl	%eax, %edx
	jle	.L21
	movl	$.LC9, %edi
	call	puts
	movq	-8(%rbp), %rax
	movq	%rax, %rcx
	movl	$1, %edx
	movl	$63750, %esi
	movl	$image2, %edi
	call	fwrite
	movq	-16(%rbp), %rax
	movq	%rax, %rdi
	call	fclose     #close file 
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	fclose     # close file
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	main, .-main
	.ident	
	.section	.note.GNU-stack,"",@progbits
