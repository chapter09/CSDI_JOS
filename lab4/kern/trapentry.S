/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
	TRAPHANDLER_NOEC(entry_div_err, T_DIVIDE);
	TRAPHANDLER_NOEC(entry_deb_exc, T_DEBUG);
	TRAPHANDLER_NOEC(entry_nmi, T_NMI);
	TRAPHANDLER_NOEC(entry_brkpt, T_BRKPT);
	TRAPHANDLER_NOEC(entry_ovflow, T_OFLOW);
	TRAPHANDLER_NOEC(entry_bound, T_BOUND);
	TRAPHANDLER_NOEC(entry_illop, T_ILLOP);
	TRAPHANDLER_NOEC(entry_dev, T_DEVICE);
	TRAPHANDLER(entry_dfault, T_DBLFLT);
	TRAPHANDLER(entry_copboc, -1); //9
	TRAPHANDLER(entry_tss, T_TSS);
	TRAPHANDLER(entry_segnp, T_SEGNP);
	TRAPHANDLER(entry_stack, T_STACK);
	TRAPHANDLER(entry_gpfault, T_GPFLT);
	TRAPHANDLER(entry_pgfault, T_PGFLT);
	TRAPHANDLER(entry_res, -1); //15
	TRAPHANDLER_NOEC(entry_fp_err, T_FPERR);
	TRAPHANDLER_NOEC(entry_align_chk, T_ALIGN);
	TRAPHANDLER_NOEC(entry_mach_chk, T_MCHK);
	TRAPHANDLER_NOEC(entry_simd_fp_err, T_SIMDERR);
	TRAPHANDLER_NOEC(entry_sys_call, T_SYSCALL);


	TRAPHANDLER_NOEC(handler_irq_0, IRQ_OFFSET + 0);
	TRAPHANDLER_NOEC(handler_irq_1, IRQ_OFFSET + 1);
	TRAPHANDLER_NOEC(handler_irq_2, IRQ_OFFSET + 2);
	TRAPHANDLER_NOEC(handler_irq_3, IRQ_OFFSET + 3);
	TRAPHANDLER_NOEC(handler_irq_4, IRQ_OFFSET + 4);
	TRAPHANDLER_NOEC(handler_irq_5, IRQ_OFFSET + 5);
	TRAPHANDLER_NOEC(handler_irq_6, IRQ_OFFSET + 6);
	TRAPHANDLER_NOEC(handler_irq_7, IRQ_OFFSET + 7);
	TRAPHANDLER_NOEC(handler_irq_8, IRQ_OFFSET + 8);
	TRAPHANDLER_NOEC(handler_irq_9, IRQ_OFFSET + 9);
	TRAPHANDLER_NOEC(handler_irq_10, IRQ_OFFSET +10);
	TRAPHANDLER_NOEC(handler_irq_11, IRQ_OFFSET +11);
	TRAPHANDLER_NOEC(handler_irq_12, IRQ_OFFSET + 12);
	TRAPHANDLER_NOEC(handler_irq_13, IRQ_OFFSET +13);
	TRAPHANDLER_NOEC(handler_irq_14, IRQ_OFFSET +14);
	TRAPHANDLER_NOEC(handler_irq_15, IRQ_OFFSET +15);


.globl sysenter_handler;
.type sysenter_handler, @function;
.align 2;
sysenter_handler:
/*
 * Lab 3: Your code here for system call handling
 */
    pushl %esi
    pushl %ebp
    pushl %edi
    pushl %edi
    pushl %ebx
    pushl %ecx
    pushl %edx
    pushl %eax 
    call syscall_dummy
    popl %ebx
    popl %ebx
    popl %ebx
    popl %ebx
    popl %ebx
    popl %ebx
    popl %ecx
    popl %edx
    pushfl      //enable IF
    movl (%esp),%ebx
    orl $0x200,%ebx
    movl %ebx, (%esp)
    popfl
	sysexit

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
	pushl %es
	pushal

	movw $GD_KD, %ax
	movw %ax, %ds
	movw %ax, %es

	pushl %esp
	call trap

