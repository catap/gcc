/* PowerPC support code for fibers and multithreading.
   Copyright (C) 2019-2026 Free Software Foundation, Inc.

This file is part of GCC.

GCC is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

GCC is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

Under Section 7 of GPL version 3, you are granted additional
permissions described in the GCC Runtime Library Exception, version
3.1, as published by the Free Software Foundation.

You should have received a copy of the GNU General Public License and
a copy of the GCC Runtime Library Exception along with this program;
see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
<http://www.gnu.org/licenses/>.  */

#include "../common/threadasm.S"

#if defined(__ELF__)

/**
 * Performs a context switch.
 *
 * r3 - old context pointer
 * r4 - new context pointer
 *
 */
    .text
    .globl CSYM(fiber_switchContext)
    .type CSYM(fiber_switchContext), @function
    .align 2
CSYM(fiber_switchContext):
    .cfi_startproc
#ifdef __PPC64__
    /* ELF64 - Save linkage area */
    mflr        0
    mfcr        5
    std     0, 16(1)
    stw     5, 8(1)

    /* Make room for 18 GPRs, 18 FPRs */
    addi    6, 1, -18 * 8
    addi    1, 6, -18 * 8

    /* Save GPRs */
    std     31, (17 * 8)(6)
    std     30, (16 * 8)(6)
    std     29, (15 * 8)(6)
    std     28, (14 * 8)(6)
    std     27, (13 * 8)(6)
    std     26, (12 * 8)(6)
    std     25, (11 * 8)(6)
    std     24, (10 * 8)(6)
    std     23, (9 * 8)(6)
    std     22, (8 * 8)(6)
    std     21, (7 * 8)(6)
    std     20, (6 * 8)(6)
    std     19, (5 * 8)(6)
    std     18, (4 * 8)(6)
    std     17, (3 * 8)(6)
    std     16, (2 * 8)(6)
    std     15, (1 * 8)(6)
    std     14, (0 * 8)(6)
#else
    /* ELF32 - Save linkage area */
    mflr        0
    mfcr        5
    stw     0, 4(1)

    /* Make room for 18 GPRs, CR, 18 FPRs; rounding up so r1 stays
       16-byte aligned.  We must move r1, because ELF32 allows
       signals to clobber below r1 (no red zone). */
    addi    6, 1, -20 * 4
    addi    1, 6, -18 * 8

    /* Save GPRs */
    stw     31, (19 * 4)(6)
    stw     30, (18 * 4)(6)
    stw     29, (17 * 4)(6)
    stw     28, (16 * 4)(6)
    stw     27, (15 * 4)(6)
    stw     26, (14 * 4)(6)
    stw     25, (13 * 4)(6)
    stw     24, (12 * 4)(6)
    stw     23, (11 * 4)(6)
    stw     22, (10 * 4)(6)
    stw     21, (9 * 4)(6)
    stw     20, (8 * 4)(6)
    stw     19, (7 * 4)(6)
    stw     18, (6 * 4)(6)
    stw     17, (5 * 4)(6)
    stw     16, (4 * 4)(6)
    stw     15, (3 * 4)(6)
    stw     14, (2 * 4)(6)

    /* Save condition register */
    stw     5, 0(6)
#endif

    /* ELF32 and ELF64 - Save FPRs */
    stfd    31, (-1 * 8)(6)
    stfd    30, (-2 * 8)(6)
    stfd    29, (-3 * 8)(6)
    stfd    28, (-4 * 8)(6)
    stfd    27, (-5 * 8)(6)
    stfd    26, (-6 * 8)(6)
    stfd    25, (-7 * 8)(6)
    stfd    24, (-8 * 8)(6)
    stfd    23, (-9 * 8)(6)
    stfd    22, (-10 * 8)(6)
    stfd    21, (-11 * 8)(6)
    stfd    20, (-12 * 8)(6)
    stfd    19, (-13 * 8)(6)
    stfd    18, (-14 * 8)(6)
    stfd    17, (-15 * 8)(6)
    stfd    16, (-16 * 8)(6)
    stfd    15, (-17 * 8)(6)
    stfd    14, (-18 * 8)(6)

    /* Save r6 in the old context, since we do not want the GC to
       scan the floating point registers. */

#ifdef __PPC64__
    /* ELF64 - Update the old stack pointer */
    std     6, 0(3)

    /* Set new stack pointer */
    addi    1, 4, -18 * 8

    /* Set condition and link register.  If lr is &fiber_entryPoint,
       then ELFv2 ABI needs the same address in r12. */
    lwz     5, (18 * 8 + 8)(4)
    ld      12, (18 * 8 + 16)(4)
    mtcr        5
    mtlr        12
#else
    /* ELF32 - Update the old stack pointer */
    stw     6, 0(3)

    /* Set new stack pointer */
    addi    1, 4, -18 * 8

    /* Set condition and link register */
    lwz     5, 0(4)
    lwz     12, (20 * 4 + 4)(4)
    mtcr        5
    mtlr        12
#endif

    /* PPC32 and PPC64 - Restore FPRs */
    lfd     14, (-18 * 8)(4)
    lfd     15, (-17 * 8)(4)
    lfd     16, (-16 * 8)(4)
    lfd     17, (-15 * 8)(4)
    lfd     18, (-14 * 8)(4)
    lfd     19, (-13 * 8)(4)
    lfd     20, (-12 * 8)(4)
    lfd     21, (-11 * 8)(4)
    lfd     22, (-10 * 8)(4)
    lfd     23, (-9 * 8)(4)
    lfd     24, (-8 * 8)(4)
    lfd     25, (-7 * 8)(4)
    lfd     26, (-6 * 8)(4)
    lfd     27, (-5 * 8)(4)
    lfd     28, (-4 * 8)(4)
    lfd     29, (-3 * 8)(4)
    lfd     30, (-2 * 8)(4)
    lfd     31, (-1 * 8)(4)

#ifdef __PPC64__
    /* PPC64 - Restore GPRs */
    ld      14, (0 * 8)(4)
    ld      15, (1 * 8)(4)
    ld      16, (2 * 8)(4)
    ld      17, (3 * 8)(4)
    ld      18, (4 * 8)(4)
    ld      19, (5 * 8)(4)
    ld      20, (6 * 8)(4)
    ld      21, (7 * 8)(4)
    ld      22, (8 * 8)(4)
    ld      23, (9 * 8)(4)
    ld      24, (10 * 8)(4)
    ld      25, (11 * 8)(4)
    ld      26, (12 * 8)(4)
    ld      27, (13 * 8)(4)
    ld      28, (14 * 8)(4)
    ld      29, (15 * 8)(4)
    ld      30, (16 * 8)(4)
    ld      31, (17 * 8)(4)

    /* Return and switch context */
    addi    1, 4, 18 * 8
    blr
#else
    /* PPC32 - Restore GPRs */
    lwz     14, (2 * 4)(4)
    lwz     15, (3 * 4)(4)
    lwz     16, (4 * 4)(4)
    lwz     17, (5 * 4)(4)
    lwz     18, (6 * 4)(4)
    lwz     19, (7 * 4)(4)
    lwz     20, (8 * 4)(4)
    lwz     21, (9 * 4)(4)
    lwz     22, (10 * 4)(4)
    lwz     23, (11 * 4)(4)
    lwz     24, (12 * 4)(4)
    lwz     25, (13 * 4)(4)
    lwz     26, (14 * 4)(4)
    lwz     27, (15 * 4)(4)
    lwz     28, (16 * 4)(4)
    lwz     29, (17 * 4)(4)
    lwz     30, (18 * 4)(4)
    lwz     31, (19 * 4)(4)

    /* Return and switch context */
    addi    1, 4, 20 * 4
    blr
#endif
    .cfi_endproc
    .size CSYM(fiber_switchContext),.-CSYM(fiber_switchContext)

#elif !defined(__PPC64__) && !defined(__MACH__)

/**
 * Performs a context switch.
 *
 * r3 - old context pointer
 * r4 - new context pointer
 *
 */
    .text
    .globl CSYM(fiber_switchContext)
    .type CSYM(fiber_switchContext), @function
    .align 2
CSYM(fiber_switchContext):
    .cfi_startproc
    /* Save linkage area */
    mflr        0
    mfcr        5
    stw     0, 8(1)
    stw     5, 4(1)

    /* Save GPRs */
    stw     11, (-1 * 4)(1)
    stw     13, (-2 * 4)(1)
    stw     14, (-3 * 4)(1)
    stw     15, (-4 * 4)(1)
    stw     16, (-5 * 4)(1)
    stw     17, (-6 * 4)(1)
    stw     18, (-7 * 4)(1)
    stw     19, (-8 * 4)(1)
    stw     20, (-9 * 4)(1)
    stw     21, (-10 * 4)(1)
    stw     22, (-11 * 4)(1)
    stw     23, (-12 * 4)(1)
    stw     24, (-13 * 4)(1)
    stw     25, (-14 * 4)(1)
    stw     26, (-15 * 4)(1)
    stw     27, (-16 * 4)(1)
    stw     28, (-17 * 4)(1)
    stw     29, (-18 * 4)(1)
    stw     30, (-19 * 4)(1)
    stwu    31, (-20 * 4)(1)

    /* We update the stack pointer here, since we do not want the GC to
       scan the floating point registers. */

    /* Save FPRs */
    stfd    14, (-1 * 8)(1)
    stfd    15, (-2 * 8)(1)
    stfd    16, (-3 * 8)(1)
    stfd    17, (-4 * 8)(1)
    stfd    18, (-5 * 8)(1)
    stfd    19, (-6 * 8)(1)
    stfd    20, (-7 * 8)(1)
    stfd    21, (-8 * 8)(1)
    stfd    22, (-9 * 8)(1)
    stfd    23, (-10 * 8)(1)
    stfd    24, (-11 * 8)(1)
    stfd    25, (-12 * 8)(1)
    stfd    26, (-13 * 8)(1)
    stfd    27, (-14 * 8)(1)
    stfd    28, (-15 * 8)(1)
    stfd    29, (-16 * 8)(1)
    stfd    30, (-17 * 8)(1)
    stfd    31, (-18 * 8)(1)

    /* Update the old stack pointer */
    stw     1, 0(3)

    /* Set new stack pointer */
    addi        1, 4, 20 * 4

    /* Restore linkage area */
    lwz     0, 8(1)
    lwz     5, 4(1)

    /* Restore GPRs */
    lwz     11, (-1 * 4)(1)
    lwz     13, (-2 * 4)(1)
    lwz     14, (-3 * 4)(1)
    lwz     15, (-4 * 4)(1)
    lwz     16, (-5 * 4)(1)
    lwz     17, (-6 * 4)(1)
    lwz     18, (-7 * 4)(1)
    lwz     19, (-8 * 4)(1)
    lwz     20, (-9 * 4)(1)
    lwz     21, (-10 * 4)(1)
    lwz     22, (-11 * 4)(1)
    lwz     23, (-12 * 4)(1)
    lwz     24, (-13 * 4)(1)
    lwz     25, (-14 * 4)(1)
    lwz     26, (-15 * 4)(1)
    lwz     27, (-16 * 4)(1)
    lwz     28, (-17 * 4)(1)
    lwz     29, (-18 * 4)(1)
    lwz     30, (-19 * 4)(1)
    lwz     31, (-20 * 4)(1)

    /* Restore FPRs */
    lfd     14, (-1 * 8)(4)
    lfd     15, (-2 * 8)(4)
    lfd     16, (-3 * 8)(4)
    lfd     17, (-4 * 8)(4)
    lfd     18, (-5 * 8)(4)
    lfd     19, (-6 * 8)(4)
    lfd     20, (-7 * 8)(4)
    lfd     21, (-8 * 8)(4)
    lfd     22, (-9 * 8)(4)
    lfd     23, (-10 * 8)(4)
    lfd     24, (-11 * 8)(4)
    lfd     25, (-12 * 8)(4)
    lfd     26, (-13 * 8)(4)
    lfd     27, (-14 * 8)(4)
    lfd     28, (-15 * 8)(4)
    lfd     29, (-16 * 8)(4)
    lfd     30, (-17 * 8)(4)
    lfd     31, (-18 * 8)(4)

    /* Set condition and link register */
    mtcr        5
    mtlr        0

    /* Return and switch context */
    blr
    .cfi_endproc
    .size CSYM(fiber_switchContext),.-CSYM(fiber_switchContext)

#elif defined(__MACH__)

/* Implementation for Darwin/macOS preserving callee-saved regs.

   FIXME : There is no unwind frame.
   FIXME : not sure if we should save the vsave reg (perhaps using the slot we have
           r11 in at present).  */

/* Darwin has a red zone (220 bytes for PPC 288 for PPC64) which we can write
   to before the stack is updated without worrying about it being clobbered by
   signals or hardware interrupts.

   The stack will be 16byte aligned on entry with:
						  PPC	PPC64
   SP-> +---------------------------------------+
	| back chain to caller			| 0	  0
	+---------------------------------------+
	| slot to save CR			| 4       8
	+---------------------------------------+
	| slot to save LR			| 8       16
	+---------------------------------------+
	| etc.. etc.. as per C calling conv.    |  */

# if __PPC64__
#  define LD ld
#  define ST std
#  define STU stdu
#  define SZ 8
#  define MACHINE ppc64
#  define RED_ZONE 288
# else
#  define LD lwz
#  define ST stw
#  define STU stwu
#  define SZ 4
#  define MACHINE ppc7400
#  define RED_ZONE 220
# endif

# define SAVE_VECTORS 0
/**
 * Performs a context switch.
 *
 * r3 - old context pointer
 * r4 - new context pointer
 *
 */
    .machine MACHINE
    .text
    .globl CSYM(fiber_switchContext)
    .align 2
CSYM(fiber_switchContext):
LFB0:
    /* Get the link reg. */
    mflr  r0
    /* Get the callee-saved crs (well all of them, actually). */
    mfcr  r12

    /* Save GPRs, we save the static chain here too although it is not clear if we need to.  */
    ST    r31, ( -1 * SZ)(r1)
    ST    r30, ( -2 * SZ)(r1)
    ST    r29, ( -3 * SZ)(r1)
    ST    r28, ( -4 * SZ)(r1)
    ST    r27, ( -5 * SZ)(r1)
    ST    r26, ( -6 * SZ)(r1)
    ST    r25, ( -7 * SZ)(r1)
    ST    r24, ( -8 * SZ)(r1)
    ST    r23, ( -9 * SZ)(r1)
    ST    r22, (-10 * SZ)(r1)
    ST    r21, (-11 * SZ)(r1)
    ST    r20, (-12 * SZ)(r1)
    ST    r19, (-13 * SZ)(r1)
    ST    r18, (-14 * SZ)(r1)
    ST    r17, (-15 * SZ)(r1)
    ST    r16, (-16 * SZ)(r1)
    ST    r15, (-17 * SZ)(r1)
    ST    r14, (-18 * SZ)(r1)
    ST    r13, (-19 * SZ)(r1)

    /* Save the lr and cr into the normal function linkage area.  */
    ST    r0, 2*SZ(r1)
    ST    r12, SZ(r1)

    /* We update the stack pointer here, since we do not want the GC to
       scan the floating point registers. We are still 16-byte aligned. */
    STU   r11, (-20 * SZ)(r1)

    /* Update the stack pointer in the old context as per comment above. */
    ST    r1, 0(r3)

    /* Save FPRs - same for PPC and PPC64 */
    stfd  f14, (-18 * 8)(r1)
    stfd  f15, (-17 * 8)(r1)
    stfd  f16, (-16 * 8)(r1)
    stfd  f17, (-15 * 8)(r1)
    stfd  f18, (-14 * 8)(r1)
    stfd  f19, (-13 * 8)(r1)
    stfd  f20, (-12 * 8)(r1)
    stfd  f21, (-11 * 8)(r1)
    stfd  f22, (-10 * 8)(r1)
    stfd  f23, ( -9 * 8)(r1)
    stfd  f24, ( -8 * 8)(r1)
    stfd  f25, ( -7 * 8)(r1)
    stfd  f26, ( -6 * 8)(r1)
    stfd  f27, ( -5 * 8)(r1)
    stfd  f28, ( -4 * 8)(r1)
    stfd  f29, ( -3 * 8)(r1)
    stfd  f30, ( -2 * 8)(r1)
    stfd  f31, ( -1 * 8)(r1)

#if SAVE_VECTORS
    /* We are still 16byte aligned - so we are ok for vector saves.
       but the combined size of the vectors (12 x 16) + the FPRs (144) exceeds the
       red zone size so we need to adjust the stack again - note this means careful
       ordering is needed on the restore.  */

    addi  r1, r1, -(12*16+18*8)
    li    r11, 0
    stvx  v20,r11,r1
    addi  r11, r11, 16
    stvx  v21,r11,r1
    addi  r11, r11, 16
    stvx  v22,r11,r1
    addi  r11, r11, 16
    stvx  v23,r11,r1
    addi  r11, r11, 16
    stvx  v24,r11,r1
    addi  r11, r11, 16
    stvx  v25,r11,r1
    addi  r11, r11, 16
    stvx  v26,r11,r1
    addi  r11, r11, 16
    stvx  v27,r11,r1
    addi  r11, r11, 16
    stvx  v28,r11,r1
    addi  r11, r11, 16
    stvx  v29,r11,r1
    addi  r11, r11, 16
    stvx  v30,r11,r1
    addi  r11, r11, 16
    stvx  v31,r11,r1

    /* Now do the same thing in reverse - starting with r4 pointing to
       the block of GPRs - stage 1 point to the saved vectors and fprs. */

    addi  r1, r4, -(12*16+18*8)
    li    r11, 0
    lvx   v20,r11,r1
    addi  r11, r11, 16
    lvx   v21,r11,r1
    addi  r11, r11, 16
    lvx   v22,r11,r1
    addi  r11, r11, 16
    lvx   v23,r11,r1
    addi  r11, r11, 16
    lvx   v24,r11,r1
    addi  r11, r11, 16
    lvx   v25,r11,r1
    addi  r11, r11, 16
    lvx   v26,r11,r1
    addi  r11, r11, 16
    lvx   v27,r11,r1
    addi  r11, r11, 16
    lvx   v28,r11,r1
    addi  r11, r11, 16
    lvx   v29,r11,r1
    addi  r11, r11, 16
    lvx   v30,r11,r1
    addi  r11, r11, 16
    lvx   v31,r11,r1
#endif

    /* Now it is safe to update the stack pointer since the combined
       size of the GPRs and FPRs will not exceed the red zone.  */

    addi  r1, r4, 20 * SZ

    /* Restore FPRs */
    lfd  f14, (-18 * 8)(r4)
    lfd  f15, (-17 * 8)(r4)
    lfd  f16, (-16 * 8)(r4)
    lfd  f17, (-15 * 8)(r4)
    lfd  f18, (-14 * 8)(r4)
    lfd  f19, (-13 * 8)(r4)
    lfd  f20, (-12 * 8)(r4)
    lfd  f21, (-11 * 8)(r4)
    lfd  f22, (-10 * 8)(r4)
    lfd  f23, ( -9 * 8)(r4)
    lfd  f24, ( -8 * 8)(r4)
    lfd  f25, ( -7 * 8)(r4)
    lfd  f26, ( -6 * 8)(r4)
    lfd  f27, ( -5 * 8)(r4)
    lfd  f28, ( -4 * 8)(r4)
    lfd  f29, ( -3 * 8)(r4)
    lfd  f30, ( -2 * 8)(r4)
    lfd  f31, ( -1 * 8)(r4)

    /* Pick up lr and cr */
    LD    r0, 2*SZ(r1)
    LD    r12, SZ(r1)

    /* Restore GPRs */
    LD     r11, (-20 * SZ)(r1)
    LD     r13, (-19 * SZ)(r1)
    LD     r14, (-18 * SZ)(r1)
    LD     r15, (-17 * SZ)(r1)
    LD     r16, (-16 * SZ)(r1)
    LD     r17, (-15 * SZ)(r1)
    LD     r18, (-14 * SZ)(r1)
    LD     r19, (-13 * SZ)(r1)
    LD     r20, (-12 * SZ)(r1)
    LD     r21, (-11 * SZ)(r1)
    LD     r22, (-10 * SZ)(r1)
    LD     r23, ( -9 * SZ)(r1)
    LD     r24, ( -8 * SZ)(r1)
    LD     r25, ( -7 * SZ)(r1)
    LD     r26, ( -6 * SZ)(r1)
    LD     r27, ( -5 * SZ)(r1)
    LD     r28, ( -4 * SZ)(r1)
    LD     r29, ( -3 * SZ)(r1)
    LD     r30, ( -2 * SZ)(r1)
    LD     r31, ( -1 * SZ)(r1)

    /* Set cr and lr */
    mtcr  r12
    mtlr  r0

    /* Return and switch context */
    blr
LFE0:

/* Minimal CFI / FDE which does not describe the stacking of the GPRs - but only that
   the routine has been entered/exited.  */

# if __PPC64__
#  define DATA_ALIGN 0x78
#  define ALIGN_SIZE 3
#  define ADDRD .quad
# else
#  define DATA_ALIGN 0x7c
#  define ALIGN_SIZE 3
#  define ADDRD .long
# endif

	.section __TEXT,__eh_frame,coalesced,no_toc+strip_static_syms+live_support
EH_frame1:
	.set L$set$0,LECIE1-LSCIE1
	.long L$set$0	; Length of Common Information Entry
LSCIE1:
	.long	0	; CIE Identifier Tag
	.byte	0x3	; CIE Version
	.ascii "zR\0"	; CIE Augmentation
	.byte	0x1	; uleb128 0x1; CIE Code Alignment Factor
	.byte	DATA_ALIGN	; sleb128 -4/-8; CIE Data Alignment Factor
	.byte	0x41	; uleb128 0x41; CIE RA Column
	.byte	0x1	; uleb128 0x1; Augmentation size
	.byte	0x10	; FDE Encoding (pcrel)
	.byte	0xc	; DW_CFA_def_cfa
	.byte	0x1	; uleb128 0x1
	.byte	0	; uleb128 0
	.p2align ALIGN_SIZE,0
LECIE1:
LSFDE1:
	.set L$set$1,LEFDE1-LASFDE1
	.long L$set$1	; FDE Length
LASFDE1:
	.long	LASFDE1-EH_frame1	; FDE CIE offset
	ADDRD	LFB0-.	; FDE initial location
	.set L$set$2,LFE0-LFB0
	ADDRD L$set$2	; FDE address range
	.byte	0	; uleb128 0; Augmentation size
	.p2align ALIGN_SIZE,0
LEFDE1:

#endif /* defined(__MACH__) */
