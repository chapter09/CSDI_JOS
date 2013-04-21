
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# physical addresses [0, 4MB).  This 4MB region will be suffice
	# until we set up our real page table in mem_init in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 b0 11 00       	mov    $0x11b000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 b0 11 f0       	mov    $0xf011b000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 a6 00 00 00       	call   f01000e4 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
		monitor(NULL);
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
f0100047:	8d 5d 14             	lea    0x14(%ebp),%ebx
{
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
f010004a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010004d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100051:	8b 45 08             	mov    0x8(%ebp),%eax
f0100054:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100058:	c7 04 24 e0 58 10 f0 	movl   $0xf01058e0,(%esp)
f010005f:	e8 47 3c 00 00       	call   f0103cab <cprintf>
	vcprintf(fmt, ap);
f0100064:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100068:	8b 45 10             	mov    0x10(%ebp),%eax
f010006b:	89 04 24             	mov    %eax,(%esp)
f010006e:	e8 05 3c 00 00       	call   f0103c78 <vcprintf>
	cprintf("\n");
f0100073:	c7 04 24 a8 67 10 f0 	movl   $0xf01067a8,(%esp)
f010007a:	e8 2c 3c 00 00       	call   f0103cab <cprintf>
	va_end(ap);
}
f010007f:	83 c4 14             	add    $0x14,%esp
f0100082:	5b                   	pop    %ebx
f0100083:	5d                   	pop    %ebp
f0100084:	c3                   	ret    

f0100085 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100085:	55                   	push   %ebp
f0100086:	89 e5                	mov    %esp,%ebp
f0100088:	56                   	push   %esi
f0100089:	53                   	push   %ebx
f010008a:	83 ec 10             	sub    $0x10,%esp
f010008d:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100090:	83 3d c0 87 18 f0 00 	cmpl   $0x0,0xf01887c0
f0100097:	75 3d                	jne    f01000d6 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f0100099:	89 35 c0 87 18 f0    	mov    %esi,0xf01887c0

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010009f:	fa                   	cli    
f01000a0:	fc                   	cld    
/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
f01000a1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f01000a4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000a7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01000ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b2:	c7 04 24 fa 58 10 f0 	movl   $0xf01058fa,(%esp)
f01000b9:	e8 ed 3b 00 00       	call   f0103cab <cprintf>
	vcprintf(fmt, ap);
f01000be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000c2:	89 34 24             	mov    %esi,(%esp)
f01000c5:	e8 ae 3b 00 00       	call   f0103c78 <vcprintf>
	cprintf("\n");
f01000ca:	c7 04 24 a8 67 10 f0 	movl   $0xf01067a8,(%esp)
f01000d1:	e8 d5 3b 00 00       	call   f0103cab <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000dd:	e8 f2 06 00 00       	call   f01007d4 <monitor>
f01000e2:	eb f2                	jmp    f01000d6 <_panic+0x51>

f01000e4 <i386_init>:
#include <inc/x86.h>


void
i386_init(void)
{
f01000e4:	55                   	push   %ebp
f01000e5:	89 e5                	mov    %esp,%ebp
f01000e7:	57                   	push   %edi
f01000e8:	81 ec 14 01 00 00    	sub    $0x114,%esp
	extern char edata[], end[];
    // Lab1 only
    char chnum1 = 0, chnum2 = 0, ntest[256] = {};
f01000ee:	8d bd f8 fe ff ff    	lea    -0x108(%ebp),%edi
f01000f4:	b9 40 00 00 00       	mov    $0x40,%ecx
f01000f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01000fe:	f3 ab                	rep stos %eax,%es:(%edi)

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100100:	b8 d0 87 18 f0       	mov    $0xf01887d0,%eax
f0100105:	2d e0 78 18 f0       	sub    $0xf01878e0,%eax
f010010a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010010e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100115:	00 
f0100116:	c7 04 24 e0 78 18 f0 	movl   $0xf01878e0,(%esp)
f010011d:	e8 e4 52 00 00       	call   f0105406 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100122:	e8 83 03 00 00       	call   f01004aa <cons_init>

	/*cprintf("6828 decimal is %o octal!%n\n%n", 6828, &chnum1, &chnum2);*/
    /*cprintf("chnum1: %d chnum2: %d\n", chnum1, chnum2);*/
    memset(ntest, 0xd, sizeof(ntest) - 1);
f0100127:	c7 44 24 08 ff 00 00 	movl   $0xff,0x8(%esp)
f010012e:	00 
f010012f:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
f0100136:	00 
f0100137:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
f010013d:	89 04 24             	mov    %eax,(%esp)
f0100140:	e8 c1 52 00 00       	call   f0105406 <memset>
//================================



	// Lab 2 memory management initialization functions
	mem_init();
f0100145:	e8 88 23 00 00       	call   f01024d2 <mem_init>
//================================
	// Test the stack backtrace function (lab 1 only)
//	test_backtrace(5);

	// Lab 3 user environment initialization functions
	env_init();
f010014a:	e8 8e 34 00 00       	call   f01035dd <env_init>
	wrmsr(0x174, GD_KT, 0);
f010014f:	ba 00 00 00 00       	mov    $0x0,%edx
f0100154:	b8 08 00 00 00       	mov    $0x8,%eax
f0100159:	b9 74 01 00 00       	mov    $0x174,%ecx
f010015e:	0f 30                	wrmsr  
	wrmsr(0x175, KSTACKTOP,0);
f0100160:	b8 00 00 c0 ef       	mov    $0xefc00000,%eax
f0100165:	b1 75                	mov    $0x75,%cl
f0100167:	0f 30                	wrmsr  
	extern void sysenter_handler();
	wrmsr(0x176, sysenter_handler,0);
f0100169:	b8 ca 44 10 f0       	mov    $0xf01044ca,%eax
f010016e:	b1 76                	mov    $0x76,%cl
f0100170:	0f 30                	wrmsr  
	trap_init();
f0100172:	e8 d6 3b 00 00       	call   f0103d4d <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100177:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010017e:	00 
f010017f:	c7 44 24 04 f1 88 00 	movl   $0x88f1,0x4(%esp)
f0100186:	00 
f0100187:	c7 04 24 b1 b4 13 f0 	movl   $0xf013b4b1,(%esp)
f010018e:	e8 9c 39 00 00       	call   f0103b2f <env_create>
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*
	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100193:	a1 1c 7b 18 f0       	mov    0xf0187b1c,%eax
f0100198:	89 04 24             	mov    %eax,(%esp)
f010019b:	e8 c7 34 00 00       	call   f0103667 <env_run>

f01001a0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01001a0:	55                   	push   %ebp
f01001a1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001a3:	ba 84 00 00 00       	mov    $0x84,%edx
f01001a8:	ec                   	in     (%dx),%al
f01001a9:	ec                   	in     (%dx),%al
f01001aa:	ec                   	in     (%dx),%al
f01001ab:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01001ac:	5d                   	pop    %ebp
f01001ad:	c3                   	ret    

f01001ae <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001ae:	55                   	push   %ebp
f01001af:	89 e5                	mov    %esp,%ebp
f01001b1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001b6:	ec                   	in     (%dx),%al
f01001b7:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001be:	f6 c2 01             	test   $0x1,%dl
f01001c1:	74 09                	je     f01001cc <serial_proc_data+0x1e>
f01001c3:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001c8:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001c9:	0f b6 c0             	movzbl %al,%eax
}
f01001cc:	5d                   	pop    %ebp
f01001cd:	c3                   	ret    

f01001ce <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001ce:	55                   	push   %ebp
f01001cf:	89 e5                	mov    %esp,%ebp
f01001d1:	57                   	push   %edi
f01001d2:	56                   	push   %esi
f01001d3:	53                   	push   %ebx
f01001d4:	83 ec 0c             	sub    $0xc,%esp
f01001d7:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01001d9:	bb 04 7b 18 f0       	mov    $0xf0187b04,%ebx
f01001de:	bf 00 79 18 f0       	mov    $0xf0187900,%edi
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001e3:	eb 1e                	jmp    f0100203 <cons_intr+0x35>
		if (c == 0)
f01001e5:	85 c0                	test   %eax,%eax
f01001e7:	74 1a                	je     f0100203 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01001e9:	8b 13                	mov    (%ebx),%edx
f01001eb:	88 04 17             	mov    %al,(%edi,%edx,1)
f01001ee:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f01001f1:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f01001f6:	0f 94 c2             	sete   %dl
f01001f9:	0f b6 d2             	movzbl %dl,%edx
f01001fc:	83 ea 01             	sub    $0x1,%edx
f01001ff:	21 d0                	and    %edx,%eax
f0100201:	89 03                	mov    %eax,(%ebx)
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100203:	ff d6                	call   *%esi
f0100205:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100208:	75 db                	jne    f01001e5 <cons_intr+0x17>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010020a:	83 c4 0c             	add    $0xc,%esp
f010020d:	5b                   	pop    %ebx
f010020e:	5e                   	pop    %esi
f010020f:	5f                   	pop    %edi
f0100210:	5d                   	pop    %ebp
f0100211:	c3                   	ret    

f0100212 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100212:	55                   	push   %ebp
f0100213:	89 e5                	mov    %esp,%ebp
f0100215:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100218:	b8 9a 05 10 f0       	mov    $0xf010059a,%eax
f010021d:	e8 ac ff ff ff       	call   f01001ce <cons_intr>
}
f0100222:	c9                   	leave  
f0100223:	c3                   	ret    

f0100224 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100224:	55                   	push   %ebp
f0100225:	89 e5                	mov    %esp,%ebp
f0100227:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f010022a:	83 3d e4 78 18 f0 00 	cmpl   $0x0,0xf01878e4
f0100231:	74 0a                	je     f010023d <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100233:	b8 ae 01 10 f0       	mov    $0xf01001ae,%eax
f0100238:	e8 91 ff ff ff       	call   f01001ce <cons_intr>
}
f010023d:	c9                   	leave  
f010023e:	c3                   	ret    

f010023f <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010023f:	55                   	push   %ebp
f0100240:	89 e5                	mov    %esp,%ebp
f0100242:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100245:	e8 da ff ff ff       	call   f0100224 <serial_intr>
	kbd_intr();
f010024a:	e8 c3 ff ff ff       	call   f0100212 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010024f:	8b 15 00 7b 18 f0    	mov    0xf0187b00,%edx
f0100255:	b8 00 00 00 00       	mov    $0x0,%eax
f010025a:	3b 15 04 7b 18 f0    	cmp    0xf0187b04,%edx
f0100260:	74 21                	je     f0100283 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f0100262:	0f b6 82 00 79 18 f0 	movzbl -0xfe78700(%edx),%eax
f0100269:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f010026c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f0100272:	0f 94 c1             	sete   %cl
f0100275:	0f b6 c9             	movzbl %cl,%ecx
f0100278:	83 e9 01             	sub    $0x1,%ecx
f010027b:	21 ca                	and    %ecx,%edx
f010027d:	89 15 00 7b 18 f0    	mov    %edx,0xf0187b00
		return c;
	}
	return 0;
}
f0100283:	c9                   	leave  
f0100284:	c3                   	ret    

f0100285 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f0100285:	55                   	push   %ebp
f0100286:	89 e5                	mov    %esp,%ebp
f0100288:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010028b:	e8 af ff ff ff       	call   f010023f <cons_getc>
f0100290:	85 c0                	test   %eax,%eax
f0100292:	74 f7                	je     f010028b <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100294:	c9                   	leave  
f0100295:	c3                   	ret    

f0100296 <iscons>:

int
iscons(int fdnum)
{
f0100296:	55                   	push   %ebp
f0100297:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100299:	b8 01 00 00 00       	mov    $0x1,%eax
f010029e:	5d                   	pop    %ebp
f010029f:	c3                   	ret    

f01002a0 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002a0:	55                   	push   %ebp
f01002a1:	89 e5                	mov    %esp,%ebp
f01002a3:	57                   	push   %edi
f01002a4:	56                   	push   %esi
f01002a5:	53                   	push   %ebx
f01002a6:	83 ec 2c             	sub    $0x2c,%esp
f01002a9:	89 c7                	mov    %eax,%edi
f01002ab:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002b0:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01002b1:	a8 20                	test   $0x20,%al
f01002b3:	75 21                	jne    f01002d6 <cons_putc+0x36>
f01002b5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01002ba:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01002bf:	e8 dc fe ff ff       	call   f01001a0 <delay>
f01002c4:	89 f2                	mov    %esi,%edx
f01002c6:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01002c7:	a8 20                	test   $0x20,%al
f01002c9:	75 0b                	jne    f01002d6 <cons_putc+0x36>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002cb:	83 c3 01             	add    $0x1,%ebx
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f01002ce:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01002d4:	75 e9                	jne    f01002bf <cons_putc+0x1f>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
f01002d6:	89 fa                	mov    %edi,%edx
f01002d8:	89 f8                	mov    %edi,%eax
f01002da:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002dd:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002e2:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002e3:	b2 79                	mov    $0x79,%dl
f01002e5:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002e6:	84 c0                	test   %al,%al
f01002e8:	78 21                	js     f010030b <cons_putc+0x6b>
f01002ea:	bb 00 00 00 00       	mov    $0x0,%ebx
f01002ef:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f01002f4:	e8 a7 fe ff ff       	call   f01001a0 <delay>
f01002f9:	89 f2                	mov    %esi,%edx
f01002fb:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002fc:	84 c0                	test   %al,%al
f01002fe:	78 0b                	js     f010030b <cons_putc+0x6b>
f0100300:	83 c3 01             	add    $0x1,%ebx
f0100303:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100309:	75 e9                	jne    f01002f4 <cons_putc+0x54>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010030b:	ba 78 03 00 00       	mov    $0x378,%edx
f0100310:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100314:	ee                   	out    %al,(%dx)
f0100315:	b2 7a                	mov    $0x7a,%dl
f0100317:	b8 0d 00 00 00       	mov    $0xd,%eax
f010031c:	ee                   	out    %al,(%dx)
f010031d:	b8 08 00 00 00       	mov    $0x8,%eax
f0100322:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100323:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100329:	75 06                	jne    f0100331 <cons_putc+0x91>
		c |= 0x0700;
f010032b:	81 cf 00 07 00 00    	or     $0x700,%edi

	switch (c & 0xff) {
f0100331:	89 f8                	mov    %edi,%eax
f0100333:	25 ff 00 00 00       	and    $0xff,%eax
f0100338:	83 f8 09             	cmp    $0x9,%eax
f010033b:	0f 84 83 00 00 00    	je     f01003c4 <cons_putc+0x124>
f0100341:	83 f8 09             	cmp    $0x9,%eax
f0100344:	7f 0c                	jg     f0100352 <cons_putc+0xb2>
f0100346:	83 f8 08             	cmp    $0x8,%eax
f0100349:	0f 85 a9 00 00 00    	jne    f01003f8 <cons_putc+0x158>
f010034f:	90                   	nop
f0100350:	eb 18                	jmp    f010036a <cons_putc+0xca>
f0100352:	83 f8 0a             	cmp    $0xa,%eax
f0100355:	8d 76 00             	lea    0x0(%esi),%esi
f0100358:	74 40                	je     f010039a <cons_putc+0xfa>
f010035a:	83 f8 0d             	cmp    $0xd,%eax
f010035d:	8d 76 00             	lea    0x0(%esi),%esi
f0100360:	0f 85 92 00 00 00    	jne    f01003f8 <cons_putc+0x158>
f0100366:	66 90                	xchg   %ax,%ax
f0100368:	eb 38                	jmp    f01003a2 <cons_putc+0x102>
	case '\b':
		if (crt_pos > 0) {
f010036a:	0f b7 05 f0 78 18 f0 	movzwl 0xf01878f0,%eax
f0100371:	66 85 c0             	test   %ax,%ax
f0100374:	0f 84 e8 00 00 00    	je     f0100462 <cons_putc+0x1c2>
			crt_pos--;
f010037a:	83 e8 01             	sub    $0x1,%eax
f010037d:	66 a3 f0 78 18 f0    	mov    %ax,0xf01878f0
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100383:	0f b7 c0             	movzwl %ax,%eax
f0100386:	66 81 e7 00 ff       	and    $0xff00,%di
f010038b:	83 cf 20             	or     $0x20,%edi
f010038e:	8b 15 ec 78 18 f0    	mov    0xf01878ec,%edx
f0100394:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100398:	eb 7b                	jmp    f0100415 <cons_putc+0x175>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010039a:	66 83 05 f0 78 18 f0 	addw   $0x50,0xf01878f0
f01003a1:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003a2:	0f b7 05 f0 78 18 f0 	movzwl 0xf01878f0,%eax
f01003a9:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003af:	c1 e8 10             	shr    $0x10,%eax
f01003b2:	66 c1 e8 06          	shr    $0x6,%ax
f01003b6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003b9:	c1 e0 04             	shl    $0x4,%eax
f01003bc:	66 a3 f0 78 18 f0    	mov    %ax,0xf01878f0
f01003c2:	eb 51                	jmp    f0100415 <cons_putc+0x175>
		break;
	case '\t':
		cons_putc(' ');
f01003c4:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c9:	e8 d2 fe ff ff       	call   f01002a0 <cons_putc>
		cons_putc(' ');
f01003ce:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d3:	e8 c8 fe ff ff       	call   f01002a0 <cons_putc>
		cons_putc(' ');
f01003d8:	b8 20 00 00 00       	mov    $0x20,%eax
f01003dd:	e8 be fe ff ff       	call   f01002a0 <cons_putc>
		cons_putc(' ');
f01003e2:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e7:	e8 b4 fe ff ff       	call   f01002a0 <cons_putc>
		cons_putc(' ');
f01003ec:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f1:	e8 aa fe ff ff       	call   f01002a0 <cons_putc>
f01003f6:	eb 1d                	jmp    f0100415 <cons_putc+0x175>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003f8:	0f b7 05 f0 78 18 f0 	movzwl 0xf01878f0,%eax
f01003ff:	0f b7 c8             	movzwl %ax,%ecx
f0100402:	8b 15 ec 78 18 f0    	mov    0xf01878ec,%edx
f0100408:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f010040c:	83 c0 01             	add    $0x1,%eax
f010040f:	66 a3 f0 78 18 f0    	mov    %ax,0xf01878f0
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100415:	66 81 3d f0 78 18 f0 	cmpw   $0x7cf,0xf01878f0
f010041c:	cf 07 
f010041e:	76 42                	jbe    f0100462 <cons_putc+0x1c2>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100420:	a1 ec 78 18 f0       	mov    0xf01878ec,%eax
f0100425:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010042c:	00 
f010042d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100433:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100437:	89 04 24             	mov    %eax,(%esp)
f010043a:	e8 26 50 00 00       	call   f0105465 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010043f:	8b 15 ec 78 18 f0    	mov    0xf01878ec,%edx
f0100445:	b8 80 07 00 00       	mov    $0x780,%eax
f010044a:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100450:	83 c0 01             	add    $0x1,%eax
f0100453:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100458:	75 f0                	jne    f010044a <cons_putc+0x1aa>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010045a:	66 83 2d f0 78 18 f0 	subw   $0x50,0xf01878f0
f0100461:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100462:	8b 0d e8 78 18 f0    	mov    0xf01878e8,%ecx
f0100468:	89 cb                	mov    %ecx,%ebx
f010046a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010046f:	89 ca                	mov    %ecx,%edx
f0100471:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100472:	0f b7 35 f0 78 18 f0 	movzwl 0xf01878f0,%esi
f0100479:	83 c1 01             	add    $0x1,%ecx
f010047c:	89 f0                	mov    %esi,%eax
f010047e:	66 c1 e8 08          	shr    $0x8,%ax
f0100482:	89 ca                	mov    %ecx,%edx
f0100484:	ee                   	out    %al,(%dx)
f0100485:	b8 0f 00 00 00       	mov    $0xf,%eax
f010048a:	89 da                	mov    %ebx,%edx
f010048c:	ee                   	out    %al,(%dx)
f010048d:	89 f0                	mov    %esi,%eax
f010048f:	89 ca                	mov    %ecx,%edx
f0100491:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100492:	83 c4 2c             	add    $0x2c,%esp
f0100495:	5b                   	pop    %ebx
f0100496:	5e                   	pop    %esi
f0100497:	5f                   	pop    %edi
f0100498:	5d                   	pop    %ebp
f0100499:	c3                   	ret    

f010049a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010049a:	55                   	push   %ebp
f010049b:	89 e5                	mov    %esp,%ebp
f010049d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01004a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01004a3:	e8 f8 fd ff ff       	call   f01002a0 <cons_putc>
}
f01004a8:	c9                   	leave  
f01004a9:	c3                   	ret    

f01004aa <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004aa:	55                   	push   %ebp
f01004ab:	89 e5                	mov    %esp,%ebp
f01004ad:	57                   	push   %edi
f01004ae:	56                   	push   %esi
f01004af:	53                   	push   %ebx
f01004b0:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01004b3:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f01004b8:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f01004bb:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f01004c0:	0f b7 00             	movzwl (%eax),%eax
f01004c3:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01004c7:	74 11                	je     f01004da <cons_init+0x30>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01004c9:	c7 05 e8 78 18 f0 b4 	movl   $0x3b4,0xf01878e8
f01004d0:	03 00 00 
f01004d3:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01004d8:	eb 16                	jmp    f01004f0 <cons_init+0x46>
	} else {
		*cp = was;
f01004da:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01004e1:	c7 05 e8 78 18 f0 d4 	movl   $0x3d4,0xf01878e8
f01004e8:	03 00 00 
f01004eb:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f01004f0:	8b 0d e8 78 18 f0    	mov    0xf01878e8,%ecx
f01004f6:	89 cb                	mov    %ecx,%ebx
f01004f8:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004fd:	89 ca                	mov    %ecx,%edx
f01004ff:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100500:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100503:	89 ca                	mov    %ecx,%edx
f0100505:	ec                   	in     (%dx),%al
f0100506:	0f b6 f8             	movzbl %al,%edi
f0100509:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010050c:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100511:	89 da                	mov    %ebx,%edx
f0100513:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100514:	89 ca                	mov    %ecx,%edx
f0100516:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100517:	89 35 ec 78 18 f0    	mov    %esi,0xf01878ec
	crt_pos = pos;
f010051d:	0f b6 c8             	movzbl %al,%ecx
f0100520:	09 cf                	or     %ecx,%edi
f0100522:	66 89 3d f0 78 18 f0 	mov    %di,0xf01878f0
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100529:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010052e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100533:	89 da                	mov    %ebx,%edx
f0100535:	ee                   	out    %al,(%dx)
f0100536:	b2 fb                	mov    $0xfb,%dl
f0100538:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010053d:	ee                   	out    %al,(%dx)
f010053e:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100543:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100548:	89 ca                	mov    %ecx,%edx
f010054a:	ee                   	out    %al,(%dx)
f010054b:	b2 f9                	mov    $0xf9,%dl
f010054d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100552:	ee                   	out    %al,(%dx)
f0100553:	b2 fb                	mov    $0xfb,%dl
f0100555:	b8 03 00 00 00       	mov    $0x3,%eax
f010055a:	ee                   	out    %al,(%dx)
f010055b:	b2 fc                	mov    $0xfc,%dl
f010055d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100562:	ee                   	out    %al,(%dx)
f0100563:	b2 f9                	mov    $0xf9,%dl
f0100565:	b8 01 00 00 00       	mov    $0x1,%eax
f010056a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010056b:	b2 fd                	mov    $0xfd,%dl
f010056d:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010056e:	3c ff                	cmp    $0xff,%al
f0100570:	0f 95 c0             	setne  %al
f0100573:	0f b6 f0             	movzbl %al,%esi
f0100576:	89 35 e4 78 18 f0    	mov    %esi,0xf01878e4
f010057c:	89 da                	mov    %ebx,%edx
f010057e:	ec                   	in     (%dx),%al
f010057f:	89 ca                	mov    %ecx,%edx
f0100581:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100582:	85 f6                	test   %esi,%esi
f0100584:	75 0c                	jne    f0100592 <cons_init+0xe8>
		cprintf("Serial port does not exist!\n");
f0100586:	c7 04 24 12 59 10 f0 	movl   $0xf0105912,(%esp)
f010058d:	e8 19 37 00 00       	call   f0103cab <cprintf>
}
f0100592:	83 c4 1c             	add    $0x1c,%esp
f0100595:	5b                   	pop    %ebx
f0100596:	5e                   	pop    %esi
f0100597:	5f                   	pop    %edi
f0100598:	5d                   	pop    %ebp
f0100599:	c3                   	ret    

f010059a <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010059a:	55                   	push   %ebp
f010059b:	89 e5                	mov    %esp,%ebp
f010059d:	53                   	push   %ebx
f010059e:	83 ec 14             	sub    $0x14,%esp
f01005a1:	ba 64 00 00 00       	mov    $0x64,%edx
f01005a6:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01005a7:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01005ac:	a8 01                	test   $0x1,%al
f01005ae:	0f 84 d9 00 00 00    	je     f010068d <kbd_proc_data+0xf3>
f01005b4:	b2 60                	mov    $0x60,%dl
f01005b6:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01005b7:	3c e0                	cmp    $0xe0,%al
f01005b9:	75 11                	jne    f01005cc <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f01005bb:	83 0d e0 78 18 f0 40 	orl    $0x40,0xf01878e0
f01005c2:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f01005c7:	e9 c1 00 00 00       	jmp    f010068d <kbd_proc_data+0xf3>
	} else if (data & 0x80) {
f01005cc:	84 c0                	test   %al,%al
f01005ce:	79 32                	jns    f0100602 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01005d0:	8b 15 e0 78 18 f0    	mov    0xf01878e0,%edx
f01005d6:	f6 c2 40             	test   $0x40,%dl
f01005d9:	75 03                	jne    f01005de <kbd_proc_data+0x44>
f01005db:	83 e0 7f             	and    $0x7f,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f01005de:	0f b6 c0             	movzbl %al,%eax
f01005e1:	0f b6 80 40 59 10 f0 	movzbl -0xfefa6c0(%eax),%eax
f01005e8:	83 c8 40             	or     $0x40,%eax
f01005eb:	0f b6 c0             	movzbl %al,%eax
f01005ee:	f7 d0                	not    %eax
f01005f0:	21 c2                	and    %eax,%edx
f01005f2:	89 15 e0 78 18 f0    	mov    %edx,0xf01878e0
f01005f8:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f01005fd:	e9 8b 00 00 00       	jmp    f010068d <kbd_proc_data+0xf3>
	} else if (shift & E0ESC) {
f0100602:	8b 15 e0 78 18 f0    	mov    0xf01878e0,%edx
f0100608:	f6 c2 40             	test   $0x40,%dl
f010060b:	74 0c                	je     f0100619 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010060d:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f0100610:	83 e2 bf             	and    $0xffffffbf,%edx
f0100613:	89 15 e0 78 18 f0    	mov    %edx,0xf01878e0
	}

	shift |= shiftcode[data];
f0100619:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f010061c:	0f b6 90 40 59 10 f0 	movzbl -0xfefa6c0(%eax),%edx
f0100623:	0b 15 e0 78 18 f0    	or     0xf01878e0,%edx
f0100629:	0f b6 88 40 5a 10 f0 	movzbl -0xfefa5c0(%eax),%ecx
f0100630:	31 ca                	xor    %ecx,%edx
f0100632:	89 15 e0 78 18 f0    	mov    %edx,0xf01878e0

	c = charcode[shift & (CTL | SHIFT)][data];
f0100638:	89 d1                	mov    %edx,%ecx
f010063a:	83 e1 03             	and    $0x3,%ecx
f010063d:	8b 0c 8d 40 5b 10 f0 	mov    -0xfefa4c0(,%ecx,4),%ecx
f0100644:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f0100648:	f6 c2 08             	test   $0x8,%dl
f010064b:	74 1a                	je     f0100667 <kbd_proc_data+0xcd>
		if ('a' <= c && c <= 'z')
f010064d:	89 d9                	mov    %ebx,%ecx
f010064f:	8d 43 9f             	lea    -0x61(%ebx),%eax
f0100652:	83 f8 19             	cmp    $0x19,%eax
f0100655:	77 05                	ja     f010065c <kbd_proc_data+0xc2>
			c += 'A' - 'a';
f0100657:	83 eb 20             	sub    $0x20,%ebx
f010065a:	eb 0b                	jmp    f0100667 <kbd_proc_data+0xcd>
		else if ('A' <= c && c <= 'Z')
f010065c:	83 e9 41             	sub    $0x41,%ecx
f010065f:	83 f9 19             	cmp    $0x19,%ecx
f0100662:	77 03                	ja     f0100667 <kbd_proc_data+0xcd>
			c += 'a' - 'A';
f0100664:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100667:	f7 d2                	not    %edx
f0100669:	f6 c2 06             	test   $0x6,%dl
f010066c:	75 1f                	jne    f010068d <kbd_proc_data+0xf3>
f010066e:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100674:	75 17                	jne    f010068d <kbd_proc_data+0xf3>
		cprintf("Rebooting!\n");
f0100676:	c7 04 24 2f 59 10 f0 	movl   $0xf010592f,(%esp)
f010067d:	e8 29 36 00 00       	call   f0103cab <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100682:	ba 92 00 00 00       	mov    $0x92,%edx
f0100687:	b8 03 00 00 00       	mov    $0x3,%eax
f010068c:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010068d:	89 d8                	mov    %ebx,%eax
f010068f:	83 c4 14             	add    $0x14,%esp
f0100692:	5b                   	pop    %ebx
f0100693:	5d                   	pop    %ebp
f0100694:	c3                   	ret    
	...

f01006a0 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f01006a0:	55                   	push   %ebp
f01006a1:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f01006a3:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f01006a6:	5d                   	pop    %ebp
f01006a7:	c3                   	ret    

f01006a8 <do_overflow>:
    return pretaddr;
}

void
do_overflow(void)
{
f01006a8:	55                   	push   %ebp
f01006a9:	89 e5                	mov    %esp,%ebp
f01006ab:	83 ec 18             	sub    $0x18,%esp
    cprintf("Overflow success\n");
f01006ae:	c7 04 24 50 5b 10 f0 	movl   $0xf0105b50,(%esp)
f01006b5:	e8 f1 35 00 00       	call   f0103cab <cprintf>
}
f01006ba:	c9                   	leave  
f01006bb:	c3                   	ret    

f01006bc <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006bc:	55                   	push   %ebp
f01006bd:	89 e5                	mov    %esp,%ebp
f01006bf:	83 ec 18             	sub    $0x18,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006c2:	c7 04 24 62 5b 10 f0 	movl   $0xf0105b62,(%esp)
f01006c9:	e8 dd 35 00 00       	call   f0103cab <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006ce:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006d5:	00 
f01006d6:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006dd:	f0 
f01006de:	c7 04 24 38 5c 10 f0 	movl   $0xf0105c38,(%esp)
f01006e5:	e8 c1 35 00 00       	call   f0103cab <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006ea:	c7 44 24 08 d5 58 10 	movl   $0x1058d5,0x8(%esp)
f01006f1:	00 
f01006f2:	c7 44 24 04 d5 58 10 	movl   $0xf01058d5,0x4(%esp)
f01006f9:	f0 
f01006fa:	c7 04 24 5c 5c 10 f0 	movl   $0xf0105c5c,(%esp)
f0100701:	e8 a5 35 00 00       	call   f0103cab <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100706:	c7 44 24 08 e0 78 18 	movl   $0x1878e0,0x8(%esp)
f010070d:	00 
f010070e:	c7 44 24 04 e0 78 18 	movl   $0xf01878e0,0x4(%esp)
f0100715:	f0 
f0100716:	c7 04 24 80 5c 10 f0 	movl   $0xf0105c80,(%esp)
f010071d:	e8 89 35 00 00       	call   f0103cab <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100722:	c7 44 24 08 d0 87 18 	movl   $0x1887d0,0x8(%esp)
f0100729:	00 
f010072a:	c7 44 24 04 d0 87 18 	movl   $0xf01887d0,0x4(%esp)
f0100731:	f0 
f0100732:	c7 04 24 a4 5c 10 f0 	movl   $0xf0105ca4,(%esp)
f0100739:	e8 6d 35 00 00       	call   f0103cab <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010073e:	b8 cf 8b 18 f0       	mov    $0xf0188bcf,%eax
f0100743:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100748:	89 c2                	mov    %eax,%edx
f010074a:	c1 fa 1f             	sar    $0x1f,%edx
f010074d:	c1 ea 16             	shr    $0x16,%edx
f0100750:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0100753:	c1 f8 0a             	sar    $0xa,%eax
f0100756:	89 44 24 04          	mov    %eax,0x4(%esp)
f010075a:	c7 04 24 c8 5c 10 f0 	movl   $0xf0105cc8,(%esp)
f0100761:	e8 45 35 00 00       	call   f0103cab <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f0100766:	b8 00 00 00 00       	mov    $0x0,%eax
f010076b:	c9                   	leave  
f010076c:	c3                   	ret    

f010076d <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010076d:	55                   	push   %ebp
f010076e:	89 e5                	mov    %esp,%ebp
f0100770:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100773:	a1 c4 5d 10 f0       	mov    0xf0105dc4,%eax
f0100778:	89 44 24 08          	mov    %eax,0x8(%esp)
f010077c:	a1 c0 5d 10 f0       	mov    0xf0105dc0,%eax
f0100781:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100785:	c7 04 24 7b 5b 10 f0 	movl   $0xf0105b7b,(%esp)
f010078c:	e8 1a 35 00 00       	call   f0103cab <cprintf>
f0100791:	a1 d0 5d 10 f0       	mov    0xf0105dd0,%eax
f0100796:	89 44 24 08          	mov    %eax,0x8(%esp)
f010079a:	a1 cc 5d 10 f0       	mov    0xf0105dcc,%eax
f010079f:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007a3:	c7 04 24 7b 5b 10 f0 	movl   $0xf0105b7b,(%esp)
f01007aa:	e8 fc 34 00 00       	call   f0103cab <cprintf>
f01007af:	a1 dc 5d 10 f0       	mov    0xf0105ddc,%eax
f01007b4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007b8:	a1 d8 5d 10 f0       	mov    0xf0105dd8,%eax
f01007bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007c1:	c7 04 24 7b 5b 10 f0 	movl   $0xf0105b7b,(%esp)
f01007c8:	e8 de 34 00 00       	call   f0103cab <cprintf>
	return 0;
}
f01007cd:	b8 00 00 00 00       	mov    $0x0,%eax
f01007d2:	c9                   	leave  
f01007d3:	c3                   	ret    

f01007d4 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007d4:	55                   	push   %ebp
f01007d5:	89 e5                	mov    %esp,%ebp
f01007d7:	57                   	push   %edi
f01007d8:	56                   	push   %esi
f01007d9:	53                   	push   %ebx
f01007da:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007dd:	c7 04 24 f4 5c 10 f0 	movl   $0xf0105cf4,(%esp)
f01007e4:	e8 c2 34 00 00       	call   f0103cab <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007e9:	c7 04 24 18 5d 10 f0 	movl   $0xf0105d18,(%esp)
f01007f0:	e8 b6 34 00 00       	call   f0103cab <cprintf>

	if (tf != NULL)
f01007f5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01007f9:	74 0b                	je     f0100806 <monitor+0x32>
		print_trapframe(tf);
f01007fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01007fe:	89 04 24             	mov    %eax,(%esp)
f0100801:	e8 29 39 00 00       	call   f010412f <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100806:	c7 04 24 84 5b 10 f0 	movl   $0xf0105b84,(%esp)
f010080d:	e8 3e 49 00 00       	call   f0105150 <readline>
f0100812:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100814:	85 c0                	test   %eax,%eax
f0100816:	74 ee                	je     f0100806 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100818:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f010081f:	be 00 00 00 00       	mov    $0x0,%esi
f0100824:	eb 06                	jmp    f010082c <monitor+0x58>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100826:	c6 03 00             	movb   $0x0,(%ebx)
f0100829:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010082c:	0f b6 03             	movzbl (%ebx),%eax
f010082f:	84 c0                	test   %al,%al
f0100831:	74 6a                	je     f010089d <monitor+0xc9>
f0100833:	0f be c0             	movsbl %al,%eax
f0100836:	89 44 24 04          	mov    %eax,0x4(%esp)
f010083a:	c7 04 24 88 5b 10 f0 	movl   $0xf0105b88,(%esp)
f0100841:	e8 65 4b 00 00       	call   f01053ab <strchr>
f0100846:	85 c0                	test   %eax,%eax
f0100848:	75 dc                	jne    f0100826 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f010084a:	80 3b 00             	cmpb   $0x0,(%ebx)
f010084d:	74 4e                	je     f010089d <monitor+0xc9>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010084f:	83 fe 0f             	cmp    $0xf,%esi
f0100852:	75 16                	jne    f010086a <monitor+0x96>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100854:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f010085b:	00 
f010085c:	c7 04 24 8d 5b 10 f0 	movl   $0xf0105b8d,(%esp)
f0100863:	e8 43 34 00 00       	call   f0103cab <cprintf>
f0100868:	eb 9c                	jmp    f0100806 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f010086a:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010086e:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100871:	0f b6 03             	movzbl (%ebx),%eax
f0100874:	84 c0                	test   %al,%al
f0100876:	75 0c                	jne    f0100884 <monitor+0xb0>
f0100878:	eb b2                	jmp    f010082c <monitor+0x58>
			buf++;
f010087a:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010087d:	0f b6 03             	movzbl (%ebx),%eax
f0100880:	84 c0                	test   %al,%al
f0100882:	74 a8                	je     f010082c <monitor+0x58>
f0100884:	0f be c0             	movsbl %al,%eax
f0100887:	89 44 24 04          	mov    %eax,0x4(%esp)
f010088b:	c7 04 24 88 5b 10 f0 	movl   $0xf0105b88,(%esp)
f0100892:	e8 14 4b 00 00       	call   f01053ab <strchr>
f0100897:	85 c0                	test   %eax,%eax
f0100899:	74 df                	je     f010087a <monitor+0xa6>
f010089b:	eb 8f                	jmp    f010082c <monitor+0x58>
			buf++;
	}
	argv[argc] = 0;
f010089d:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008a4:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008a5:	85 f6                	test   %esi,%esi
f01008a7:	0f 84 59 ff ff ff    	je     f0100806 <monitor+0x32>
f01008ad:	bb c0 5d 10 f0       	mov    $0xf0105dc0,%ebx
f01008b2:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008b7:	8b 03                	mov    (%ebx),%eax
f01008b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008bd:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008c0:	89 04 24             	mov    %eax,(%esp)
f01008c3:	e8 6d 4a 00 00       	call   f0105335 <strcmp>
f01008c8:	85 c0                	test   %eax,%eax
f01008ca:	75 23                	jne    f01008ef <monitor+0x11b>
			return commands[i].func(argc, argv, tf);
f01008cc:	6b ff 0c             	imul   $0xc,%edi,%edi
f01008cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01008d2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008d6:	8d 45 a8             	lea    -0x58(%ebp),%eax
f01008d9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008dd:	89 34 24             	mov    %esi,(%esp)
f01008e0:	ff 97 c8 5d 10 f0    	call   *-0xfefa238(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008e6:	85 c0                	test   %eax,%eax
f01008e8:	78 28                	js     f0100912 <monitor+0x13e>
f01008ea:	e9 17 ff ff ff       	jmp    f0100806 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01008ef:	83 c7 01             	add    $0x1,%edi
f01008f2:	83 c3 0c             	add    $0xc,%ebx
f01008f5:	83 ff 03             	cmp    $0x3,%edi
f01008f8:	75 bd                	jne    f01008b7 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008fa:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008fd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100901:	c7 04 24 aa 5b 10 f0 	movl   $0xf0105baa,(%esp)
f0100908:	e8 9e 33 00 00       	call   f0103cab <cprintf>
f010090d:	e9 f4 fe ff ff       	jmp    f0100806 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100912:	83 c4 5c             	add    $0x5c,%esp
f0100915:	5b                   	pop    %ebx
f0100916:	5e                   	pop    %esi
f0100917:	5f                   	pop    %edi
f0100918:	5d                   	pop    %ebp
f0100919:	c3                   	ret    

f010091a <start_overflow>:
    cprintf("Overflow success\n");
}

void
start_overflow(void)
{
f010091a:	55                   	push   %ebp
f010091b:	89 e5                	mov    %esp,%ebp
f010091d:	57                   	push   %edi
f010091e:	56                   	push   %esi
f010091f:	53                   	push   %ebx
f0100920:	81 ec 3c 01 00 00    	sub    $0x13c,%esp
    // hint: You can use the read_pretaddr function to retrieve 
    //       the pointer to the function call return address;



    char str[256] = {};
f0100926:	8d bd e8 fe ff ff    	lea    -0x118(%ebp),%edi
f010092c:	b9 40 00 00 00       	mov    $0x40,%ecx
f0100931:	b8 00 00 00 00       	mov    $0x0,%eax
f0100936:	f3 ab                	rep stos %eax,%es:(%edi)
// Lab1 only
// read the pointer to the retaddr on the stack
static uint32_t
read_pretaddr() {
    uint32_t pretaddr;
    __asm __volatile("leal 4(%%ebp), %0" : "=r" (pretaddr)); 
f0100938:	8d 75 04             	lea    0x4(%ebp),%esi
    int nstr = 0;
    char *pret_addr;
	char exec[11];
	
	int* eip_ptr = (int*)read_pretaddr();
	int eip_addr = *eip_ptr;
f010093b:	8b 1e                	mov    (%esi),%ebx
	cprintf("%#x\n", eip_addr);
f010093d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100941:	c7 04 24 c0 5b 10 f0 	movl   $0xf0105bc0,(%esp)
f0100948:	e8 5e 33 00 00       	call   f0103cab <cprintf>
	int of_addr = (int) do_overflow;
f010094d:	b8 a8 06 10 f0       	mov    $0xf01006a8,%eax
	//cprintf("%#x\n", of_addr);
	//cprintf("%#x\n", (int*)exec);
	exec[0] = 0x68;
f0100952:	c6 85 dd fe ff ff 68 	movb   $0x68,-0x123(%ebp)
	exec[1] = (char)eip_addr; 
f0100959:	88 9d de fe ff ff    	mov    %bl,-0x122(%ebp)
	exec[2] = (char)(eip_addr >> 8);
f010095f:	89 da                	mov    %ebx,%edx
f0100961:	c1 fa 08             	sar    $0x8,%edx
f0100964:	88 95 df fe ff ff    	mov    %dl,-0x121(%ebp)
	exec[3] = (char)(eip_addr >> 16);
f010096a:	89 da                	mov    %ebx,%edx
f010096c:	c1 fa 10             	sar    $0x10,%edx
f010096f:	88 95 e0 fe ff ff    	mov    %dl,-0x120(%ebp)
	exec[4] = (char)(eip_addr >> 24);
f0100975:	c1 fb 18             	sar    $0x18,%ebx
f0100978:	88 9d e1 fe ff ff    	mov    %bl,-0x11f(%ebp)
	exec[5] = 0x68;
f010097e:	c6 85 e2 fe ff ff 68 	movb   $0x68,-0x11e(%ebp)
	exec[6] = (char)of_addr;
f0100985:	88 85 e3 fe ff ff    	mov    %al,-0x11d(%ebp)
	exec[7] = (char)(of_addr >> 8);
f010098b:	89 c2                	mov    %eax,%edx
f010098d:	c1 fa 08             	sar    $0x8,%edx
f0100990:	88 95 e4 fe ff ff    	mov    %dl,-0x11c(%ebp)
	exec[8] = (char)(of_addr >> 16);
f0100996:	89 c2                	mov    %eax,%edx
f0100998:	c1 fa 10             	sar    $0x10,%edx
f010099b:	88 95 e5 fe ff ff    	mov    %dl,-0x11b(%ebp)
	exec[9] = (char)(of_addr >> 24);
f01009a1:	c1 f8 18             	sar    $0x18,%eax
f01009a4:	88 85 e6 fe ff ff    	mov    %al,-0x11a(%ebp)
	exec[10] = 0xc3; 	
f01009aa:	c6 85 e7 fe ff ff c3 	movb   $0xc3,-0x119(%ebp)
	
	//cprintf("%s\n", exec);
	//cprintf("%#x\n", eip_ptr);
	//cprintf("%#x\n", *eip_ptr);
//	*eip_ptr = (int) exec;
	cprintf("%#x\n", eip_ptr);
f01009b1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01009b5:	c7 04 24 c0 5b 10 f0 	movl   $0xf0105bc0,(%esp)
f01009bc:	e8 ea 32 00 00       	call   f0103cab <cprintf>
	cprintf("%#x\n", exec);
f01009c1:	8d 9d dd fe ff ff    	lea    -0x123(%ebp),%ebx
f01009c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01009cb:	c7 04 24 c0 5b 10 f0 	movl   $0xf0105bc0,(%esp)
f01009d2:	e8 d4 32 00 00       	call   f0103cab <cprintf>
	cprintf("%#x\n", (int)exec >> 24 & 0x000000ff);
f01009d7:	89 d8                	mov    %ebx,%eax
f01009d9:	c1 e8 18             	shr    $0x18,%eax
f01009dc:	89 85 d4 fe ff ff    	mov    %eax,-0x12c(%ebp)
f01009e2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009e6:	c7 04 24 c0 5b 10 f0 	movl   $0xf0105bc0,(%esp)
f01009ed:	e8 b9 32 00 00       	call   f0103cab <cprintf>
	cprintf("%#x\n", (int)exec >> 16 & 0x000000ff);
f01009f2:	89 d8                	mov    %ebx,%eax
f01009f4:	c1 f8 10             	sar    $0x10,%eax
f01009f7:	25 ff 00 00 00       	and    $0xff,%eax
f01009fc:	89 85 d0 fe ff ff    	mov    %eax,-0x130(%ebp)
f0100a02:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a06:	c7 04 24 c0 5b 10 f0 	movl   $0xf0105bc0,(%esp)
f0100a0d:	e8 99 32 00 00       	call   f0103cab <cprintf>
	cprintf("%#x\n", (int)exec >> 8 & 0x00000ff);
f0100a12:	0f b6 c7             	movzbl %bh,%eax
f0100a15:	89 85 cc fe ff ff    	mov    %eax,-0x134(%ebp)
f0100a1b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a1f:	c7 04 24 c0 5b 10 f0 	movl   $0xf0105bc0,(%esp)
f0100a26:	e8 80 32 00 00       	call   f0103cab <cprintf>
	cprintf("%#x\n", (int)exec & 0x000000ff);
f0100a2b:	0f b6 fb             	movzbl %bl,%edi
f0100a2e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100a32:	c7 04 24 c0 5b 10 f0 	movl   $0xf0105bc0,(%esp)
f0100a39:	e8 6d 32 00 00       	call   f0103cab <cprintf>

	memset(str, '\0', 256);	
f0100a3e:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
f0100a45:	00 
f0100a46:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100a4d:	00 
f0100a4e:	8d 9d e8 fe ff ff    	lea    -0x118(%ebp),%ebx
f0100a54:	89 1c 24             	mov    %ebx,(%esp)
f0100a57:	e8 aa 49 00 00       	call   f0105406 <memset>

	memset(str,'1', (int)exec & 0x000000ff);
f0100a5c:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100a60:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
f0100a67:	00 
f0100a68:	89 1c 24             	mov    %ebx,(%esp)
f0100a6b:	e8 96 49 00 00       	call   f0105406 <memset>
	cprintf("%s%n", str, (char*)eip_ptr);	
f0100a70:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100a74:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100a78:	c7 04 24 c5 5b 10 f0 	movl   $0xf0105bc5,(%esp)
f0100a7f:	e8 27 32 00 00       	call   f0103cab <cprintf>

	memset(str, '\0', 256);	
f0100a84:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
f0100a8b:	00 
f0100a8c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100a93:	00 
f0100a94:	89 1c 24             	mov    %ebx,(%esp)
f0100a97:	e8 6a 49 00 00       	call   f0105406 <memset>
	memset(str,'1', (int)exec >> 8 & 0x000000ff);
f0100a9c:	8b 85 cc fe ff ff    	mov    -0x134(%ebp),%eax
f0100aa2:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100aa6:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
f0100aad:	00 
f0100aae:	89 1c 24             	mov    %ebx,(%esp)
f0100ab1:	e8 50 49 00 00       	call   f0105406 <memset>
	cprintf("%s%n", str, (char*)eip_ptr+1);	
f0100ab6:	8d 46 01             	lea    0x1(%esi),%eax
f0100ab9:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100abd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ac1:	c7 04 24 c5 5b 10 f0 	movl   $0xf0105bc5,(%esp)
f0100ac8:	e8 de 31 00 00       	call   f0103cab <cprintf>

	memset(str, '\0', 256);	
f0100acd:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
f0100ad4:	00 
f0100ad5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100adc:	00 
f0100add:	89 1c 24             	mov    %ebx,(%esp)
f0100ae0:	e8 21 49 00 00       	call   f0105406 <memset>
	memset(str,'1', (int)exec >> 16 & 0x000000ff);
f0100ae5:	8b 85 d0 fe ff ff    	mov    -0x130(%ebp),%eax
f0100aeb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100aef:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
f0100af6:	00 
f0100af7:	89 1c 24             	mov    %ebx,(%esp)
f0100afa:	e8 07 49 00 00       	call   f0105406 <memset>
	cprintf("%s%n", str, (char*)eip_ptr+2);	
f0100aff:	8d 46 02             	lea    0x2(%esi),%eax
f0100b02:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b06:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100b0a:	c7 04 24 c5 5b 10 f0 	movl   $0xf0105bc5,(%esp)
f0100b11:	e8 95 31 00 00       	call   f0103cab <cprintf>

	memset(str, '\0', 256);	
f0100b16:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
f0100b1d:	00 
f0100b1e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100b25:	00 
f0100b26:	89 1c 24             	mov    %ebx,(%esp)
f0100b29:	e8 d8 48 00 00       	call   f0105406 <memset>
	memset(str,'1', (int)exec >> 24 & 0x000000ff);
f0100b2e:	8b 85 d4 fe ff ff    	mov    -0x12c(%ebp),%eax
f0100b34:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b38:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
f0100b3f:	00 
f0100b40:	89 1c 24             	mov    %ebx,(%esp)
f0100b43:	e8 be 48 00 00       	call   f0105406 <memset>
	cprintf("%s%n", str, (char*)eip_ptr+3);	
f0100b48:	83 c6 03             	add    $0x3,%esi
f0100b4b:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100b4f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100b53:	c7 04 24 c5 5b 10 f0 	movl   $0xf0105bc5,(%esp)
f0100b5a:	e8 4c 31 00 00       	call   f0103cab <cprintf>

}
f0100b5f:	81 c4 3c 01 00 00    	add    $0x13c,%esp
f0100b65:	5b                   	pop    %ebx
f0100b66:	5e                   	pop    %esi
f0100b67:	5f                   	pop    %edi
f0100b68:	5d                   	pop    %ebp
f0100b69:	c3                   	ret    

f0100b6a <overflow_me>:

void
overflow_me(void)
{
f0100b6a:	55                   	push   %ebp
f0100b6b:	89 e5                	mov    %esp,%ebp
f0100b6d:	83 ec 08             	sub    $0x8,%esp
	start_overflow();
f0100b70:	e8 a5 fd ff ff       	call   f010091a <start_overflow>
}
f0100b75:	c9                   	leave  
f0100b76:	c3                   	ret    

f0100b77 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100b77:	55                   	push   %ebp
f0100b78:	89 e5                	mov    %esp,%ebp
f0100b7a:	57                   	push   %edi
f0100b7b:	56                   	push   %esi
f0100b7c:	53                   	push   %ebx
f0100b7d:	83 ec 4c             	sub    $0x4c,%esp
	// Your code here.
	uint32_t *ebp = (uint32_t*) read_ebp();
f0100b80:	89 eb                	mov    %ebp,%ebx
	struct Eipdebuginfo eip_info;
	cprintf("Stack backtrace:\n");
f0100b82:	c7 04 24 ca 5b 10 f0 	movl   $0xf0105bca,(%esp)
f0100b89:	e8 1d 31 00 00       	call   f0103cab <cprintf>
	while(ebp != 0x0) {
f0100b8e:	85 db                	test   %ebx,%ebx
f0100b90:	0f 84 88 00 00 00    	je     f0100c1e <mon_backtrace+0xa7>
		cprintf(" ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", 
			ebp, ebp[1], ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
		debuginfo_eip(ebp[1], &eip_info);
f0100b96:	8d 7d d0             	lea    -0x30(%ebp),%edi
	uint32_t *ebp = (uint32_t*) read_ebp();
	struct Eipdebuginfo eip_info;
	cprintf("Stack backtrace:\n");
	while(ebp != 0x0) {
		cprintf(" ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", 
			ebp, ebp[1], ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
f0100b99:	8d 73 04             	lea    0x4(%ebx),%esi
	// Your code here.
	uint32_t *ebp = (uint32_t*) read_ebp();
	struct Eipdebuginfo eip_info;
	cprintf("Stack backtrace:\n");
	while(ebp != 0x0) {
		cprintf(" ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", 
f0100b9c:	8b 43 18             	mov    0x18(%ebx),%eax
f0100b9f:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0100ba3:	8b 43 14             	mov    0x14(%ebx),%eax
f0100ba6:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100baa:	8b 43 10             	mov    0x10(%ebx),%eax
f0100bad:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100bb1:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100bb4:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100bb8:	8b 43 08             	mov    0x8(%ebx),%eax
f0100bbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100bbf:	8b 06                	mov    (%esi),%eax
f0100bc1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100bc5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100bc9:	c7 04 24 40 5d 10 f0 	movl   $0xf0105d40,(%esp)
f0100bd0:	e8 d6 30 00 00       	call   f0103cab <cprintf>
			ebp, ebp[1], ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
		debuginfo_eip(ebp[1], &eip_info);
f0100bd5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100bd9:	8b 06                	mov    (%esi),%eax
f0100bdb:	89 04 24             	mov    %eax,(%esp)
f0100bde:	e8 6b 3c 00 00       	call   f010484e <debuginfo_eip>
		cprintf("%s:%d: %.*s+%d\n",
f0100be3:	8b 06                	mov    (%esi),%eax
f0100be5:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100be8:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100bec:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bef:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100bf3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100bf6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100bfa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100bfd:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c01:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100c04:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c08:	c7 04 24 dc 5b 10 f0 	movl   $0xf0105bdc,(%esp)
f0100c0f:	e8 97 30 00 00       	call   f0103cab <cprintf>
				eip_info.eip_file, 
				eip_info.eip_line,
                eip_info.eip_fn_namelen,
				eip_info.eip_fn_name,
                ebp[1]-eip_info.eip_fn_addr);
		ebp = (uint32_t*) ebp[0];
f0100c14:	8b 1b                	mov    (%ebx),%ebx
{
	// Your code here.
	uint32_t *ebp = (uint32_t*) read_ebp();
	struct Eipdebuginfo eip_info;
	cprintf("Stack backtrace:\n");
	while(ebp != 0x0) {
f0100c16:	85 db                	test   %ebx,%ebx
f0100c18:	0f 85 7b ff ff ff    	jne    f0100b99 <mon_backtrace+0x22>
				eip_info.eip_fn_name,
                ebp[1]-eip_info.eip_fn_addr);
		ebp = (uint32_t*) ebp[0];
	}

    overflow_me();
f0100c1e:	e8 47 ff ff ff       	call   f0100b6a <overflow_me>
    cprintf("Backtrace success\n");
f0100c23:	c7 04 24 ec 5b 10 f0 	movl   $0xf0105bec,(%esp)
f0100c2a:	e8 7c 30 00 00       	call   f0103cab <cprintf>
	return 0;
}
f0100c2f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c34:	83 c4 4c             	add    $0x4c,%esp
f0100c37:	5b                   	pop    %ebx
f0100c38:	5e                   	pop    %esi
f0100c39:	5f                   	pop    %edi
f0100c3a:	5d                   	pop    %ebp
f0100c3b:	c3                   	ret    
f0100c3c:	00 00                	add    %al,(%eax)
	...

f0100c40 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f0100c40:	55                   	push   %ebp
f0100c41:	89 e5                	mov    %esp,%ebp
f0100c43:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	//put the pp to the head of page_free_list
	pp->pp_link = page_free_list;
f0100c46:	8b 15 10 7b 18 f0    	mov    0xf0187b10,%edx
f0100c4c:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100c4e:	a3 10 7b 18 f0       	mov    %eax,0xf0187b10
	return;
}
f0100c53:	5d                   	pop    %ebp
f0100c54:	c3                   	ret    

f0100c55 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0100c55:	55                   	push   %ebp
f0100c56:	89 e5                	mov    %esp,%ebp
f0100c58:	83 ec 04             	sub    $0x4,%esp
f0100c5b:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100c5e:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0100c62:	83 ea 01             	sub    $0x1,%edx
f0100c65:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100c69:	66 85 d2             	test   %dx,%dx
f0100c6c:	75 08                	jne    f0100c76 <page_decref+0x21>
		page_free(pp);
f0100c6e:	89 04 24             	mov    %eax,(%esp)
f0100c71:	e8 ca ff ff ff       	call   f0100c40 <page_free>
}
f0100c76:	c9                   	leave  
f0100c77:	c3                   	ret    

f0100c78 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100c78:	55                   	push   %ebp
f0100c79:	89 e5                	mov    %esp,%ebp
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100c7b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c7e:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0100c81:	5d                   	pop    %ebp
f0100c82:	c3                   	ret    

f0100c83 <check_continuous>:
	cprintf("check_page() succeeded!\n");
}

static int
check_continuous(struct Page *pp)
{
f0100c83:	55                   	push   %ebp
f0100c84:	89 e5                	mov    %esp,%ebp
f0100c86:	56                   	push   %esi
f0100c87:	53                   	push   %ebx
	struct Page *tmp; 
	int i;
	for( tmp = pp, i = 0; i < 3; tmp = tmp->pp_link, i++ )
	{	
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
f0100c88:	8b 18                	mov    (%eax),%ebx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c8a:	8b 15 cc 87 18 f0    	mov    0xf01887cc,%edx
f0100c90:	89 d9                	mov    %ebx,%ecx
f0100c92:	29 d1                	sub    %edx,%ecx
f0100c94:	c1 f9 03             	sar    $0x3,%ecx
f0100c97:	c1 e1 0c             	shl    $0xc,%ecx
f0100c9a:	29 d0                	sub    %edx,%eax
f0100c9c:	c1 f8 03             	sar    $0x3,%eax
f0100c9f:	c1 e0 0c             	shl    $0xc,%eax
f0100ca2:	89 ce                	mov    %ecx,%esi
f0100ca4:	29 c6                	sub    %eax,%esi
f0100ca6:	81 fe 00 10 00 00    	cmp    $0x1000,%esi
f0100cac:	75 34                	jne    f0100ce2 <check_continuous+0x5f>
f0100cae:	8b 1b                	mov    (%ebx),%ebx
f0100cb0:	89 d8                	mov    %ebx,%eax
f0100cb2:	29 d0                	sub    %edx,%eax
f0100cb4:	c1 f8 03             	sar    $0x3,%eax
f0100cb7:	c1 e0 0c             	shl    $0xc,%eax
f0100cba:	89 c6                	mov    %eax,%esi
f0100cbc:	29 ce                	sub    %ecx,%esi
f0100cbe:	81 fe 00 10 00 00    	cmp    $0x1000,%esi
f0100cc4:	75 1c                	jne    f0100ce2 <check_continuous+0x5f>
f0100cc6:	8b 0b                	mov    (%ebx),%ecx
f0100cc8:	29 d1                	sub    %edx,%ecx
f0100cca:	89 ca                	mov    %ecx,%edx
f0100ccc:	c1 fa 03             	sar    $0x3,%edx
f0100ccf:	c1 e2 0c             	shl    $0xc,%edx
f0100cd2:	29 c2                	sub    %eax,%edx
f0100cd4:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f0100cda:	0f 94 c0             	sete   %al
f0100cdd:	0f b6 c0             	movzbl %al,%eax
f0100ce0:	eb 05                	jmp    f0100ce7 <check_continuous+0x64>
f0100ce2:	b8 00 00 00 00       	mov    $0x0,%eax
		{
			return 0;
		}
	}
	return 1;
}
f0100ce7:	5b                   	pop    %ebx
f0100ce8:	5e                   	pop    %esi
f0100ce9:	5d                   	pop    %ebp
f0100cea:	c3                   	ret    

f0100ceb <page_free_4pages>:
//	2. Add the pages to the chunck list.
//	
//	Return 0 if everything ok
int
page_free_4pages(struct Page *pp)
{
f0100ceb:	55                   	push   %ebp
f0100cec:	89 e5                	mov    %esp,%ebp
f0100cee:	53                   	push   %ebx
f0100cef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Fill this function
	int i;
	if(check_continuous(pp)) {
f0100cf2:	89 d8                	mov    %ebx,%eax
f0100cf4:	e8 8a ff ff ff       	call   f0100c83 <check_continuous>
f0100cf9:	89 c2                	mov    %eax,%edx
f0100cfb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d00:	85 d2                	test   %edx,%edx
f0100d02:	74 18                	je     f0100d1c <page_free_4pages+0x31>
		page_free_list = pp->pp_link->pp_link->pp_link->pp_link;
f0100d04:	8b 03                	mov    (%ebx),%eax
f0100d06:	8b 00                	mov    (%eax),%eax
f0100d08:	8b 00                	mov    (%eax),%eax
f0100d0a:	8b 00                	mov    (%eax),%eax
f0100d0c:	a3 10 7b 18 f0       	mov    %eax,0xf0187b10
		chunck_list = pp;
f0100d11:	89 1d 14 7b 18 f0    	mov    %ebx,0xf0187b14
f0100d17:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		return -1;
	}
	return 0;
}
f0100d1c:	5b                   	pop    %ebx
f0100d1d:	5d                   	pop    %ebp
f0100d1e:	c3                   	ret    

f0100d1f <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100d1f:	55                   	push   %ebp
f0100d20:	89 e5                	mov    %esp,%ebp
f0100d22:	53                   	push   %ebx
f0100d23:	83 ec 14             	sub    $0x14,%esp
f0100d26:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100d28:	83 3d 08 7b 18 f0 00 	cmpl   $0x0,0xf0187b08
f0100d2f:	75 0f                	jne    f0100d40 <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100d31:	b8 cf 97 18 f0       	mov    $0xf01897cf,%eax
f0100d36:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d3b:	a3 08 7b 18 f0       	mov    %eax,0xf0187b08
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = ROUNDUP(nextfree, PGSIZE);
f0100d40:	a1 08 7b 18 f0       	mov    0xf0187b08,%eax
f0100d45:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100d4a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	int32_t alloc_space = (uint32_t) result - KERNBASE + n;
	uint32_t total_space = (uint32_t) npages * PGSIZE; 
	if(alloc_space > total_space){
f0100d4f:	8d 9c 10 00 00 00 10 	lea    0x10000000(%eax,%edx,1),%ebx
f0100d56:	8b 0d c4 87 18 f0    	mov    0xf01887c4,%ecx
f0100d5c:	c1 e1 0c             	shl    $0xc,%ecx
f0100d5f:	39 cb                	cmp    %ecx,%ebx
f0100d61:	76 1c                	jbe    f0100d7f <boot_alloc+0x60>
		panic("[boot_alloc] out of physical memory\n");
f0100d63:	c7 44 24 08 e4 5d 10 	movl   $0xf0105de4,0x8(%esp)
f0100d6a:	f0 
f0100d6b:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
f0100d72:	00 
f0100d73:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0100d7a:	e8 06 f3 ff ff       	call   f0100085 <_panic>
	}
	nextfree = result + n;
f0100d7f:	8d 14 10             	lea    (%eax,%edx,1),%edx
f0100d82:	89 15 08 7b 18 f0    	mov    %edx,0xf0187b08
	return result;
}
f0100d88:	83 c4 14             	add    $0x14,%esp
f0100d8b:	5b                   	pop    %ebx
f0100d8c:	5d                   	pop    %ebp
f0100d8d:	c3                   	ret    

f0100d8e <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100d8e:	55                   	push   %ebp
f0100d8f:	89 e5                	mov    %esp,%ebp
f0100d91:	57                   	push   %edi
f0100d92:	56                   	push   %esi
f0100d93:	53                   	push   %ebx
f0100d94:	83 ec 1c             	sub    $0x1c,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	page_free_list = NULL;
f0100d97:	c7 05 10 7b 18 f0 00 	movl   $0x0,0xf0187b10
f0100d9e:	00 00 00 
	size_t EXTPHYSMEM_END = PADDR(boot_alloc(0)) / PGSIZE;
f0100da1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100da6:	e8 74 ff ff ff       	call   f0100d1f <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100dab:	89 c6                	mov    %eax,%esi
f0100dad:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100db2:	77 20                	ja     f0100dd4 <page_init+0x46>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100db4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100db8:	c7 44 24 08 0c 5e 10 	movl   $0xf0105e0c,0x8(%esp)
f0100dbf:	f0 
f0100dc0:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
f0100dc7:	00 
f0100dc8:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0100dcf:	e8 b1 f2 ff ff       	call   f0100085 <_panic>
f0100dd4:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0100dda:	c1 ee 0c             	shr    $0xc,%esi
	//ROUNDDOWN in case of occupying address of IO hole
	size_t IOPHYSMEM_START = ROUNDDOWN(IOPHYSMEM, PGSIZE) / PGSIZE;

	for(i = npages - 1; i >= 0; i--) {
f0100ddd:	8b 15 c4 87 18 f0    	mov    0xf01887c4,%edx
f0100de3:	8d 42 ff             	lea    -0x1(%edx),%eax
		pages[i].pp_ref = 0;
f0100de6:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f0100ded:	8b 1d cc 87 18 f0    	mov    0xf01887cc,%ebx
f0100df3:	66 c7 44 0b 04 00 00 	movw   $0x0,0x4(%ebx,%ecx,1)
		if(i == 0) {
f0100dfa:	85 c0                	test   %eax,%eax
f0100dfc:	74 4a                	je     f0100e48 <page_init+0xba>
f0100dfe:	8b 1d 10 7b 18 f0    	mov    0xf0187b10,%ebx
f0100e04:	8d 14 d5 f0 ff ff ff 	lea    -0x10(,%edx,8),%edx
		//	pages[i].pp_link=NULL;
		//	page_free_list = &pages[i];
			break;
		}
		if(IOPHYSMEM_START <= i && i < EXTPHYSMEM_END) {
f0100e0b:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f0100e10:	76 04                	jbe    f0100e16 <page_init+0x88>
f0100e12:	39 f0                	cmp    %esi,%eax
f0100e14:	72 11                	jb     f0100e27 <page_init+0x99>
			continue;
		}
		pages[i].pp_link = page_free_list;
f0100e16:	8b 3d cc 87 18 f0    	mov    0xf01887cc,%edi
f0100e1c:	89 1c 0f             	mov    %ebx,(%edi,%ecx,1)
		page_free_list = &pages[i];
f0100e1f:	89 cb                	mov    %ecx,%ebx
f0100e21:	03 1d cc 87 18 f0    	add    0xf01887cc,%ebx
	size_t EXTPHYSMEM_END = PADDR(boot_alloc(0)) / PGSIZE;
	//ROUNDDOWN in case of occupying address of IO hole
	size_t IOPHYSMEM_START = ROUNDDOWN(IOPHYSMEM, PGSIZE) / PGSIZE;

	for(i = npages - 1; i >= 0; i--) {
		pages[i].pp_ref = 0;
f0100e27:	8b 0d cc 87 18 f0    	mov    0xf01887cc,%ecx
f0100e2d:	66 c7 44 11 04 00 00 	movw   $0x0,0x4(%ecx,%edx,1)
f0100e34:	8d 7a f8             	lea    -0x8(%edx),%edi
		if(i == 0) {
f0100e37:	83 e8 01             	sub    $0x1,%eax
f0100e3a:	74 06                	je     f0100e42 <page_init+0xb4>
f0100e3c:	89 d1                	mov    %edx,%ecx
f0100e3e:	89 fa                	mov    %edi,%edx
f0100e40:	eb c9                	jmp    f0100e0b <page_init+0x7d>
f0100e42:	89 1d 10 7b 18 f0    	mov    %ebx,0xf0187b10
		}
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
//		pages[i-1].pp_link = &pages[i]; 
	}
}
f0100e48:	83 c4 1c             	add    $0x1c,%esp
f0100e4b:	5b                   	pop    %ebx
f0100e4c:	5e                   	pop    %esi
f0100e4d:	5f                   	pop    %edi
f0100e4e:	5d                   	pop    %ebp
f0100e4f:	c3                   	ret    

f0100e50 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100e50:	55                   	push   %ebp
f0100e51:	89 e5                	mov    %esp,%ebp
f0100e53:	83 ec 18             	sub    $0x18,%esp
f0100e56:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100e59:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100e5c:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100e5e:	89 04 24             	mov    %eax,(%esp)
f0100e61:	e8 ea 2d 00 00       	call   f0103c50 <mc146818_read>
f0100e66:	89 c6                	mov    %eax,%esi
f0100e68:	83 c3 01             	add    $0x1,%ebx
f0100e6b:	89 1c 24             	mov    %ebx,(%esp)
f0100e6e:	e8 dd 2d 00 00       	call   f0103c50 <mc146818_read>
f0100e73:	c1 e0 08             	shl    $0x8,%eax
f0100e76:	09 f0                	or     %esi,%eax
}
f0100e78:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100e7b:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100e7e:	89 ec                	mov    %ebp,%esp
f0100e80:	5d                   	pop    %ebp
f0100e81:	c3                   	ret    

f0100e82 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc(int alloc_flags)
{
f0100e82:	55                   	push   %ebp
f0100e83:	89 e5                	mov    %esp,%ebp
f0100e85:	53                   	push   %ebx
f0100e86:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	struct Page * page_ptr;
	if(page_free_list != NULL) {
f0100e89:	8b 1d 10 7b 18 f0    	mov    0xf0187b10,%ebx
f0100e8f:	85 db                	test   %ebx,%ebx
f0100e91:	74 65                	je     f0100ef8 <page_alloc+0x76>
		page_ptr = page_free_list;
		page_free_list = (struct Page *) page_free_list->pp_link;
f0100e93:	8b 03                	mov    (%ebx),%eax
f0100e95:	a3 10 7b 18 f0       	mov    %eax,0xf0187b10
		if(alloc_flags & ALLOC_ZERO) {
f0100e9a:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e9e:	74 58                	je     f0100ef8 <page_alloc+0x76>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ea0:	89 d8                	mov    %ebx,%eax
f0100ea2:	2b 05 cc 87 18 f0    	sub    0xf01887cc,%eax
f0100ea8:	c1 f8 03             	sar    $0x3,%eax
f0100eab:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100eae:	89 c2                	mov    %eax,%edx
f0100eb0:	c1 ea 0c             	shr    $0xc,%edx
f0100eb3:	3b 15 c4 87 18 f0    	cmp    0xf01887c4,%edx
f0100eb9:	72 20                	jb     f0100edb <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ebb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ebf:	c7 44 24 08 30 5e 10 	movl   $0xf0105e30,0x8(%esp)
f0100ec6:	f0 
f0100ec7:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100ece:	00 
f0100ecf:	c7 04 24 d9 65 10 f0 	movl   $0xf01065d9,(%esp)
f0100ed6:	e8 aa f1 ff ff       	call   f0100085 <_panic>
			memset(page2kva(page_ptr), '\0' , PGSIZE);	
f0100edb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100ee2:	00 
f0100ee3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100eea:	00 
f0100eeb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ef0:	89 04 24             	mov    %eax,(%esp)
f0100ef3:	e8 0e 45 00 00       	call   f0105406 <memset>
		}
		return page_ptr; 
	} else { 
		return NULL;
	}
}
f0100ef8:	89 d8                	mov    %ebx,%eax
f0100efa:	83 c4 14             	add    $0x14,%esp
f0100efd:	5b                   	pop    %ebx
f0100efe:	5d                   	pop    %ebp
f0100eff:	c3                   	ret    

f0100f00 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100f00:	55                   	push   %ebp
f0100f01:	89 e5                	mov    %esp,%ebp
f0100f03:	83 ec 18             	sub    $0x18,%esp
f0100f06:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100f09:	89 75 fc             	mov    %esi,-0x4(%ebp)
	// Fill this function in
	pte_t *pgdir_entry = &pgdir[PDX(va)];	
f0100f0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100f0f:	89 de                	mov    %ebx,%esi
f0100f11:	c1 ee 16             	shr    $0x16,%esi
f0100f14:	c1 e6 02             	shl    $0x2,%esi
f0100f17:	03 75 08             	add    0x8(%ebp),%esi
	//if the pgdir_entry exists
	if(*pgdir_entry & PTE_P) {
f0100f1a:	8b 06                	mov    (%esi),%eax
f0100f1c:	a8 01                	test   $0x1,%al
f0100f1e:	74 44                	je     f0100f64 <pgdir_walk+0x64>
		pte_t *pt_va = (pte_t *) KADDR(PTE_ADDR(*pgdir_entry));
f0100f20:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f25:	89 c2                	mov    %eax,%edx
f0100f27:	c1 ea 0c             	shr    $0xc,%edx
f0100f2a:	3b 15 c4 87 18 f0    	cmp    0xf01887c4,%edx
f0100f30:	72 20                	jb     f0100f52 <pgdir_walk+0x52>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f32:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f36:	c7 44 24 08 30 5e 10 	movl   $0xf0105e30,0x8(%esp)
f0100f3d:	f0 
f0100f3e:	c7 44 24 04 cd 01 00 	movl   $0x1cd,0x4(%esp)
f0100f45:	00 
f0100f46:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0100f4d:	e8 33 f1 ff ff       	call   f0100085 <_panic>
		return pt_va + PTX(va);
f0100f52:	c1 eb 0a             	shr    $0xa,%ebx
f0100f55:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100f5b:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0100f62:	eb 75                	jmp    f0100fd9 <pgdir_walk+0xd9>
	} else {
		//if the page table does not exist
		if(!create) {
f0100f64:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100f68:	74 6a                	je     f0100fd4 <pgdir_walk+0xd4>
			return NULL;
		} else {
			//ask for a new physical page
			struct Page *new_pgt = page_alloc(1);
f0100f6a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0100f71:	e8 0c ff ff ff       	call   f0100e82 <page_alloc>
			if(new_pgt != NULL) {
f0100f76:	85 c0                	test   %eax,%eax
f0100f78:	74 5a                	je     f0100fd4 <pgdir_walk+0xd4>
				new_pgt->pp_ref = 1;
f0100f7a:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f80:	2b 05 cc 87 18 f0    	sub    0xf01887cc,%eax
f0100f86:	c1 f8 03             	sar    $0x3,%eax
f0100f89:	c1 e0 0c             	shl    $0xc,%eax
				physaddr_t new_pgt_pa = page2pa(new_pgt);
				*pgdir_entry = new_pgt_pa | PTE_W | PTE_U | PTE_P;
f0100f8c:	89 c2                	mov    %eax,%edx
f0100f8e:	83 ca 07             	or     $0x7,%edx
f0100f91:	89 16                	mov    %edx,(%esi)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f93:	89 c2                	mov    %eax,%edx
f0100f95:	c1 ea 0c             	shr    $0xc,%edx
f0100f98:	3b 15 c4 87 18 f0    	cmp    0xf01887c4,%edx
f0100f9e:	72 20                	jb     f0100fc0 <pgdir_walk+0xc0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fa0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fa4:	c7 44 24 08 30 5e 10 	movl   $0xf0105e30,0x8(%esp)
f0100fab:	f0 
f0100fac:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
f0100fb3:	00 
f0100fb4:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0100fbb:	e8 c5 f0 ff ff       	call   f0100085 <_panic>
				return (pte_t *)KADDR(new_pgt_pa) + PTX(va);
f0100fc0:	c1 eb 0a             	shr    $0xa,%ebx
f0100fc3:	89 da                	mov    %ebx,%edx
f0100fc5:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f0100fcb:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
f0100fd2:	eb 05                	jmp    f0100fd9 <pgdir_walk+0xd9>
f0100fd4:	b8 00 00 00 00       	mov    $0x0,%eax
				return NULL;
			}	
		}
	}	
	return NULL;
}
f0100fd9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100fdc:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100fdf:	89 ec                	mov    %ebp,%esp
f0100fe1:	5d                   	pop    %ebp
f0100fe2:	c3                   	ret    

f0100fe3 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0100fe3:	55                   	push   %ebp
f0100fe4:	89 e5                	mov    %esp,%ebp
f0100fe6:	57                   	push   %edi
f0100fe7:	56                   	push   %esi
f0100fe8:	53                   	push   %ebx
f0100fe9:	83 ec 2c             	sub    $0x2c,%esp
f0100fec:	8b 75 08             	mov    0x8(%ebp),%esi
f0100fef:	8b 45 14             	mov    0x14(%ebp),%eax
	// LAB 3: Your code here.
	pte_t* pte;

	uint32_t offset = (uint32_t)va;
f0100ff2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uint32_t limit = ROUNDUP(offset + len, PGSIZE);
f0100ff5:	89 df                	mov    %ebx,%edi
f0100ff7:	03 7d 10             	add    0x10(%ebp),%edi
f0100ffa:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f0101000:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi

	for(; offset < limit; offset += PGSIZE) {
f0101006:	39 fb                	cmp    %edi,%ebx
f0101008:	0f 83 b8 00 00 00    	jae    f01010c6 <user_mem_check+0xe3>
		if(offset >= ULIM) {
f010100e:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101014:	76 1c                	jbe    f0101032 <user_mem_check+0x4f>
f0101016:	eb 0a                	jmp    f0101022 <user_mem_check+0x3f>
f0101018:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010101e:	66 90                	xchg   %ax,%ax
f0101020:	76 1e                	jbe    f0101040 <user_mem_check+0x5d>
			user_mem_check_addr = (uintptr_t)offset;
f0101022:	89 1d 18 7b 18 f0    	mov    %ebx,0xf0187b18
f0101028:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
			return -E_FAULT;
f010102d:	e9 99 00 00 00       	jmp    f01010cb <user_mem_check+0xe8>
		}
		pte = pgdir_walk(env->env_pgdir, (void*)offset, 0);
		if(pte == NULL || !(*pte & (perm | PTE_P))) {
f0101032:	89 c2                	mov    %eax,%edx
f0101034:	83 ca 01             	or     $0x1,%edx
f0101037:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		if((previ & PTE_P) == 0){
			user_mem_check_addr = (uintptr_t)offset;
			return -E_FAULT;
		}
		if(previ & PTE_U){
			if(!(previ & PTE_W) && (perm&PTE_W)){
f010103a:	83 e0 02             	and    $0x2,%eax
f010103d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for(; offset < limit; offset += PGSIZE) {
		if(offset >= ULIM) {
			user_mem_check_addr = (uintptr_t)offset;
			return -E_FAULT;
		}
		pte = pgdir_walk(env->env_pgdir, (void*)offset, 0);
f0101040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101047:	00 
f0101048:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010104c:	8b 46 5c             	mov    0x5c(%esi),%eax
f010104f:	89 04 24             	mov    %eax,(%esp)
f0101052:	e8 a9 fe ff ff       	call   f0100f00 <pgdir_walk>
		if(pte == NULL || !(*pte & (perm | PTE_P))) {
f0101057:	85 c0                	test   %eax,%eax
f0101059:	74 07                	je     f0101062 <user_mem_check+0x7f>
f010105b:	8b 00                	mov    (%eax),%eax
f010105d:	85 45 e4             	test   %eax,-0x1c(%ebp)
f0101060:	75 0d                	jne    f010106f <user_mem_check+0x8c>
			user_mem_check_addr = (uintptr_t)offset;
f0101062:	89 1d 18 7b 18 f0    	mov    %ebx,0xf0187b18
f0101068:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
			return -E_FAULT;
f010106d:	eb 5c                	jmp    f01010cb <user_mem_check+0xe8>
		}
		unsigned int previ = PGOFF(*pte);
f010106f:	89 c2                	mov    %eax,%edx
f0101071:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
		if((previ & PTE_P) == 0){
f0101077:	a8 01                	test   $0x1,%al
f0101079:	75 0d                	jne    f0101088 <user_mem_check+0xa5>
			user_mem_check_addr = (uintptr_t)offset;
f010107b:	89 1d 18 7b 18 f0    	mov    %ebx,0xf0187b18
f0101081:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
			return -E_FAULT;
f0101086:	eb 43                	jmp    f01010cb <user_mem_check+0xe8>
		}
		if(previ & PTE_U){
f0101088:	f6 c2 04             	test   $0x4,%dl
f010108b:	74 18                	je     f01010a5 <user_mem_check+0xc2>
			if(!(previ & PTE_W) && (perm&PTE_W)){
f010108d:	f6 c2 02             	test   $0x2,%dl
f0101090:	75 20                	jne    f01010b2 <user_mem_check+0xcf>
f0101092:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101096:	74 1a                	je     f01010b2 <user_mem_check+0xcf>
				user_mem_check_addr = (uintptr_t)offset;
f0101098:	89 1d 18 7b 18 f0    	mov    %ebx,0xf0187b18
f010109e:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
				return -E_FAULT;
f01010a3:	eb 26                	jmp    f01010cb <user_mem_check+0xe8>
			}
		}else{
			user_mem_check_addr = (uintptr_t)offset;
f01010a5:	89 1d 18 7b 18 f0    	mov    %ebx,0xf0187b18
f01010ab:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
			return -E_FAULT;
f01010b0:	eb 19                	jmp    f01010cb <user_mem_check+0xe8>
		}
		offset = ROUNDDOWN(offset, PGSIZE);
f01010b2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	pte_t* pte;

	uint32_t offset = (uint32_t)va;
	uint32_t limit = ROUNDUP(offset + len, PGSIZE);

	for(; offset < limit; offset += PGSIZE) {
f01010b8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01010be:	39 df                	cmp    %ebx,%edi
f01010c0:	0f 87 52 ff ff ff    	ja     f0101018 <user_mem_check+0x35>
f01010c6:	b8 00 00 00 00       	mov    $0x0,%eax
			return -E_FAULT;
		}
		offset = ROUNDDOWN(offset, PGSIZE);
	}
	return 0;
}
f01010cb:	83 c4 2c             	add    $0x2c,%esp
f01010ce:	5b                   	pop    %ebx
f01010cf:	5e                   	pop    %esi
f01010d0:	5f                   	pop    %edi
f01010d1:	5d                   	pop    %ebp
f01010d2:	c3                   	ret    

f01010d3 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01010d3:	55                   	push   %ebp
f01010d4:	89 e5                	mov    %esp,%ebp
f01010d6:	53                   	push   %ebx
f01010d7:	83 ec 14             	sub    $0x14,%esp
f01010da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01010dd:	8b 45 14             	mov    0x14(%ebp),%eax
f01010e0:	83 c8 04             	or     $0x4,%eax
f01010e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01010e7:	8b 45 10             	mov    0x10(%ebp),%eax
f01010ea:	89 44 24 08          	mov    %eax,0x8(%esp)
f01010ee:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010f1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01010f5:	89 1c 24             	mov    %ebx,(%esp)
f01010f8:	e8 e6 fe ff ff       	call   f0100fe3 <user_mem_check>
f01010fd:	85 c0                	test   %eax,%eax
f01010ff:	79 24                	jns    f0101125 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0101101:	a1 18 7b 18 f0       	mov    0xf0187b18,%eax
f0101106:	89 44 24 08          	mov    %eax,0x8(%esp)
f010110a:	8b 43 48             	mov    0x48(%ebx),%eax
f010110d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101111:	c7 04 24 54 5e 10 f0 	movl   $0xf0105e54,(%esp)
f0101118:	e8 8e 2b 00 00       	call   f0103cab <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f010111d:	89 1c 24             	mov    %ebx,(%esp)
f0101120:	e8 b7 27 00 00       	call   f01038dc <env_destroy>
	}
}
f0101125:	83 c4 14             	add    $0x14,%esp
f0101128:	5b                   	pop    %ebx
f0101129:	5d                   	pop    %ebp
f010112a:	c3                   	ret    

f010112b <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010112b:	55                   	push   %ebp
f010112c:	89 e5                	mov    %esp,%ebp
f010112e:	53                   	push   %ebx
f010112f:	83 ec 14             	sub    $0x14,%esp
f0101132:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pgt_entry = pgdir_walk(pgdir, (void *)va, 0);
f0101135:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010113c:	00 
f010113d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101140:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101144:	8b 45 08             	mov    0x8(%ebp),%eax
f0101147:	89 04 24             	mov    %eax,(%esp)
f010114a:	e8 b1 fd ff ff       	call   f0100f00 <pgdir_walk>
	if(pgt_entry == NULL || (*pgt_entry & PTE_P) == 0) {
f010114f:	85 c0                	test   %eax,%eax
f0101151:	74 3f                	je     f0101192 <page_lookup+0x67>
f0101153:	f6 00 01             	testb  $0x1,(%eax)
f0101156:	74 3a                	je     f0101192 <page_lookup+0x67>
		return NULL;	
	}	
	if(pte_store != 0) {
f0101158:	85 db                	test   %ebx,%ebx
f010115a:	74 02                	je     f010115e <page_lookup+0x33>
		*pte_store = pgt_entry;
f010115c:	89 03                	mov    %eax,(%ebx)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010115e:	8b 00                	mov    (%eax),%eax
f0101160:	c1 e8 0c             	shr    $0xc,%eax
f0101163:	3b 05 c4 87 18 f0    	cmp    0xf01887c4,%eax
f0101169:	72 1c                	jb     f0101187 <page_lookup+0x5c>
		panic("pa2page called with invalid pa");
f010116b:	c7 44 24 08 8c 5e 10 	movl   $0xf0105e8c,0x8(%esp)
f0101172:	f0 
f0101173:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f010117a:	00 
f010117b:	c7 04 24 d9 65 10 f0 	movl   $0xf01065d9,(%esp)
f0101182:	e8 fe ee ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f0101187:	c1 e0 03             	shl    $0x3,%eax
f010118a:	03 05 cc 87 18 f0    	add    0xf01887cc,%eax
	}
	return pa2page(PTE_ADDR(*pgt_entry));
f0101190:	eb 05                	jmp    f0101197 <page_lookup+0x6c>
f0101192:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101197:	83 c4 14             	add    $0x14,%esp
f010119a:	5b                   	pop    %ebx
f010119b:	5d                   	pop    %ebp
f010119c:	c3                   	ret    

f010119d <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010119d:	55                   	push   %ebp
f010119e:	89 e5                	mov    %esp,%ebp
f01011a0:	83 ec 28             	sub    $0x28,%esp
f01011a3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01011a6:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01011a9:	8b 75 08             	mov    0x8(%ebp),%esi
f01011ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pgt_entry;
	struct Page *pg_rm;
	pg_rm = page_lookup(pgdir, va, &pgt_entry);
f01011af:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01011b2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01011b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01011ba:	89 34 24             	mov    %esi,(%esp)
f01011bd:	e8 69 ff ff ff       	call   f010112b <page_lookup>

	if(pg_rm != NULL) {
f01011c2:	85 c0                	test   %eax,%eax
f01011c4:	74 1d                	je     f01011e3 <page_remove+0x46>
		page_decref(pg_rm);
f01011c6:	89 04 24             	mov    %eax,(%esp)
f01011c9:	e8 87 fa ff ff       	call   f0100c55 <page_decref>
		*pgt_entry = 0;
f01011ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011d1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, va);
f01011d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01011db:	89 34 24             	mov    %esi,(%esp)
f01011de:	e8 95 fa ff ff       	call   f0100c78 <tlb_invalidate>
	}
	return;
}
f01011e3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01011e6:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01011e9:	89 ec                	mov    %ebp,%esp
f01011eb:	5d                   	pop    %ebp
f01011ec:	c3                   	ret    

f01011ed <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm)
{
f01011ed:	55                   	push   %ebp
f01011ee:	89 e5                	mov    %esp,%ebp
f01011f0:	83 ec 28             	sub    $0x28,%esp
f01011f3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01011f6:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01011f9:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01011fc:	8b 75 0c             	mov    0xc(%ebp),%esi
f01011ff:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *pgt_entry = pgdir_walk(pgdir, (void *)va, 1);
f0101202:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101209:	00 
f010120a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010120e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101211:	89 04 24             	mov    %eax,(%esp)
f0101214:	e8 e7 fc ff ff       	call   f0100f00 <pgdir_walk>
f0101219:	89 c3                	mov    %eax,%ebx
	if(pgt_entry == NULL) {
f010121b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101220:	85 db                	test   %ebx,%ebx
f0101222:	74 64                	je     f0101288 <page_insert+0x9b>
		return -E_NO_MEM;
	} else {
		if(*pgt_entry & PTE_P) {
f0101224:	8b 03                	mov    (%ebx),%eax
f0101226:	a8 01                	test   $0x1,%al
f0101228:	74 3c                	je     f0101266 <page_insert+0x79>
			if(PTE_ADDR(*pgt_entry) == page2pa(pp)) {
f010122a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010122f:	89 f2                	mov    %esi,%edx
f0101231:	2b 15 cc 87 18 f0    	sub    0xf01887cc,%edx
f0101237:	c1 fa 03             	sar    $0x3,%edx
f010123a:	c1 e2 0c             	shl    $0xc,%edx
f010123d:	39 d0                	cmp    %edx,%eax
f010123f:	75 16                	jne    f0101257 <page_insert+0x6a>
				//if the page pp has been mapped to va
				pp->pp_ref--;
f0101241:	66 83 6e 04 01       	subw   $0x1,0x4(%esi)
				tlb_invalidate(pgdir, va);
f0101246:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010124a:	8b 45 08             	mov    0x8(%ebp),%eax
f010124d:	89 04 24             	mov    %eax,(%esp)
f0101250:	e8 23 fa ff ff       	call   f0100c78 <tlb_invalidate>
f0101255:	eb 0f                	jmp    f0101266 <page_insert+0x79>
			} else {
				//if other page has been mapped to va
				page_remove(pgdir, va);
f0101257:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010125b:	8b 45 08             	mov    0x8(%ebp),%eax
f010125e:	89 04 24             	mov    %eax,(%esp)
f0101261:	e8 37 ff ff ff       	call   f010119d <page_remove>
			}
		}	
	}
	*pgt_entry = page2pa(pp) | perm | PTE_P;
f0101266:	8b 45 14             	mov    0x14(%ebp),%eax
f0101269:	83 c8 01             	or     $0x1,%eax
f010126c:	89 f2                	mov    %esi,%edx
f010126e:	2b 15 cc 87 18 f0    	sub    0xf01887cc,%edx
f0101274:	c1 fa 03             	sar    $0x3,%edx
f0101277:	c1 e2 0c             	shl    $0xc,%edx
f010127a:	09 d0                	or     %edx,%eax
f010127c:	89 03                	mov    %eax,(%ebx)
	pp->pp_ref++;
f010127e:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
f0101283:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f0101288:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010128b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010128e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101291:	89 ec                	mov    %ebp,%esp
f0101293:	5d                   	pop    %ebp
f0101294:	c3                   	ret    

f0101295 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101295:	55                   	push   %ebp
f0101296:	89 e5                	mov    %esp,%ebp
f0101298:	57                   	push   %edi
f0101299:	56                   	push   %esi
f010129a:	53                   	push   %ebx
f010129b:	83 ec 2c             	sub    $0x2c,%esp
f010129e:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01012a1:	89 d3                	mov    %edx,%ebx
f01012a3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01012a6:	8b 7d 08             	mov    0x8(%ebp),%edi
	// Fill this function in
	uintptr_t unit;
	pte_t *pgt_entry;
	for(unit = 0; unit < size; unit += PGSIZE) {
f01012a9:	85 c9                	test   %ecx,%ecx
f01012ab:	74 43                	je     f01012f0 <boot_map_region+0x5b>
f01012ad:	be 00 00 00 00       	mov    $0x0,%esi
		//get the page table entry for every page
		pgt_entry = pgdir_walk(pgdir, (void *)va, 1);
		//set the permission and 
		*pgt_entry = pa | perm | PTE_P;
f01012b2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012b5:	83 c8 01             	or     $0x1,%eax
f01012b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// Fill this function in
	uintptr_t unit;
	pte_t *pgt_entry;
	for(unit = 0; unit < size; unit += PGSIZE) {
		//get the page table entry for every page
		pgt_entry = pgdir_walk(pgdir, (void *)va, 1);
f01012bb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01012c2:	00 
f01012c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01012c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01012ca:	89 04 24             	mov    %eax,(%esp)
f01012cd:	e8 2e fc ff ff       	call   f0100f00 <pgdir_walk>
		//set the permission and 
		*pgt_entry = pa | perm | PTE_P;
f01012d2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01012d5:	09 fa                	or     %edi,%edx
f01012d7:	89 10                	mov    %edx,(%eax)
		pa += PGSIZE;
f01012d9:	81 c7 00 10 00 00    	add    $0x1000,%edi
		va += PGSIZE;
f01012df:	81 c3 00 10 00 00    	add    $0x1000,%ebx
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	uintptr_t unit;
	pte_t *pgt_entry;
	for(unit = 0; unit < size; unit += PGSIZE) {
f01012e5:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01012eb:	39 75 e0             	cmp    %esi,-0x20(%ebp)
f01012ee:	77 cb                	ja     f01012bb <boot_map_region+0x26>
		*pgt_entry = pa | perm | PTE_P;
		pa += PGSIZE;
		va += PGSIZE;
	}	
	return;
}
f01012f0:	83 c4 2c             	add    $0x2c,%esp
f01012f3:	5b                   	pop    %ebx
f01012f4:	5e                   	pop    %esi
f01012f5:	5f                   	pop    %edi
f01012f6:	5d                   	pop    %ebp
f01012f7:	c3                   	ret    

f01012f8 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01012f8:	55                   	push   %ebp
f01012f9:	89 e5                	mov    %esp,%ebp
f01012fb:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f01012fe:	89 d1                	mov    %edx,%ecx
f0101300:	c1 e9 16             	shr    $0x16,%ecx
f0101303:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0101306:	a8 01                	test   $0x1,%al
f0101308:	74 4d                	je     f0101357 <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f010130a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010130f:	89 c1                	mov    %eax,%ecx
f0101311:	c1 e9 0c             	shr    $0xc,%ecx
f0101314:	3b 0d c4 87 18 f0    	cmp    0xf01887c4,%ecx
f010131a:	72 20                	jb     f010133c <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010131c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101320:	c7 44 24 08 30 5e 10 	movl   $0xf0105e30,0x8(%esp)
f0101327:	f0 
f0101328:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f010132f:	00 
f0101330:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101337:	e8 49 ed ff ff       	call   f0100085 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f010133c:	c1 ea 0c             	shr    $0xc,%edx
f010133f:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0101345:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f010134c:	a8 01                	test   $0x1,%al
f010134e:	74 07                	je     f0101357 <check_va2pa+0x5f>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0101350:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101355:	eb 05                	jmp    f010135c <check_va2pa+0x64>
f0101357:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f010135c:	c9                   	leave  
f010135d:	c3                   	ret    

f010135e <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f010135e:	55                   	push   %ebp
f010135f:	89 e5                	mov    %esp,%ebp
f0101361:	57                   	push   %edi
f0101362:	56                   	push   %esi
f0101363:	53                   	push   %ebx
f0101364:	83 ec 4c             	sub    $0x4c,%esp
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101367:	83 f8 01             	cmp    $0x1,%eax
f010136a:	19 f6                	sbb    %esi,%esi
f010136c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0101372:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101375:	8b 1d 10 7b 18 f0    	mov    0xf0187b10,%ebx
f010137b:	85 db                	test   %ebx,%ebx
f010137d:	75 1c                	jne    f010139b <check_page_free_list+0x3d>
		panic("'page_free_list' is a null pointer!");
f010137f:	c7 44 24 08 ac 5e 10 	movl   $0xf0105eac,0x8(%esp)
f0101386:	f0 
f0101387:	c7 44 24 04 cf 02 00 	movl   $0x2cf,0x4(%esp)
f010138e:	00 
f010138f:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101396:	e8 ea ec ff ff       	call   f0100085 <_panic>

	if (only_low_memory) {
f010139b:	85 c0                	test   %eax,%eax
f010139d:	74 52                	je     f01013f1 <check_page_free_list+0x93>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
f010139f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01013a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01013a5:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01013a8:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01013ab:	8b 0d cc 87 18 f0    	mov    0xf01887cc,%ecx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01013b1:	89 d8                	mov    %ebx,%eax
f01013b3:	29 c8                	sub    %ecx,%eax
f01013b5:	c1 e0 09             	shl    $0x9,%eax
f01013b8:	c1 e8 16             	shr    $0x16,%eax
f01013bb:	39 c6                	cmp    %eax,%esi
f01013bd:	0f 96 c0             	setbe  %al
f01013c0:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f01013c3:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f01013c7:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f01013c9:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01013cd:	8b 1b                	mov    (%ebx),%ebx
f01013cf:	85 db                	test   %ebx,%ebx
f01013d1:	75 de                	jne    f01013b1 <check_page_free_list+0x53>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f01013d3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01013d6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01013dc:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01013df:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01013e2:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01013e4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01013e7:	89 1d 10 7b 18 f0    	mov    %ebx,0xf0187b10
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f01013ed:	85 db                	test   %ebx,%ebx
f01013ef:	74 67                	je     f0101458 <check_page_free_list+0xfa>
f01013f1:	89 d8                	mov    %ebx,%eax
f01013f3:	2b 05 cc 87 18 f0    	sub    0xf01887cc,%eax
f01013f9:	c1 f8 03             	sar    $0x3,%eax
f01013fc:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f01013ff:	89 c2                	mov    %eax,%edx
f0101401:	c1 ea 16             	shr    $0x16,%edx
f0101404:	39 d6                	cmp    %edx,%esi
f0101406:	76 4a                	jbe    f0101452 <check_page_free_list+0xf4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101408:	89 c2                	mov    %eax,%edx
f010140a:	c1 ea 0c             	shr    $0xc,%edx
f010140d:	3b 15 c4 87 18 f0    	cmp    0xf01887c4,%edx
f0101413:	72 20                	jb     f0101435 <check_page_free_list+0xd7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101415:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101419:	c7 44 24 08 30 5e 10 	movl   $0xf0105e30,0x8(%esp)
f0101420:	f0 
f0101421:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101428:	00 
f0101429:	c7 04 24 d9 65 10 f0 	movl   $0xf01065d9,(%esp)
f0101430:	e8 50 ec ff ff       	call   f0100085 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101435:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f010143c:	00 
f010143d:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101444:	00 
f0101445:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010144a:	89 04 24             	mov    %eax,(%esp)
f010144d:	e8 b4 3f 00 00       	call   f0105406 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0101452:	8b 1b                	mov    (%ebx),%ebx
f0101454:	85 db                	test   %ebx,%ebx
f0101456:	75 99                	jne    f01013f1 <check_page_free_list+0x93>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
f0101458:	b8 00 00 00 00       	mov    $0x0,%eax
f010145d:	e8 bd f8 ff ff       	call   f0100d1f <boot_alloc>
f0101462:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101465:	a1 10 7b 18 f0       	mov    0xf0187b10,%eax
f010146a:	85 c0                	test   %eax,%eax
f010146c:	0f 84 10 02 00 00    	je     f0101682 <check_page_free_list+0x324>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101472:	8b 0d cc 87 18 f0    	mov    0xf01887cc,%ecx
f0101478:	39 c8                	cmp    %ecx,%eax
f010147a:	72 56                	jb     f01014d2 <check_page_free_list+0x174>
		assert(pp < pages + npages);
f010147c:	8b 15 c4 87 18 f0    	mov    0xf01887c4,%edx
f0101482:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0101485:	8d 3c d1             	lea    (%ecx,%edx,8),%edi
f0101488:	39 f8                	cmp    %edi,%eax
f010148a:	73 6e                	jae    f01014fa <check_page_free_list+0x19c>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010148c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f010148f:	89 c2                	mov    %eax,%edx
f0101491:	29 ca                	sub    %ecx,%edx
f0101493:	f6 c2 07             	test   $0x7,%dl
f0101496:	0f 85 8c 00 00 00    	jne    f0101528 <check_page_free_list+0x1ca>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010149c:	c1 fa 03             	sar    $0x3,%edx
f010149f:	c1 e2 0c             	shl    $0xc,%edx

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01014a2:	85 d2                	test   %edx,%edx
f01014a4:	0f 84 ac 00 00 00    	je     f0101556 <check_page_free_list+0x1f8>
		assert(page2pa(pp) != IOPHYSMEM);
f01014aa:	81 fa 00 00 0a 00    	cmp    $0xa0000,%edx
f01014b0:	0f 84 cc 00 00 00    	je     f0101582 <check_page_free_list+0x224>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01014b6:	81 fa 00 f0 0f 00    	cmp    $0xff000,%edx
f01014bc:	0f 85 10 01 00 00    	jne    f01015d2 <check_page_free_list+0x274>
f01014c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01014c8:	e9 e1 00 00 00       	jmp    f01015ae <check_page_free_list+0x250>
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01014cd:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
f01014d0:	73 24                	jae    f01014f6 <check_page_free_list+0x198>
f01014d2:	c7 44 24 0c e7 65 10 	movl   $0xf01065e7,0xc(%esp)
f01014d9:	f0 
f01014da:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01014e1:	f0 
f01014e2:	c7 44 24 04 ea 02 00 	movl   $0x2ea,0x4(%esp)
f01014e9:	00 
f01014ea:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01014f1:	e8 8f eb ff ff       	call   f0100085 <_panic>
		assert(pp < pages + npages);
f01014f6:	39 f8                	cmp    %edi,%eax
f01014f8:	72 24                	jb     f010151e <check_page_free_list+0x1c0>
f01014fa:	c7 44 24 0c 08 66 10 	movl   $0xf0106608,0xc(%esp)
f0101501:	f0 
f0101502:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101509:	f0 
f010150a:	c7 44 24 04 eb 02 00 	movl   $0x2eb,0x4(%esp)
f0101511:	00 
f0101512:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101519:	e8 67 eb ff ff       	call   f0100085 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010151e:	89 c2                	mov    %eax,%edx
f0101520:	2b 55 d4             	sub    -0x2c(%ebp),%edx
f0101523:	f6 c2 07             	test   $0x7,%dl
f0101526:	74 24                	je     f010154c <check_page_free_list+0x1ee>
f0101528:	c7 44 24 0c d0 5e 10 	movl   $0xf0105ed0,0xc(%esp)
f010152f:	f0 
f0101530:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101537:	f0 
f0101538:	c7 44 24 04 ec 02 00 	movl   $0x2ec,0x4(%esp)
f010153f:	00 
f0101540:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101547:	e8 39 eb ff ff       	call   f0100085 <_panic>
f010154c:	c1 fa 03             	sar    $0x3,%edx
f010154f:	c1 e2 0c             	shl    $0xc,%edx

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101552:	85 d2                	test   %edx,%edx
f0101554:	75 24                	jne    f010157a <check_page_free_list+0x21c>
f0101556:	c7 44 24 0c 1c 66 10 	movl   $0xf010661c,0xc(%esp)
f010155d:	f0 
f010155e:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101565:	f0 
f0101566:	c7 44 24 04 ef 02 00 	movl   $0x2ef,0x4(%esp)
f010156d:	00 
f010156e:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101575:	e8 0b eb ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f010157a:	81 fa 00 00 0a 00    	cmp    $0xa0000,%edx
f0101580:	75 24                	jne    f01015a6 <check_page_free_list+0x248>
f0101582:	c7 44 24 0c 2d 66 10 	movl   $0xf010662d,0xc(%esp)
f0101589:	f0 
f010158a:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101591:	f0 
f0101592:	c7 44 24 04 f0 02 00 	movl   $0x2f0,0x4(%esp)
f0101599:	00 
f010159a:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01015a1:	e8 df ea ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01015a6:	81 fa 00 f0 0f 00    	cmp    $0xff000,%edx
f01015ac:	75 31                	jne    f01015df <check_page_free_list+0x281>
f01015ae:	c7 44 24 0c 04 5f 10 	movl   $0xf0105f04,0xc(%esp)
f01015b5:	f0 
f01015b6:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01015bd:	f0 
f01015be:	c7 44 24 04 f1 02 00 	movl   $0x2f1,0x4(%esp)
f01015c5:	00 
f01015c6:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01015cd:	e8 b3 ea ff ff       	call   f0100085 <_panic>
f01015d2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01015d7:	be 00 00 00 00       	mov    $0x0,%esi
f01015dc:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
		assert(page2pa(pp) != EXTPHYSMEM);
f01015df:	81 fa 00 00 10 00    	cmp    $0x100000,%edx
f01015e5:	75 24                	jne    f010160b <check_page_free_list+0x2ad>
f01015e7:	c7 44 24 0c 46 66 10 	movl   $0xf0106646,0xc(%esp)
f01015ee:	f0 
f01015ef:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01015f6:	f0 
f01015f7:	c7 44 24 04 f2 02 00 	movl   $0x2f2,0x4(%esp)
f01015fe:	00 
f01015ff:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101606:	e8 7a ea ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010160b:	81 fa ff ff 0f 00    	cmp    $0xfffff,%edx
f0101611:	76 59                	jbe    f010166c <check_page_free_list+0x30e>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101613:	89 d1                	mov    %edx,%ecx
f0101615:	c1 e9 0c             	shr    $0xc,%ecx
f0101618:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f010161b:	77 20                	ja     f010163d <check_page_free_list+0x2df>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010161d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101621:	c7 44 24 08 30 5e 10 	movl   $0xf0105e30,0x8(%esp)
f0101628:	f0 
f0101629:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101630:	00 
f0101631:	c7 04 24 d9 65 10 f0 	movl   $0xf01065d9,(%esp)
f0101638:	e8 48 ea ff ff       	call   f0100085 <_panic>
f010163d:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101643:	39 55 c8             	cmp    %edx,-0x38(%ebp)
f0101646:	76 29                	jbe    f0101671 <check_page_free_list+0x313>
f0101648:	c7 44 24 0c 28 5f 10 	movl   $0xf0105f28,0xc(%esp)
f010164f:	f0 
f0101650:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101657:	f0 
f0101658:	c7 44 24 04 f3 02 00 	movl   $0x2f3,0x4(%esp)
f010165f:	00 
f0101660:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101667:	e8 19 ea ff ff       	call   f0100085 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f010166c:	83 c6 01             	add    $0x1,%esi
f010166f:	eb 03                	jmp    f0101674 <check_page_free_list+0x316>
		else
			++nfree_extmem;
f0101671:	83 c3 01             	add    $0x1,%ebx
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101674:	8b 00                	mov    (%eax),%eax
f0101676:	85 c0                	test   %eax,%eax
f0101678:	0f 85 4f fe ff ff    	jne    f01014cd <check_page_free_list+0x16f>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f010167e:	85 f6                	test   %esi,%esi
f0101680:	7f 24                	jg     f01016a6 <check_page_free_list+0x348>
f0101682:	c7 44 24 0c 60 66 10 	movl   $0xf0106660,0xc(%esp)
f0101689:	f0 
f010168a:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101691:	f0 
f0101692:	c7 44 24 04 fb 02 00 	movl   $0x2fb,0x4(%esp)
f0101699:	00 
f010169a:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01016a1:	e8 df e9 ff ff       	call   f0100085 <_panic>
	assert(nfree_extmem > 0);
f01016a6:	85 db                	test   %ebx,%ebx
f01016a8:	7f 24                	jg     f01016ce <check_page_free_list+0x370>
f01016aa:	c7 44 24 0c 72 66 10 	movl   $0xf0106672,0xc(%esp)
f01016b1:	f0 
f01016b2:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01016b9:	f0 
f01016ba:	c7 44 24 04 fc 02 00 	movl   $0x2fc,0x4(%esp)
f01016c1:	00 
f01016c2:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01016c9:	e8 b7 e9 ff ff       	call   f0100085 <_panic>
}
f01016ce:	83 c4 4c             	add    $0x4c,%esp
f01016d1:	5b                   	pop    %ebx
f01016d2:	5e                   	pop    %esi
f01016d3:	5f                   	pop    %edi
f01016d4:	5d                   	pop    %ebp
f01016d5:	c3                   	ret    

f01016d6 <check_page>:


// check page_insert, page_remove, &c
static void
check_page(void)
{
f01016d6:	55                   	push   %ebp
f01016d7:	89 e5                	mov    %esp,%ebp
f01016d9:	57                   	push   %edi
f01016da:	56                   	push   %esi
f01016db:	53                   	push   %ebx
f01016dc:	83 ec 3c             	sub    $0x3c,%esp
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016e6:	e8 97 f7 ff ff       	call   f0100e82 <page_alloc>
f01016eb:	89 c6                	mov    %eax,%esi
f01016ed:	85 c0                	test   %eax,%eax
f01016ef:	75 24                	jne    f0101715 <check_page+0x3f>
f01016f1:	c7 44 24 0c 83 66 10 	movl   $0xf0106683,0xc(%esp)
f01016f8:	f0 
f01016f9:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101700:	f0 
f0101701:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0101708:	00 
f0101709:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101710:	e8 70 e9 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0101715:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010171c:	e8 61 f7 ff ff       	call   f0100e82 <page_alloc>
f0101721:	89 c7                	mov    %eax,%edi
f0101723:	85 c0                	test   %eax,%eax
f0101725:	75 24                	jne    f010174b <check_page+0x75>
f0101727:	c7 44 24 0c 99 66 10 	movl   $0xf0106699,0xc(%esp)
f010172e:	f0 
f010172f:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101736:	f0 
f0101737:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f010173e:	00 
f010173f:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101746:	e8 3a e9 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f010174b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101752:	e8 2b f7 ff ff       	call   f0100e82 <page_alloc>
f0101757:	89 c3                	mov    %eax,%ebx
f0101759:	85 c0                	test   %eax,%eax
f010175b:	75 24                	jne    f0101781 <check_page+0xab>
f010175d:	c7 44 24 0c af 66 10 	movl   $0xf01066af,0xc(%esp)
f0101764:	f0 
f0101765:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f010176c:	f0 
f010176d:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f0101774:	00 
f0101775:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f010177c:	e8 04 e9 ff ff       	call   f0100085 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101781:	39 fe                	cmp    %edi,%esi
f0101783:	75 24                	jne    f01017a9 <check_page+0xd3>
f0101785:	c7 44 24 0c c5 66 10 	movl   $0xf01066c5,0xc(%esp)
f010178c:	f0 
f010178d:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101794:	f0 
f0101795:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f010179c:	00 
f010179d:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01017a4:	e8 dc e8 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017a9:	39 c7                	cmp    %eax,%edi
f01017ab:	74 04                	je     f01017b1 <check_page+0xdb>
f01017ad:	39 c6                	cmp    %eax,%esi
f01017af:	75 24                	jne    f01017d5 <check_page+0xff>
f01017b1:	c7 44 24 0c 70 5f 10 	movl   $0xf0105f70,0xc(%esp)
f01017b8:	f0 
f01017b9:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01017c0:	f0 
f01017c1:	c7 44 24 04 ac 03 00 	movl   $0x3ac,0x4(%esp)
f01017c8:	00 
f01017c9:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01017d0:	e8 b0 e8 ff ff       	call   f0100085 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01017d5:	a1 10 7b 18 f0       	mov    0xf0187b10,%eax
f01017da:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f01017dd:	c7 05 10 7b 18 f0 00 	movl   $0x0,0xf0187b10
f01017e4:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01017e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017ee:	e8 8f f6 ff ff       	call   f0100e82 <page_alloc>
f01017f3:	85 c0                	test   %eax,%eax
f01017f5:	74 24                	je     f010181b <check_page+0x145>
f01017f7:	c7 44 24 0c d7 66 10 	movl   $0xf01066d7,0xc(%esp)
f01017fe:	f0 
f01017ff:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101806:	f0 
f0101807:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f010180e:	00 
f010180f:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101816:	e8 6a e8 ff ff       	call   f0100085 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010181b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010181e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101822:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101829:	00 
f010182a:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f010182f:	89 04 24             	mov    %eax,(%esp)
f0101832:	e8 f4 f8 ff ff       	call   f010112b <page_lookup>
f0101837:	85 c0                	test   %eax,%eax
f0101839:	74 24                	je     f010185f <check_page+0x189>
f010183b:	c7 44 24 0c 90 5f 10 	movl   $0xf0105f90,0xc(%esp)
f0101842:	f0 
f0101843:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f010184a:	f0 
f010184b:	c7 44 24 04 b6 03 00 	movl   $0x3b6,0x4(%esp)
f0101852:	00 
f0101853:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f010185a:	e8 26 e8 ff ff       	call   f0100085 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010185f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101866:	00 
f0101867:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010186e:	00 
f010186f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101873:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0101878:	89 04 24             	mov    %eax,(%esp)
f010187b:	e8 6d f9 ff ff       	call   f01011ed <page_insert>
f0101880:	85 c0                	test   %eax,%eax
f0101882:	78 24                	js     f01018a8 <check_page+0x1d2>
f0101884:	c7 44 24 0c c8 5f 10 	movl   $0xf0105fc8,0xc(%esp)
f010188b:	f0 
f010188c:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101893:	f0 
f0101894:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f010189b:	00 
f010189c:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01018a3:	e8 dd e7 ff ff       	call   f0100085 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01018a8:	89 34 24             	mov    %esi,(%esp)
f01018ab:	e8 90 f3 ff ff       	call   f0100c40 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01018b0:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01018b7:	00 
f01018b8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01018bf:	00 
f01018c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01018c4:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f01018c9:	89 04 24             	mov    %eax,(%esp)
f01018cc:	e8 1c f9 ff ff       	call   f01011ed <page_insert>
f01018d1:	85 c0                	test   %eax,%eax
f01018d3:	74 24                	je     f01018f9 <check_page+0x223>
f01018d5:	c7 44 24 0c f8 5f 10 	movl   $0xf0105ff8,0xc(%esp)
f01018dc:	f0 
f01018dd:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01018e4:	f0 
f01018e5:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f01018ec:	00 
f01018ed:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01018f4:	e8 8c e7 ff ff       	call   f0100085 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01018f9:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01018fe:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0101901:	8b 08                	mov    (%eax),%ecx
f0101903:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101909:	89 f2                	mov    %esi,%edx
f010190b:	2b 15 cc 87 18 f0    	sub    0xf01887cc,%edx
f0101911:	c1 fa 03             	sar    $0x3,%edx
f0101914:	c1 e2 0c             	shl    $0xc,%edx
f0101917:	39 d1                	cmp    %edx,%ecx
f0101919:	74 24                	je     f010193f <check_page+0x269>
f010191b:	c7 44 24 0c 28 60 10 	movl   $0xf0106028,0xc(%esp)
f0101922:	f0 
f0101923:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f010192a:	f0 
f010192b:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f0101932:	00 
f0101933:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f010193a:	e8 46 e7 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010193f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101944:	e8 af f9 ff ff       	call   f01012f8 <check_va2pa>
f0101949:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010194c:	89 fa                	mov    %edi,%edx
f010194e:	2b 15 cc 87 18 f0    	sub    0xf01887cc,%edx
f0101954:	c1 fa 03             	sar    $0x3,%edx
f0101957:	c1 e2 0c             	shl    $0xc,%edx
f010195a:	39 d0                	cmp    %edx,%eax
f010195c:	74 24                	je     f0101982 <check_page+0x2ac>
f010195e:	c7 44 24 0c 50 60 10 	movl   $0xf0106050,0xc(%esp)
f0101965:	f0 
f0101966:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f010196d:	f0 
f010196e:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f0101975:	00 
f0101976:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f010197d:	e8 03 e7 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 1);
f0101982:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101987:	74 24                	je     f01019ad <check_page+0x2d7>
f0101989:	c7 44 24 0c e6 66 10 	movl   $0xf01066e6,0xc(%esp)
f0101990:	f0 
f0101991:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101998:	f0 
f0101999:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f01019a0:	00 
f01019a1:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01019a8:	e8 d8 e6 ff ff       	call   f0100085 <_panic>
	assert(pp0->pp_ref == 1);
f01019ad:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01019b2:	74 24                	je     f01019d8 <check_page+0x302>
f01019b4:	c7 44 24 0c f7 66 10 	movl   $0xf01066f7,0xc(%esp)
f01019bb:	f0 
f01019bc:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01019c3:	f0 
f01019c4:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f01019cb:	00 
f01019cc:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01019d3:	e8 ad e6 ff ff       	call   f0100085 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01019d8:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01019df:	00 
f01019e0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01019e7:	00 
f01019e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01019ec:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f01019f1:	89 04 24             	mov    %eax,(%esp)
f01019f4:	e8 f4 f7 ff ff       	call   f01011ed <page_insert>
f01019f9:	85 c0                	test   %eax,%eax
f01019fb:	74 24                	je     f0101a21 <check_page+0x34b>
f01019fd:	c7 44 24 0c 80 60 10 	movl   $0xf0106080,0xc(%esp)
f0101a04:	f0 
f0101a05:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101a0c:	f0 
f0101a0d:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0101a14:	00 
f0101a15:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101a1c:	e8 64 e6 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a21:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a26:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0101a2b:	e8 c8 f8 ff ff       	call   f01012f8 <check_va2pa>
f0101a30:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0101a33:	89 da                	mov    %ebx,%edx
f0101a35:	2b 15 cc 87 18 f0    	sub    0xf01887cc,%edx
f0101a3b:	c1 fa 03             	sar    $0x3,%edx
f0101a3e:	c1 e2 0c             	shl    $0xc,%edx
f0101a41:	39 d0                	cmp    %edx,%eax
f0101a43:	74 24                	je     f0101a69 <check_page+0x393>
f0101a45:	c7 44 24 0c bc 60 10 	movl   $0xf01060bc,0xc(%esp)
f0101a4c:	f0 
f0101a4d:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101a54:	f0 
f0101a55:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f0101a5c:	00 
f0101a5d:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101a64:	e8 1c e6 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f0101a69:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a6e:	74 24                	je     f0101a94 <check_page+0x3be>
f0101a70:	c7 44 24 0c 08 67 10 	movl   $0xf0106708,0xc(%esp)
f0101a77:	f0 
f0101a78:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101a7f:	f0 
f0101a80:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f0101a87:	00 
f0101a88:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101a8f:	e8 f1 e5 ff ff       	call   f0100085 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101a94:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a9b:	e8 e2 f3 ff ff       	call   f0100e82 <page_alloc>
f0101aa0:	85 c0                	test   %eax,%eax
f0101aa2:	74 24                	je     f0101ac8 <check_page+0x3f2>
f0101aa4:	c7 44 24 0c d7 66 10 	movl   $0xf01066d7,0xc(%esp)
f0101aab:	f0 
f0101aac:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101ab3:	f0 
f0101ab4:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f0101abb:	00 
f0101abc:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101ac3:	e8 bd e5 ff ff       	call   f0100085 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ac8:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101acf:	00 
f0101ad0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ad7:	00 
f0101ad8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101adc:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0101ae1:	89 04 24             	mov    %eax,(%esp)
f0101ae4:	e8 04 f7 ff ff       	call   f01011ed <page_insert>
f0101ae9:	85 c0                	test   %eax,%eax
f0101aeb:	74 24                	je     f0101b11 <check_page+0x43b>
f0101aed:	c7 44 24 0c 80 60 10 	movl   $0xf0106080,0xc(%esp)
f0101af4:	f0 
f0101af5:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101afc:	f0 
f0101afd:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0101b04:	00 
f0101b05:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101b0c:	e8 74 e5 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b11:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b16:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0101b1b:	e8 d8 f7 ff ff       	call   f01012f8 <check_va2pa>
f0101b20:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0101b23:	2b 15 cc 87 18 f0    	sub    0xf01887cc,%edx
f0101b29:	c1 fa 03             	sar    $0x3,%edx
f0101b2c:	c1 e2 0c             	shl    $0xc,%edx
f0101b2f:	39 d0                	cmp    %edx,%eax
f0101b31:	74 24                	je     f0101b57 <check_page+0x481>
f0101b33:	c7 44 24 0c bc 60 10 	movl   $0xf01060bc,0xc(%esp)
f0101b3a:	f0 
f0101b3b:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101b42:	f0 
f0101b43:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f0101b4a:	00 
f0101b4b:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101b52:	e8 2e e5 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f0101b57:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b5c:	74 24                	je     f0101b82 <check_page+0x4ac>
f0101b5e:	c7 44 24 0c 08 67 10 	movl   $0xf0106708,0xc(%esp)
f0101b65:	f0 
f0101b66:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101b6d:	f0 
f0101b6e:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f0101b75:	00 
f0101b76:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101b7d:	e8 03 e5 ff ff       	call   f0100085 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101b82:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b89:	e8 f4 f2 ff ff       	call   f0100e82 <page_alloc>
f0101b8e:	85 c0                	test   %eax,%eax
f0101b90:	74 24                	je     f0101bb6 <check_page+0x4e0>
f0101b92:	c7 44 24 0c d7 66 10 	movl   $0xf01066d7,0xc(%esp)
f0101b99:	f0 
f0101b9a:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101ba1:	f0 
f0101ba2:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f0101ba9:	00 
f0101baa:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101bb1:	e8 cf e4 ff ff       	call   f0100085 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101bb6:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0101bbb:	8b 00                	mov    (%eax),%eax
f0101bbd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101bc2:	89 c2                	mov    %eax,%edx
f0101bc4:	c1 ea 0c             	shr    $0xc,%edx
f0101bc7:	3b 15 c4 87 18 f0    	cmp    0xf01887c4,%edx
f0101bcd:	72 20                	jb     f0101bef <check_page+0x519>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101bcf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101bd3:	c7 44 24 08 30 5e 10 	movl   $0xf0105e30,0x8(%esp)
f0101bda:	f0 
f0101bdb:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0101be2:	00 
f0101be3:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101bea:	e8 96 e4 ff ff       	call   f0100085 <_panic>
f0101bef:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101bf4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101bf7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101bfe:	00 
f0101bff:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101c06:	00 
f0101c07:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0101c0c:	89 04 24             	mov    %eax,(%esp)
f0101c0f:	e8 ec f2 ff ff       	call   f0100f00 <pgdir_walk>
f0101c14:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101c17:	83 c2 04             	add    $0x4,%edx
f0101c1a:	39 d0                	cmp    %edx,%eax
f0101c1c:	74 24                	je     f0101c42 <check_page+0x56c>
f0101c1e:	c7 44 24 0c ec 60 10 	movl   $0xf01060ec,0xc(%esp)
f0101c25:	f0 
f0101c26:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101c2d:	f0 
f0101c2e:	c7 44 24 04 d6 03 00 	movl   $0x3d6,0x4(%esp)
f0101c35:	00 
f0101c36:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101c3d:	e8 43 e4 ff ff       	call   f0100085 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101c42:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101c49:	00 
f0101c4a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101c51:	00 
f0101c52:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101c56:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0101c5b:	89 04 24             	mov    %eax,(%esp)
f0101c5e:	e8 8a f5 ff ff       	call   f01011ed <page_insert>
f0101c63:	85 c0                	test   %eax,%eax
f0101c65:	74 24                	je     f0101c8b <check_page+0x5b5>
f0101c67:	c7 44 24 0c 2c 61 10 	movl   $0xf010612c,0xc(%esp)
f0101c6e:	f0 
f0101c6f:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101c76:	f0 
f0101c77:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f0101c7e:	00 
f0101c7f:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101c86:	e8 fa e3 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c8b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c90:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0101c95:	e8 5e f6 ff ff       	call   f01012f8 <check_va2pa>
f0101c9a:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0101c9d:	2b 15 cc 87 18 f0    	sub    0xf01887cc,%edx
f0101ca3:	c1 fa 03             	sar    $0x3,%edx
f0101ca6:	c1 e2 0c             	shl    $0xc,%edx
f0101ca9:	39 d0                	cmp    %edx,%eax
f0101cab:	74 24                	je     f0101cd1 <check_page+0x5fb>
f0101cad:	c7 44 24 0c bc 60 10 	movl   $0xf01060bc,0xc(%esp)
f0101cb4:	f0 
f0101cb5:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101cbc:	f0 
f0101cbd:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0101cc4:	00 
f0101cc5:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101ccc:	e8 b4 e3 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f0101cd1:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101cd6:	74 24                	je     f0101cfc <check_page+0x626>
f0101cd8:	c7 44 24 0c 08 67 10 	movl   $0xf0106708,0xc(%esp)
f0101cdf:	f0 
f0101ce0:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101ce7:	f0 
f0101ce8:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0101cef:	00 
f0101cf0:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101cf7:	e8 89 e3 ff ff       	call   f0100085 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101cfc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d03:	00 
f0101d04:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101d0b:	00 
f0101d0c:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0101d11:	89 04 24             	mov    %eax,(%esp)
f0101d14:	e8 e7 f1 ff ff       	call   f0100f00 <pgdir_walk>
f0101d19:	f6 00 04             	testb  $0x4,(%eax)
f0101d1c:	75 24                	jne    f0101d42 <check_page+0x66c>
f0101d1e:	c7 44 24 0c 6c 61 10 	movl   $0xf010616c,0xc(%esp)
f0101d25:	f0 
f0101d26:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101d2d:	f0 
f0101d2e:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0101d35:	00 
f0101d36:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101d3d:	e8 43 e3 ff ff       	call   f0100085 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101d42:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0101d47:	f6 00 04             	testb  $0x4,(%eax)
f0101d4a:	75 24                	jne    f0101d70 <check_page+0x69a>
f0101d4c:	c7 44 24 0c 19 67 10 	movl   $0xf0106719,0xc(%esp)
f0101d53:	f0 
f0101d54:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101d5b:	f0 
f0101d5c:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f0101d63:	00 
f0101d64:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101d6b:	e8 15 e3 ff ff       	call   f0100085 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101d70:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d77:	00 
f0101d78:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101d7f:	00 
f0101d80:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101d84:	89 04 24             	mov    %eax,(%esp)
f0101d87:	e8 61 f4 ff ff       	call   f01011ed <page_insert>
f0101d8c:	85 c0                	test   %eax,%eax
f0101d8e:	78 24                	js     f0101db4 <check_page+0x6de>
f0101d90:	c7 44 24 0c a0 61 10 	movl   $0xf01061a0,0xc(%esp)
f0101d97:	f0 
f0101d98:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101d9f:	f0 
f0101da0:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0101da7:	00 
f0101da8:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101daf:	e8 d1 e2 ff ff       	call   f0100085 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101db4:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101dbb:	00 
f0101dbc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101dc3:	00 
f0101dc4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101dc8:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0101dcd:	89 04 24             	mov    %eax,(%esp)
f0101dd0:	e8 18 f4 ff ff       	call   f01011ed <page_insert>
f0101dd5:	85 c0                	test   %eax,%eax
f0101dd7:	74 24                	je     f0101dfd <check_page+0x727>
f0101dd9:	c7 44 24 0c d8 61 10 	movl   $0xf01061d8,0xc(%esp)
f0101de0:	f0 
f0101de1:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101de8:	f0 
f0101de9:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f0101df0:	00 
f0101df1:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101df8:	e8 88 e2 ff ff       	call   f0100085 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101dfd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e04:	00 
f0101e05:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e0c:	00 
f0101e0d:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0101e12:	89 04 24             	mov    %eax,(%esp)
f0101e15:	e8 e6 f0 ff ff       	call   f0100f00 <pgdir_walk>
f0101e1a:	f6 00 04             	testb  $0x4,(%eax)
f0101e1d:	74 24                	je     f0101e43 <check_page+0x76d>
f0101e1f:	c7 44 24 0c 14 62 10 	movl   $0xf0106214,0xc(%esp)
f0101e26:	f0 
f0101e27:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101e2e:	f0 
f0101e2f:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0101e36:	00 
f0101e37:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101e3e:	e8 42 e2 ff ff       	call   f0100085 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101e43:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e48:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0101e4d:	e8 a6 f4 ff ff       	call   f01012f8 <check_va2pa>
f0101e52:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101e55:	2b 15 cc 87 18 f0    	sub    0xf01887cc,%edx
f0101e5b:	c1 fa 03             	sar    $0x3,%edx
f0101e5e:	c1 e2 0c             	shl    $0xc,%edx
f0101e61:	39 d0                	cmp    %edx,%eax
f0101e63:	74 24                	je     f0101e89 <check_page+0x7b3>
f0101e65:	c7 44 24 0c 4c 62 10 	movl   $0xf010624c,0xc(%esp)
f0101e6c:	f0 
f0101e6d:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101e74:	f0 
f0101e75:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f0101e7c:	00 
f0101e7d:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101e84:	e8 fc e1 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e89:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e8e:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0101e93:	e8 60 f4 ff ff       	call   f01012f8 <check_va2pa>
f0101e98:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101e9b:	2b 15 cc 87 18 f0    	sub    0xf01887cc,%edx
f0101ea1:	c1 fa 03             	sar    $0x3,%edx
f0101ea4:	c1 e2 0c             	shl    $0xc,%edx
f0101ea7:	39 d0                	cmp    %edx,%eax
f0101ea9:	74 24                	je     f0101ecf <check_page+0x7f9>
f0101eab:	c7 44 24 0c 78 62 10 	movl   $0xf0106278,0xc(%esp)
f0101eb2:	f0 
f0101eb3:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101eba:	f0 
f0101ebb:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f0101ec2:	00 
f0101ec3:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101eca:	e8 b6 e1 ff ff       	call   f0100085 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101ecf:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101ed4:	74 24                	je     f0101efa <check_page+0x824>
f0101ed6:	c7 44 24 0c 2f 67 10 	movl   $0xf010672f,0xc(%esp)
f0101edd:	f0 
f0101ede:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101ee5:	f0 
f0101ee6:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f0101eed:	00 
f0101eee:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101ef5:	e8 8b e1 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f0101efa:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101eff:	74 24                	je     f0101f25 <check_page+0x84f>
f0101f01:	c7 44 24 0c 40 67 10 	movl   $0xf0106740,0xc(%esp)
f0101f08:	f0 
f0101f09:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101f10:	f0 
f0101f11:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f0101f18:	00 
f0101f19:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101f20:	e8 60 e1 ff ff       	call   f0100085 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101f25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f2c:	e8 51 ef ff ff       	call   f0100e82 <page_alloc>
f0101f31:	85 c0                	test   %eax,%eax
f0101f33:	74 04                	je     f0101f39 <check_page+0x863>
f0101f35:	39 c3                	cmp    %eax,%ebx
f0101f37:	74 24                	je     f0101f5d <check_page+0x887>
f0101f39:	c7 44 24 0c a8 62 10 	movl   $0xf01062a8,0xc(%esp)
f0101f40:	f0 
f0101f41:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101f48:	f0 
f0101f49:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0101f50:	00 
f0101f51:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101f58:	e8 28 e1 ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101f5d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101f64:	00 
f0101f65:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0101f6a:	89 04 24             	mov    %eax,(%esp)
f0101f6d:	e8 2b f2 ff ff       	call   f010119d <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f72:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f77:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0101f7c:	e8 77 f3 ff ff       	call   f01012f8 <check_va2pa>
f0101f81:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f84:	74 24                	je     f0101faa <check_page+0x8d4>
f0101f86:	c7 44 24 0c cc 62 10 	movl   $0xf01062cc,0xc(%esp)
f0101f8d:	f0 
f0101f8e:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101f95:	f0 
f0101f96:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f0101f9d:	00 
f0101f9e:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101fa5:	e8 db e0 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101faa:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101faf:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0101fb4:	e8 3f f3 ff ff       	call   f01012f8 <check_va2pa>
f0101fb9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101fbc:	2b 15 cc 87 18 f0    	sub    0xf01887cc,%edx
f0101fc2:	c1 fa 03             	sar    $0x3,%edx
f0101fc5:	c1 e2 0c             	shl    $0xc,%edx
f0101fc8:	39 d0                	cmp    %edx,%eax
f0101fca:	74 24                	je     f0101ff0 <check_page+0x91a>
f0101fcc:	c7 44 24 0c 78 62 10 	movl   $0xf0106278,0xc(%esp)
f0101fd3:	f0 
f0101fd4:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0101fdb:	f0 
f0101fdc:	c7 44 24 04 f3 03 00 	movl   $0x3f3,0x4(%esp)
f0101fe3:	00 
f0101fe4:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0101feb:	e8 95 e0 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 1);
f0101ff0:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101ff5:	74 24                	je     f010201b <check_page+0x945>
f0101ff7:	c7 44 24 0c e6 66 10 	movl   $0xf01066e6,0xc(%esp)
f0101ffe:	f0 
f0101fff:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102006:	f0 
f0102007:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f010200e:	00 
f010200f:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102016:	e8 6a e0 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f010201b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102020:	74 24                	je     f0102046 <check_page+0x970>
f0102022:	c7 44 24 0c 40 67 10 	movl   $0xf0106740,0xc(%esp)
f0102029:	f0 
f010202a:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102031:	f0 
f0102032:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f0102039:	00 
f010203a:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102041:	e8 3f e0 ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102046:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010204d:	00 
f010204e:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0102053:	89 04 24             	mov    %eax,(%esp)
f0102056:	e8 42 f1 ff ff       	call   f010119d <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010205b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102060:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0102065:	e8 8e f2 ff ff       	call   f01012f8 <check_va2pa>
f010206a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010206d:	74 24                	je     f0102093 <check_page+0x9bd>
f010206f:	c7 44 24 0c cc 62 10 	movl   $0xf01062cc,0xc(%esp)
f0102076:	f0 
f0102077:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f010207e:	f0 
f010207f:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f0102086:	00 
f0102087:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f010208e:	e8 f2 df ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102093:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102098:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f010209d:	e8 56 f2 ff ff       	call   f01012f8 <check_va2pa>
f01020a2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020a5:	74 24                	je     f01020cb <check_page+0x9f5>
f01020a7:	c7 44 24 0c f0 62 10 	movl   $0xf01062f0,0xc(%esp)
f01020ae:	f0 
f01020af:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01020b6:	f0 
f01020b7:	c7 44 24 04 fa 03 00 	movl   $0x3fa,0x4(%esp)
f01020be:	00 
f01020bf:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01020c6:	e8 ba df ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f01020cb:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01020d0:	74 24                	je     f01020f6 <check_page+0xa20>
f01020d2:	c7 44 24 0c 51 67 10 	movl   $0xf0106751,0xc(%esp)
f01020d9:	f0 
f01020da:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01020e1:	f0 
f01020e2:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f01020e9:	00 
f01020ea:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01020f1:	e8 8f df ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f01020f6:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01020fb:	74 24                	je     f0102121 <check_page+0xa4b>
f01020fd:	c7 44 24 0c 40 67 10 	movl   $0xf0106740,0xc(%esp)
f0102104:	f0 
f0102105:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f010210c:	f0 
f010210d:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f0102114:	00 
f0102115:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f010211c:	e8 64 df ff ff       	call   f0100085 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102121:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102128:	e8 55 ed ff ff       	call   f0100e82 <page_alloc>
f010212d:	85 c0                	test   %eax,%eax
f010212f:	74 04                	je     f0102135 <check_page+0xa5f>
f0102131:	39 c7                	cmp    %eax,%edi
f0102133:	74 24                	je     f0102159 <check_page+0xa83>
f0102135:	c7 44 24 0c 18 63 10 	movl   $0xf0106318,0xc(%esp)
f010213c:	f0 
f010213d:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102144:	f0 
f0102145:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f010214c:	00 
f010214d:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102154:	e8 2c df ff ff       	call   f0100085 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102159:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102160:	e8 1d ed ff ff       	call   f0100e82 <page_alloc>
f0102165:	85 c0                	test   %eax,%eax
f0102167:	74 24                	je     f010218d <check_page+0xab7>
f0102169:	c7 44 24 0c d7 66 10 	movl   $0xf01066d7,0xc(%esp)
f0102170:	f0 
f0102171:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102178:	f0 
f0102179:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f0102180:	00 
f0102181:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102188:	e8 f8 de ff ff       	call   f0100085 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010218d:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0102192:	8b 08                	mov    (%eax),%ecx
f0102194:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010219a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010219d:	2b 15 cc 87 18 f0    	sub    0xf01887cc,%edx
f01021a3:	c1 fa 03             	sar    $0x3,%edx
f01021a6:	c1 e2 0c             	shl    $0xc,%edx
f01021a9:	39 d1                	cmp    %edx,%ecx
f01021ab:	74 24                	je     f01021d1 <check_page+0xafb>
f01021ad:	c7 44 24 0c 28 60 10 	movl   $0xf0106028,0xc(%esp)
f01021b4:	f0 
f01021b5:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01021bc:	f0 
f01021bd:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f01021c4:	00 
f01021c5:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01021cc:	e8 b4 de ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f01021d1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01021d7:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01021dc:	74 24                	je     f0102202 <check_page+0xb2c>
f01021de:	c7 44 24 0c f7 66 10 	movl   $0xf01066f7,0xc(%esp)
f01021e5:	f0 
f01021e6:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01021ed:	f0 
f01021ee:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f01021f5:	00 
f01021f6:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01021fd:	e8 83 de ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f0102202:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102208:	89 34 24             	mov    %esi,(%esp)
f010220b:	e8 30 ea ff ff       	call   f0100c40 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102210:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102217:	00 
f0102218:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f010221f:	00 
f0102220:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0102225:	89 04 24             	mov    %eax,(%esp)
f0102228:	e8 d3 ec ff ff       	call   f0100f00 <pgdir_walk>
f010222d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102230:	8b 0d c8 87 18 f0    	mov    0xf01887c8,%ecx
f0102236:	83 c1 04             	add    $0x4,%ecx
f0102239:	8b 11                	mov    (%ecx),%edx
f010223b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102241:	89 55 cc             	mov    %edx,-0x34(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102244:	c1 ea 0c             	shr    $0xc,%edx
f0102247:	3b 15 c4 87 18 f0    	cmp    0xf01887c4,%edx
f010224d:	72 23                	jb     f0102272 <check_page+0xb9c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010224f:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0102252:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102256:	c7 44 24 08 30 5e 10 	movl   $0xf0105e30,0x8(%esp)
f010225d:	f0 
f010225e:	c7 44 24 04 0e 04 00 	movl   $0x40e,0x4(%esp)
f0102265:	00 
f0102266:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f010226d:	e8 13 de ff ff       	call   f0100085 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102272:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0102275:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f010227b:	39 d0                	cmp    %edx,%eax
f010227d:	74 24                	je     f01022a3 <check_page+0xbcd>
f010227f:	c7 44 24 0c 62 67 10 	movl   $0xf0106762,0xc(%esp)
f0102286:	f0 
f0102287:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f010228e:	f0 
f010228f:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f0102296:	00 
f0102297:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f010229e:	e8 e2 dd ff ff       	call   f0100085 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01022a3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	pp0->pp_ref = 0;
f01022a9:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01022af:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01022b2:	2b 05 cc 87 18 f0    	sub    0xf01887cc,%eax
f01022b8:	c1 f8 03             	sar    $0x3,%eax
f01022bb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01022be:	89 c2                	mov    %eax,%edx
f01022c0:	c1 ea 0c             	shr    $0xc,%edx
f01022c3:	3b 15 c4 87 18 f0    	cmp    0xf01887c4,%edx
f01022c9:	72 20                	jb     f01022eb <check_page+0xc15>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01022cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01022cf:	c7 44 24 08 30 5e 10 	movl   $0xf0105e30,0x8(%esp)
f01022d6:	f0 
f01022d7:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01022de:	00 
f01022df:	c7 04 24 d9 65 10 f0 	movl   $0xf01065d9,(%esp)
f01022e6:	e8 9a dd ff ff       	call   f0100085 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01022eb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01022f2:	00 
f01022f3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01022fa:	00 
f01022fb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102300:	89 04 24             	mov    %eax,(%esp)
f0102303:	e8 fe 30 00 00       	call   f0105406 <memset>
	page_free(pp0);
f0102308:	89 34 24             	mov    %esi,(%esp)
f010230b:	e8 30 e9 ff ff       	call   f0100c40 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102310:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102317:	00 
f0102318:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010231f:	00 
f0102320:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0102325:	89 04 24             	mov    %eax,(%esp)
f0102328:	e8 d3 eb ff ff       	call   f0100f00 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010232d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102330:	2b 15 cc 87 18 f0    	sub    0xf01887cc,%edx
f0102336:	c1 fa 03             	sar    $0x3,%edx
f0102339:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010233c:	89 d0                	mov    %edx,%eax
f010233e:	c1 e8 0c             	shr    $0xc,%eax
f0102341:	3b 05 c4 87 18 f0    	cmp    0xf01887c4,%eax
f0102347:	72 20                	jb     f0102369 <check_page+0xc93>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102349:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010234d:	c7 44 24 08 30 5e 10 	movl   $0xf0105e30,0x8(%esp)
f0102354:	f0 
f0102355:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010235c:	00 
f010235d:	c7 04 24 d9 65 10 f0 	movl   $0xf01065d9,(%esp)
f0102364:	e8 1c dd ff ff       	call   f0100085 <_panic>
	ptep = (pte_t *) page2kva(pp0);
f0102369:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f010236f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102372:	f6 00 01             	testb  $0x1,(%eax)
f0102375:	75 11                	jne    f0102388 <check_page+0xcb2>
f0102377:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
}


// check page_insert, page_remove, &c
static void
check_page(void)
f010237d:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102383:	f6 00 01             	testb  $0x1,(%eax)
f0102386:	74 24                	je     f01023ac <check_page+0xcd6>
f0102388:	c7 44 24 0c 7a 67 10 	movl   $0xf010677a,0xc(%esp)
f010238f:	f0 
f0102390:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102397:	f0 
f0102398:	c7 44 24 04 19 04 00 	movl   $0x419,0x4(%esp)
f010239f:	00 
f01023a0:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01023a7:	e8 d9 dc ff ff       	call   f0100085 <_panic>
f01023ac:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01023af:	39 d0                	cmp    %edx,%eax
f01023b1:	75 d0                	jne    f0102383 <check_page+0xcad>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01023b3:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f01023b8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01023be:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f01023c4:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01023c7:	a3 10 7b 18 f0       	mov    %eax,0xf0187b10

	// free the pages we took
	page_free(pp0);
f01023cc:	89 34 24             	mov    %esi,(%esp)
f01023cf:	e8 6c e8 ff ff       	call   f0100c40 <page_free>
	page_free(pp1);
f01023d4:	89 3c 24             	mov    %edi,(%esp)
f01023d7:	e8 64 e8 ff ff       	call   f0100c40 <page_free>
	page_free(pp2);
f01023dc:	89 1c 24             	mov    %ebx,(%esp)
f01023df:	e8 5c e8 ff ff       	call   f0100c40 <page_free>

	cprintf("check_page() succeeded!\n");
f01023e4:	c7 04 24 91 67 10 f0 	movl   $0xf0106791,(%esp)
f01023eb:	e8 bb 18 00 00       	call   f0103cab <cprintf>
}
f01023f0:	83 c4 3c             	add    $0x3c,%esp
f01023f3:	5b                   	pop    %ebx
f01023f4:	5e                   	pop    %esi
f01023f5:	5f                   	pop    %edi
f01023f6:	5d                   	pop    %ebp
f01023f7:	c3                   	ret    

f01023f8 <page_alloc_4pages>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc_4pages(int alloc_flags)
{
f01023f8:	55                   	push   %ebp
f01023f9:	89 e5                	mov    %esp,%ebp
f01023fb:	53                   	push   %ebx
f01023fc:	83 ec 14             	sub    $0x14,%esp

	struct Page *result;
	int found = 0;
	if (!page_free_list) {
f01023ff:	8b 1d 10 7b 18 f0    	mov    0xf0187b10,%ebx
f0102405:	85 db                	test   %ebx,%ebx
f0102407:	74 0a                	je     f0102413 <page_alloc_4pages+0x1b>
		panic("page_alloc_4pages: out of page_free_list");
		return NULL;
	}
	result = page_free_list;
	while(result->pp_link) {
f0102409:	83 3b 00             	cmpl   $0x0,(%ebx)
f010240c:	75 21                	jne    f010242f <page_alloc_4pages+0x37>
f010240e:	e9 a3 00 00 00       	jmp    f01024b6 <page_alloc_4pages+0xbe>
{

	struct Page *result;
	int found = 0;
	if (!page_free_list) {
		panic("page_alloc_4pages: out of page_free_list");
f0102413:	c7 44 24 08 3c 63 10 	movl   $0xf010633c,0x8(%esp)
f010241a:	f0 
f010241b:	c7 44 24 04 65 01 00 	movl   $0x165,0x4(%esp)
f0102422:	00 
f0102423:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f010242a:	e8 56 dc ff ff       	call   f0100085 <_panic>
//			if((page2pa(tmp) - page2pa(tmp->pp_link)) != PGSIZE) {
//				result = result->pp_link;
//				continue;
//			}
//		}
		if(check_continuous(result)) {
f010242f:	89 d8                	mov    %ebx,%eax
f0102431:	e8 4d e8 ff ff       	call   f0100c83 <check_continuous>
f0102436:	85 c0                	test   %eax,%eax
f0102438:	75 09                	jne    f0102443 <page_alloc_4pages+0x4b>
			found = 1;
			break;
		}
		result = result->pp_link;
f010243a:	8b 1b                	mov    (%ebx),%ebx
	if (!page_free_list) {
		panic("page_alloc_4pages: out of page_free_list");
		return NULL;
	}
	result = page_free_list;
	while(result->pp_link) {
f010243c:	83 3b 00             	cmpl   $0x0,(%ebx)
f010243f:	75 ee                	jne    f010242f <page_alloc_4pages+0x37>
f0102441:	eb 73                	jmp    f01024b6 <page_alloc_4pages+0xbe>
			break;
		}
		result = result->pp_link;
	}
	if (found) {
		page_free_list = result->pp_link->pp_link->pp_link->pp_link;
f0102443:	8b 03                	mov    (%ebx),%eax
f0102445:	8b 00                	mov    (%eax),%eax
f0102447:	8b 00                	mov    (%eax),%eax
f0102449:	8b 00                	mov    (%eax),%eax
f010244b:	a3 10 7b 18 f0       	mov    %eax,0xf0187b10
		if (alloc_flags & ALLOC_ZERO) {
f0102450:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0102454:	74 58                	je     f01024ae <page_alloc_4pages+0xb6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102456:	89 d8                	mov    %ebx,%eax
f0102458:	2b 05 cc 87 18 f0    	sub    0xf01887cc,%eax
f010245e:	c1 f8 03             	sar    $0x3,%eax
f0102461:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102464:	89 c2                	mov    %eax,%edx
f0102466:	c1 ea 0c             	shr    $0xc,%edx
f0102469:	3b 15 c4 87 18 f0    	cmp    0xf01887c4,%edx
f010246f:	72 20                	jb     f0102491 <page_alloc_4pages+0x99>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102471:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102475:	c7 44 24 08 30 5e 10 	movl   $0xf0105e30,0x8(%esp)
f010247c:	f0 
f010247d:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102484:	00 
f0102485:	c7 04 24 d9 65 10 f0 	movl   $0xf01065d9,(%esp)
f010248c:	e8 f4 db ff ff       	call   f0100085 <_panic>
			memset(page2kva(result), 0, PGSIZE * 4);
f0102491:	c7 44 24 08 00 40 00 	movl   $0x4000,0x8(%esp)
f0102498:	00 
f0102499:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01024a0:	00 
f01024a1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024a6:	89 04 24             	mov    %eax,(%esp)
f01024a9:	e8 58 2f 00 00       	call   f0105406 <memset>
		return result;
	} else {
		panic("page_alloc_4pages: out of memory1");
		return NULL;
	}
}
f01024ae:	89 d8                	mov    %ebx,%eax
f01024b0:	83 c4 14             	add    $0x14,%esp
f01024b3:	5b                   	pop    %ebx
f01024b4:	5d                   	pop    %ebp
f01024b5:	c3                   	ret    
		if (alloc_flags & ALLOC_ZERO) {
			memset(page2kva(result), 0, PGSIZE * 4);
		}
		return result;
	} else {
		panic("page_alloc_4pages: out of memory1");
f01024b6:	c7 44 24 08 68 63 10 	movl   $0xf0106368,0x8(%esp)
f01024bd:	f0 
f01024be:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f01024c5:	00 
f01024c6:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01024cd:	e8 b3 db ff ff       	call   f0100085 <_panic>

f01024d2 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01024d2:	55                   	push   %ebp
f01024d3:	89 e5                	mov    %esp,%ebp
f01024d5:	57                   	push   %edi
f01024d6:	56                   	push   %esi
f01024d7:	53                   	push   %ebx
f01024d8:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01024db:	b8 15 00 00 00       	mov    $0x15,%eax
f01024e0:	e8 6b e9 ff ff       	call   f0100e50 <nvram_read>
f01024e5:	c1 e0 0a             	shl    $0xa,%eax
f01024e8:	89 c2                	mov    %eax,%edx
f01024ea:	c1 fa 1f             	sar    $0x1f,%edx
f01024ed:	c1 ea 14             	shr    $0x14,%edx
f01024f0:	8d 04 02             	lea    (%edx,%eax,1),%eax
f01024f3:	c1 f8 0c             	sar    $0xc,%eax
f01024f6:	a3 0c 7b 18 f0       	mov    %eax,0xf0187b0c
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01024fb:	b8 17 00 00 00       	mov    $0x17,%eax
f0102500:	e8 4b e9 ff ff       	call   f0100e50 <nvram_read>
f0102505:	c1 e0 0a             	shl    $0xa,%eax
f0102508:	89 c2                	mov    %eax,%edx
f010250a:	c1 fa 1f             	sar    $0x1f,%edx
f010250d:	c1 ea 14             	shr    $0x14,%edx
f0102510:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0102513:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0102516:	85 c0                	test   %eax,%eax
f0102518:	74 0e                	je     f0102528 <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010251a:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0102520:	89 15 c4 87 18 f0    	mov    %edx,0xf01887c4
f0102526:	eb 0c                	jmp    f0102534 <mem_init+0x62>
	else
		npages = npages_basemem;
f0102528:	8b 15 0c 7b 18 f0    	mov    0xf0187b0c,%edx
f010252e:	89 15 c4 87 18 f0    	mov    %edx,0xf01887c4

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0102534:	c1 e0 0c             	shl    $0xc,%eax
f0102537:	c1 e8 0a             	shr    $0xa,%eax
f010253a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010253e:	a1 0c 7b 18 f0       	mov    0xf0187b0c,%eax
f0102543:	c1 e0 0c             	shl    $0xc,%eax
f0102546:	c1 e8 0a             	shr    $0xa,%eax
f0102549:	89 44 24 08          	mov    %eax,0x8(%esp)
f010254d:	a1 c4 87 18 f0       	mov    0xf01887c4,%eax
f0102552:	c1 e0 0c             	shl    $0xc,%eax
f0102555:	c1 e8 0a             	shr    $0xa,%eax
f0102558:	89 44 24 04          	mov    %eax,0x4(%esp)
f010255c:	c7 04 24 8c 63 10 f0 	movl   $0xf010638c,(%esp)
f0102563:	e8 43 17 00 00       	call   f0103cab <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0102568:	b8 00 10 00 00       	mov    $0x1000,%eax
f010256d:	e8 ad e7 ff ff       	call   f0100d1f <boot_alloc>
f0102572:	a3 c8 87 18 f0       	mov    %eax,0xf01887c8
	memset(kern_pgdir, 0, PGSIZE);
f0102577:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010257e:	00 
f010257f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102586:	00 
f0102587:	89 04 24             	mov    %eax,(%esp)
f010258a:	e8 77 2e 00 00       	call   f0105406 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010258f:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102594:	89 c2                	mov    %eax,%edx
f0102596:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010259b:	77 20                	ja     f01025bd <mem_init+0xeb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010259d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01025a1:	c7 44 24 08 0c 5e 10 	movl   $0xf0105e0c,0x8(%esp)
f01025a8:	f0 
f01025a9:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
f01025b0:	00 
f01025b1:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01025b8:	e8 c8 da ff ff       	call   f0100085 <_panic>
f01025bd:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01025c3:	83 ca 05             	or     $0x5,%edx
f01025c6:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct Page in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:

	// the size of space to store all the Page structs
	size_t pages_sz = npages * sizeof(struct Page); 
f01025cc:	8b 1d c4 87 18 f0    	mov    0xf01887c4,%ebx
f01025d2:	c1 e3 03             	shl    $0x3,%ebx
	pages = (struct Page *) boot_alloc(pages_sz); 
f01025d5:	89 d8                	mov    %ebx,%eax
f01025d7:	e8 43 e7 ff ff       	call   f0100d1f <boot_alloc>
f01025dc:	a3 cc 87 18 f0       	mov    %eax,0xf01887cc
	memset(pages, 0, pages_sz);
f01025e1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01025e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01025ec:	00 
f01025ed:	89 04 24             	mov    %eax,(%esp)
f01025f0:	e8 11 2e 00 00       	call   f0105406 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	size_t env_sz = NENV * sizeof(struct Env); 
	envs = (struct Env *) boot_alloc(env_sz); 
f01025f5:	b8 00 90 01 00       	mov    $0x19000,%eax
f01025fa:	e8 20 e7 ff ff       	call   f0100d1f <boot_alloc>
f01025ff:	a3 1c 7b 18 f0       	mov    %eax,0xf0187b1c
	memset(envs, 0, env_sz);
f0102604:	c7 44 24 08 00 90 01 	movl   $0x19000,0x8(%esp)
f010260b:	00 
f010260c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102613:	00 
f0102614:	89 04 24             	mov    %eax,(%esp)
f0102617:	e8 ea 2d 00 00       	call   f0105406 <memset>
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert

	page_init();
f010261c:	e8 6d e7 ff ff       	call   f0100d8e <page_init>
	check_page_free_list(1);
f0102621:	b8 01 00 00 00       	mov    $0x1,%eax
f0102626:	e8 33 ed ff ff       	call   f010135e <check_page_free_list>
	int nfree;
	struct Page *fl;
	char *c;
	int i;

	if (!pages)
f010262b:	83 3d cc 87 18 f0 00 	cmpl   $0x0,0xf01887cc
f0102632:	75 1c                	jne    f0102650 <mem_init+0x17e>
		panic("'pages' is a null pointer!");
f0102634:	c7 44 24 08 aa 67 10 	movl   $0xf01067aa,0x8(%esp)
f010263b:	f0 
f010263c:	c7 44 24 04 0d 03 00 	movl   $0x30d,0x4(%esp)
f0102643:	00 
f0102644:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f010264b:	e8 35 da ff ff       	call   f0100085 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0102650:	a1 10 7b 18 f0       	mov    0xf0187b10,%eax
f0102655:	bb 00 00 00 00       	mov    $0x0,%ebx
f010265a:	85 c0                	test   %eax,%eax
f010265c:	74 09                	je     f0102667 <mem_init+0x195>
		++nfree;
f010265e:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0102661:	8b 00                	mov    (%eax),%eax
f0102663:	85 c0                	test   %eax,%eax
f0102665:	75 f7                	jne    f010265e <mem_init+0x18c>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102667:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010266e:	e8 0f e8 ff ff       	call   f0100e82 <page_alloc>
f0102673:	89 c6                	mov    %eax,%esi
f0102675:	85 c0                	test   %eax,%eax
f0102677:	75 24                	jne    f010269d <mem_init+0x1cb>
f0102679:	c7 44 24 0c 83 66 10 	movl   $0xf0106683,0xc(%esp)
f0102680:	f0 
f0102681:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102688:	f0 
f0102689:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f0102690:	00 
f0102691:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102698:	e8 e8 d9 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f010269d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01026a4:	e8 d9 e7 ff ff       	call   f0100e82 <page_alloc>
f01026a9:	89 c7                	mov    %eax,%edi
f01026ab:	85 c0                	test   %eax,%eax
f01026ad:	75 24                	jne    f01026d3 <mem_init+0x201>
f01026af:	c7 44 24 0c 99 66 10 	movl   $0xf0106699,0xc(%esp)
f01026b6:	f0 
f01026b7:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01026be:	f0 
f01026bf:	c7 44 24 04 16 03 00 	movl   $0x316,0x4(%esp)
f01026c6:	00 
f01026c7:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01026ce:	e8 b2 d9 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f01026d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01026da:	e8 a3 e7 ff ff       	call   f0100e82 <page_alloc>
f01026df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01026e2:	85 c0                	test   %eax,%eax
f01026e4:	75 24                	jne    f010270a <mem_init+0x238>
f01026e6:	c7 44 24 0c af 66 10 	movl   $0xf01066af,0xc(%esp)
f01026ed:	f0 
f01026ee:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01026f5:	f0 
f01026f6:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f01026fd:	00 
f01026fe:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102705:	e8 7b d9 ff ff       	call   f0100085 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010270a:	39 fe                	cmp    %edi,%esi
f010270c:	75 24                	jne    f0102732 <mem_init+0x260>
f010270e:	c7 44 24 0c c5 66 10 	movl   $0xf01066c5,0xc(%esp)
f0102715:	f0 
f0102716:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f010271d:	f0 
f010271e:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f0102725:	00 
f0102726:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f010272d:	e8 53 d9 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102732:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0102735:	74 05                	je     f010273c <mem_init+0x26a>
f0102737:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f010273a:	75 24                	jne    f0102760 <mem_init+0x28e>
f010273c:	c7 44 24 0c 70 5f 10 	movl   $0xf0105f70,0xc(%esp)
f0102743:	f0 
f0102744:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f010274b:	f0 
f010274c:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f0102753:	00 
f0102754:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f010275b:	e8 25 d9 ff ff       	call   f0100085 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102760:	8b 15 cc 87 18 f0    	mov    0xf01887cc,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0102766:	a1 c4 87 18 f0       	mov    0xf01887c4,%eax
f010276b:	c1 e0 0c             	shl    $0xc,%eax
f010276e:	89 f1                	mov    %esi,%ecx
f0102770:	29 d1                	sub    %edx,%ecx
f0102772:	c1 f9 03             	sar    $0x3,%ecx
f0102775:	c1 e1 0c             	shl    $0xc,%ecx
f0102778:	39 c1                	cmp    %eax,%ecx
f010277a:	72 24                	jb     f01027a0 <mem_init+0x2ce>
f010277c:	c7 44 24 0c c5 67 10 	movl   $0xf01067c5,0xc(%esp)
f0102783:	f0 
f0102784:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f010278b:	f0 
f010278c:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f0102793:	00 
f0102794:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f010279b:	e8 e5 d8 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01027a0:	89 f9                	mov    %edi,%ecx
f01027a2:	29 d1                	sub    %edx,%ecx
f01027a4:	c1 f9 03             	sar    $0x3,%ecx
f01027a7:	c1 e1 0c             	shl    $0xc,%ecx
f01027aa:	39 c8                	cmp    %ecx,%eax
f01027ac:	77 24                	ja     f01027d2 <mem_init+0x300>
f01027ae:	c7 44 24 0c e2 67 10 	movl   $0xf01067e2,0xc(%esp)
f01027b5:	f0 
f01027b6:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01027bd:	f0 
f01027be:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f01027c5:	00 
f01027c6:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01027cd:	e8 b3 d8 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01027d2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01027d5:	29 d1                	sub    %edx,%ecx
f01027d7:	89 ca                	mov    %ecx,%edx
f01027d9:	c1 fa 03             	sar    $0x3,%edx
f01027dc:	c1 e2 0c             	shl    $0xc,%edx
f01027df:	39 d0                	cmp    %edx,%eax
f01027e1:	77 24                	ja     f0102807 <mem_init+0x335>
f01027e3:	c7 44 24 0c ff 67 10 	movl   $0xf01067ff,0xc(%esp)
f01027ea:	f0 
f01027eb:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01027f2:	f0 
f01027f3:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f01027fa:	00 
f01027fb:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102802:	e8 7e d8 ff ff       	call   f0100085 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102807:	a1 10 7b 18 f0       	mov    0xf0187b10,%eax
f010280c:	89 45 dc             	mov    %eax,-0x24(%ebp)
	page_free_list = 0;
f010280f:	c7 05 10 7b 18 f0 00 	movl   $0x0,0xf0187b10
f0102816:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102819:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102820:	e8 5d e6 ff ff       	call   f0100e82 <page_alloc>
f0102825:	85 c0                	test   %eax,%eax
f0102827:	74 24                	je     f010284d <mem_init+0x37b>
f0102829:	c7 44 24 0c d7 66 10 	movl   $0xf01066d7,0xc(%esp)
f0102830:	f0 
f0102831:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102838:	f0 
f0102839:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f0102840:	00 
f0102841:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102848:	e8 38 d8 ff ff       	call   f0100085 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010284d:	89 34 24             	mov    %esi,(%esp)
f0102850:	e8 eb e3 ff ff       	call   f0100c40 <page_free>
	page_free(pp1);
f0102855:	89 3c 24             	mov    %edi,(%esp)
f0102858:	e8 e3 e3 ff ff       	call   f0100c40 <page_free>
	page_free(pp2);
f010285d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102860:	89 0c 24             	mov    %ecx,(%esp)
f0102863:	e8 d8 e3 ff ff       	call   f0100c40 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102868:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010286f:	e8 0e e6 ff ff       	call   f0100e82 <page_alloc>
f0102874:	89 c6                	mov    %eax,%esi
f0102876:	85 c0                	test   %eax,%eax
f0102878:	75 24                	jne    f010289e <mem_init+0x3cc>
f010287a:	c7 44 24 0c 83 66 10 	movl   $0xf0106683,0xc(%esp)
f0102881:	f0 
f0102882:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102889:	f0 
f010288a:	c7 44 24 04 2c 03 00 	movl   $0x32c,0x4(%esp)
f0102891:	00 
f0102892:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102899:	e8 e7 d7 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f010289e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028a5:	e8 d8 e5 ff ff       	call   f0100e82 <page_alloc>
f01028aa:	89 c7                	mov    %eax,%edi
f01028ac:	85 c0                	test   %eax,%eax
f01028ae:	75 24                	jne    f01028d4 <mem_init+0x402>
f01028b0:	c7 44 24 0c 99 66 10 	movl   $0xf0106699,0xc(%esp)
f01028b7:	f0 
f01028b8:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01028bf:	f0 
f01028c0:	c7 44 24 04 2d 03 00 	movl   $0x32d,0x4(%esp)
f01028c7:	00 
f01028c8:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01028cf:	e8 b1 d7 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f01028d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028db:	e8 a2 e5 ff ff       	call   f0100e82 <page_alloc>
f01028e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01028e3:	85 c0                	test   %eax,%eax
f01028e5:	75 24                	jne    f010290b <mem_init+0x439>
f01028e7:	c7 44 24 0c af 66 10 	movl   $0xf01066af,0xc(%esp)
f01028ee:	f0 
f01028ef:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01028f6:	f0 
f01028f7:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f01028fe:	00 
f01028ff:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102906:	e8 7a d7 ff ff       	call   f0100085 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010290b:	39 fe                	cmp    %edi,%esi
f010290d:	75 24                	jne    f0102933 <mem_init+0x461>
f010290f:	c7 44 24 0c c5 66 10 	movl   $0xf01066c5,0xc(%esp)
f0102916:	f0 
f0102917:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f010291e:	f0 
f010291f:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f0102926:	00 
f0102927:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f010292e:	e8 52 d7 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102933:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0102936:	74 05                	je     f010293d <mem_init+0x46b>
f0102938:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f010293b:	75 24                	jne    f0102961 <mem_init+0x48f>
f010293d:	c7 44 24 0c 70 5f 10 	movl   $0xf0105f70,0xc(%esp)
f0102944:	f0 
f0102945:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f010294c:	f0 
f010294d:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f0102954:	00 
f0102955:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f010295c:	e8 24 d7 ff ff       	call   f0100085 <_panic>
	assert(!page_alloc(0));
f0102961:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102968:	e8 15 e5 ff ff       	call   f0100e82 <page_alloc>
f010296d:	85 c0                	test   %eax,%eax
f010296f:	74 24                	je     f0102995 <mem_init+0x4c3>
f0102971:	c7 44 24 0c d7 66 10 	movl   $0xf01066d7,0xc(%esp)
f0102978:	f0 
f0102979:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102980:	f0 
f0102981:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f0102988:	00 
f0102989:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102990:	e8 f0 d6 ff ff       	call   f0100085 <_panic>
f0102995:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0102998:	89 f0                	mov    %esi,%eax
f010299a:	2b 05 cc 87 18 f0    	sub    0xf01887cc,%eax
f01029a0:	c1 f8 03             	sar    $0x3,%eax
f01029a3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01029a6:	89 c2                	mov    %eax,%edx
f01029a8:	c1 ea 0c             	shr    $0xc,%edx
f01029ab:	3b 15 c4 87 18 f0    	cmp    0xf01887c4,%edx
f01029b1:	72 20                	jb     f01029d3 <mem_init+0x501>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01029b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01029b7:	c7 44 24 08 30 5e 10 	movl   $0xf0105e30,0x8(%esp)
f01029be:	f0 
f01029bf:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01029c6:	00 
f01029c7:	c7 04 24 d9 65 10 f0 	movl   $0xf01065d9,(%esp)
f01029ce:	e8 b2 d6 ff ff       	call   f0100085 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01029d3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01029da:	00 
f01029db:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01029e2:	00 
f01029e3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01029e8:	89 04 24             	mov    %eax,(%esp)
f01029eb:	e8 16 2a 00 00       	call   f0105406 <memset>
	page_free(pp0);
f01029f0:	89 34 24             	mov    %esi,(%esp)
f01029f3:	e8 48 e2 ff ff       	call   f0100c40 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01029f8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01029ff:	e8 7e e4 ff ff       	call   f0100e82 <page_alloc>
f0102a04:	85 c0                	test   %eax,%eax
f0102a06:	75 24                	jne    f0102a2c <mem_init+0x55a>
f0102a08:	c7 44 24 0c 1c 68 10 	movl   $0xf010681c,0xc(%esp)
f0102a0f:	f0 
f0102a10:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102a17:	f0 
f0102a18:	c7 44 24 04 37 03 00 	movl   $0x337,0x4(%esp)
f0102a1f:	00 
f0102a20:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102a27:	e8 59 d6 ff ff       	call   f0100085 <_panic>
	assert(pp && pp0 == pp);
f0102a2c:	39 c6                	cmp    %eax,%esi
f0102a2e:	74 24                	je     f0102a54 <mem_init+0x582>
f0102a30:	c7 44 24 0c 3a 68 10 	movl   $0xf010683a,0xc(%esp)
f0102a37:	f0 
f0102a38:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102a3f:	f0 
f0102a40:	c7 44 24 04 38 03 00 	movl   $0x338,0x4(%esp)
f0102a47:	00 
f0102a48:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102a4f:	e8 31 d6 ff ff       	call   f0100085 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a54:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102a57:	2b 15 cc 87 18 f0    	sub    0xf01887cc,%edx
f0102a5d:	c1 fa 03             	sar    $0x3,%edx
f0102a60:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a63:	89 d0                	mov    %edx,%eax
f0102a65:	c1 e8 0c             	shr    $0xc,%eax
f0102a68:	3b 05 c4 87 18 f0    	cmp    0xf01887c4,%eax
f0102a6e:	72 20                	jb     f0102a90 <mem_init+0x5be>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a70:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102a74:	c7 44 24 08 30 5e 10 	movl   $0xf0105e30,0x8(%esp)
f0102a7b:	f0 
f0102a7c:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102a83:	00 
f0102a84:	c7 04 24 d9 65 10 f0 	movl   $0xf01065d9,(%esp)
f0102a8b:	e8 f5 d5 ff ff       	call   f0100085 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102a90:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0102a97:	75 11                	jne    f0102aaa <mem_init+0x5d8>
f0102a99:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102a9f:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102aa5:	80 38 00             	cmpb   $0x0,(%eax)
f0102aa8:	74 24                	je     f0102ace <mem_init+0x5fc>
f0102aaa:	c7 44 24 0c 4a 68 10 	movl   $0xf010684a,0xc(%esp)
f0102ab1:	f0 
f0102ab2:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102ab9:	f0 
f0102aba:	c7 44 24 04 3b 03 00 	movl   $0x33b,0x4(%esp)
f0102ac1:	00 
f0102ac2:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102ac9:	e8 b7 d5 ff ff       	call   f0100085 <_panic>
f0102ace:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0102ad1:	39 d0                	cmp    %edx,%eax
f0102ad3:	75 d0                	jne    f0102aa5 <mem_init+0x5d3>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0102ad5:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102ad8:	a3 10 7b 18 f0       	mov    %eax,0xf0187b10

	// free the pages we took
	page_free(pp0);
f0102add:	89 34 24             	mov    %esi,(%esp)
f0102ae0:	e8 5b e1 ff ff       	call   f0100c40 <page_free>
	page_free(pp1);
f0102ae5:	89 3c 24             	mov    %edi,(%esp)
f0102ae8:	e8 53 e1 ff ff       	call   f0100c40 <page_free>
	page_free(pp2);
f0102aed:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102af0:	89 0c 24             	mov    %ecx,(%esp)
f0102af3:	e8 48 e1 ff ff       	call   f0100c40 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102af8:	a1 10 7b 18 f0       	mov    0xf0187b10,%eax
f0102afd:	85 c0                	test   %eax,%eax
f0102aff:	74 09                	je     f0102b0a <mem_init+0x638>
		--nfree;
f0102b01:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102b04:	8b 00                	mov    (%eax),%eax
f0102b06:	85 c0                	test   %eax,%eax
f0102b08:	75 f7                	jne    f0102b01 <mem_init+0x62f>
		--nfree;
	assert(nfree == 0);
f0102b0a:	85 db                	test   %ebx,%ebx
f0102b0c:	74 24                	je     f0102b32 <mem_init+0x660>
f0102b0e:	c7 44 24 0c 54 68 10 	movl   $0xf0106854,0xc(%esp)
f0102b15:	f0 
f0102b16:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102b1d:	f0 
f0102b1e:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f0102b25:	00 
f0102b26:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102b2d:	e8 53 d5 ff ff       	call   f0100085 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0102b32:	c7 04 24 c8 63 10 f0 	movl   $0xf01063c8,(%esp)
f0102b39:	e8 6d 11 00 00       	call   f0103cab <cprintf>
	// or page_insert

	page_init();
	check_page_free_list(1);
	check_page_alloc();
	check_page();
f0102b3e:	e8 93 eb ff ff       	call   f01016d6 <check_page>
	char* addr;
	int i;
	pp = pp0 = 0;
	
	// Allocate two single pages
	pp =  page_alloc(0);
f0102b43:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b4a:	e8 33 e3 ff ff       	call   f0100e82 <page_alloc>
f0102b4f:	89 c3                	mov    %eax,%ebx
	pp0 = page_alloc(0);
f0102b51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b58:	e8 25 e3 ff ff       	call   f0100e82 <page_alloc>
f0102b5d:	89 c6                	mov    %eax,%esi
	assert(pp != 0);
f0102b5f:	85 db                	test   %ebx,%ebx
f0102b61:	75 24                	jne    f0102b87 <mem_init+0x6b5>
f0102b63:	c7 44 24 0c 5f 68 10 	movl   $0xf010685f,0xc(%esp)
f0102b6a:	f0 
f0102b6b:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102b72:	f0 
f0102b73:	c7 44 24 04 43 04 00 	movl   $0x443,0x4(%esp)
f0102b7a:	00 
f0102b7b:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102b82:	e8 fe d4 ff ff       	call   f0100085 <_panic>
	assert(pp0 != 0);
f0102b87:	85 c0                	test   %eax,%eax
f0102b89:	75 24                	jne    f0102baf <mem_init+0x6dd>
f0102b8b:	c7 44 24 0c 67 68 10 	movl   $0xf0106867,0xc(%esp)
f0102b92:	f0 
f0102b93:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102b9a:	f0 
f0102b9b:	c7 44 24 04 44 04 00 	movl   $0x444,0x4(%esp)
f0102ba2:	00 
f0102ba3:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102baa:	e8 d6 d4 ff ff       	call   f0100085 <_panic>
	assert(pp != pp0);
f0102baf:	39 c3                	cmp    %eax,%ebx
f0102bb1:	75 24                	jne    f0102bd7 <mem_init+0x705>
f0102bb3:	c7 44 24 0c 70 68 10 	movl   $0xf0106870,0xc(%esp)
f0102bba:	f0 
f0102bbb:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102bc2:	f0 
f0102bc3:	c7 44 24 04 45 04 00 	movl   $0x445,0x4(%esp)
f0102bca:	00 
f0102bcb:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102bd2:	e8 ae d4 ff ff       	call   f0100085 <_panic>

	// Free pp and assign four continuous pages
	page_free(pp);
f0102bd7:	89 1c 24             	mov    %ebx,(%esp)
f0102bda:	e8 61 e0 ff ff       	call   f0100c40 <page_free>
	pp = page_alloc_4pages(0);
f0102bdf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102be6:	e8 0d f8 ff ff       	call   f01023f8 <page_alloc_4pages>
f0102beb:	89 c3                	mov    %eax,%ebx
	assert(check_continuous(pp));
f0102bed:	e8 91 e0 ff ff       	call   f0100c83 <check_continuous>
f0102bf2:	85 c0                	test   %eax,%eax
f0102bf4:	75 24                	jne    f0102c1a <mem_init+0x748>
f0102bf6:	c7 44 24 0c 7a 68 10 	movl   $0xf010687a,0xc(%esp)
f0102bfd:	f0 
f0102bfe:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102c05:	f0 
f0102c06:	c7 44 24 04 4a 04 00 	movl   $0x44a,0x4(%esp)
f0102c0d:	00 
f0102c0e:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102c15:	e8 6b d4 ff ff       	call   f0100085 <_panic>

	// Free four continuous pages
	assert(!page_free_4pages(pp));
f0102c1a:	89 1c 24             	mov    %ebx,(%esp)
f0102c1d:	e8 c9 e0 ff ff       	call   f0100ceb <page_free_4pages>
f0102c22:	85 c0                	test   %eax,%eax
f0102c24:	74 24                	je     f0102c4a <mem_init+0x778>
f0102c26:	c7 44 24 0c 8f 68 10 	movl   $0xf010688f,0xc(%esp)
f0102c2d:	f0 
f0102c2e:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102c35:	f0 
f0102c36:	c7 44 24 04 4d 04 00 	movl   $0x44d,0x4(%esp)
f0102c3d:	00 
f0102c3e:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102c45:	e8 3b d4 ff ff       	call   f0100085 <_panic>

	// Free pp0 and assign four continuous zero pages
	page_free(pp0);
f0102c4a:	89 34 24             	mov    %esi,(%esp)
f0102c4d:	e8 ee df ff ff       	call   f0100c40 <page_free>
	pp0 = page_alloc_4pages(ALLOC_ZERO);
f0102c52:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102c59:	e8 9a f7 ff ff       	call   f01023f8 <page_alloc_4pages>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c5e:	89 c1                	mov    %eax,%ecx
f0102c60:	2b 0d cc 87 18 f0    	sub    0xf01887cc,%ecx
f0102c66:	c1 f9 03             	sar    $0x3,%ecx
f0102c69:	c1 e1 0c             	shl    $0xc,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c6c:	89 ca                	mov    %ecx,%edx
f0102c6e:	c1 ea 0c             	shr    $0xc,%edx
f0102c71:	3b 15 c4 87 18 f0    	cmp    0xf01887c4,%edx
f0102c77:	72 20                	jb     f0102c99 <mem_init+0x7c7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102c7d:	c7 44 24 08 30 5e 10 	movl   $0xf0105e30,0x8(%esp)
f0102c84:	f0 
f0102c85:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102c8c:	00 
f0102c8d:	c7 04 24 d9 65 10 f0 	movl   $0xf01065d9,(%esp)
f0102c94:	e8 ec d3 ff ff       	call   f0100085 <_panic>
	addr = (char*)page2kva(pp0);
	
	// Check Zero
	for( i = 0; i < 4 * PGSIZE; i++ ){
		assert(addr[i] == 0);
f0102c99:	80 b9 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%ecx)
f0102ca0:	75 11                	jne    f0102cb3 <mem_init+0x7e1>
f0102ca2:	8d 91 01 00 00 f0    	lea    -0xfffffff(%ecx),%edx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102ca8:	81 e9 00 c0 ff 0f    	sub    $0xfffc000,%ecx
	pp0 = page_alloc_4pages(ALLOC_ZERO);
	addr = (char*)page2kva(pp0);
	
	// Check Zero
	for( i = 0; i < 4 * PGSIZE; i++ ){
		assert(addr[i] == 0);
f0102cae:	80 3a 00             	cmpb   $0x0,(%edx)
f0102cb1:	74 24                	je     f0102cd7 <mem_init+0x805>
f0102cb3:	c7 44 24 0c a5 68 10 	movl   $0xf01068a5,0xc(%esp)
f0102cba:	f0 
f0102cbb:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102cc2:	f0 
f0102cc3:	c7 44 24 04 56 04 00 	movl   $0x456,0x4(%esp)
f0102cca:	00 
f0102ccb:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102cd2:	e8 ae d3 ff ff       	call   f0100085 <_panic>
f0102cd7:	83 c2 01             	add    $0x1,%edx
	page_free(pp0);
	pp0 = page_alloc_4pages(ALLOC_ZERO);
	addr = (char*)page2kva(pp0);
	
	// Check Zero
	for( i = 0; i < 4 * PGSIZE; i++ ){
f0102cda:	39 ca                	cmp    %ecx,%edx
f0102cdc:	75 d0                	jne    f0102cae <mem_init+0x7dc>
		assert(addr[i] == 0);
	}

	// Free pages
	assert(!page_free_4pages(pp0));
f0102cde:	89 04 24             	mov    %eax,(%esp)
f0102ce1:	e8 05 e0 ff ff       	call   f0100ceb <page_free_4pages>
f0102ce6:	85 c0                	test   %eax,%eax
f0102ce8:	74 24                	je     f0102d0e <mem_init+0x83c>
f0102cea:	c7 44 24 0c b2 68 10 	movl   $0xf01068b2,0xc(%esp)
f0102cf1:	f0 
f0102cf2:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102cf9:	f0 
f0102cfa:	c7 44 24 04 5a 04 00 	movl   $0x45a,0x4(%esp)
f0102d01:	00 
f0102d02:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102d09:	e8 77 d3 ff ff       	call   f0100085 <_panic>
	cprintf("check_four_pages() succeeded!\n");
f0102d0e:	c7 04 24 e8 63 10 f0 	movl   $0xf01063e8,(%esp)
f0102d15:	e8 91 0f 00 00       	call   f0103cab <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	
	size_t size = ROUNDUP(npages * sizeof(struct Page), PGSIZE); 	
f0102d1a:	8b 0d c4 87 18 f0    	mov    0xf01887c4,%ecx
	boot_map_region(kern_pgdir, UPAGES, size, PADDR(pages), PTE_U|PTE_P);
f0102d20:	a1 cc 87 18 f0       	mov    0xf01887cc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d25:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d2a:	77 20                	ja     f0102d4c <mem_init+0x87a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d2c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d30:	c7 44 24 08 0c 5e 10 	movl   $0xf0105e0c,0x8(%esp)
f0102d37:	f0 
f0102d38:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
f0102d3f:	00 
f0102d40:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102d47:	e8 39 d3 ff ff       	call   f0100085 <_panic>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	
	size_t size = ROUNDUP(npages * sizeof(struct Page), PGSIZE); 	
f0102d4c:	8d 0c cd ff 0f 00 00 	lea    0xfff(,%ecx,8),%ecx
	boot_map_region(kern_pgdir, UPAGES, size, PADDR(pages), PTE_U|PTE_P);
f0102d53:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102d59:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102d60:	00 
f0102d61:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0102d67:	89 04 24             	mov    %eax,(%esp)
f0102d6a:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102d6f:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0102d74:	e8 1c e5 ff ff       	call   f0101295 <boot_map_region>
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	
	size = ROUNDUP(NENV * sizeof(struct Env), PGSIZE);
    boot_map_region(kern_pgdir, UENVS, size, PADDR(envs), PTE_U|PTE_P);
f0102d79:	a1 1c 7b 18 f0       	mov    0xf0187b1c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d7e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d83:	77 20                	ja     f0102da5 <mem_init+0x8d3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d85:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d89:	c7 44 24 08 0c 5e 10 	movl   $0xf0105e0c,0x8(%esp)
f0102d90:	f0 
f0102d91:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
f0102d98:	00 
f0102d99:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102da0:	e8 e0 d2 ff ff       	call   f0100085 <_panic>
f0102da5:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102dac:	00 
f0102dad:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0102db3:	89 04 24             	mov    %eax,(%esp)
f0102db6:	b9 00 90 01 00       	mov    $0x19000,%ecx
f0102dbb:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102dc0:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0102dc5:	e8 cb e4 ff ff       	call   f0101295 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102dca:	b8 00 30 11 f0       	mov    $0xf0113000,%eax
f0102dcf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102dd4:	77 20                	ja     f0102df6 <mem_init+0x924>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dd6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102dda:	c7 44 24 08 0c 5e 10 	movl   $0xf0105e0c,0x8(%esp)
f0102de1:	f0 
f0102de2:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
f0102de9:	00 
f0102dea:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102df1:	e8 8f d2 ff ff       	call   f0100085 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE,
f0102df6:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102dfd:	00 
f0102dfe:	b8 00 30 11 f0       	mov    $0xf0113000,%eax
f0102e03:	05 00 00 00 10       	add    $0x10000000,%eax
f0102e08:	89 04 24             	mov    %eax,(%esp)
f0102e0b:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102e10:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f0102e15:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0102e1a:	e8 76 e4 ff ff       	call   f0101295 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, 256*1024*1024, 0, PTE_W|PTE_P);
f0102e1f:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102e26:	00 
f0102e27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102e2e:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102e33:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102e38:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0102e3d:	e8 53 e4 ff ff       	call   f0101295 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102e42:	8b 1d c8 87 18 f0    	mov    0xf01887c8,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
f0102e48:	a1 c4 87 18 f0       	mov    0xf01887c4,%eax
f0102e4d:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0102e54:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102e5a:	74 79                	je     f0102ed5 <mem_init+0xa03>
f0102e5c:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e61:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0102e67:	89 d8                	mov    %ebx,%eax
f0102e69:	e8 8a e4 ff ff       	call   f01012f8 <check_va2pa>
f0102e6e:	8b 15 cc 87 18 f0    	mov    0xf01887cc,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e74:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102e7a:	77 20                	ja     f0102e9c <mem_init+0x9ca>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e7c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102e80:	c7 44 24 08 0c 5e 10 	movl   $0xf0105e0c,0x8(%esp)
f0102e87:	f0 
f0102e88:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f0102e8f:	00 
f0102e90:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102e97:	e8 e9 d1 ff ff       	call   f0100085 <_panic>
f0102e9c:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102ea3:	39 d0                	cmp    %edx,%eax
f0102ea5:	74 24                	je     f0102ecb <mem_init+0x9f9>
f0102ea7:	c7 44 24 0c 08 64 10 	movl   $0xf0106408,0xc(%esp)
f0102eae:	f0 
f0102eaf:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102eb6:	f0 
f0102eb7:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f0102ebe:	00 
f0102ebf:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102ec6:	e8 ba d1 ff ff       	call   f0100085 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102ecb:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102ed1:	39 f7                	cmp    %esi,%edi
f0102ed3:	77 8c                	ja     f0102e61 <mem_init+0x98f>
f0102ed5:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102eda:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
f0102ee0:	89 d8                	mov    %ebx,%eax
f0102ee2:	e8 11 e4 ff ff       	call   f01012f8 <check_va2pa>
f0102ee7:	8b 15 1c 7b 18 f0    	mov    0xf0187b1c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102eed:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102ef3:	77 20                	ja     f0102f15 <mem_init+0xa43>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ef5:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102ef9:	c7 44 24 08 0c 5e 10 	movl   $0xf0105e0c,0x8(%esp)
f0102f00:	f0 
f0102f01:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0102f08:	00 
f0102f09:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102f10:	e8 70 d1 ff ff       	call   f0100085 <_panic>
f0102f15:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102f1c:	39 d0                	cmp    %edx,%eax
f0102f1e:	74 24                	je     f0102f44 <mem_init+0xa72>
f0102f20:	c7 44 24 0c 3c 64 10 	movl   $0xf010643c,0xc(%esp)
f0102f27:	f0 
f0102f28:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102f2f:	f0 
f0102f30:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0102f37:	00 
f0102f38:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102f3f:	e8 41 d1 ff ff       	call   f0100085 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102f44:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102f4a:	81 fe 00 90 01 00    	cmp    $0x19000,%esi
f0102f50:	75 88                	jne    f0102eda <mem_init+0xa08>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102f52:	a1 c4 87 18 f0       	mov    0xf01887c4,%eax
f0102f57:	c1 e0 0c             	shl    $0xc,%eax
f0102f5a:	85 c0                	test   %eax,%eax
f0102f5c:	74 4c                	je     f0102faa <mem_init+0xad8>
f0102f5e:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102f63:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102f69:	89 d8                	mov    %ebx,%eax
f0102f6b:	e8 88 e3 ff ff       	call   f01012f8 <check_va2pa>
f0102f70:	39 c6                	cmp    %eax,%esi
f0102f72:	74 24                	je     f0102f98 <mem_init+0xac6>
f0102f74:	c7 44 24 0c 70 64 10 	movl   $0xf0106470,0xc(%esp)
f0102f7b:	f0 
f0102f7c:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102f83:	f0 
f0102f84:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f0102f8b:	00 
f0102f8c:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102f93:	e8 ed d0 ff ff       	call   f0100085 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102f98:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102f9e:	a1 c4 87 18 f0       	mov    0xf01887c4,%eax
f0102fa3:	c1 e0 0c             	shl    $0xc,%eax
f0102fa6:	39 c6                	cmp    %eax,%esi
f0102fa8:	72 b9                	jb     f0102f63 <mem_init+0xa91>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102faa:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f0102faf:	89 d8                	mov    %ebx,%eax
f0102fb1:	e8 42 e3 ff ff       	call   f01012f8 <check_va2pa>
f0102fb6:	be 00 90 bf ef       	mov    $0xefbf9000,%esi
f0102fbb:	bf 00 30 11 f0       	mov    $0xf0113000,%edi
f0102fc0:	81 c7 00 70 40 20    	add    $0x20407000,%edi
f0102fc6:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0102fc9:	39 c2                	cmp    %eax,%edx
f0102fcb:	74 24                	je     f0102ff1 <mem_init+0xb1f>
f0102fcd:	c7 44 24 0c 98 64 10 	movl   $0xf0106498,0xc(%esp)
f0102fd4:	f0 
f0102fd5:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0102fdc:	f0 
f0102fdd:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0102fe4:	00 
f0102fe5:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0102fec:	e8 94 d0 ff ff       	call   f0100085 <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102ff1:	81 fe 00 00 c0 ef    	cmp    $0xefc00000,%esi
f0102ff7:	0f 85 2c 05 00 00    	jne    f0103529 <mem_init+0x1057>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102ffd:	ba 00 00 80 ef       	mov    $0xef800000,%edx
f0103002:	89 d8                	mov    %ebx,%eax
f0103004:	e8 ef e2 ff ff       	call   f01012f8 <check_va2pa>
f0103009:	83 f8 ff             	cmp    $0xffffffff,%eax
f010300c:	74 24                	je     f0103032 <mem_init+0xb60>
f010300e:	c7 44 24 0c e0 64 10 	movl   $0xf01064e0,0xc(%esp)
f0103015:	f0 
f0103016:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f010301d:	f0 
f010301e:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f0103025:	00 
f0103026:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f010302d:	e8 53 d0 ff ff       	call   f0100085 <_panic>
f0103032:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0103037:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f010303d:	83 fa 03             	cmp    $0x3,%edx
f0103040:	77 2e                	ja     f0103070 <mem_init+0xb9e>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0103042:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0103046:	0f 85 aa 00 00 00    	jne    f01030f6 <mem_init+0xc24>
f010304c:	c7 44 24 0c c9 68 10 	movl   $0xf01068c9,0xc(%esp)
f0103053:	f0 
f0103054:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f010305b:	f0 
f010305c:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f0103063:	00 
f0103064:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f010306b:	e8 15 d0 ff ff       	call   f0100085 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0103070:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0103075:	76 55                	jbe    f01030cc <mem_init+0xbfa>
				assert(pgdir[i] & PTE_P);
f0103077:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f010307a:	f6 c2 01             	test   $0x1,%dl
f010307d:	75 24                	jne    f01030a3 <mem_init+0xbd1>
f010307f:	c7 44 24 0c c9 68 10 	movl   $0xf01068c9,0xc(%esp)
f0103086:	f0 
f0103087:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f010308e:	f0 
f010308f:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f0103096:	00 
f0103097:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f010309e:	e8 e2 cf ff ff       	call   f0100085 <_panic>
				assert(pgdir[i] & PTE_W);
f01030a3:	f6 c2 02             	test   $0x2,%dl
f01030a6:	75 4e                	jne    f01030f6 <mem_init+0xc24>
f01030a8:	c7 44 24 0c da 68 10 	movl   $0xf01068da,0xc(%esp)
f01030af:	f0 
f01030b0:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01030b7:	f0 
f01030b8:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f01030bf:	00 
f01030c0:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01030c7:	e8 b9 cf ff ff       	call   f0100085 <_panic>
			} else
				assert(pgdir[i] == 0);
f01030cc:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01030d0:	74 24                	je     f01030f6 <mem_init+0xc24>
f01030d2:	c7 44 24 0c eb 68 10 	movl   $0xf01068eb,0xc(%esp)
f01030d9:	f0 
f01030da:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01030e1:	f0 
f01030e2:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f01030e9:	00 
f01030ea:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01030f1:	e8 8f cf ff ff       	call   f0100085 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01030f6:	83 c0 01             	add    $0x1,%eax
f01030f9:	3d 00 04 00 00       	cmp    $0x400,%eax
f01030fe:	0f 85 33 ff ff ff    	jne    f0103037 <mem_init+0xb65>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0103104:	c7 04 24 10 65 10 f0 	movl   $0xf0106510,(%esp)
f010310b:	e8 9b 0b 00 00       	call   f0103cab <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0103110:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103115:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010311a:	77 20                	ja     f010313c <mem_init+0xc6a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010311c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103120:	c7 44 24 08 0c 5e 10 	movl   $0xf0105e0c,0x8(%esp)
f0103127:	f0 
f0103128:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
f010312f:	00 
f0103130:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0103137:	e8 49 cf ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010313c:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103142:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0103145:	b8 00 00 00 00       	mov    $0x0,%eax
f010314a:	e8 0f e2 ff ff       	call   f010135e <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f010314f:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0103152:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0103157:	83 e0 f3             	and    $0xfffffff3,%eax
f010315a:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010315d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103164:	e8 19 dd ff ff       	call   f0100e82 <page_alloc>
f0103169:	89 c3                	mov    %eax,%ebx
f010316b:	85 c0                	test   %eax,%eax
f010316d:	75 24                	jne    f0103193 <mem_init+0xcc1>
f010316f:	c7 44 24 0c 83 66 10 	movl   $0xf0106683,0xc(%esp)
f0103176:	f0 
f0103177:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f010317e:	f0 
f010317f:	c7 44 24 04 6a 04 00 	movl   $0x46a,0x4(%esp)
f0103186:	00 
f0103187:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f010318e:	e8 f2 ce ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0103193:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010319a:	e8 e3 dc ff ff       	call   f0100e82 <page_alloc>
f010319f:	89 c7                	mov    %eax,%edi
f01031a1:	85 c0                	test   %eax,%eax
f01031a3:	75 24                	jne    f01031c9 <mem_init+0xcf7>
f01031a5:	c7 44 24 0c 99 66 10 	movl   $0xf0106699,0xc(%esp)
f01031ac:	f0 
f01031ad:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01031b4:	f0 
f01031b5:	c7 44 24 04 6b 04 00 	movl   $0x46b,0x4(%esp)
f01031bc:	00 
f01031bd:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01031c4:	e8 bc ce ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f01031c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031d0:	e8 ad dc ff ff       	call   f0100e82 <page_alloc>
f01031d5:	89 c6                	mov    %eax,%esi
f01031d7:	85 c0                	test   %eax,%eax
f01031d9:	75 24                	jne    f01031ff <mem_init+0xd2d>
f01031db:	c7 44 24 0c af 66 10 	movl   $0xf01066af,0xc(%esp)
f01031e2:	f0 
f01031e3:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01031ea:	f0 
f01031eb:	c7 44 24 04 6c 04 00 	movl   $0x46c,0x4(%esp)
f01031f2:	00 
f01031f3:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01031fa:	e8 86 ce ff ff       	call   f0100085 <_panic>
	page_free(pp0);
f01031ff:	89 1c 24             	mov    %ebx,(%esp)
f0103202:	e8 39 da ff ff       	call   f0100c40 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0103207:	89 f8                	mov    %edi,%eax
f0103209:	2b 05 cc 87 18 f0    	sub    0xf01887cc,%eax
f010320f:	c1 f8 03             	sar    $0x3,%eax
f0103212:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103215:	89 c2                	mov    %eax,%edx
f0103217:	c1 ea 0c             	shr    $0xc,%edx
f010321a:	3b 15 c4 87 18 f0    	cmp    0xf01887c4,%edx
f0103220:	72 20                	jb     f0103242 <mem_init+0xd70>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103222:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103226:	c7 44 24 08 30 5e 10 	movl   $0xf0105e30,0x8(%esp)
f010322d:	f0 
f010322e:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0103235:	00 
f0103236:	c7 04 24 d9 65 10 f0 	movl   $0xf01065d9,(%esp)
f010323d:	e8 43 ce ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103242:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103249:	00 
f010324a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103251:	00 
f0103252:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103257:	89 04 24             	mov    %eax,(%esp)
f010325a:	e8 a7 21 00 00       	call   f0105406 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010325f:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0103262:	89 f0                	mov    %esi,%eax
f0103264:	2b 05 cc 87 18 f0    	sub    0xf01887cc,%eax
f010326a:	c1 f8 03             	sar    $0x3,%eax
f010326d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103270:	89 c2                	mov    %eax,%edx
f0103272:	c1 ea 0c             	shr    $0xc,%edx
f0103275:	3b 15 c4 87 18 f0    	cmp    0xf01887c4,%edx
f010327b:	72 20                	jb     f010329d <mem_init+0xdcb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010327d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103281:	c7 44 24 08 30 5e 10 	movl   $0xf0105e30,0x8(%esp)
f0103288:	f0 
f0103289:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0103290:	00 
f0103291:	c7 04 24 d9 65 10 f0 	movl   $0xf01065d9,(%esp)
f0103298:	e8 e8 cd ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f010329d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01032a4:	00 
f01032a5:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01032ac:	00 
f01032ad:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01032b2:	89 04 24             	mov    %eax,(%esp)
f01032b5:	e8 4c 21 00 00       	call   f0105406 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01032ba:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01032c1:	00 
f01032c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01032c9:	00 
f01032ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01032ce:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f01032d3:	89 04 24             	mov    %eax,(%esp)
f01032d6:	e8 12 df ff ff       	call   f01011ed <page_insert>
	assert(pp1->pp_ref == 1);
f01032db:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01032e0:	74 24                	je     f0103306 <mem_init+0xe34>
f01032e2:	c7 44 24 0c e6 66 10 	movl   $0xf01066e6,0xc(%esp)
f01032e9:	f0 
f01032ea:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01032f1:	f0 
f01032f2:	c7 44 24 04 71 04 00 	movl   $0x471,0x4(%esp)
f01032f9:	00 
f01032fa:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0103301:	e8 7f cd ff ff       	call   f0100085 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103306:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f010330d:	01 01 01 
f0103310:	74 24                	je     f0103336 <mem_init+0xe64>
f0103312:	c7 44 24 0c 30 65 10 	movl   $0xf0106530,0xc(%esp)
f0103319:	f0 
f010331a:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0103321:	f0 
f0103322:	c7 44 24 04 72 04 00 	movl   $0x472,0x4(%esp)
f0103329:	00 
f010332a:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0103331:	e8 4f cd ff ff       	call   f0100085 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0103336:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010333d:	00 
f010333e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103345:	00 
f0103346:	89 74 24 04          	mov    %esi,0x4(%esp)
f010334a:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f010334f:	89 04 24             	mov    %eax,(%esp)
f0103352:	e8 96 de ff ff       	call   f01011ed <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103357:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f010335e:	02 02 02 
f0103361:	74 24                	je     f0103387 <mem_init+0xeb5>
f0103363:	c7 44 24 0c 54 65 10 	movl   $0xf0106554,0xc(%esp)
f010336a:	f0 
f010336b:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0103372:	f0 
f0103373:	c7 44 24 04 74 04 00 	movl   $0x474,0x4(%esp)
f010337a:	00 
f010337b:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0103382:	e8 fe cc ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f0103387:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010338c:	74 24                	je     f01033b2 <mem_init+0xee0>
f010338e:	c7 44 24 0c 08 67 10 	movl   $0xf0106708,0xc(%esp)
f0103395:	f0 
f0103396:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f010339d:	f0 
f010339e:	c7 44 24 04 75 04 00 	movl   $0x475,0x4(%esp)
f01033a5:	00 
f01033a6:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01033ad:	e8 d3 cc ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f01033b2:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01033b7:	74 24                	je     f01033dd <mem_init+0xf0b>
f01033b9:	c7 44 24 0c 51 67 10 	movl   $0xf0106751,0xc(%esp)
f01033c0:	f0 
f01033c1:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01033c8:	f0 
f01033c9:	c7 44 24 04 76 04 00 	movl   $0x476,0x4(%esp)
f01033d0:	00 
f01033d1:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01033d8:	e8 a8 cc ff ff       	call   f0100085 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01033dd:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01033e4:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01033e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033ea:	2b 05 cc 87 18 f0    	sub    0xf01887cc,%eax
f01033f0:	c1 f8 03             	sar    $0x3,%eax
f01033f3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01033f6:	89 c2                	mov    %eax,%edx
f01033f8:	c1 ea 0c             	shr    $0xc,%edx
f01033fb:	3b 15 c4 87 18 f0    	cmp    0xf01887c4,%edx
f0103401:	72 20                	jb     f0103423 <mem_init+0xf51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103403:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103407:	c7 44 24 08 30 5e 10 	movl   $0xf0105e30,0x8(%esp)
f010340e:	f0 
f010340f:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0103416:	00 
f0103417:	c7 04 24 d9 65 10 f0 	movl   $0xf01065d9,(%esp)
f010341e:	e8 62 cc ff ff       	call   f0100085 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103423:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010342a:	03 03 03 
f010342d:	74 24                	je     f0103453 <mem_init+0xf81>
f010342f:	c7 44 24 0c 78 65 10 	movl   $0xf0106578,0xc(%esp)
f0103436:	f0 
f0103437:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f010343e:	f0 
f010343f:	c7 44 24 04 78 04 00 	movl   $0x478,0x4(%esp)
f0103446:	00 
f0103447:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f010344e:	e8 32 cc ff ff       	call   f0100085 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103453:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010345a:	00 
f010345b:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0103460:	89 04 24             	mov    %eax,(%esp)
f0103463:	e8 35 dd ff ff       	call   f010119d <page_remove>
	assert(pp2->pp_ref == 0);
f0103468:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010346d:	74 24                	je     f0103493 <mem_init+0xfc1>
f010346f:	c7 44 24 0c 40 67 10 	movl   $0xf0106740,0xc(%esp)
f0103476:	f0 
f0103477:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f010347e:	f0 
f010347f:	c7 44 24 04 7a 04 00 	movl   $0x47a,0x4(%esp)
f0103486:	00 
f0103487:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f010348e:	e8 f2 cb ff ff       	call   f0100085 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103493:	a1 c8 87 18 f0       	mov    0xf01887c8,%eax
f0103498:	8b 08                	mov    (%eax),%ecx
f010349a:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01034a0:	89 da                	mov    %ebx,%edx
f01034a2:	2b 15 cc 87 18 f0    	sub    0xf01887cc,%edx
f01034a8:	c1 fa 03             	sar    $0x3,%edx
f01034ab:	c1 e2 0c             	shl    $0xc,%edx
f01034ae:	39 d1                	cmp    %edx,%ecx
f01034b0:	74 24                	je     f01034d6 <mem_init+0x1004>
f01034b2:	c7 44 24 0c 28 60 10 	movl   $0xf0106028,0xc(%esp)
f01034b9:	f0 
f01034ba:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01034c1:	f0 
f01034c2:	c7 44 24 04 7d 04 00 	movl   $0x47d,0x4(%esp)
f01034c9:	00 
f01034ca:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f01034d1:	e8 af cb ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f01034d6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01034dc:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01034e1:	74 24                	je     f0103507 <mem_init+0x1035>
f01034e3:	c7 44 24 0c f7 66 10 	movl   $0xf01066f7,0xc(%esp)
f01034ea:	f0 
f01034eb:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f01034f2:	f0 
f01034f3:	c7 44 24 04 7f 04 00 	movl   $0x47f,0x4(%esp)
f01034fa:	00 
f01034fb:	c7 04 24 cd 65 10 f0 	movl   $0xf01065cd,(%esp)
f0103502:	e8 7e cb ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f0103507:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010350d:	89 1c 24             	mov    %ebx,(%esp)
f0103510:	e8 2b d7 ff ff       	call   f0100c40 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103515:	c7 04 24 a4 65 10 f0 	movl   $0xf01065a4,(%esp)
f010351c:	e8 8a 07 00 00       	call   f0103cab <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103521:	83 c4 2c             	add    $0x2c,%esp
f0103524:	5b                   	pop    %ebx
f0103525:	5e                   	pop    %esi
f0103526:	5f                   	pop    %edi
f0103527:	5d                   	pop    %ebp
f0103528:	c3                   	ret    
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0103529:	89 f2                	mov    %esi,%edx
f010352b:	89 d8                	mov    %ebx,%eax
f010352d:	e8 c6 dd ff ff       	call   f01012f8 <check_va2pa>
f0103532:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103538:	e9 89 fa ff ff       	jmp    f0102fc6 <mem_init+0xaf4>
f010353d:	00 00                	add    %al,(%eax)
	...

f0103540 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103540:	55                   	push   %ebp
f0103541:	89 e5                	mov    %esp,%ebp
f0103543:	53                   	push   %ebx
f0103544:	8b 45 08             	mov    0x8(%ebp),%eax
f0103547:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010354a:	85 c0                	test   %eax,%eax
f010354c:	75 0e                	jne    f010355c <envid2env+0x1c>
		*env_store = curenv;
f010354e:	a1 20 7b 18 f0       	mov    0xf0187b20,%eax
f0103553:	89 01                	mov    %eax,(%ecx)
f0103555:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
f010355a:	eb 54                	jmp    f01035b0 <envid2env+0x70>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010355c:	89 c2                	mov    %eax,%edx
f010355e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0103564:	6b d2 64             	imul   $0x64,%edx,%edx
f0103567:	03 15 1c 7b 18 f0    	add    0xf0187b1c,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010356d:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0103571:	74 05                	je     f0103578 <envid2env+0x38>
f0103573:	39 42 48             	cmp    %eax,0x48(%edx)
f0103576:	74 0d                	je     f0103585 <envid2env+0x45>
		*env_store = 0;
f0103578:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f010357e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0103583:	eb 2b                	jmp    f01035b0 <envid2env+0x70>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103585:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0103589:	74 1e                	je     f01035a9 <envid2env+0x69>
f010358b:	a1 20 7b 18 f0       	mov    0xf0187b20,%eax
f0103590:	39 c2                	cmp    %eax,%edx
f0103592:	74 15                	je     f01035a9 <envid2env+0x69>
f0103594:	8b 5a 4c             	mov    0x4c(%edx),%ebx
f0103597:	3b 58 48             	cmp    0x48(%eax),%ebx
f010359a:	74 0d                	je     f01035a9 <envid2env+0x69>
		*env_store = 0;
f010359c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f01035a2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f01035a7:	eb 07                	jmp    f01035b0 <envid2env+0x70>
	}

	*env_store = e;
f01035a9:	89 11                	mov    %edx,(%ecx)
f01035ab:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f01035b0:	5b                   	pop    %ebx
f01035b1:	5d                   	pop    %ebp
f01035b2:	c3                   	ret    

f01035b3 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01035b3:	55                   	push   %ebp
f01035b4:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01035b6:	b8 30 d3 11 f0       	mov    $0xf011d330,%eax
f01035bb:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01035be:	b8 23 00 00 00       	mov    $0x23,%eax
f01035c3:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01035c5:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01035c7:	b0 10                	mov    $0x10,%al
f01035c9:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01035cb:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01035cd:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01035cf:	ea d6 35 10 f0 08 00 	ljmp   $0x8,$0xf01035d6
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01035d6:	b0 00                	mov    $0x0,%al
f01035d8:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01035db:	5d                   	pop    %ebp
f01035dc:	c3                   	ret    

f01035dd <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01035dd:	55                   	push   %ebp
f01035de:	89 e5                	mov    %esp,%ebp
f01035e0:	b8 00 00 00 00       	mov    $0x0,%eax
	// LAB 3: Your code here.
	int i;
//	env_free_list = &envs[0];
	
	for (i = 0; i < NENV; i++) {
		envs[i].env_status = ENV_FREE;
f01035e5:	8b 15 1c 7b 18 f0    	mov    0xf0187b1c,%edx
f01035eb:	c7 44 02 54 00 00 00 	movl   $0x0,0x54(%edx,%eax,1)
f01035f2:	00 
		envs[i].env_id = 0;
f01035f3:	8b 15 1c 7b 18 f0    	mov    0xf0187b1c,%edx
f01035f9:	c7 44 02 48 00 00 00 	movl   $0x0,0x48(%edx,%eax,1)
f0103600:	00 
f0103601:	83 c0 64             	add    $0x64,%eax
	// Set up envs array
	// LAB 3: Your code here.
	int i;
//	env_free_list = &envs[0];
	
	for (i = 0; i < NENV; i++) {
f0103604:	3d 00 90 01 00       	cmp    $0x19000,%eax
f0103609:	75 da                	jne    f01035e5 <env_init+0x8>
f010360b:	66 b8 9c 8f          	mov    $0x8f9c,%ax
f010360f:	ba 00 00 00 00       	mov    $0x0,%edx
		envs[i].env_id = 0;
	}
	
	env_free_list = (struct Env *) 0;
	for (i = NENV -1; i >= 0; i--) {
		envs[i].env_link = env_free_list;
f0103614:	8b 0d 1c 7b 18 f0    	mov    0xf0187b1c,%ecx
f010361a:	89 54 01 44          	mov    %edx,0x44(%ecx,%eax,1)
		env_free_list = &envs[i];
f010361e:	89 c2                	mov    %eax,%edx
f0103620:	03 15 1c 7b 18 f0    	add    0xf0187b1c,%edx
f0103626:	83 e8 64             	sub    $0x64,%eax
		envs[i].env_status = ENV_FREE;
		envs[i].env_id = 0;
	}
	
	env_free_list = (struct Env *) 0;
	for (i = NENV -1; i >= 0; i--) {
f0103629:	83 f8 9c             	cmp    $0xffffff9c,%eax
f010362c:	75 e6                	jne    f0103614 <env_init+0x37>
f010362e:	89 15 24 7b 18 f0    	mov    %edx,0xf0187b24
		envs[i].env_status = ENV_FREE;
		envs[i].env_id = 0;
		envs[i - 1].env_link = &envs[i];
	}*/

	env_init_percpu();
f0103634:	e8 7a ff ff ff       	call   f01035b3 <env_init_percpu>
}
f0103639:	5d                   	pop    %ebp
f010363a:	c3                   	ret    

f010363b <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010363b:	55                   	push   %ebp
f010363c:	89 e5                	mov    %esp,%ebp
f010363e:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f0103641:	8b 65 08             	mov    0x8(%ebp),%esp
f0103644:	61                   	popa   
f0103645:	07                   	pop    %es
f0103646:	1f                   	pop    %ds
f0103647:	83 c4 08             	add    $0x8,%esp
f010364a:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010364b:	c7 44 24 08 f9 68 10 	movl   $0xf01068f9,0x8(%esp)
f0103652:	f0 
f0103653:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
f010365a:	00 
f010365b:	c7 04 24 05 69 10 f0 	movl   $0xf0106905,(%esp)
f0103662:	e8 1e ca ff ff       	call   f0100085 <_panic>

f0103667 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103667:	55                   	push   %ebp
f0103668:	89 e5                	mov    %esp,%ebp
f010366a:	83 ec 18             	sub    $0x18,%esp
f010366d:	8b 55 08             	mov    0x8(%ebp),%edx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv != e) {
f0103670:	a1 20 7b 18 f0       	mov    0xf0187b20,%eax
f0103675:	39 d0                	cmp    %edx,%eax
f0103677:	74 61                	je     f01036da <env_run+0x73>
		if(curenv && curenv->env_status 
f0103679:	85 c0                	test   %eax,%eax
f010367b:	74 0d                	je     f010368a <env_run+0x23>
f010367d:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0103681:	75 07                	jne    f010368a <env_run+0x23>
				== ENV_RUNNING) {
			curenv->env_status = ENV_RUNNABLE;
f0103683:	c7 40 54 01 00 00 00 	movl   $0x1,0x54(%eax)
		}
		curenv = e;
f010368a:	89 15 20 7b 18 f0    	mov    %edx,0xf0187b20
		curenv->env_status = ENV_RUNNING;
f0103690:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
		curenv->env_runs += 1;
f0103697:	a1 20 7b 18 f0       	mov    0xf0187b20,%eax
f010369c:	83 40 58 01          	addl   $0x1,0x58(%eax)
		lcr3(PADDR(curenv->env_pgdir));
f01036a0:	a1 20 7b 18 f0       	mov    0xf0187b20,%eax
f01036a5:	8b 40 5c             	mov    0x5c(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036a8:	89 c2                	mov    %eax,%edx
f01036aa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036af:	77 20                	ja     f01036d1 <env_run+0x6a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01036b5:	c7 44 24 08 0c 5e 10 	movl   $0xf0105e0c,0x8(%esp)
f01036bc:	f0 
f01036bd:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
f01036c4:	00 
f01036c5:	c7 04 24 05 69 10 f0 	movl   $0xf0106905,(%esp)
f01036cc:	e8 b4 c9 ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01036d1:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01036d7:	0f 22 da             	mov    %edx,%cr3
	}
	cprintf("FLAG\n");
f01036da:	c7 04 24 10 69 10 f0 	movl   $0xf0106910,(%esp)
f01036e1:	e8 c5 05 00 00       	call   f0103cab <cprintf>
	env_pop_tf(&(curenv->env_tf));
f01036e6:	a1 20 7b 18 f0       	mov    0xf0187b20,%eax
f01036eb:	89 04 24             	mov    %eax,(%esp)
f01036ee:	e8 48 ff ff ff       	call   f010363b <env_pop_tf>

f01036f3 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01036f3:	55                   	push   %ebp
f01036f4:	89 e5                	mov    %esp,%ebp
f01036f6:	57                   	push   %edi
f01036f7:	56                   	push   %esi
f01036f8:	53                   	push   %ebx
f01036f9:	83 ec 2c             	sub    $0x2c,%esp
f01036fc:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01036ff:	a1 20 7b 18 f0       	mov    0xf0187b20,%eax
f0103704:	39 c7                	cmp    %eax,%edi
f0103706:	75 37                	jne    f010373f <env_free+0x4c>
		lcr3(PADDR(kern_pgdir));
f0103708:	8b 15 c8 87 18 f0    	mov    0xf01887c8,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010370e:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103714:	77 20                	ja     f0103736 <env_free+0x43>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103716:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010371a:	c7 44 24 08 0c 5e 10 	movl   $0xf0105e0c,0x8(%esp)
f0103721:	f0 
f0103722:	c7 44 24 04 ab 01 00 	movl   $0x1ab,0x4(%esp)
f0103729:	00 
f010372a:	c7 04 24 05 69 10 f0 	movl   $0xf0106905,(%esp)
f0103731:	e8 4f c9 ff ff       	call   f0100085 <_panic>
f0103736:	8d 92 00 00 00 10    	lea    0x10000000(%edx),%edx
f010373c:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010373f:	8b 4f 48             	mov    0x48(%edi),%ecx
f0103742:	ba 00 00 00 00       	mov    $0x0,%edx
f0103747:	85 c0                	test   %eax,%eax
f0103749:	74 03                	je     f010374e <env_free+0x5b>
f010374b:	8b 50 48             	mov    0x48(%eax),%edx
f010374e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103752:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103756:	c7 04 24 16 69 10 f0 	movl   $0xf0106916,(%esp)
f010375d:	e8 49 05 00 00       	call   f0103cab <cprintf>
f0103762:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103769:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010376c:	c1 e0 02             	shl    $0x2,%eax
f010376f:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103772:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103775:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103778:	8b 34 10             	mov    (%eax,%edx,1),%esi
f010377b:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103781:	0f 84 b8 00 00 00    	je     f010383f <env_free+0x14c>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103787:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010378d:	89 f0                	mov    %esi,%eax
f010378f:	c1 e8 0c             	shr    $0xc,%eax
f0103792:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103795:	3b 05 c4 87 18 f0    	cmp    0xf01887c4,%eax
f010379b:	72 20                	jb     f01037bd <env_free+0xca>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010379d:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01037a1:	c7 44 24 08 30 5e 10 	movl   $0xf0105e30,0x8(%esp)
f01037a8:	f0 
f01037a9:	c7 44 24 04 ba 01 00 	movl   $0x1ba,0x4(%esp)
f01037b0:	00 
f01037b1:	c7 04 24 05 69 10 f0 	movl   $0xf0106905,(%esp)
f01037b8:	e8 c8 c8 ff ff       	call   f0100085 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01037bd:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01037c0:	c1 e2 16             	shl    $0x16,%edx
f01037c3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01037c6:	bb 00 00 00 00       	mov    $0x0,%ebx
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
f01037cb:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01037d2:	01 
f01037d3:	74 17                	je     f01037ec <env_free+0xf9>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01037d5:	89 d8                	mov    %ebx,%eax
f01037d7:	c1 e0 0c             	shl    $0xc,%eax
f01037da:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01037dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037e1:	8b 47 5c             	mov    0x5c(%edi),%eax
f01037e4:	89 04 24             	mov    %eax,(%esp)
f01037e7:	e8 b1 d9 ff ff       	call   f010119d <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01037ec:	83 c3 01             	add    $0x1,%ebx
f01037ef:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01037f5:	75 d4                	jne    f01037cb <env_free+0xd8>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01037f7:	8b 47 5c             	mov    0x5c(%edi),%eax
f01037fa:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01037fd:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103804:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103807:	3b 05 c4 87 18 f0    	cmp    0xf01887c4,%eax
f010380d:	72 1c                	jb     f010382b <env_free+0x138>
		panic("pa2page called with invalid pa");
f010380f:	c7 44 24 08 8c 5e 10 	movl   $0xf0105e8c,0x8(%esp)
f0103816:	f0 
f0103817:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f010381e:	00 
f010381f:	c7 04 24 d9 65 10 f0 	movl   $0xf01065d9,(%esp)
f0103826:	e8 5a c8 ff ff       	call   f0100085 <_panic>
		page_decref(pa2page(pa));
f010382b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010382e:	c1 e0 03             	shl    $0x3,%eax
f0103831:	03 05 cc 87 18 f0    	add    0xf01887cc,%eax
f0103837:	89 04 24             	mov    %eax,(%esp)
f010383a:	e8 16 d4 ff ff       	call   f0100c55 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010383f:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103843:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f010384a:	0f 85 19 ff ff ff    	jne    f0103769 <env_free+0x76>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103850:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103853:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103858:	77 20                	ja     f010387a <env_free+0x187>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010385a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010385e:	c7 44 24 08 0c 5e 10 	movl   $0xf0105e0c,0x8(%esp)
f0103865:	f0 
f0103866:	c7 44 24 04 c8 01 00 	movl   $0x1c8,0x4(%esp)
f010386d:	00 
f010386e:	c7 04 24 05 69 10 f0 	movl   $0xf0106905,(%esp)
f0103875:	e8 0b c8 ff ff       	call   f0100085 <_panic>
	e->env_pgdir = 0;
f010387a:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103881:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103887:	c1 e8 0c             	shr    $0xc,%eax
f010388a:	3b 05 c4 87 18 f0    	cmp    0xf01887c4,%eax
f0103890:	72 1c                	jb     f01038ae <env_free+0x1bb>
		panic("pa2page called with invalid pa");
f0103892:	c7 44 24 08 8c 5e 10 	movl   $0xf0105e8c,0x8(%esp)
f0103899:	f0 
f010389a:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01038a1:	00 
f01038a2:	c7 04 24 d9 65 10 f0 	movl   $0xf01065d9,(%esp)
f01038a9:	e8 d7 c7 ff ff       	call   f0100085 <_panic>
	page_decref(pa2page(pa));
f01038ae:	c1 e0 03             	shl    $0x3,%eax
f01038b1:	03 05 cc 87 18 f0    	add    0xf01887cc,%eax
f01038b7:	89 04 24             	mov    %eax,(%esp)
f01038ba:	e8 96 d3 ff ff       	call   f0100c55 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01038bf:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01038c6:	a1 24 7b 18 f0       	mov    0xf0187b24,%eax
f01038cb:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01038ce:	89 3d 24 7b 18 f0    	mov    %edi,0xf0187b24
}
f01038d4:	83 c4 2c             	add    $0x2c,%esp
f01038d7:	5b                   	pop    %ebx
f01038d8:	5e                   	pop    %esi
f01038d9:	5f                   	pop    %edi
f01038da:	5d                   	pop    %ebp
f01038db:	c3                   	ret    

f01038dc <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f01038dc:	55                   	push   %ebp
f01038dd:	89 e5                	mov    %esp,%ebp
f01038df:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f01038e2:	8b 45 08             	mov    0x8(%ebp),%eax
f01038e5:	89 04 24             	mov    %eax,(%esp)
f01038e8:	e8 06 fe ff ff       	call   f01036f3 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01038ed:	c7 04 24 8c 69 10 f0 	movl   $0xf010698c,(%esp)
f01038f4:	e8 b2 03 00 00       	call   f0103cab <cprintf>
	while (1)
		monitor(NULL);
f01038f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103900:	e8 cf ce ff ff       	call   f01007d4 <monitor>
f0103905:	eb f2                	jmp    f01038f9 <env_destroy+0x1d>

f0103907 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len) 
{
f0103907:	55                   	push   %ebp
f0103908:	89 e5                	mov    %esp,%ebp
f010390a:	57                   	push   %edi
f010390b:	56                   	push   %esi
f010390c:	53                   	push   %ebx
f010390d:	83 ec 1c             	sub    $0x1c,%esp
f0103910:	89 c6                	mov    %eax,%esi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	uint32_t start = (uint32_t) ROUNDDOWN(va, PGSIZE);
f0103912:	89 d3                	mov    %edx,%ebx
f0103914:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t u_bound = start + len;
f010391a:	8d 3c 0b             	lea    (%ebx,%ecx,1),%edi
	struct Page *p;

	for(; start < u_bound; start += PGSIZE) {
f010391d:	39 fb                	cmp    %edi,%ebx
f010391f:	73 75                	jae    f0103996 <region_alloc+0x8f>
		p = page_alloc(ALLOC_ZERO);
f0103921:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103928:	e8 55 d5 ff ff       	call   f0100e82 <page_alloc>
		if(p == NULL) {
f010392d:	85 c0                	test   %eax,%eax
f010392f:	75 1c                	jne    f010394d <region_alloc+0x46>
			panic("region_alloc: out of memory!\n");
f0103931:	c7 44 24 08 2c 69 10 	movl   $0xf010692c,0x8(%esp)
f0103938:	f0 
f0103939:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
f0103940:	00 
f0103941:	c7 04 24 05 69 10 f0 	movl   $0xf0106905,(%esp)
f0103948:	e8 38 c7 ff ff       	call   f0100085 <_panic>
		}
		int r = page_insert(e->env_pgdir, p, (void *) start, PTE_U | PTE_W);
f010394d:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103954:	00 
f0103955:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103959:	89 44 24 04          	mov    %eax,0x4(%esp)
f010395d:	8b 46 5c             	mov    0x5c(%esi),%eax
f0103960:	89 04 24             	mov    %eax,(%esp)
f0103963:	e8 85 d8 ff ff       	call   f01011ed <page_insert>
		if(r != 0) {
f0103968:	85 c0                	test   %eax,%eax
f010396a:	74 20                	je     f010398c <region_alloc+0x85>
			panic("region_alloc: %e\n", r);
f010396c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103970:	c7 44 24 08 4a 69 10 	movl   $0xf010694a,0x8(%esp)
f0103977:	f0 
f0103978:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
f010397f:	00 
f0103980:	c7 04 24 05 69 10 f0 	movl   $0xf0106905,(%esp)
f0103987:	e8 f9 c6 ff ff       	call   f0100085 <_panic>
	//   (Watch out for corner-cases!)
	uint32_t start = (uint32_t) ROUNDDOWN(va, PGSIZE);
	uint32_t u_bound = start + len;
	struct Page *p;

	for(; start < u_bound; start += PGSIZE) {
f010398c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103992:	39 df                	cmp    %ebx,%edi
f0103994:	77 8b                	ja     f0103921 <region_alloc+0x1a>
		int r = page_insert(e->env_pgdir, p, (void *) start, PTE_U | PTE_W);
		if(r != 0) {
			panic("region_alloc: %e\n", r);
		}
	}
}
f0103996:	83 c4 1c             	add    $0x1c,%esp
f0103999:	5b                   	pop    %ebx
f010399a:	5e                   	pop    %esi
f010399b:	5f                   	pop    %edi
f010399c:	5d                   	pop    %ebp
f010399d:	c3                   	ret    

f010399e <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010399e:	55                   	push   %ebp
f010399f:	89 e5                	mov    %esp,%ebp
f01039a1:	56                   	push   %esi
f01039a2:	53                   	push   %ebx
f01039a3:	83 ec 10             	sub    $0x10,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01039a6:	8b 1d 24 7b 18 f0    	mov    0xf0187b24,%ebx
f01039ac:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01039b1:	85 db                	test   %ebx,%ebx
f01039b3:	0f 84 6f 01 00 00    	je     f0103b28 <env_alloc+0x18a>
{
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f01039b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01039c0:	e8 bd d4 ff ff       	call   f0100e82 <page_alloc>
f01039c5:	89 c6                	mov    %eax,%esi
f01039c7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01039cc:	85 f6                	test   %esi,%esi
f01039ce:	0f 84 54 01 00 00    	je     f0103b28 <env_alloc+0x18a>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01039d4:	89 f0                	mov    %esi,%eax
f01039d6:	2b 05 cc 87 18 f0    	sub    0xf01887cc,%eax
f01039dc:	c1 f8 03             	sar    $0x3,%eax
f01039df:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01039e2:	89 c2                	mov    %eax,%edx
f01039e4:	c1 ea 0c             	shr    $0xc,%edx
f01039e7:	3b 15 c4 87 18 f0    	cmp    0xf01887c4,%edx
f01039ed:	72 20                	jb     f0103a0f <env_alloc+0x71>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01039ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039f3:	c7 44 24 08 30 5e 10 	movl   $0xf0105e30,0x8(%esp)
f01039fa:	f0 
f01039fb:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0103a02:	00 
f0103a03:	c7 04 24 d9 65 10 f0 	movl   $0xf01065d9,(%esp)
f0103a0a:	e8 76 c6 ff ff       	call   f0100085 <_panic>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = (pde_t *) page2kva(p);
f0103a0f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103a14:	89 43 5c             	mov    %eax,0x5c(%ebx)
//	e->env_cr3 = page2pa(p);
	memmove(e->env_pgdir, kern_pgdir, PGSIZE);
f0103a17:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103a1e:	00 
f0103a1f:	8b 15 c8 87 18 f0    	mov    0xf01887c8,%edx
f0103a25:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103a29:	89 04 24             	mov    %eax,(%esp)
f0103a2c:	e8 34 1a 00 00       	call   f0105465 <memmove>
//	memset(e->env_pgdir, 0, PDX(UTOP) * sizeof(pde_t));
	p->pp_ref ++;
f0103a31:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103a36:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a39:	89 c2                	mov    %eax,%edx
f0103a3b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a40:	77 20                	ja     f0103a62 <env_alloc+0xc4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a42:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a46:	c7 44 24 08 0c 5e 10 	movl   $0xf0105e0c,0x8(%esp)
f0103a4d:	f0 
f0103a4e:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
f0103a55:	00 
f0103a56:	c7 04 24 05 69 10 f0 	movl   $0xf0106905,(%esp)
f0103a5d:	e8 23 c6 ff ff       	call   f0100085 <_panic>
f0103a62:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103a68:	83 ca 05             	or     $0x5,%edx
f0103a6b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103a71:	8b 43 48             	mov    0x48(%ebx),%eax
f0103a74:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103a79:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103a7e:	7f 05                	jg     f0103a85 <env_alloc+0xe7>
f0103a80:	b8 00 10 00 00       	mov    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f0103a85:	89 da                	mov    %ebx,%edx
f0103a87:	2b 15 1c 7b 18 f0    	sub    0xf0187b1c,%edx
f0103a8d:	c1 fa 02             	sar    $0x2,%edx
f0103a90:	69 d2 29 5c 8f c2    	imul   $0xc28f5c29,%edx,%edx
f0103a96:	09 d0                	or     %edx,%eax
f0103a98:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103a9b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a9e:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103aa1:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103aa8:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
f0103aaf:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103ab6:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103abd:	00 
f0103abe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103ac5:	00 
f0103ac6:	89 1c 24             	mov    %ebx,(%esp)
f0103ac9:	e8 38 19 00 00       	call   f0105406 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103ace:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103ad4:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103ada:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103ae0:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103ae7:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0103aed:	8b 43 44             	mov    0x44(%ebx),%eax
f0103af0:	a3 24 7b 18 f0       	mov    %eax,0xf0187b24
	*newenv_store = e;
f0103af5:	8b 45 08             	mov    0x8(%ebp),%eax
f0103af8:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103afa:	8b 4b 48             	mov    0x48(%ebx),%ecx
f0103afd:	8b 15 20 7b 18 f0    	mov    0xf0187b20,%edx
f0103b03:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b08:	85 d2                	test   %edx,%edx
f0103b0a:	74 03                	je     f0103b0f <env_alloc+0x171>
f0103b0c:	8b 42 48             	mov    0x48(%edx),%eax
f0103b0f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103b13:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b17:	c7 04 24 5c 69 10 f0 	movl   $0xf010695c,(%esp)
f0103b1e:	e8 88 01 00 00       	call   f0103cab <cprintf>
f0103b23:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f0103b28:	83 c4 10             	add    $0x10,%esp
f0103b2b:	5b                   	pop    %ebx
f0103b2c:	5e                   	pop    %esi
f0103b2d:	5d                   	pop    %ebp
f0103b2e:	c3                   	ret    

f0103b2f <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0103b2f:	55                   	push   %ebp
f0103b30:	89 e5                	mov    %esp,%ebp
f0103b32:	57                   	push   %edi
f0103b33:	56                   	push   %esi
f0103b34:	53                   	push   %ebx
f0103b35:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 3: Your code here.
	struct Env *e;
	int r = env_alloc(&e, (envid_t) 0);
f0103b38:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103b3f:	00 
f0103b40:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103b43:	89 04 24             	mov    %eax,(%esp)
f0103b46:	e8 53 fe ff ff       	call   f010399e <env_alloc>
	if(r < 0) {
f0103b4b:	85 c0                	test   %eax,%eax
f0103b4d:	79 20                	jns    f0103b6f <env_create+0x40>
		panic("kern/env.c: create faild, env_alloc returns %e\n", r);
f0103b4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b53:	c7 44 24 08 c4 69 10 	movl   $0xf01069c4,0x8(%esp)
f0103b5a:	f0 
f0103b5b:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
f0103b62:	00 
f0103b63:	c7 04 24 05 69 10 f0 	movl   $0xf0106905,(%esp)
f0103b6a:	e8 16 c5 ff ff       	call   f0100085 <_panic>
	}
	e->env_type = type;
f0103b6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b72:	8b 55 10             	mov    0x10(%ebp),%edx
f0103b75:	89 50 50             	mov    %edx,0x50(%eax)
	load_icode(e, binary, size);
f0103b78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b7b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	struct Proghdr *ph, *eph;
	struct Elf *elf_hdr = (struct Elf *) binary;
f0103b7e:	8b 7d 08             	mov    0x8(%ebp),%edi

	if(elf_hdr->e_magic != ELF_MAGIC) {
f0103b81:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103b87:	74 1c                	je     f0103ba5 <env_create+0x76>
		panic("kern/env.c: not valid ELF");
f0103b89:	c7 44 24 08 71 69 10 	movl   $0xf0106971,0x8(%esp)
f0103b90:	f0 
f0103b91:	c7 44 24 04 70 01 00 	movl   $0x170,0x4(%esp)
f0103b98:	00 
f0103b99:	c7 04 24 05 69 10 f0 	movl   $0xf0106905,(%esp)
f0103ba0:	e8 e0 c4 ff ff       	call   f0100085 <_panic>
	}

	ph = (struct Proghdr *) ((uint8_t *) elf_hdr + elf_hdr->e_phoff);
f0103ba5:	8b 5f 1c             	mov    0x1c(%edi),%ebx
	eph	= ph + elf_hdr->e_phnum;
f0103ba8:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
    lcr3(PADDR(e->env_pgdir));	
f0103bac:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103baf:	8b 42 5c             	mov    0x5c(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103bb2:	89 c2                	mov    %eax,%edx
f0103bb4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bb9:	77 20                	ja     f0103bdb <env_create+0xac>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103bbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103bbf:	c7 44 24 08 0c 5e 10 	movl   $0xf0105e0c,0x8(%esp)
f0103bc6:	f0 
f0103bc7:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
f0103bce:	00 
f0103bcf:	c7 04 24 05 69 10 f0 	movl   $0xf0106905,(%esp)
f0103bd6:	e8 aa c4 ff ff       	call   f0100085 <_panic>

	if(elf_hdr->e_magic != ELF_MAGIC) {
		panic("kern/env.c: not valid ELF");
	}

	ph = (struct Proghdr *) ((uint8_t *) elf_hdr + elf_hdr->e_phoff);
f0103bdb:	8d 1c 1f             	lea    (%edi,%ebx,1),%ebx
	eph	= ph + elf_hdr->e_phnum;
f0103bde:	0f b7 f6             	movzwl %si,%esi
f0103be1:	c1 e6 05             	shl    $0x5,%esi
f0103be4:	8d 34 33             	lea    (%ebx,%esi,1),%esi
f0103be7:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103bed:	0f 22 da             	mov    %edx,%cr3
    lcr3(PADDR(e->env_pgdir));	

	for(; ph < eph; ph++) {
f0103bf0:	39 f3                	cmp    %esi,%ebx
f0103bf2:	73 36                	jae    f0103c2a <env_create+0xfb>
		if(ph->p_type != ELF_PROG_LOAD) {
f0103bf4:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103bf7:	75 2a                	jne    f0103c23 <env_create+0xf4>
			continue;
		}
		region_alloc(e, (void *) ph->p_va, ph->p_memsz);
f0103bf9:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103bfc:	8b 53 08             	mov    0x8(%ebx),%edx
f0103bff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103c02:	e8 00 fd ff ff       	call   f0103907 <region_alloc>
//		memset((void *) ph->p_va, 0, ph->p_memsz);
		//copy data from the binary to the va
		memmove((void *) ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103c07:	8b 43 10             	mov    0x10(%ebx),%eax
f0103c0a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103c0e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c11:	03 43 04             	add    0x4(%ebx),%eax
f0103c14:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c18:	8b 43 08             	mov    0x8(%ebx),%eax
f0103c1b:	89 04 24             	mov    %eax,(%esp)
f0103c1e:	e8 42 18 00 00       	call   f0105465 <memmove>

	ph = (struct Proghdr *) ((uint8_t *) elf_hdr + elf_hdr->e_phoff);
	eph	= ph + elf_hdr->e_phnum;
    lcr3(PADDR(e->env_pgdir));	

	for(; ph < eph; ph++) {
f0103c23:	83 c3 20             	add    $0x20,%ebx
f0103c26:	39 de                	cmp    %ebx,%esi
f0103c28:	77 ca                	ja     f0103bf4 <env_create+0xc5>
		//copy data from the binary to the va
		memmove((void *) ph->p_va, binary + ph->p_offset, ph->p_filesz);
		
	}
	
	e->env_tf.tf_eip = elf_hdr->e_entry;
f0103c2a:	8b 47 18             	mov    0x18(%edi),%eax
f0103c2d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103c30:	89 42 30             	mov    %eax,0x30(%edx)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f0103c33:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103c38:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103c3d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103c40:	e8 c2 fc ff ff       	call   f0103907 <region_alloc>
	if(r < 0) {
		panic("kern/env.c: create faild, env_alloc returns %e\n", r);
	}
	e->env_type = type;
	load_icode(e, binary, size);
}
f0103c45:	83 c4 3c             	add    $0x3c,%esp
f0103c48:	5b                   	pop    %ebx
f0103c49:	5e                   	pop    %esi
f0103c4a:	5f                   	pop    %edi
f0103c4b:	5d                   	pop    %ebp
f0103c4c:	c3                   	ret    
f0103c4d:	00 00                	add    %al,(%eax)
	...

f0103c50 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103c50:	55                   	push   %ebp
f0103c51:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103c53:	ba 70 00 00 00       	mov    $0x70,%edx
f0103c58:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c5b:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103c5c:	b2 71                	mov    $0x71,%dl
f0103c5e:	ec                   	in     (%dx),%al
f0103c5f:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f0103c62:	5d                   	pop    %ebp
f0103c63:	c3                   	ret    

f0103c64 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103c64:	55                   	push   %ebp
f0103c65:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103c67:	ba 70 00 00 00       	mov    $0x70,%edx
f0103c6c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c6f:	ee                   	out    %al,(%dx)
f0103c70:	b2 71                	mov    $0x71,%dl
f0103c72:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c75:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103c76:	5d                   	pop    %ebp
f0103c77:	c3                   	ret    

f0103c78 <vcprintf>:
    (*cnt)++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f0103c78:	55                   	push   %ebp
f0103c79:	89 e5                	mov    %esp,%ebp
f0103c7b:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103c7e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103c85:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c88:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c8c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c8f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103c93:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103c96:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c9a:	c7 04 24 c5 3c 10 f0 	movl   $0xf0103cc5,(%esp)
f0103ca1:	e8 87 0f 00 00       	call   f0104c2d <vprintfmt>
	return cnt;
}
f0103ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103ca9:	c9                   	leave  
f0103caa:	c3                   	ret    

f0103cab <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103cab:	55                   	push   %ebp
f0103cac:	89 e5                	mov    %esp,%ebp
f0103cae:	83 ec 18             	sub    $0x18,%esp
	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}

int
cprintf(const char *fmt, ...)
f0103cb1:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0103cb4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cb8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cbb:	89 04 24             	mov    %eax,(%esp)
f0103cbe:	e8 b5 ff ff ff       	call   f0103c78 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103cc3:	c9                   	leave  
f0103cc4:	c3                   	ret    

f0103cc5 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103cc5:	55                   	push   %ebp
f0103cc6:	89 e5                	mov    %esp,%ebp
f0103cc8:	53                   	push   %ebx
f0103cc9:	83 ec 14             	sub    $0x14,%esp
f0103ccc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f0103ccf:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cd2:	89 04 24             	mov    %eax,(%esp)
f0103cd5:	e8 c0 c7 ff ff       	call   f010049a <cputchar>
    (*cnt)++;
f0103cda:	83 03 01             	addl   $0x1,(%ebx)
}
f0103cdd:	83 c4 14             	add    $0x14,%esp
f0103ce0:	5b                   	pop    %ebx
f0103ce1:	5d                   	pop    %ebp
f0103ce2:	c3                   	ret    
	...

f0103cf0 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103cf0:	55                   	push   %ebp
f0103cf1:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103cf3:	c7 05 44 83 18 f0 00 	movl   $0xefc00000,0xf0188344
f0103cfa:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f0103cfd:	66 c7 05 48 83 18 f0 	movw   $0x10,0xf0188348
f0103d04:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103d06:	66 c7 05 28 d3 11 f0 	movw   $0x68,0xf011d328
f0103d0d:	68 00 
f0103d0f:	b8 40 83 18 f0       	mov    $0xf0188340,%eax
f0103d14:	66 a3 2a d3 11 f0    	mov    %ax,0xf011d32a
f0103d1a:	89 c2                	mov    %eax,%edx
f0103d1c:	c1 ea 10             	shr    $0x10,%edx
f0103d1f:	88 15 2c d3 11 f0    	mov    %dl,0xf011d32c
f0103d25:	c6 05 2e d3 11 f0 40 	movb   $0x40,0xf011d32e
f0103d2c:	c1 e8 18             	shr    $0x18,%eax
f0103d2f:	a2 2f d3 11 f0       	mov    %al,0xf011d32f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103d34:	c6 05 2d d3 11 f0 89 	movb   $0x89,0xf011d32d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103d3b:	b8 28 00 00 00       	mov    $0x28,%eax
f0103d40:	0f 00 d8             	ltr    %ax
}  

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103d43:	b8 38 d3 11 f0       	mov    $0xf011d338,%eax
f0103d48:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103d4b:	5d                   	pop    %ebp
f0103d4c:	c3                   	ret    

f0103d4d <trap_init>:
}


void
trap_init(void)
{
f0103d4d:	55                   	push   %ebp
f0103d4e:	89 e5                	mov    %esp,%ebp
	extern void entry_align_chk();
	extern void entry_mach_chk();
	extern void entry_simd_fp_err();
	extern void entry_sys_call();
	
	SETGATE(idt[T_DIVIDE], 0 , GD_KT, entry_div_err, 0);
f0103d50:	b8 40 44 10 f0       	mov    $0xf0104440,%eax
f0103d55:	66 a3 40 7b 18 f0    	mov    %ax,0xf0187b40
f0103d5b:	66 c7 05 42 7b 18 f0 	movw   $0x8,0xf0187b42
f0103d62:	08 00 
f0103d64:	c6 05 44 7b 18 f0 00 	movb   $0x0,0xf0187b44
f0103d6b:	c6 05 45 7b 18 f0 8e 	movb   $0x8e,0xf0187b45
f0103d72:	c1 e8 10             	shr    $0x10,%eax
f0103d75:	66 a3 46 7b 18 f0    	mov    %ax,0xf0187b46
	SETGATE(idt[T_DEBUG], 0 , GD_KT, entry_deb_exc, 0);
f0103d7b:	b8 4a 44 10 f0       	mov    $0xf010444a,%eax
f0103d80:	66 a3 48 7b 18 f0    	mov    %ax,0xf0187b48
f0103d86:	66 c7 05 4a 7b 18 f0 	movw   $0x8,0xf0187b4a
f0103d8d:	08 00 
f0103d8f:	c6 05 4c 7b 18 f0 00 	movb   $0x0,0xf0187b4c
f0103d96:	c6 05 4d 7b 18 f0 8e 	movb   $0x8e,0xf0187b4d
f0103d9d:	c1 e8 10             	shr    $0x10,%eax
f0103da0:	66 a3 4e 7b 18 f0    	mov    %ax,0xf0187b4e
	SETGATE(idt[T_NMI], 0 , GD_KT, entry_nmi, 0);
f0103da6:	b8 54 44 10 f0       	mov    $0xf0104454,%eax
f0103dab:	66 a3 50 7b 18 f0    	mov    %ax,0xf0187b50
f0103db1:	66 c7 05 52 7b 18 f0 	movw   $0x8,0xf0187b52
f0103db8:	08 00 
f0103dba:	c6 05 54 7b 18 f0 00 	movb   $0x0,0xf0187b54
f0103dc1:	c6 05 55 7b 18 f0 8e 	movb   $0x8e,0xf0187b55
f0103dc8:	c1 e8 10             	shr    $0x10,%eax
f0103dcb:	66 a3 56 7b 18 f0    	mov    %ax,0xf0187b56
	SETGATE(idt[T_BRKPT], 0 , GD_KT, entry_brkpt, 3);
f0103dd1:	b8 5e 44 10 f0       	mov    $0xf010445e,%eax
f0103dd6:	66 a3 58 7b 18 f0    	mov    %ax,0xf0187b58
f0103ddc:	66 c7 05 5a 7b 18 f0 	movw   $0x8,0xf0187b5a
f0103de3:	08 00 
f0103de5:	c6 05 5c 7b 18 f0 00 	movb   $0x0,0xf0187b5c
f0103dec:	c6 05 5d 7b 18 f0 ee 	movb   $0xee,0xf0187b5d
f0103df3:	c1 e8 10             	shr    $0x10,%eax
f0103df6:	66 a3 5e 7b 18 f0    	mov    %ax,0xf0187b5e
	SETGATE(idt[T_OFLOW], 0 , GD_KT, entry_ovflow, 0);
f0103dfc:	b8 68 44 10 f0       	mov    $0xf0104468,%eax
f0103e01:	66 a3 60 7b 18 f0    	mov    %ax,0xf0187b60
f0103e07:	66 c7 05 62 7b 18 f0 	movw   $0x8,0xf0187b62
f0103e0e:	08 00 
f0103e10:	c6 05 64 7b 18 f0 00 	movb   $0x0,0xf0187b64
f0103e17:	c6 05 65 7b 18 f0 8e 	movb   $0x8e,0xf0187b65
f0103e1e:	c1 e8 10             	shr    $0x10,%eax
f0103e21:	66 a3 66 7b 18 f0    	mov    %ax,0xf0187b66
	SETGATE(idt[T_BOUND], 0 , GD_KT, entry_bound, 0);
f0103e27:	b8 72 44 10 f0       	mov    $0xf0104472,%eax
f0103e2c:	66 a3 68 7b 18 f0    	mov    %ax,0xf0187b68
f0103e32:	66 c7 05 6a 7b 18 f0 	movw   $0x8,0xf0187b6a
f0103e39:	08 00 
f0103e3b:	c6 05 6c 7b 18 f0 00 	movb   $0x0,0xf0187b6c
f0103e42:	c6 05 6d 7b 18 f0 8e 	movb   $0x8e,0xf0187b6d
f0103e49:	c1 e8 10             	shr    $0x10,%eax
f0103e4c:	66 a3 6e 7b 18 f0    	mov    %ax,0xf0187b6e
	SETGATE(idt[T_ILLOP], 0 , GD_KT, entry_illop, 0);
f0103e52:	b8 7c 44 10 f0       	mov    $0xf010447c,%eax
f0103e57:	66 a3 70 7b 18 f0    	mov    %ax,0xf0187b70
f0103e5d:	66 c7 05 72 7b 18 f0 	movw   $0x8,0xf0187b72
f0103e64:	08 00 
f0103e66:	c6 05 74 7b 18 f0 00 	movb   $0x0,0xf0187b74
f0103e6d:	c6 05 75 7b 18 f0 8e 	movb   $0x8e,0xf0187b75
f0103e74:	c1 e8 10             	shr    $0x10,%eax
f0103e77:	66 a3 76 7b 18 f0    	mov    %ax,0xf0187b76
	SETGATE(idt[T_DEVICE], 0 , GD_KT, entry_dev, 0);
f0103e7d:	b8 86 44 10 f0       	mov    $0xf0104486,%eax
f0103e82:	66 a3 78 7b 18 f0    	mov    %ax,0xf0187b78
f0103e88:	66 c7 05 7a 7b 18 f0 	movw   $0x8,0xf0187b7a
f0103e8f:	08 00 
f0103e91:	c6 05 7c 7b 18 f0 00 	movb   $0x0,0xf0187b7c
f0103e98:	c6 05 7d 7b 18 f0 8e 	movb   $0x8e,0xf0187b7d
f0103e9f:	c1 e8 10             	shr    $0x10,%eax
f0103ea2:	66 a3 7e 7b 18 f0    	mov    %ax,0xf0187b7e
	SETGATE(idt[T_DBLFLT], 0 , GD_KT, entry_dfault, 0);
f0103ea8:	b8 8c 44 10 f0       	mov    $0xf010448c,%eax
f0103ead:	66 a3 80 7b 18 f0    	mov    %ax,0xf0187b80
f0103eb3:	66 c7 05 82 7b 18 f0 	movw   $0x8,0xf0187b82
f0103eba:	08 00 
f0103ebc:	c6 05 84 7b 18 f0 00 	movb   $0x0,0xf0187b84
f0103ec3:	c6 05 85 7b 18 f0 8e 	movb   $0x8e,0xf0187b85
f0103eca:	c1 e8 10             	shr    $0x10,%eax
f0103ecd:	66 a3 86 7b 18 f0    	mov    %ax,0xf0187b86
	SETGATE(idt[T_TSS], 0 , GD_KT, entry_tss, 0);
f0103ed3:	b8 94 44 10 f0       	mov    $0xf0104494,%eax
f0103ed8:	66 a3 90 7b 18 f0    	mov    %ax,0xf0187b90
f0103ede:	66 c7 05 92 7b 18 f0 	movw   $0x8,0xf0187b92
f0103ee5:	08 00 
f0103ee7:	c6 05 94 7b 18 f0 00 	movb   $0x0,0xf0187b94
f0103eee:	c6 05 95 7b 18 f0 8e 	movb   $0x8e,0xf0187b95
f0103ef5:	c1 e8 10             	shr    $0x10,%eax
f0103ef8:	66 a3 96 7b 18 f0    	mov    %ax,0xf0187b96
	SETGATE(idt[T_SEGNP], 0 , GD_KT, entry_segnp, 0);
f0103efe:	b8 98 44 10 f0       	mov    $0xf0104498,%eax
f0103f03:	66 a3 98 7b 18 f0    	mov    %ax,0xf0187b98
f0103f09:	66 c7 05 9a 7b 18 f0 	movw   $0x8,0xf0187b9a
f0103f10:	08 00 
f0103f12:	c6 05 9c 7b 18 f0 00 	movb   $0x0,0xf0187b9c
f0103f19:	c6 05 9d 7b 18 f0 8e 	movb   $0x8e,0xf0187b9d
f0103f20:	c1 e8 10             	shr    $0x10,%eax
f0103f23:	66 a3 9e 7b 18 f0    	mov    %ax,0xf0187b9e
	SETGATE(idt[T_STACK], 0 , GD_KT, entry_stack, 0);
f0103f29:	b8 9c 44 10 f0       	mov    $0xf010449c,%eax
f0103f2e:	66 a3 a0 7b 18 f0    	mov    %ax,0xf0187ba0
f0103f34:	66 c7 05 a2 7b 18 f0 	movw   $0x8,0xf0187ba2
f0103f3b:	08 00 
f0103f3d:	c6 05 a4 7b 18 f0 00 	movb   $0x0,0xf0187ba4
f0103f44:	c6 05 a5 7b 18 f0 8e 	movb   $0x8e,0xf0187ba5
f0103f4b:	c1 e8 10             	shr    $0x10,%eax
f0103f4e:	66 a3 a6 7b 18 f0    	mov    %ax,0xf0187ba6
	SETGATE(idt[T_GPFLT], 0 , GD_KT, entry_gpfault, 0);
f0103f54:	b8 a0 44 10 f0       	mov    $0xf01044a0,%eax
f0103f59:	66 a3 a8 7b 18 f0    	mov    %ax,0xf0187ba8
f0103f5f:	66 c7 05 aa 7b 18 f0 	movw   $0x8,0xf0187baa
f0103f66:	08 00 
f0103f68:	c6 05 ac 7b 18 f0 00 	movb   $0x0,0xf0187bac
f0103f6f:	c6 05 ad 7b 18 f0 8e 	movb   $0x8e,0xf0187bad
f0103f76:	c1 e8 10             	shr    $0x10,%eax
f0103f79:	66 a3 ae 7b 18 f0    	mov    %ax,0xf0187bae
	SETGATE(idt[T_PGFLT], 0 , GD_KT, entry_pgfault, 0);
f0103f7f:	b8 a4 44 10 f0       	mov    $0xf01044a4,%eax
f0103f84:	66 a3 b0 7b 18 f0    	mov    %ax,0xf0187bb0
f0103f8a:	66 c7 05 b2 7b 18 f0 	movw   $0x8,0xf0187bb2
f0103f91:	08 00 
f0103f93:	c6 05 b4 7b 18 f0 00 	movb   $0x0,0xf0187bb4
f0103f9a:	c6 05 b5 7b 18 f0 8e 	movb   $0x8e,0xf0187bb5
f0103fa1:	c1 e8 10             	shr    $0x10,%eax
f0103fa4:	66 a3 b6 7b 18 f0    	mov    %ax,0xf0187bb6
	SETGATE(idt[T_FPERR], 0 , GD_KT, entry_fp_err, 0);
f0103faa:	b8 ac 44 10 f0       	mov    $0xf01044ac,%eax
f0103faf:	66 a3 c0 7b 18 f0    	mov    %ax,0xf0187bc0
f0103fb5:	66 c7 05 c2 7b 18 f0 	movw   $0x8,0xf0187bc2
f0103fbc:	08 00 
f0103fbe:	c6 05 c4 7b 18 f0 00 	movb   $0x0,0xf0187bc4
f0103fc5:	c6 05 c5 7b 18 f0 8e 	movb   $0x8e,0xf0187bc5
f0103fcc:	c1 e8 10             	shr    $0x10,%eax
f0103fcf:	66 a3 c6 7b 18 f0    	mov    %ax,0xf0187bc6
	SETGATE(idt[T_ALIGN], 0 , GD_KT, entry_align_chk, 0);
f0103fd5:	b8 b2 44 10 f0       	mov    $0xf01044b2,%eax
f0103fda:	66 a3 c8 7b 18 f0    	mov    %ax,0xf0187bc8
f0103fe0:	66 c7 05 ca 7b 18 f0 	movw   $0x8,0xf0187bca
f0103fe7:	08 00 
f0103fe9:	c6 05 cc 7b 18 f0 00 	movb   $0x0,0xf0187bcc
f0103ff0:	c6 05 cd 7b 18 f0 8e 	movb   $0x8e,0xf0187bcd
f0103ff7:	c1 e8 10             	shr    $0x10,%eax
f0103ffa:	66 a3 ce 7b 18 f0    	mov    %ax,0xf0187bce
	SETGATE(idt[T_MCHK], 0 , GD_KT, entry_mach_chk, 0);
f0104000:	b8 b8 44 10 f0       	mov    $0xf01044b8,%eax
f0104005:	66 a3 d0 7b 18 f0    	mov    %ax,0xf0187bd0
f010400b:	66 c7 05 d2 7b 18 f0 	movw   $0x8,0xf0187bd2
f0104012:	08 00 
f0104014:	c6 05 d4 7b 18 f0 00 	movb   $0x0,0xf0187bd4
f010401b:	c6 05 d5 7b 18 f0 8e 	movb   $0x8e,0xf0187bd5
f0104022:	c1 e8 10             	shr    $0x10,%eax
f0104025:	66 a3 d6 7b 18 f0    	mov    %ax,0xf0187bd6
	SETGATE(idt[T_SIMDERR], 0 , GD_KT, entry_simd_fp_err, 0);
f010402b:	b8 be 44 10 f0       	mov    $0xf01044be,%eax
f0104030:	66 a3 d8 7b 18 f0    	mov    %ax,0xf0187bd8
f0104036:	66 c7 05 da 7b 18 f0 	movw   $0x8,0xf0187bda
f010403d:	08 00 
f010403f:	c6 05 dc 7b 18 f0 00 	movb   $0x0,0xf0187bdc
f0104046:	c6 05 dd 7b 18 f0 8e 	movb   $0x8e,0xf0187bdd
f010404d:	c1 e8 10             	shr    $0x10,%eax
f0104050:	66 a3 de 7b 18 f0    	mov    %ax,0xf0187bde
	SETGATE(idt[T_SYSCALL], 0 , GD_KT, entry_sys_call, 3);
f0104056:	b8 c4 44 10 f0       	mov    $0xf01044c4,%eax
f010405b:	66 a3 c0 7c 18 f0    	mov    %ax,0xf0187cc0
f0104061:	66 c7 05 c2 7c 18 f0 	movw   $0x8,0xf0187cc2
f0104068:	08 00 
f010406a:	c6 05 c4 7c 18 f0 00 	movb   $0x0,0xf0187cc4
f0104071:	c6 05 c5 7c 18 f0 ee 	movb   $0xee,0xf0187cc5
f0104078:	c1 e8 10             	shr    $0x10,%eax
f010407b:	66 a3 c6 7c 18 f0    	mov    %ax,0xf0187cc6

	// Per-CPU setup 
	trap_init_percpu();
f0104081:	e8 6a fc ff ff       	call   f0103cf0 <trap_init_percpu>
}
f0104086:	5d                   	pop    %ebp
f0104087:	c3                   	ret    

f0104088 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104088:	55                   	push   %ebp
f0104089:	89 e5                	mov    %esp,%ebp
f010408b:	53                   	push   %ebx
f010408c:	83 ec 14             	sub    $0x14,%esp
f010408f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104092:	8b 03                	mov    (%ebx),%eax
f0104094:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104098:	c7 04 24 f4 69 10 f0 	movl   $0xf01069f4,(%esp)
f010409f:	e8 07 fc ff ff       	call   f0103cab <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01040a4:	8b 43 04             	mov    0x4(%ebx),%eax
f01040a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040ab:	c7 04 24 03 6a 10 f0 	movl   $0xf0106a03,(%esp)
f01040b2:	e8 f4 fb ff ff       	call   f0103cab <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01040b7:	8b 43 08             	mov    0x8(%ebx),%eax
f01040ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040be:	c7 04 24 12 6a 10 f0 	movl   $0xf0106a12,(%esp)
f01040c5:	e8 e1 fb ff ff       	call   f0103cab <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01040ca:	8b 43 0c             	mov    0xc(%ebx),%eax
f01040cd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040d1:	c7 04 24 21 6a 10 f0 	movl   $0xf0106a21,(%esp)
f01040d8:	e8 ce fb ff ff       	call   f0103cab <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01040dd:	8b 43 10             	mov    0x10(%ebx),%eax
f01040e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040e4:	c7 04 24 30 6a 10 f0 	movl   $0xf0106a30,(%esp)
f01040eb:	e8 bb fb ff ff       	call   f0103cab <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01040f0:	8b 43 14             	mov    0x14(%ebx),%eax
f01040f3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040f7:	c7 04 24 3f 6a 10 f0 	movl   $0xf0106a3f,(%esp)
f01040fe:	e8 a8 fb ff ff       	call   f0103cab <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104103:	8b 43 18             	mov    0x18(%ebx),%eax
f0104106:	89 44 24 04          	mov    %eax,0x4(%esp)
f010410a:	c7 04 24 4e 6a 10 f0 	movl   $0xf0106a4e,(%esp)
f0104111:	e8 95 fb ff ff       	call   f0103cab <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104116:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104119:	89 44 24 04          	mov    %eax,0x4(%esp)
f010411d:	c7 04 24 5d 6a 10 f0 	movl   $0xf0106a5d,(%esp)
f0104124:	e8 82 fb ff ff       	call   f0103cab <cprintf>
}
f0104129:	83 c4 14             	add    $0x14,%esp
f010412c:	5b                   	pop    %ebx
f010412d:	5d                   	pop    %ebp
f010412e:	c3                   	ret    

f010412f <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f010412f:	55                   	push   %ebp
f0104130:	89 e5                	mov    %esp,%ebp
f0104132:	56                   	push   %esi
f0104133:	53                   	push   %ebx
f0104134:	83 ec 10             	sub    $0x10,%esp
f0104137:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f010413a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010413e:	c7 04 24 93 6b 10 f0 	movl   $0xf0106b93,(%esp)
f0104145:	e8 61 fb ff ff       	call   f0103cab <cprintf>
	print_regs(&tf->tf_regs);
f010414a:	89 1c 24             	mov    %ebx,(%esp)
f010414d:	e8 36 ff ff ff       	call   f0104088 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104152:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104156:	89 44 24 04          	mov    %eax,0x4(%esp)
f010415a:	c7 04 24 6c 6a 10 f0 	movl   $0xf0106a6c,(%esp)
f0104161:	e8 45 fb ff ff       	call   f0103cab <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104166:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010416a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010416e:	c7 04 24 7f 6a 10 f0 	movl   $0xf0106a7f,(%esp)
f0104175:	e8 31 fb ff ff       	call   f0103cab <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010417a:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f010417d:	83 f8 13             	cmp    $0x13,%eax
f0104180:	77 09                	ja     f010418b <print_trapframe+0x5c>
		return excnames[trapno];
f0104182:	8b 14 85 80 6d 10 f0 	mov    -0xfef9280(,%eax,4),%edx
f0104189:	eb 0f                	jmp    f010419a <print_trapframe+0x6b>
	if (trapno == T_SYSCALL)
f010418b:	ba a1 6a 10 f0       	mov    $0xf0106aa1,%edx
f0104190:	83 f8 30             	cmp    $0x30,%eax
f0104193:	74 05                	je     f010419a <print_trapframe+0x6b>
f0104195:	ba 92 6a 10 f0       	mov    $0xf0106a92,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010419a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010419e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01041a2:	c7 04 24 ad 6a 10 f0 	movl   $0xf0106aad,(%esp)
f01041a9:	e8 fd fa ff ff       	call   f0103cab <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01041ae:	3b 1d a8 83 18 f0    	cmp    0xf01883a8,%ebx
f01041b4:	75 19                	jne    f01041cf <print_trapframe+0xa0>
f01041b6:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01041ba:	75 13                	jne    f01041cf <print_trapframe+0xa0>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01041bc:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01041bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01041c3:	c7 04 24 bf 6a 10 f0 	movl   $0xf0106abf,(%esp)
f01041ca:	e8 dc fa ff ff       	call   f0103cab <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f01041cf:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01041d2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01041d6:	c7 04 24 ce 6a 10 f0 	movl   $0xf0106ace,(%esp)
f01041dd:	e8 c9 fa ff ff       	call   f0103cab <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01041e2:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01041e6:	75 47                	jne    f010422f <print_trapframe+0x100>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01041e8:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01041eb:	be e8 6a 10 f0       	mov    $0xf0106ae8,%esi
f01041f0:	a8 01                	test   $0x1,%al
f01041f2:	75 05                	jne    f01041f9 <print_trapframe+0xca>
f01041f4:	be dc 6a 10 f0       	mov    $0xf0106adc,%esi
f01041f9:	b9 f8 6a 10 f0       	mov    $0xf0106af8,%ecx
f01041fe:	a8 02                	test   $0x2,%al
f0104200:	75 05                	jne    f0104207 <print_trapframe+0xd8>
f0104202:	b9 f3 6a 10 f0       	mov    $0xf0106af3,%ecx
f0104207:	ba fe 6a 10 f0       	mov    $0xf0106afe,%edx
f010420c:	a8 04                	test   $0x4,%al
f010420e:	75 05                	jne    f0104215 <print_trapframe+0xe6>
f0104210:	ba be 6b 10 f0       	mov    $0xf0106bbe,%edx
f0104215:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104219:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010421d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104221:	c7 04 24 03 6b 10 f0 	movl   $0xf0106b03,(%esp)
f0104228:	e8 7e fa ff ff       	call   f0103cab <cprintf>
f010422d:	eb 0c                	jmp    f010423b <print_trapframe+0x10c>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f010422f:	c7 04 24 a8 67 10 f0 	movl   $0xf01067a8,(%esp)
f0104236:	e8 70 fa ff ff       	call   f0103cab <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010423b:	8b 43 30             	mov    0x30(%ebx),%eax
f010423e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104242:	c7 04 24 12 6b 10 f0 	movl   $0xf0106b12,(%esp)
f0104249:	e8 5d fa ff ff       	call   f0103cab <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010424e:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104252:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104256:	c7 04 24 21 6b 10 f0 	movl   $0xf0106b21,(%esp)
f010425d:	e8 49 fa ff ff       	call   f0103cab <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104262:	8b 43 38             	mov    0x38(%ebx),%eax
f0104265:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104269:	c7 04 24 34 6b 10 f0 	movl   $0xf0106b34,(%esp)
f0104270:	e8 36 fa ff ff       	call   f0103cab <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104275:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104279:	74 27                	je     f01042a2 <print_trapframe+0x173>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010427b:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010427e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104282:	c7 04 24 43 6b 10 f0 	movl   $0xf0106b43,(%esp)
f0104289:	e8 1d fa ff ff       	call   f0103cab <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010428e:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104292:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104296:	c7 04 24 52 6b 10 f0 	movl   $0xf0106b52,(%esp)
f010429d:	e8 09 fa ff ff       	call   f0103cab <cprintf>
	}
}
f01042a2:	83 c4 10             	add    $0x10,%esp
f01042a5:	5b                   	pop    %ebx
f01042a6:	5e                   	pop    %esi
f01042a7:	5d                   	pop    %ebp
f01042a8:	c3                   	ret    

f01042a9 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01042a9:	55                   	push   %ebp
f01042aa:	89 e5                	mov    %esp,%ebp
f01042ac:	53                   	push   %ebx
f01042ad:	83 ec 14             	sub    $0x14,%esp
f01042b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01042b3:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if(tf->tf_cs == GD_KT) {
f01042b6:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f01042bb:	75 1c                	jne    f01042d9 <page_fault_handler+0x30>
		panic("kern/trap.c:74: kernel page fault\n");
f01042bd:	c7 44 24 08 08 6d 10 	movl   $0xf0106d08,0x8(%esp)
f01042c4:	f0 
f01042c5:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
f01042cc:	00 
f01042cd:	c7 04 24 65 6b 10 f0 	movl   $0xf0106b65,(%esp)
f01042d4:	e8 ac bd ff ff       	call   f0100085 <_panic>
	}
	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01042d9:	8b 53 30             	mov    0x30(%ebx),%edx
f01042dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01042e0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01042e4:	a1 20 7b 18 f0       	mov    0xf0187b20,%eax
f01042e9:	8b 40 48             	mov    0x48(%eax),%eax
f01042ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042f0:	c7 04 24 2c 6d 10 f0 	movl   $0xf0106d2c,(%esp)
f01042f7:	e8 af f9 ff ff       	call   f0103cab <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01042fc:	89 1c 24             	mov    %ebx,(%esp)
f01042ff:	e8 2b fe ff ff       	call   f010412f <print_trapframe>
	env_destroy(curenv);
f0104304:	a1 20 7b 18 f0       	mov    0xf0187b20,%eax
f0104309:	89 04 24             	mov    %eax,(%esp)
f010430c:	e8 cb f5 ff ff       	call   f01038dc <env_destroy>
}
f0104311:	83 c4 14             	add    $0x14,%esp
f0104314:	5b                   	pop    %ebx
f0104315:	5d                   	pop    %ebp
f0104316:	c3                   	ret    

f0104317 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104317:	55                   	push   %ebp
f0104318:	89 e5                	mov    %esp,%ebp
f010431a:	57                   	push   %edi
f010431b:	56                   	push   %esi
f010431c:	83 ec 10             	sub    $0x10,%esp
f010431f:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104322:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104323:	9c                   	pushf  
f0104324:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104325:	f6 c4 02             	test   $0x2,%ah
f0104328:	74 24                	je     f010434e <trap+0x37>
f010432a:	c7 44 24 0c 71 6b 10 	movl   $0xf0106b71,0xc(%esp)
f0104331:	f0 
f0104332:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0104339:	f0 
f010433a:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
f0104341:	00 
f0104342:	c7 04 24 65 6b 10 f0 	movl   $0xf0106b65,(%esp)
f0104349:	e8 37 bd ff ff       	call   f0100085 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f010434e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104352:	c7 04 24 8a 6b 10 f0 	movl   $0xf0106b8a,(%esp)
f0104359:	e8 4d f9 ff ff       	call   f0103cab <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f010435e:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104362:	83 e0 03             	and    $0x3,%eax
f0104365:	83 f8 03             	cmp    $0x3,%eax
f0104368:	75 3c                	jne    f01043a6 <trap+0x8f>
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		assert(curenv);
f010436a:	a1 20 7b 18 f0       	mov    0xf0187b20,%eax
f010436f:	85 c0                	test   %eax,%eax
f0104371:	75 24                	jne    f0104397 <trap+0x80>
f0104373:	c7 44 24 0c a5 6b 10 	movl   $0xf0106ba5,0xc(%esp)
f010437a:	f0 
f010437b:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0104382:	f0 
f0104383:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
f010438a:	00 
f010438b:	c7 04 24 65 6b 10 f0 	movl   $0xf0106b65,(%esp)
f0104392:	e8 ee bc ff ff       	call   f0100085 <_panic>
		curenv->env_tf = *tf;
f0104397:	b9 11 00 00 00       	mov    $0x11,%ecx
f010439c:	89 c7                	mov    %eax,%edi
f010439e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01043a0:	8b 35 20 7b 18 f0    	mov    0xf0187b20,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01043a6:	89 35 a8 83 18 f0    	mov    %esi,0xf01883a8
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	int ret;
	
	switch(tf->tf_trapno) {
f01043ac:	8b 46 28             	mov    0x28(%esi),%eax
f01043af:	83 f8 03             	cmp    $0x3,%eax
f01043b2:	74 0f                	je     f01043c3 <trap+0xac>
f01043b4:	83 f8 0e             	cmp    $0xe,%eax
f01043b7:	75 12                	jne    f01043cb <trap+0xb4>
		case T_PGFLT:
			page_fault_handler(tf);
f01043b9:	89 34 24             	mov    %esi,(%esp)
f01043bc:	e8 e8 fe ff ff       	call   f01042a9 <page_fault_handler>
f01043c1:	eb 08                	jmp    f01043cb <trap+0xb4>
			break;
		case T_BRKPT:
			monitor(tf);
f01043c3:	89 34 24             	mov    %esi,(%esp)
f01043c6:	e8 09 c4 ff ff       	call   f01007d4 <monitor>
		default:
			break;

	}
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01043cb:	89 34 24             	mov    %esi,(%esp)
f01043ce:	e8 5c fd ff ff       	call   f010412f <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01043d3:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01043d8:	75 1c                	jne    f01043f6 <trap+0xdf>
		panic("unhandled trap in kernel");
f01043da:	c7 44 24 08 ac 6b 10 	movl   $0xf0106bac,0x8(%esp)
f01043e1:	f0 
f01043e2:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
f01043e9:	00 
f01043ea:	c7 04 24 65 6b 10 f0 	movl   $0xf0106b65,(%esp)
f01043f1:	e8 8f bc ff ff       	call   f0100085 <_panic>
	else {
		env_destroy(curenv);
f01043f6:	a1 20 7b 18 f0       	mov    0xf0187b20,%eax
f01043fb:	89 04 24             	mov    %eax,(%esp)
f01043fe:	e8 d9 f4 ff ff       	call   f01038dc <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0104403:	a1 20 7b 18 f0       	mov    0xf0187b20,%eax
f0104408:	85 c0                	test   %eax,%eax
f010440a:	74 06                	je     f0104412 <trap+0xfb>
f010440c:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104410:	74 24                	je     f0104436 <trap+0x11f>
f0104412:	c7 44 24 0c 50 6d 10 	movl   $0xf0106d50,0xc(%esp)
f0104419:	f0 
f010441a:	c7 44 24 08 f3 65 10 	movl   $0xf01065f3,0x8(%esp)
f0104421:	f0 
f0104422:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
f0104429:	00 
f010442a:	c7 04 24 65 6b 10 f0 	movl   $0xf0106b65,(%esp)
f0104431:	e8 4f bc ff ff       	call   f0100085 <_panic>
	env_run(curenv);
f0104436:	89 04 24             	mov    %eax,(%esp)
f0104439:	e8 29 f2 ff ff       	call   f0103667 <env_run>
	...

f0104440 <entry_div_err>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
	TRAPHANDLER_NOEC(entry_div_err, T_DIVIDE);
f0104440:	6a 00                	push   $0x0
f0104442:	6a 00                	push   $0x0
f0104444:	e9 c1 00 00 00       	jmp    f010450a <_alltraps>
f0104449:	90                   	nop

f010444a <entry_deb_exc>:
	TRAPHANDLER_NOEC(entry_deb_exc, T_DEBUG);
f010444a:	6a 00                	push   $0x0
f010444c:	6a 01                	push   $0x1
f010444e:	e9 b7 00 00 00       	jmp    f010450a <_alltraps>
f0104453:	90                   	nop

f0104454 <entry_nmi>:
	TRAPHANDLER_NOEC(entry_nmi, T_NMI);
f0104454:	6a 00                	push   $0x0
f0104456:	6a 02                	push   $0x2
f0104458:	e9 ad 00 00 00       	jmp    f010450a <_alltraps>
f010445d:	90                   	nop

f010445e <entry_brkpt>:
	TRAPHANDLER_NOEC(entry_brkpt, T_BRKPT);
f010445e:	6a 00                	push   $0x0
f0104460:	6a 03                	push   $0x3
f0104462:	e9 a3 00 00 00       	jmp    f010450a <_alltraps>
f0104467:	90                   	nop

f0104468 <entry_ovflow>:
	TRAPHANDLER_NOEC(entry_ovflow, T_OFLOW);
f0104468:	6a 00                	push   $0x0
f010446a:	6a 04                	push   $0x4
f010446c:	e9 99 00 00 00       	jmp    f010450a <_alltraps>
f0104471:	90                   	nop

f0104472 <entry_bound>:
	TRAPHANDLER_NOEC(entry_bound, T_BOUND);
f0104472:	6a 00                	push   $0x0
f0104474:	6a 05                	push   $0x5
f0104476:	e9 8f 00 00 00       	jmp    f010450a <_alltraps>
f010447b:	90                   	nop

f010447c <entry_illop>:
	TRAPHANDLER_NOEC(entry_illop, T_ILLOP);
f010447c:	6a 00                	push   $0x0
f010447e:	6a 06                	push   $0x6
f0104480:	e9 85 00 00 00       	jmp    f010450a <_alltraps>
f0104485:	90                   	nop

f0104486 <entry_dev>:
	TRAPHANDLER_NOEC(entry_dev, T_DEVICE);
f0104486:	6a 00                	push   $0x0
f0104488:	6a 07                	push   $0x7
f010448a:	eb 7e                	jmp    f010450a <_alltraps>

f010448c <entry_dfault>:
	TRAPHANDLER(entry_dfault, T_DBLFLT);
f010448c:	6a 08                	push   $0x8
f010448e:	eb 7a                	jmp    f010450a <_alltraps>

f0104490 <entry_copboc>:
	TRAPHANDLER(entry_copboc, -1); //9
f0104490:	6a ff                	push   $0xffffffff
f0104492:	eb 76                	jmp    f010450a <_alltraps>

f0104494 <entry_tss>:
	TRAPHANDLER(entry_tss, T_TSS);
f0104494:	6a 0a                	push   $0xa
f0104496:	eb 72                	jmp    f010450a <_alltraps>

f0104498 <entry_segnp>:
	TRAPHANDLER(entry_segnp, T_SEGNP);
f0104498:	6a 0b                	push   $0xb
f010449a:	eb 6e                	jmp    f010450a <_alltraps>

f010449c <entry_stack>:
	TRAPHANDLER(entry_stack, T_STACK);
f010449c:	6a 0c                	push   $0xc
f010449e:	eb 6a                	jmp    f010450a <_alltraps>

f01044a0 <entry_gpfault>:
	TRAPHANDLER(entry_gpfault, T_GPFLT);
f01044a0:	6a 0d                	push   $0xd
f01044a2:	eb 66                	jmp    f010450a <_alltraps>

f01044a4 <entry_pgfault>:
	TRAPHANDLER(entry_pgfault, T_PGFLT);
f01044a4:	6a 0e                	push   $0xe
f01044a6:	eb 62                	jmp    f010450a <_alltraps>

f01044a8 <entry_res>:
	TRAPHANDLER(entry_res, -1); //15
f01044a8:	6a ff                	push   $0xffffffff
f01044aa:	eb 5e                	jmp    f010450a <_alltraps>

f01044ac <entry_fp_err>:
	TRAPHANDLER_NOEC(entry_fp_err, T_FPERR);
f01044ac:	6a 00                	push   $0x0
f01044ae:	6a 10                	push   $0x10
f01044b0:	eb 58                	jmp    f010450a <_alltraps>

f01044b2 <entry_align_chk>:
	TRAPHANDLER_NOEC(entry_align_chk, T_ALIGN);
f01044b2:	6a 00                	push   $0x0
f01044b4:	6a 11                	push   $0x11
f01044b6:	eb 52                	jmp    f010450a <_alltraps>

f01044b8 <entry_mach_chk>:
	TRAPHANDLER_NOEC(entry_mach_chk, T_MCHK);
f01044b8:	6a 00                	push   $0x0
f01044ba:	6a 12                	push   $0x12
f01044bc:	eb 4c                	jmp    f010450a <_alltraps>

f01044be <entry_simd_fp_err>:
	TRAPHANDLER_NOEC(entry_simd_fp_err, T_SIMDERR);
f01044be:	6a 00                	push   $0x0
f01044c0:	6a 13                	push   $0x13
f01044c2:	eb 46                	jmp    f010450a <_alltraps>

f01044c4 <entry_sys_call>:
	TRAPHANDLER_NOEC(entry_sys_call, T_SYSCALL);
f01044c4:	6a 00                	push   $0x0
f01044c6:	6a 30                	push   $0x30
f01044c8:	eb 40                	jmp    f010450a <_alltraps>

f01044ca <sysenter_handler>:
.align 2;
sysenter_handler:
/*
 * Lab 3: Your code here for system call handling
 */
	pushw $0x0
f01044ca:	66 6a 00             	pushw  $0x0
	pushw $GD_UD | 3
f01044cd:	66 6a 23             	pushw  $0x23
	pushl %ebp
f01044d0:	55                   	push   %ebp
	pushfl
f01044d1:	9c                   	pushf  

	pushw $0x0
f01044d2:	66 6a 00             	pushw  $0x0
	pushw $GD_UT | 3
f01044d5:	66 6a 1b             	pushw  $0x1b
	pushl %esi
f01044d8:	56                   	push   %esi
	pushl $0
f01044d9:	6a 00                	push   $0x0
	pushl $0
f01044db:	6a 00                	push   $0x0

	pushw $0x0
f01044dd:	66 6a 00             	pushw  $0x0

	pushw %ds
f01044e0:	66 1e                	pushw  %ds

	pushw $0x0
f01044e2:	66 6a 00             	pushw  $0x0
	pushw %es
f01044e5:	66 06                	pushw  %es

	pushal
f01044e7:	60                   	pusha  

	mov $GD_KD, %ax
f01044e8:	66 b8 10 00          	mov    $0x10,%ax
	mov %ax, %ds
f01044ec:	8e d8                	mov    %eax,%ds
	mov %ax, %es
f01044ee:	8e c0                	mov    %eax,%es
	
	pushl %esp
f01044f0:	54                   	push   %esp

	call syscall_dummy
f01044f1:	e8 bb 01 00 00       	call   f01046b1 <syscall_dummy>

	popl %esp
f01044f6:	5c                   	pop    %esp

	popal
f01044f7:	61                   	popa   

	popl %es
f01044f8:	07                   	pop    %es

	popl %ds
f01044f9:	1f                   	pop    %ds

	movl %ebp, %ecx
f01044fa:	89 e9                	mov    %ebp,%ecx
	movl %esi, %edx
f01044fc:	89 f2                	mov    %esi,%edx

	sysexit
f01044fe:	0f 35                	sysexit 
	
	pushl %edi
f0104500:	57                   	push   %edi
	pushl %ebx
f0104501:	53                   	push   %ebx
	pushl %ecx
f0104502:	51                   	push   %ecx
	pushl %edx
f0104503:	52                   	push   %edx
	pushl %eax
f0104504:	50                   	push   %eax
	call syscall
f0104505:	e8 26 00 00 00       	call   f0104530 <syscall>

f010450a <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushw $0x0
f010450a:	66 6a 00             	pushw  $0x0
	pushw %ds
f010450d:	66 1e                	pushw  %ds
	pushw $0x0
f010450f:	66 6a 00             	pushw  $0x0
	pushw %ss
f0104512:	66 16                	pushw  %ss
	pushal
f0104514:	60                   	pusha  

	movl $GD_KD, %eax
f0104515:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f010451a:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f010451c:	8e c0                	mov    %eax,%es

	pushl %esp
f010451e:	54                   	push   %esp
	call trap
f010451f:	e8 f3 fd ff ff       	call   f0104317 <trap>
	...

f0104530 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104530:	55                   	push   %ebp
f0104531:	89 e5                	mov    %esp,%ebp
f0104533:	83 ec 28             	sub    $0x28,%esp
f0104536:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0104539:	89 75 fc             	mov    %esi,-0x4(%ebp)
f010453c:	8b 55 08             	mov    0x8(%ebp),%edx
f010453f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104542:	8b 75 10             	mov    0x10(%ebp),%esi
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch(syscallno){
f0104545:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010454a:	83 fa 04             	cmp    $0x4,%edx
f010454d:	0f 87 54 01 00 00    	ja     f01046a7 <syscall+0x177>
f0104553:	ff 24 95 18 6e 10 f0 	jmp    *-0xfef91e8(,%edx,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, (void *)s, len, PTE_U);
f010455a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104561:	00 
f0104562:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104566:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010456a:	a1 20 7b 18 f0       	mov    0xf0187b20,%eax
f010456f:	89 04 24             	mov    %eax,(%esp)
f0104572:	e8 5c cb ff ff       	call   f01010d3 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104577:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010457b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010457f:	c7 04 24 d0 6d 10 f0 	movl   $0xf0106dd0,(%esp)
f0104586:	e8 20 f7 ff ff       	call   f0103cab <cprintf>
f010458b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104590:	e9 12 01 00 00       	jmp    f01046a7 <syscall+0x177>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104595:	e8 a5 bc ff ff       	call   f010023f <cons_getc>
	switch(syscallno){
		case SYS_cputs:
			sys_cputs((const char*)a1, (size_t)a2);
			break;
		case SYS_cgetc:
			return sys_cgetc();
f010459a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01045a0:	e9 02 01 00 00       	jmp    f01046a7 <syscall+0x177>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01045a5:	a1 20 7b 18 f0       	mov    0xf0187b20,%eax
f01045aa:	8b 40 48             	mov    0x48(%eax),%eax
			break;
		case SYS_cgetc:
			return sys_cgetc();
			break;
		case SYS_getenvid:
			return sys_getenvid();
f01045ad:	e9 f5 00 00 00       	jmp    f01046a7 <syscall+0x177>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01045b2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01045b9:	00 
f01045ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01045bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045c1:	89 1c 24             	mov    %ebx,(%esp)
f01045c4:	e8 77 ef ff ff       	call   f0103540 <envid2env>
f01045c9:	85 c0                	test   %eax,%eax
f01045cb:	0f 88 d6 00 00 00    	js     f01046a7 <syscall+0x177>
		return r;
	if (e == curenv)
f01045d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01045d4:	8b 15 20 7b 18 f0    	mov    0xf0187b20,%edx
f01045da:	39 d0                	cmp    %edx,%eax
f01045dc:	75 15                	jne    f01045f3 <syscall+0xc3>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01045de:	8b 40 48             	mov    0x48(%eax),%eax
f01045e1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045e5:	c7 04 24 d5 6d 10 f0 	movl   $0xf0106dd5,(%esp)
f01045ec:	e8 ba f6 ff ff       	call   f0103cab <cprintf>
f01045f1:	eb 1a                	jmp    f010460d <syscall+0xdd>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01045f3:	8b 40 48             	mov    0x48(%eax),%eax
f01045f6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01045fa:	8b 42 48             	mov    0x48(%edx),%eax
f01045fd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104601:	c7 04 24 f0 6d 10 f0 	movl   $0xf0106df0,(%esp)
f0104608:	e8 9e f6 ff ff       	call   f0103cab <cprintf>
	env_destroy(e);
f010460d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104610:	89 04 24             	mov    %eax,(%esp)
f0104613:	e8 c4 f2 ff ff       	call   f01038dc <env_destroy>
f0104618:	b8 00 00 00 00       	mov    $0x0,%eax
f010461d:	e9 85 00 00 00       	jmp    f01046a7 <syscall+0x177>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104622:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0104628:	77 20                	ja     f010464a <syscall+0x11a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010462a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010462e:	c7 44 24 08 0c 5e 10 	movl   $0xf0105e0c,0x8(%esp)
f0104635:	f0 
f0104636:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
f010463d:	00 
f010463e:	c7 04 24 08 6e 10 f0 	movl   $0xf0106e08,(%esp)
f0104645:	e8 3b ba ff ff       	call   f0100085 <_panic>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010464a:	81 c3 00 00 00 10    	add    $0x10000000,%ebx
f0104650:	c1 eb 0c             	shr    $0xc,%ebx
f0104653:	3b 1d c4 87 18 f0    	cmp    0xf01887c4,%ebx
f0104659:	72 1c                	jb     f0104677 <syscall+0x147>
		panic("pa2page called with invalid pa");
f010465b:	c7 44 24 08 8c 5e 10 	movl   $0xf0105e8c,0x8(%esp)
f0104662:	f0 
f0104663:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f010466a:	00 
f010466b:	c7 04 24 d9 65 10 f0 	movl   $0xf01065d9,(%esp)
f0104672:	e8 0e ba ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f0104677:	c1 e3 03             	shl    $0x3,%ebx
static int
sys_map_kernel_page(void* kpage, void* va)
{
	int r;
	struct Page* p = pa2page(PADDR(kpage));
	if(p ==NULL)
f010467a:	b8 03 00 00 00       	mov    $0x3,%eax
f010467f:	03 1d cc 87 18 f0    	add    0xf01887cc,%ebx
f0104685:	74 20                	je     f01046a7 <syscall+0x177>
		return E_INVAL;
	r = page_insert(curenv->env_pgdir, p, va, PTE_U | PTE_W);
f0104687:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010468e:	00 
f010468f:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104693:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104697:	a1 20 7b 18 f0       	mov    0xf0187b20,%eax
f010469c:	8b 40 5c             	mov    0x5c(%eax),%eax
f010469f:	89 04 24             	mov    %eax,(%esp)
f01046a2:	e8 46 cb ff ff       	call   f01011ed <page_insert>
		default:
			return -E_INVAL;
	}
	return 0;
//	panic("syscall not implemented");
}
f01046a7:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01046aa:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01046ad:	89 ec                	mov    %ebp,%esp
f01046af:	5d                   	pop    %ebp
f01046b0:	c3                   	ret    

f01046b1 <syscall_dummy>:

void
syscall_dummy(struct Trapframe *tf){
f01046b1:	55                   	push   %ebp
f01046b2:	89 e5                	mov    %esp,%ebp
f01046b4:	83 ec 38             	sub    $0x38,%esp
f01046b7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01046ba:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01046bd:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01046c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	curenv->env_tf = *tf;
f01046c3:	a1 20 7b 18 f0       	mov    0xf0187b20,%eax
f01046c8:	b9 11 00 00 00       	mov    $0x11,%ecx
f01046cd:	89 c7                	mov    %eax,%edi
f01046cf:	89 de                	mov    %ebx,%esi
f01046d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	tf->tf_regs.reg_eax=syscall(tf->tf_regs.reg_eax,
f01046d3:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
f01046da:	00 
f01046db:	8b 03                	mov    (%ebx),%eax
f01046dd:	89 44 24 10          	mov    %eax,0x10(%esp)
f01046e1:	8b 43 10             	mov    0x10(%ebx),%eax
f01046e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01046e8:	8b 43 18             	mov    0x18(%ebx),%eax
f01046eb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01046ef:	8b 43 14             	mov    0x14(%ebx),%eax
f01046f2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046f6:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01046f9:	89 04 24             	mov    %eax,(%esp)
f01046fc:	e8 2f fe ff ff       	call   f0104530 <syscall>
f0104701:	89 43 1c             	mov    %eax,0x1c(%ebx)
							tf->tf_regs.reg_edx,
							tf->tf_regs.reg_ecx,
							tf->tf_regs.reg_ebx,
							tf->tf_regs.reg_edi,0);
	return;
}
f0104704:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104707:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010470a:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010470d:	89 ec                	mov    %ebp,%esp
f010470f:	5d                   	pop    %ebp
f0104710:	c3                   	ret    
	...

f0104720 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104720:	55                   	push   %ebp
f0104721:	89 e5                	mov    %esp,%ebp
f0104723:	57                   	push   %edi
f0104724:	56                   	push   %esi
f0104725:	53                   	push   %ebx
f0104726:	83 ec 14             	sub    $0x14,%esp
f0104729:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010472c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010472f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104732:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104735:	8b 1a                	mov    (%edx),%ebx
f0104737:	8b 01                	mov    (%ecx),%eax
f0104739:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f010473c:	39 c3                	cmp    %eax,%ebx
f010473e:	0f 8f 9c 00 00 00    	jg     f01047e0 <stab_binsearch+0xc0>
f0104744:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f010474b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010474e:	01 d8                	add    %ebx,%eax
f0104750:	89 c7                	mov    %eax,%edi
f0104752:	c1 ef 1f             	shr    $0x1f,%edi
f0104755:	01 c7                	add    %eax,%edi
f0104757:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104759:	39 df                	cmp    %ebx,%edi
f010475b:	7c 33                	jl     f0104790 <stab_binsearch+0x70>
f010475d:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0104760:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104763:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0104768:	39 f0                	cmp    %esi,%eax
f010476a:	0f 84 bc 00 00 00    	je     f010482c <stab_binsearch+0x10c>
f0104770:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
f0104774:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
f0104778:	89 f8                	mov    %edi,%eax
			m--;
f010477a:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010477d:	39 d8                	cmp    %ebx,%eax
f010477f:	7c 0f                	jl     f0104790 <stab_binsearch+0x70>
f0104781:	0f b6 0a             	movzbl (%edx),%ecx
f0104784:	83 ea 0c             	sub    $0xc,%edx
f0104787:	39 f1                	cmp    %esi,%ecx
f0104789:	75 ef                	jne    f010477a <stab_binsearch+0x5a>
f010478b:	e9 9e 00 00 00       	jmp    f010482e <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104790:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104793:	eb 3c                	jmp    f01047d1 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104795:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104798:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f010479a:	8d 5f 01             	lea    0x1(%edi),%ebx
f010479d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01047a4:	eb 2b                	jmp    f01047d1 <stab_binsearch+0xb1>
		} else if (stabs[m].n_value > addr) {
f01047a6:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01047a9:	76 14                	jbe    f01047bf <stab_binsearch+0x9f>
			*region_right = m - 1;
f01047ab:	83 e8 01             	sub    $0x1,%eax
f01047ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01047b1:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01047b4:	89 02                	mov    %eax,(%edx)
f01047b6:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01047bd:	eb 12                	jmp    f01047d1 <stab_binsearch+0xb1>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01047bf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01047c2:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f01047c4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01047c8:	89 c3                	mov    %eax,%ebx
f01047ca:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f01047d1:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f01047d4:	0f 8d 71 ff ff ff    	jge    f010474b <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01047da:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01047de:	75 0f                	jne    f01047ef <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f01047e0:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01047e3:	8b 03                	mov    (%ebx),%eax
f01047e5:	83 e8 01             	sub    $0x1,%eax
f01047e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01047eb:	89 02                	mov    %eax,(%edx)
f01047ed:	eb 57                	jmp    f0104846 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01047ef:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01047f2:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01047f4:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01047f7:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01047f9:	39 c1                	cmp    %eax,%ecx
f01047fb:	7d 28                	jge    f0104825 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f01047fd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104800:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0104803:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0104808:	39 f2                	cmp    %esi,%edx
f010480a:	74 19                	je     f0104825 <stab_binsearch+0x105>
f010480c:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0104810:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		     l--)
f0104814:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104817:	39 c1                	cmp    %eax,%ecx
f0104819:	7d 0a                	jge    f0104825 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f010481b:	0f b6 1a             	movzbl (%edx),%ebx
f010481e:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104821:	39 f3                	cmp    %esi,%ebx
f0104823:	75 ef                	jne    f0104814 <stab_binsearch+0xf4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f0104825:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104828:	89 02                	mov    %eax,(%edx)
f010482a:	eb 1a                	jmp    f0104846 <stab_binsearch+0x126>
	}
}
f010482c:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010482e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104831:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0104834:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104838:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010483b:	0f 82 54 ff ff ff    	jb     f0104795 <stab_binsearch+0x75>
f0104841:	e9 60 ff ff ff       	jmp    f01047a6 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104846:	83 c4 14             	add    $0x14,%esp
f0104849:	5b                   	pop    %ebx
f010484a:	5e                   	pop    %esi
f010484b:	5f                   	pop    %edi
f010484c:	5d                   	pop    %ebp
f010484d:	c3                   	ret    

f010484e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010484e:	55                   	push   %ebp
f010484f:	89 e5                	mov    %esp,%ebp
f0104851:	83 ec 48             	sub    $0x48,%esp
f0104854:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104857:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010485a:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010485d:	8b 75 08             	mov    0x8(%ebp),%esi
f0104860:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104863:	c7 03 2c 6e 10 f0    	movl   $0xf0106e2c,(%ebx)
	info->eip_line = 0;
f0104869:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104870:	c7 43 08 2c 6e 10 f0 	movl   $0xf0106e2c,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104877:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010487e:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104881:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104888:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010488e:	76 1f                	jbe    f01048af <debuginfo_eip+0x61>
f0104890:	bf 79 23 11 f0       	mov    $0xf0112379,%edi
f0104895:	c7 45 d4 39 f5 10 f0 	movl   $0xf010f539,-0x2c(%ebp)
f010489c:	c7 45 cc 38 f5 10 f0 	movl   $0xf010f538,-0x34(%ebp)
f01048a3:	c7 45 d0 c0 70 10 f0 	movl   $0xf01070c0,-0x30(%ebp)
f01048aa:	e9 a9 00 00 00       	jmp    f0104958 <debuginfo_eip+0x10a>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if(user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0) {
f01048af:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01048b6:	00 
f01048b7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01048be:	00 
f01048bf:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f01048c6:	00 
f01048c7:	a1 20 7b 18 f0       	mov    0xf0187b20,%eax
f01048cc:	89 04 24             	mov    %eax,(%esp)
f01048cf:	e8 0f c7 ff ff       	call   f0100fe3 <user_mem_check>
f01048d4:	85 c0                	test   %eax,%eax
f01048d6:	0f 88 df 01 00 00    	js     f0104abb <debuginfo_eip+0x26d>
			return -1;
		}

		stabs = usd->stabs;
f01048dc:	b8 00 00 20 00       	mov    $0x200000,%eax
f01048e1:	8b 10                	mov    (%eax),%edx
f01048e3:	89 55 d0             	mov    %edx,-0x30(%ebp)
		stab_end = usd->stab_end;
f01048e6:	8b 48 04             	mov    0x4(%eax),%ecx
f01048e9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr = usd->stabstr;
f01048ec:	8b 50 08             	mov    0x8(%eax),%edx
f01048ef:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		stabstr_end = usd->stabstr_end;
f01048f2:	8b 78 0c             	mov    0xc(%eax),%edi

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if(user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) < 0
				||user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0) {
f01048f5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01048fc:	00 
f01048fd:	89 c8                	mov    %ecx,%eax
f01048ff:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0104902:	c1 f8 02             	sar    $0x2,%eax
f0104905:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010490b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010490f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104912:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104916:	a1 20 7b 18 f0       	mov    0xf0187b20,%eax
f010491b:	89 04 24             	mov    %eax,(%esp)
f010491e:	e8 c0 c6 ff ff       	call   f0100fe3 <user_mem_check>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if(user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) < 0
f0104923:	85 c0                	test   %eax,%eax
f0104925:	0f 88 90 01 00 00    	js     f0104abb <debuginfo_eip+0x26d>
				||user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0) {
f010492b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104932:	00 
f0104933:	89 f8                	mov    %edi,%eax
f0104935:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0104938:	89 44 24 08          	mov    %eax,0x8(%esp)
f010493c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010493f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104943:	a1 20 7b 18 f0       	mov    0xf0187b20,%eax
f0104948:	89 04 24             	mov    %eax,(%esp)
f010494b:	e8 93 c6 ff ff       	call   f0100fe3 <user_mem_check>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if(user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) < 0
f0104950:	85 c0                	test   %eax,%eax
f0104952:	0f 88 63 01 00 00    	js     f0104abb <debuginfo_eip+0x26d>
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104958:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f010495b:	0f 83 5a 01 00 00    	jae    f0104abb <debuginfo_eip+0x26d>
f0104961:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0104965:	0f 85 50 01 00 00    	jne    f0104abb <debuginfo_eip+0x26d>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010496b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104972:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104975:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0104978:	c1 f8 02             	sar    $0x2,%eax
f010497b:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104981:	83 e8 01             	sub    $0x1,%eax
f0104984:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104987:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010498a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010498d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104991:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0104998:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010499b:	e8 80 fd ff ff       	call   f0104720 <stab_binsearch>
	if (lfile == 0)
f01049a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049a3:	85 c0                	test   %eax,%eax
f01049a5:	0f 84 10 01 00 00    	je     f0104abb <debuginfo_eip+0x26d>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01049ab:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01049ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01049b4:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01049b7:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01049ba:	89 74 24 04          	mov    %esi,0x4(%esp)
f01049be:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01049c5:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01049c8:	e8 53 fd ff ff       	call   f0104720 <stab_binsearch>

	if (lfun <= rfun) {
f01049cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01049d0:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f01049d3:	7f 2a                	jg     f01049ff <debuginfo_eip+0x1b1>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01049d5:	6b c0 0c             	imul   $0xc,%eax,%eax
f01049d8:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01049db:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01049de:	89 fa                	mov    %edi,%edx
f01049e0:	2b 55 d4             	sub    -0x2c(%ebp),%edx
f01049e3:	39 d0                	cmp    %edx,%eax
f01049e5:	73 06                	jae    f01049ed <debuginfo_eip+0x19f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01049e7:	03 45 d4             	add    -0x2c(%ebp),%eax
f01049ea:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01049ed:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01049f0:	6b c6 0c             	imul   $0xc,%esi,%eax
f01049f3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01049f6:	8b 44 08 08          	mov    0x8(%eax,%ecx,1),%eax
f01049fa:	89 43 10             	mov    %eax,0x10(%ebx)
f01049fd:	eb 06                	jmp    f0104a05 <debuginfo_eip+0x1b7>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01049ff:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104a02:	8b 75 e4             	mov    -0x1c(%ebp),%esi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104a05:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0104a0c:	00 
f0104a0d:	8b 43 08             	mov    0x8(%ebx),%eax
f0104a10:	89 04 24             	mov    %eax,(%esp)
f0104a13:	e8 c3 09 00 00       	call   f01053db <strfind>
f0104a18:	2b 43 08             	sub    0x8(%ebx),%eax
f0104a1b:	89 43 0c             	mov    %eax,0xc(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f0104a1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a21:	89 45 cc             	mov    %eax,-0x34(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104a24:	39 c6                	cmp    %eax,%esi
f0104a26:	7c 55                	jl     f0104a7d <debuginfo_eip+0x22f>
	       && stabs[lline].n_type != N_SOL
f0104a28:	6b ce 0c             	imul   $0xc,%esi,%ecx
f0104a2b:	03 4d d0             	add    -0x30(%ebp),%ecx
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104a2e:	0f b6 51 04          	movzbl 0x4(%ecx),%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104a32:	80 fa 84             	cmp    $0x84,%dl
f0104a35:	74 31                	je     f0104a68 <debuginfo_eip+0x21a>
f0104a37:	8d 46 ff             	lea    -0x1(%esi),%eax
f0104a3a:	6b c0 0c             	imul   $0xc,%eax,%eax
f0104a3d:	03 45 d0             	add    -0x30(%ebp),%eax
f0104a40:	eb 16                	jmp    f0104a58 <debuginfo_eip+0x20a>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104a42:	83 ee 01             	sub    $0x1,%esi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104a45:	39 75 cc             	cmp    %esi,-0x34(%ebp)
f0104a48:	7f 33                	jg     f0104a7d <debuginfo_eip+0x22f>
f0104a4a:	89 c1                	mov    %eax,%ecx
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104a4c:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0104a50:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104a53:	80 fa 84             	cmp    $0x84,%dl
f0104a56:	74 10                	je     f0104a68 <debuginfo_eip+0x21a>
f0104a58:	80 fa 64             	cmp    $0x64,%dl
f0104a5b:	75 e5                	jne    f0104a42 <debuginfo_eip+0x1f4>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104a5d:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
f0104a61:	74 df                	je     f0104a42 <debuginfo_eip+0x1f4>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104a63:	3b 75 cc             	cmp    -0x34(%ebp),%esi
f0104a66:	7c 15                	jl     f0104a7d <debuginfo_eip+0x22f>
f0104a68:	6b f6 0c             	imul   $0xc,%esi,%esi
f0104a6b:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0104a6e:	8b 04 16             	mov    (%esi,%edx,1),%eax
f0104a71:	2b 7d d4             	sub    -0x2c(%ebp),%edi
f0104a74:	39 f8                	cmp    %edi,%eax
f0104a76:	73 05                	jae    f0104a7d <debuginfo_eip+0x22f>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104a78:	03 45 d4             	add    -0x2c(%ebp),%eax
f0104a7b:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104a7d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104a80:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104a83:	39 ca                	cmp    %ecx,%edx
f0104a85:	7d 3b                	jge    f0104ac2 <debuginfo_eip+0x274>
		for (lline = lfun + 1;
f0104a87:	8d 42 01             	lea    0x1(%edx),%eax
f0104a8a:	39 c1                	cmp    %eax,%ecx
f0104a8c:	7e 34                	jle    f0104ac2 <debuginfo_eip+0x274>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104a8e:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0104a91:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104a94:	80 7c 31 04 a0       	cmpb   $0xa0,0x4(%ecx,%esi,1)
f0104a99:	75 27                	jne    f0104ac2 <debuginfo_eip+0x274>
f0104a9b:	6b d2 0c             	imul   $0xc,%edx,%edx
f0104a9e:	8d 54 16 1c          	lea    0x1c(%esi,%edx,1),%edx
		     lline++)
			info->eip_fn_narg++;
f0104aa2:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0104aa6:	83 c0 01             	add    $0x1,%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104aa9:	39 45 d8             	cmp    %eax,-0x28(%ebp)
f0104aac:	7e 14                	jle    f0104ac2 <debuginfo_eip+0x274>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104aae:	0f b6 0a             	movzbl (%edx),%ecx
f0104ab1:	83 c2 0c             	add    $0xc,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104ab4:	80 f9 a0             	cmp    $0xa0,%cl
f0104ab7:	74 e9                	je     f0104aa2 <debuginfo_eip+0x254>
f0104ab9:	eb 07                	jmp    f0104ac2 <debuginfo_eip+0x274>
f0104abb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104ac0:	eb 05                	jmp    f0104ac7 <debuginfo_eip+0x279>
f0104ac2:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
}
f0104ac7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104aca:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104acd:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0104ad0:	89 ec                	mov    %ebp,%esp
f0104ad2:	5d                   	pop    %ebp
f0104ad3:	c3                   	ret    
	...

f0104ae0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104ae0:	55                   	push   %ebp
f0104ae1:	89 e5                	mov    %esp,%ebp
f0104ae3:	57                   	push   %edi
f0104ae4:	56                   	push   %esi
f0104ae5:	53                   	push   %ebx
f0104ae6:	83 ec 4c             	sub    $0x4c,%esp
f0104ae9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104aec:	89 d6                	mov    %edx,%esi
f0104aee:	8b 45 08             	mov    0x8(%ebp),%eax
f0104af1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104af4:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104af7:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0104afa:	8b 45 10             	mov    0x10(%ebp),%eax
f0104afd:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104b00:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104b03:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0104b06:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104b0b:	39 d1                	cmp    %edx,%ecx
f0104b0d:	72 15                	jb     f0104b24 <printnum+0x44>
f0104b0f:	77 07                	ja     f0104b18 <printnum+0x38>
f0104b11:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104b14:	39 d0                	cmp    %edx,%eax
f0104b16:	76 0c                	jbe    f0104b24 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104b18:	83 eb 01             	sub    $0x1,%ebx
f0104b1b:	85 db                	test   %ebx,%ebx
f0104b1d:	8d 76 00             	lea    0x0(%esi),%esi
f0104b20:	7f 61                	jg     f0104b83 <printnum+0xa3>
f0104b22:	eb 70                	jmp    f0104b94 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104b24:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0104b28:	83 eb 01             	sub    $0x1,%ebx
f0104b2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104b2f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104b33:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0104b37:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f0104b3b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0104b3e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0104b41:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104b44:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104b48:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104b4f:	00 
f0104b50:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104b53:	89 04 24             	mov    %eax,(%esp)
f0104b56:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104b59:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104b5d:	e8 0e 0b 00 00       	call   f0105670 <__udivdi3>
f0104b62:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104b65:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104b68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104b6c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104b70:	89 04 24             	mov    %eax,(%esp)
f0104b73:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104b77:	89 f2                	mov    %esi,%edx
f0104b79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b7c:	e8 5f ff ff ff       	call   f0104ae0 <printnum>
f0104b81:	eb 11                	jmp    f0104b94 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104b83:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104b87:	89 3c 24             	mov    %edi,(%esp)
f0104b8a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104b8d:	83 eb 01             	sub    $0x1,%ebx
f0104b90:	85 db                	test   %ebx,%ebx
f0104b92:	7f ef                	jg     f0104b83 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104b94:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104b98:	8b 74 24 04          	mov    0x4(%esp),%esi
f0104b9c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104b9f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104ba3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104baa:	00 
f0104bab:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104bae:	89 14 24             	mov    %edx,(%esp)
f0104bb1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104bb4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104bb8:	e8 e3 0b 00 00       	call   f01057a0 <__umoddi3>
f0104bbd:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104bc1:	0f be 80 36 6e 10 f0 	movsbl -0xfef91ca(%eax),%eax
f0104bc8:	89 04 24             	mov    %eax,(%esp)
f0104bcb:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0104bce:	83 c4 4c             	add    $0x4c,%esp
f0104bd1:	5b                   	pop    %ebx
f0104bd2:	5e                   	pop    %esi
f0104bd3:	5f                   	pop    %edi
f0104bd4:	5d                   	pop    %ebp
f0104bd5:	c3                   	ret    

f0104bd6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104bd6:	55                   	push   %ebp
f0104bd7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104bd9:	83 fa 01             	cmp    $0x1,%edx
f0104bdc:	7e 0e                	jle    f0104bec <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104bde:	8b 10                	mov    (%eax),%edx
f0104be0:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104be3:	89 08                	mov    %ecx,(%eax)
f0104be5:	8b 02                	mov    (%edx),%eax
f0104be7:	8b 52 04             	mov    0x4(%edx),%edx
f0104bea:	eb 22                	jmp    f0104c0e <getuint+0x38>
	else if (lflag)
f0104bec:	85 d2                	test   %edx,%edx
f0104bee:	74 10                	je     f0104c00 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104bf0:	8b 10                	mov    (%eax),%edx
f0104bf2:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104bf5:	89 08                	mov    %ecx,(%eax)
f0104bf7:	8b 02                	mov    (%edx),%eax
f0104bf9:	ba 00 00 00 00       	mov    $0x0,%edx
f0104bfe:	eb 0e                	jmp    f0104c0e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104c00:	8b 10                	mov    (%eax),%edx
f0104c02:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104c05:	89 08                	mov    %ecx,(%eax)
f0104c07:	8b 02                	mov    (%edx),%eax
f0104c09:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104c0e:	5d                   	pop    %ebp
f0104c0f:	c3                   	ret    

f0104c10 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104c10:	55                   	push   %ebp
f0104c11:	89 e5                	mov    %esp,%ebp
f0104c13:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104c16:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104c1a:	8b 10                	mov    (%eax),%edx
f0104c1c:	3b 50 04             	cmp    0x4(%eax),%edx
f0104c1f:	73 0a                	jae    f0104c2b <sprintputch+0x1b>
		*b->buf++ = ch;
f0104c21:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104c24:	88 0a                	mov    %cl,(%edx)
f0104c26:	83 c2 01             	add    $0x1,%edx
f0104c29:	89 10                	mov    %edx,(%eax)
}
f0104c2b:	5d                   	pop    %ebp
f0104c2c:	c3                   	ret    

f0104c2d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104c2d:	55                   	push   %ebp
f0104c2e:	89 e5                	mov    %esp,%ebp
f0104c30:	57                   	push   %edi
f0104c31:	56                   	push   %esi
f0104c32:	53                   	push   %ebx
f0104c33:	83 ec 5c             	sub    $0x5c,%esp
f0104c36:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104c39:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104c3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0104c3f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0104c46:	eb 16                	jmp    f0104c5e <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104c48:	85 c0                	test   %eax,%eax
f0104c4a:	0f 84 4f 04 00 00    	je     f010509f <vprintfmt+0x472>
				return;
			putch(ch, putdat);
f0104c50:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104c54:	89 04 24             	mov    %eax,(%esp)
f0104c57:	ff d7                	call   *%edi
f0104c59:	eb 03                	jmp    f0104c5e <vprintfmt+0x31>
f0104c5b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104c5e:	0f b6 03             	movzbl (%ebx),%eax
f0104c61:	83 c3 01             	add    $0x1,%ebx
f0104c64:	83 f8 25             	cmp    $0x25,%eax
f0104c67:	75 df                	jne    f0104c48 <vprintfmt+0x1b>
f0104c69:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
f0104c6d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104c74:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104c7b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0104c82:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104c87:	eb 06                	jmp    f0104c8f <vprintfmt+0x62>
f0104c89:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
f0104c8d:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c8f:	0f b6 13             	movzbl (%ebx),%edx
f0104c92:	0f b6 c2             	movzbl %dl,%eax
f0104c95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104c98:	8d 43 01             	lea    0x1(%ebx),%eax
f0104c9b:	83 ea 23             	sub    $0x23,%edx
f0104c9e:	80 fa 55             	cmp    $0x55,%dl
f0104ca1:	0f 87 db 03 00 00    	ja     f0105082 <vprintfmt+0x455>
f0104ca7:	0f b6 d2             	movzbl %dl,%edx
f0104caa:	ff 24 95 3c 6f 10 f0 	jmp    *-0xfef90c4(,%edx,4)
f0104cb1:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
f0104cb5:	eb d6                	jmp    f0104c8d <vprintfmt+0x60>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104cb7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104cba:	83 ea 30             	sub    $0x30,%edx
f0104cbd:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
f0104cc0:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0104cc3:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0104cc6:	83 fb 09             	cmp    $0x9,%ebx
f0104cc9:	77 4c                	ja     f0104d17 <vprintfmt+0xea>
f0104ccb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0104cce:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104cd1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f0104cd4:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0104cd7:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
f0104cdb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0104cde:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0104ce1:	83 fb 09             	cmp    $0x9,%ebx
f0104ce4:	76 eb                	jbe    f0104cd1 <vprintfmt+0xa4>
f0104ce6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0104ce9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104cec:	eb 29                	jmp    f0104d17 <vprintfmt+0xea>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104cee:	8b 55 14             	mov    0x14(%ebp),%edx
f0104cf1:	8d 5a 04             	lea    0x4(%edx),%ebx
f0104cf4:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0104cf7:	8b 12                	mov    (%edx),%edx
f0104cf9:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
f0104cfc:	eb 19                	jmp    f0104d17 <vprintfmt+0xea>

		case '.':
			if (width < 0)
f0104cfe:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104d01:	c1 fa 1f             	sar    $0x1f,%edx
f0104d04:	f7 d2                	not    %edx
f0104d06:	21 55 d4             	and    %edx,-0x2c(%ebp)
f0104d09:	eb 82                	jmp    f0104c8d <vprintfmt+0x60>
f0104d0b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f0104d12:	e9 76 ff ff ff       	jmp    f0104c8d <vprintfmt+0x60>

		process_precision:
			if (width < 0)
f0104d17:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0104d1b:	0f 89 6c ff ff ff    	jns    f0104c8d <vprintfmt+0x60>
f0104d21:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0104d24:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104d27:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0104d2a:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104d2d:	e9 5b ff ff ff       	jmp    f0104c8d <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104d32:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
f0104d35:	e9 53 ff ff ff       	jmp    f0104c8d <vprintfmt+0x60>
f0104d3a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104d3d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d40:	8d 50 04             	lea    0x4(%eax),%edx
f0104d43:	89 55 14             	mov    %edx,0x14(%ebp)
f0104d46:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104d4a:	8b 00                	mov    (%eax),%eax
f0104d4c:	89 04 24             	mov    %eax,(%esp)
f0104d4f:	ff d7                	call   *%edi
f0104d51:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
f0104d54:	e9 05 ff ff ff       	jmp    f0104c5e <vprintfmt+0x31>
f0104d59:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104d5c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d5f:	8d 50 04             	lea    0x4(%eax),%edx
f0104d62:	89 55 14             	mov    %edx,0x14(%ebp)
f0104d65:	8b 00                	mov    (%eax),%eax
f0104d67:	89 c2                	mov    %eax,%edx
f0104d69:	c1 fa 1f             	sar    $0x1f,%edx
f0104d6c:	31 d0                	xor    %edx,%eax
f0104d6e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104d70:	83 f8 06             	cmp    $0x6,%eax
f0104d73:	7f 0b                	jg     f0104d80 <vprintfmt+0x153>
f0104d75:	8b 14 85 94 70 10 f0 	mov    -0xfef8f6c(,%eax,4),%edx
f0104d7c:	85 d2                	test   %edx,%edx
f0104d7e:	75 20                	jne    f0104da0 <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
f0104d80:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104d84:	c7 44 24 08 47 6e 10 	movl   $0xf0106e47,0x8(%esp)
f0104d8b:	f0 
f0104d8c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104d90:	89 3c 24             	mov    %edi,(%esp)
f0104d93:	e8 8f 03 00 00       	call   f0105127 <printfmt>
f0104d98:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104d9b:	e9 be fe ff ff       	jmp    f0104c5e <vprintfmt+0x31>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0104da0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104da4:	c7 44 24 08 05 66 10 	movl   $0xf0106605,0x8(%esp)
f0104dab:	f0 
f0104dac:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104db0:	89 3c 24             	mov    %edi,(%esp)
f0104db3:	e8 6f 03 00 00       	call   f0105127 <printfmt>
f0104db8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104dbb:	e9 9e fe ff ff       	jmp    f0104c5e <vprintfmt+0x31>
f0104dc0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104dc3:	89 c3                	mov    %eax,%ebx
f0104dc5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104dc8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104dcb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104dce:	8b 45 14             	mov    0x14(%ebp),%eax
f0104dd1:	8d 50 04             	lea    0x4(%eax),%edx
f0104dd4:	89 55 14             	mov    %edx,0x14(%ebp)
f0104dd7:	8b 00                	mov    (%eax),%eax
f0104dd9:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104ddc:	85 c0                	test   %eax,%eax
f0104dde:	75 07                	jne    f0104de7 <vprintfmt+0x1ba>
f0104de0:	c7 45 cc 50 6e 10 f0 	movl   $0xf0106e50,-0x34(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f0104de7:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f0104deb:	7e 06                	jle    f0104df3 <vprintfmt+0x1c6>
f0104ded:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
f0104df1:	75 13                	jne    f0104e06 <vprintfmt+0x1d9>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104df3:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104df6:	0f be 02             	movsbl (%edx),%eax
f0104df9:	85 c0                	test   %eax,%eax
f0104dfb:	0f 85 9f 00 00 00    	jne    f0104ea0 <vprintfmt+0x273>
f0104e01:	e9 8f 00 00 00       	jmp    f0104e95 <vprintfmt+0x268>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104e06:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104e0a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104e0d:	89 0c 24             	mov    %ecx,(%esp)
f0104e10:	e8 36 04 00 00       	call   f010524b <strnlen>
f0104e15:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104e18:	29 c2                	sub    %eax,%edx
f0104e1a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104e1d:	85 d2                	test   %edx,%edx
f0104e1f:	7e d2                	jle    f0104df3 <vprintfmt+0x1c6>
					putch(padc, putdat);
f0104e21:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
f0104e25:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104e28:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0104e2b:	89 d3                	mov    %edx,%ebx
f0104e2d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104e31:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e34:	89 04 24             	mov    %eax,(%esp)
f0104e37:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104e39:	83 eb 01             	sub    $0x1,%ebx
f0104e3c:	85 db                	test   %ebx,%ebx
f0104e3e:	7f ed                	jg     f0104e2d <vprintfmt+0x200>
f0104e40:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0104e43:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0104e4a:	eb a7                	jmp    f0104df3 <vprintfmt+0x1c6>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104e4c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104e50:	74 1b                	je     f0104e6d <vprintfmt+0x240>
f0104e52:	8d 50 e0             	lea    -0x20(%eax),%edx
f0104e55:	83 fa 5e             	cmp    $0x5e,%edx
f0104e58:	76 13                	jbe    f0104e6d <vprintfmt+0x240>
					putch('?', putdat);
f0104e5a:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104e5d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104e61:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0104e68:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104e6b:	eb 0d                	jmp    f0104e7a <vprintfmt+0x24d>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0104e6d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104e70:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104e74:	89 04 24             	mov    %eax,(%esp)
f0104e77:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104e7a:	83 ef 01             	sub    $0x1,%edi
f0104e7d:	0f be 03             	movsbl (%ebx),%eax
f0104e80:	85 c0                	test   %eax,%eax
f0104e82:	74 05                	je     f0104e89 <vprintfmt+0x25c>
f0104e84:	83 c3 01             	add    $0x1,%ebx
f0104e87:	eb 2e                	jmp    f0104eb7 <vprintfmt+0x28a>
f0104e89:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104e8c:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104e8f:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0104e92:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104e95:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0104e99:	7f 33                	jg     f0104ece <vprintfmt+0x2a1>
f0104e9b:	e9 bb fd ff ff       	jmp    f0104c5b <vprintfmt+0x2e>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104ea0:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104ea3:	83 c2 01             	add    $0x1,%edx
f0104ea6:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0104ea9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104eac:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0104eaf:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104eb2:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0104eb5:	89 d3                	mov    %edx,%ebx
f0104eb7:	85 f6                	test   %esi,%esi
f0104eb9:	78 91                	js     f0104e4c <vprintfmt+0x21f>
f0104ebb:	83 ee 01             	sub    $0x1,%esi
f0104ebe:	79 8c                	jns    f0104e4c <vprintfmt+0x21f>
f0104ec0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104ec3:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104ec6:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0104ec9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104ecc:	eb c7                	jmp    f0104e95 <vprintfmt+0x268>
f0104ece:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0104ed1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104ed4:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104ed8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0104edf:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104ee1:	83 eb 01             	sub    $0x1,%ebx
f0104ee4:	85 db                	test   %ebx,%ebx
f0104ee6:	7f ec                	jg     f0104ed4 <vprintfmt+0x2a7>
f0104ee8:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0104eeb:	e9 6e fd ff ff       	jmp    f0104c5e <vprintfmt+0x31>
f0104ef0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104ef3:	83 f9 01             	cmp    $0x1,%ecx
f0104ef6:	7e 16                	jle    f0104f0e <vprintfmt+0x2e1>
		return va_arg(*ap, long long);
f0104ef8:	8b 45 14             	mov    0x14(%ebp),%eax
f0104efb:	8d 50 08             	lea    0x8(%eax),%edx
f0104efe:	89 55 14             	mov    %edx,0x14(%ebp)
f0104f01:	8b 10                	mov    (%eax),%edx
f0104f03:	8b 48 04             	mov    0x4(%eax),%ecx
f0104f06:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0104f09:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104f0c:	eb 32                	jmp    f0104f40 <vprintfmt+0x313>
	else if (lflag)
f0104f0e:	85 c9                	test   %ecx,%ecx
f0104f10:	74 18                	je     f0104f2a <vprintfmt+0x2fd>
		return va_arg(*ap, long);
f0104f12:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f15:	8d 50 04             	lea    0x4(%eax),%edx
f0104f18:	89 55 14             	mov    %edx,0x14(%ebp)
f0104f1b:	8b 00                	mov    (%eax),%eax
f0104f1d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f20:	89 c1                	mov    %eax,%ecx
f0104f22:	c1 f9 1f             	sar    $0x1f,%ecx
f0104f25:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104f28:	eb 16                	jmp    f0104f40 <vprintfmt+0x313>
	else
		return va_arg(*ap, int);
f0104f2a:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f2d:	8d 50 04             	lea    0x4(%eax),%edx
f0104f30:	89 55 14             	mov    %edx,0x14(%ebp)
f0104f33:	8b 00                	mov    (%eax),%eax
f0104f35:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f38:	89 c2                	mov    %eax,%edx
f0104f3a:	c1 fa 1f             	sar    $0x1f,%edx
f0104f3d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104f40:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104f43:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104f46:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
f0104f4b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104f4f:	0f 89 8a 00 00 00    	jns    f0104fdf <vprintfmt+0x3b2>
				putch('-', putdat);
f0104f55:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104f59:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0104f60:	ff d7                	call   *%edi
				num = -(long long) num;
f0104f62:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104f65:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104f68:	f7 d8                	neg    %eax
f0104f6a:	83 d2 00             	adc    $0x0,%edx
f0104f6d:	f7 da                	neg    %edx
f0104f6f:	eb 6e                	jmp    f0104fdf <vprintfmt+0x3b2>
f0104f71:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104f74:	89 ca                	mov    %ecx,%edx
f0104f76:	8d 45 14             	lea    0x14(%ebp),%eax
f0104f79:	e8 58 fc ff ff       	call   f0104bd6 <getuint>
f0104f7e:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
f0104f83:	eb 5a                	jmp    f0104fdf <vprintfmt+0x3b2>
f0104f85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			//break;
			num = getuint(&ap, lflag);
f0104f88:	89 ca                	mov    %ecx,%edx
f0104f8a:	8d 45 14             	lea    0x14(%ebp),%eax
f0104f8d:	e8 44 fc ff ff       	call   f0104bd6 <getuint>
f0104f92:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
f0104f97:	eb 46                	jmp    f0104fdf <vprintfmt+0x3b2>
f0104f99:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f0104f9c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104fa0:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0104fa7:	ff d7                	call   *%edi
			putch('x', putdat);
f0104fa9:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104fad:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0104fb4:	ff d7                	call   *%edi
			num = (unsigned long long)
f0104fb6:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fb9:	8d 50 04             	lea    0x4(%eax),%edx
f0104fbc:	89 55 14             	mov    %edx,0x14(%ebp)
f0104fbf:	8b 00                	mov    (%eax),%eax
f0104fc1:	ba 00 00 00 00       	mov    $0x0,%edx
f0104fc6:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104fcb:	eb 12                	jmp    f0104fdf <vprintfmt+0x3b2>
f0104fcd:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104fd0:	89 ca                	mov    %ecx,%edx
f0104fd2:	8d 45 14             	lea    0x14(%ebp),%eax
f0104fd5:	e8 fc fb ff ff       	call   f0104bd6 <getuint>
f0104fda:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104fdf:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
f0104fe3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0104fe7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104fea:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104fee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104ff2:	89 04 24             	mov    %eax,(%esp)
f0104ff5:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104ff9:	89 f2                	mov    %esi,%edx
f0104ffb:	89 f8                	mov    %edi,%eax
f0104ffd:	e8 de fa ff ff       	call   f0104ae0 <printnum>
f0105002:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
f0105005:	e9 54 fc ff ff       	jmp    f0104c5e <vprintfmt+0x31>
f010500a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			char* tmp = va_arg(ap, char*);
f010500d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105010:	8d 50 04             	lea    0x4(%eax),%edx
f0105013:	89 55 14             	mov    %edx,0x14(%ebp)
f0105016:	8b 00                	mov    (%eax),%eax
			if(tmp == NULL) {
f0105018:	85 c0                	test   %eax,%eax
f010501a:	75 1f                	jne    f010503b <vprintfmt+0x40e>
f010501c:	bb c1 6e 10 f0       	mov    $0xf0106ec1,%ebx
f0105021:	b0 0a                	mov    $0xa,%al
				for(; (ch = *null_error++) != '\0';) {	
					putch(ch, putdat);
f0105023:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105027:	89 04 24             	mov    %eax,(%esp)
f010502a:	ff d7                	call   *%edi
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			char* tmp = va_arg(ap, char*);
			if(tmp == NULL) {
				for(; (ch = *null_error++) != '\0';) {	
f010502c:	0f be 03             	movsbl (%ebx),%eax
f010502f:	83 c3 01             	add    $0x1,%ebx
f0105032:	85 c0                	test   %eax,%eax
f0105034:	75 ed                	jne    f0105023 <vprintfmt+0x3f6>
f0105036:	e9 20 fc ff ff       	jmp    f0104c5b <vprintfmt+0x2e>
					putch(ch, putdat);
				}
				break;
			}
			*tmp = *((signed char*) putdat);
f010503b:	0f b6 16             	movzbl (%esi),%edx
f010503e:	88 10                	mov    %dl,(%eax)
			if(*(signed char*) putdat < 0) {
f0105040:	80 3e 00             	cmpb   $0x0,(%esi)
f0105043:	0f 89 12 fc ff ff    	jns    f0104c5b <vprintfmt+0x2e>
f0105049:	bb f9 6e 10 f0       	mov    $0xf0106ef9,%ebx
f010504e:	b8 0a 00 00 00       	mov    $0xa,%eax
				for(; (ch = *overflow_error++) != '\0';) {	
					putch(ch, putdat);
f0105053:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105057:	89 04 24             	mov    %eax,(%esp)
f010505a:	ff d7                	call   *%edi
				}
				break;
			}
			*tmp = *((signed char*) putdat);
			if(*(signed char*) putdat < 0) {
				for(; (ch = *overflow_error++) != '\0';) {	
f010505c:	0f be 03             	movsbl (%ebx),%eax
f010505f:	83 c3 01             	add    $0x1,%ebx
f0105062:	85 c0                	test   %eax,%eax
f0105064:	75 ed                	jne    f0105053 <vprintfmt+0x426>
f0105066:	e9 f0 fb ff ff       	jmp    f0104c5b <vprintfmt+0x2e>
f010506b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010506e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105071:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105075:	89 14 24             	mov    %edx,(%esp)
f0105078:	ff d7                	call   *%edi
f010507a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
f010507d:	e9 dc fb ff ff       	jmp    f0104c5e <vprintfmt+0x31>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105082:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105086:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f010508d:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010508f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0105092:	80 38 25             	cmpb   $0x25,(%eax)
f0105095:	0f 84 c3 fb ff ff    	je     f0104c5e <vprintfmt+0x31>
f010509b:	89 c3                	mov    %eax,%ebx
f010509d:	eb f0                	jmp    f010508f <vprintfmt+0x462>
				/* do nothing */;
			break;
		}
	}
}
f010509f:	83 c4 5c             	add    $0x5c,%esp
f01050a2:	5b                   	pop    %ebx
f01050a3:	5e                   	pop    %esi
f01050a4:	5f                   	pop    %edi
f01050a5:	5d                   	pop    %ebp
f01050a6:	c3                   	ret    

f01050a7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01050a7:	55                   	push   %ebp
f01050a8:	89 e5                	mov    %esp,%ebp
f01050aa:	83 ec 28             	sub    $0x28,%esp
f01050ad:	8b 45 08             	mov    0x8(%ebp),%eax
f01050b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f01050b3:	85 c0                	test   %eax,%eax
f01050b5:	74 04                	je     f01050bb <vsnprintf+0x14>
f01050b7:	85 d2                	test   %edx,%edx
f01050b9:	7f 07                	jg     f01050c2 <vsnprintf+0x1b>
f01050bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050c0:	eb 3b                	jmp    f01050fd <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f01050c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01050c5:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f01050c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01050cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01050d3:	8b 45 14             	mov    0x14(%ebp),%eax
f01050d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01050da:	8b 45 10             	mov    0x10(%ebp),%eax
f01050dd:	89 44 24 08          	mov    %eax,0x8(%esp)
f01050e1:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01050e4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050e8:	c7 04 24 10 4c 10 f0 	movl   $0xf0104c10,(%esp)
f01050ef:	e8 39 fb ff ff       	call   f0104c2d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01050f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01050f7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01050fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f01050fd:	c9                   	leave  
f01050fe:	c3                   	ret    

f01050ff <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01050ff:	55                   	push   %ebp
f0105100:	89 e5                	mov    %esp,%ebp
f0105102:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
f0105105:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0105108:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010510c:	8b 45 10             	mov    0x10(%ebp),%eax
f010510f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105113:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105116:	89 44 24 04          	mov    %eax,0x4(%esp)
f010511a:	8b 45 08             	mov    0x8(%ebp),%eax
f010511d:	89 04 24             	mov    %eax,(%esp)
f0105120:	e8 82 ff ff ff       	call   f01050a7 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105125:	c9                   	leave  
f0105126:	c3                   	ret    

f0105127 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105127:	55                   	push   %ebp
f0105128:	89 e5                	mov    %esp,%ebp
f010512a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
f010512d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0105130:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105134:	8b 45 10             	mov    0x10(%ebp),%eax
f0105137:	89 44 24 08          	mov    %eax,0x8(%esp)
f010513b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010513e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105142:	8b 45 08             	mov    0x8(%ebp),%eax
f0105145:	89 04 24             	mov    %eax,(%esp)
f0105148:	e8 e0 fa ff ff       	call   f0104c2d <vprintfmt>
	va_end(ap);
}
f010514d:	c9                   	leave  
f010514e:	c3                   	ret    
	...

f0105150 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105150:	55                   	push   %ebp
f0105151:	89 e5                	mov    %esp,%ebp
f0105153:	57                   	push   %edi
f0105154:	56                   	push   %esi
f0105155:	53                   	push   %ebx
f0105156:	83 ec 1c             	sub    $0x1c,%esp
f0105159:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010515c:	85 c0                	test   %eax,%eax
f010515e:	74 10                	je     f0105170 <readline+0x20>
		cprintf("%s", prompt);
f0105160:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105164:	c7 04 24 05 66 10 f0 	movl   $0xf0106605,(%esp)
f010516b:	e8 3b eb ff ff       	call   f0103cab <cprintf>

	i = 0;
	echoing = iscons(0);
f0105170:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105177:	e8 1a b1 ff ff       	call   f0100296 <iscons>
f010517c:	89 c7                	mov    %eax,%edi
f010517e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0105183:	e8 fd b0 ff ff       	call   f0100285 <getchar>
f0105188:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010518a:	85 c0                	test   %eax,%eax
f010518c:	79 17                	jns    f01051a5 <readline+0x55>
			cprintf("read error: %e\n", c);
f010518e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105192:	c7 04 24 b0 70 10 f0 	movl   $0xf01070b0,(%esp)
f0105199:	e8 0d eb ff ff       	call   f0103cab <cprintf>
f010519e:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f01051a3:	eb 76                	jmp    f010521b <readline+0xcb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01051a5:	83 f8 08             	cmp    $0x8,%eax
f01051a8:	74 08                	je     f01051b2 <readline+0x62>
f01051aa:	83 f8 7f             	cmp    $0x7f,%eax
f01051ad:	8d 76 00             	lea    0x0(%esi),%esi
f01051b0:	75 19                	jne    f01051cb <readline+0x7b>
f01051b2:	85 f6                	test   %esi,%esi
f01051b4:	7e 15                	jle    f01051cb <readline+0x7b>
			if (echoing)
f01051b6:	85 ff                	test   %edi,%edi
f01051b8:	74 0c                	je     f01051c6 <readline+0x76>
				cputchar('\b');
f01051ba:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01051c1:	e8 d4 b2 ff ff       	call   f010049a <cputchar>
			i--;
f01051c6:	83 ee 01             	sub    $0x1,%esi
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01051c9:	eb b8                	jmp    f0105183 <readline+0x33>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f01051cb:	83 fb 1f             	cmp    $0x1f,%ebx
f01051ce:	66 90                	xchg   %ax,%ax
f01051d0:	7e 23                	jle    f01051f5 <readline+0xa5>
f01051d2:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01051d8:	7f 1b                	jg     f01051f5 <readline+0xa5>
			if (echoing)
f01051da:	85 ff                	test   %edi,%edi
f01051dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01051e0:	74 08                	je     f01051ea <readline+0x9a>
				cputchar(c);
f01051e2:	89 1c 24             	mov    %ebx,(%esp)
f01051e5:	e8 b0 b2 ff ff       	call   f010049a <cputchar>
			buf[i++] = c;
f01051ea:	88 9e c0 83 18 f0    	mov    %bl,-0xfe77c40(%esi)
f01051f0:	83 c6 01             	add    $0x1,%esi
f01051f3:	eb 8e                	jmp    f0105183 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01051f5:	83 fb 0a             	cmp    $0xa,%ebx
f01051f8:	74 05                	je     f01051ff <readline+0xaf>
f01051fa:	83 fb 0d             	cmp    $0xd,%ebx
f01051fd:	75 84                	jne    f0105183 <readline+0x33>
			if (echoing)
f01051ff:	85 ff                	test   %edi,%edi
f0105201:	74 0c                	je     f010520f <readline+0xbf>
				cputchar('\n');
f0105203:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f010520a:	e8 8b b2 ff ff       	call   f010049a <cputchar>
			buf[i] = 0;
f010520f:	c6 86 c0 83 18 f0 00 	movb   $0x0,-0xfe77c40(%esi)
f0105216:	b8 c0 83 18 f0       	mov    $0xf01883c0,%eax
			return buf;
		}
	}
}
f010521b:	83 c4 1c             	add    $0x1c,%esp
f010521e:	5b                   	pop    %ebx
f010521f:	5e                   	pop    %esi
f0105220:	5f                   	pop    %edi
f0105221:	5d                   	pop    %ebp
f0105222:	c3                   	ret    
	...

f0105230 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105230:	55                   	push   %ebp
f0105231:	89 e5                	mov    %esp,%ebp
f0105233:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105236:	b8 00 00 00 00       	mov    $0x0,%eax
f010523b:	80 3a 00             	cmpb   $0x0,(%edx)
f010523e:	74 09                	je     f0105249 <strlen+0x19>
		n++;
f0105240:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105243:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105247:	75 f7                	jne    f0105240 <strlen+0x10>
		n++;
	return n;
}
f0105249:	5d                   	pop    %ebp
f010524a:	c3                   	ret    

f010524b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010524b:	55                   	push   %ebp
f010524c:	89 e5                	mov    %esp,%ebp
f010524e:	53                   	push   %ebx
f010524f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105252:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105255:	85 c9                	test   %ecx,%ecx
f0105257:	74 19                	je     f0105272 <strnlen+0x27>
f0105259:	80 3b 00             	cmpb   $0x0,(%ebx)
f010525c:	74 14                	je     f0105272 <strnlen+0x27>
f010525e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0105263:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105266:	39 c8                	cmp    %ecx,%eax
f0105268:	74 0d                	je     f0105277 <strnlen+0x2c>
f010526a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f010526e:	75 f3                	jne    f0105263 <strnlen+0x18>
f0105270:	eb 05                	jmp    f0105277 <strnlen+0x2c>
f0105272:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0105277:	5b                   	pop    %ebx
f0105278:	5d                   	pop    %ebp
f0105279:	c3                   	ret    

f010527a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010527a:	55                   	push   %ebp
f010527b:	89 e5                	mov    %esp,%ebp
f010527d:	53                   	push   %ebx
f010527e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105281:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105284:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105289:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010528d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0105290:	83 c2 01             	add    $0x1,%edx
f0105293:	84 c9                	test   %cl,%cl
f0105295:	75 f2                	jne    f0105289 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105297:	5b                   	pop    %ebx
f0105298:	5d                   	pop    %ebp
f0105299:	c3                   	ret    

f010529a <strcat>:

char *
strcat(char *dst, const char *src)
{
f010529a:	55                   	push   %ebp
f010529b:	89 e5                	mov    %esp,%ebp
f010529d:	53                   	push   %ebx
f010529e:	83 ec 08             	sub    $0x8,%esp
f01052a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01052a4:	89 1c 24             	mov    %ebx,(%esp)
f01052a7:	e8 84 ff ff ff       	call   f0105230 <strlen>
	strcpy(dst + len, src);
f01052ac:	8b 55 0c             	mov    0xc(%ebp),%edx
f01052af:	89 54 24 04          	mov    %edx,0x4(%esp)
f01052b3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f01052b6:	89 04 24             	mov    %eax,(%esp)
f01052b9:	e8 bc ff ff ff       	call   f010527a <strcpy>
	return dst;
}
f01052be:	89 d8                	mov    %ebx,%eax
f01052c0:	83 c4 08             	add    $0x8,%esp
f01052c3:	5b                   	pop    %ebx
f01052c4:	5d                   	pop    %ebp
f01052c5:	c3                   	ret    

f01052c6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01052c6:	55                   	push   %ebp
f01052c7:	89 e5                	mov    %esp,%ebp
f01052c9:	56                   	push   %esi
f01052ca:	53                   	push   %ebx
f01052cb:	8b 45 08             	mov    0x8(%ebp),%eax
f01052ce:	8b 55 0c             	mov    0xc(%ebp),%edx
f01052d1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01052d4:	85 f6                	test   %esi,%esi
f01052d6:	74 18                	je     f01052f0 <strncpy+0x2a>
f01052d8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f01052dd:	0f b6 1a             	movzbl (%edx),%ebx
f01052e0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01052e3:	80 3a 01             	cmpb   $0x1,(%edx)
f01052e6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01052e9:	83 c1 01             	add    $0x1,%ecx
f01052ec:	39 ce                	cmp    %ecx,%esi
f01052ee:	77 ed                	ja     f01052dd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01052f0:	5b                   	pop    %ebx
f01052f1:	5e                   	pop    %esi
f01052f2:	5d                   	pop    %ebp
f01052f3:	c3                   	ret    

f01052f4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01052f4:	55                   	push   %ebp
f01052f5:	89 e5                	mov    %esp,%ebp
f01052f7:	56                   	push   %esi
f01052f8:	53                   	push   %ebx
f01052f9:	8b 75 08             	mov    0x8(%ebp),%esi
f01052fc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01052ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105302:	89 f0                	mov    %esi,%eax
f0105304:	85 c9                	test   %ecx,%ecx
f0105306:	74 27                	je     f010532f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f0105308:	83 e9 01             	sub    $0x1,%ecx
f010530b:	74 1d                	je     f010532a <strlcpy+0x36>
f010530d:	0f b6 1a             	movzbl (%edx),%ebx
f0105310:	84 db                	test   %bl,%bl
f0105312:	74 16                	je     f010532a <strlcpy+0x36>
			*dst++ = *src++;
f0105314:	88 18                	mov    %bl,(%eax)
f0105316:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105319:	83 e9 01             	sub    $0x1,%ecx
f010531c:	74 0e                	je     f010532c <strlcpy+0x38>
			*dst++ = *src++;
f010531e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105321:	0f b6 1a             	movzbl (%edx),%ebx
f0105324:	84 db                	test   %bl,%bl
f0105326:	75 ec                	jne    f0105314 <strlcpy+0x20>
f0105328:	eb 02                	jmp    f010532c <strlcpy+0x38>
f010532a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f010532c:	c6 00 00             	movb   $0x0,(%eax)
f010532f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0105331:	5b                   	pop    %ebx
f0105332:	5e                   	pop    %esi
f0105333:	5d                   	pop    %ebp
f0105334:	c3                   	ret    

f0105335 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105335:	55                   	push   %ebp
f0105336:	89 e5                	mov    %esp,%ebp
f0105338:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010533b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010533e:	0f b6 01             	movzbl (%ecx),%eax
f0105341:	84 c0                	test   %al,%al
f0105343:	74 15                	je     f010535a <strcmp+0x25>
f0105345:	3a 02                	cmp    (%edx),%al
f0105347:	75 11                	jne    f010535a <strcmp+0x25>
		p++, q++;
f0105349:	83 c1 01             	add    $0x1,%ecx
f010534c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010534f:	0f b6 01             	movzbl (%ecx),%eax
f0105352:	84 c0                	test   %al,%al
f0105354:	74 04                	je     f010535a <strcmp+0x25>
f0105356:	3a 02                	cmp    (%edx),%al
f0105358:	74 ef                	je     f0105349 <strcmp+0x14>
f010535a:	0f b6 c0             	movzbl %al,%eax
f010535d:	0f b6 12             	movzbl (%edx),%edx
f0105360:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105362:	5d                   	pop    %ebp
f0105363:	c3                   	ret    

f0105364 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105364:	55                   	push   %ebp
f0105365:	89 e5                	mov    %esp,%ebp
f0105367:	53                   	push   %ebx
f0105368:	8b 55 08             	mov    0x8(%ebp),%edx
f010536b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010536e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0105371:	85 c0                	test   %eax,%eax
f0105373:	74 23                	je     f0105398 <strncmp+0x34>
f0105375:	0f b6 1a             	movzbl (%edx),%ebx
f0105378:	84 db                	test   %bl,%bl
f010537a:	74 25                	je     f01053a1 <strncmp+0x3d>
f010537c:	3a 19                	cmp    (%ecx),%bl
f010537e:	75 21                	jne    f01053a1 <strncmp+0x3d>
f0105380:	83 e8 01             	sub    $0x1,%eax
f0105383:	74 13                	je     f0105398 <strncmp+0x34>
		n--, p++, q++;
f0105385:	83 c2 01             	add    $0x1,%edx
f0105388:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010538b:	0f b6 1a             	movzbl (%edx),%ebx
f010538e:	84 db                	test   %bl,%bl
f0105390:	74 0f                	je     f01053a1 <strncmp+0x3d>
f0105392:	3a 19                	cmp    (%ecx),%bl
f0105394:	74 ea                	je     f0105380 <strncmp+0x1c>
f0105396:	eb 09                	jmp    f01053a1 <strncmp+0x3d>
f0105398:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010539d:	5b                   	pop    %ebx
f010539e:	5d                   	pop    %ebp
f010539f:	90                   	nop
f01053a0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01053a1:	0f b6 02             	movzbl (%edx),%eax
f01053a4:	0f b6 11             	movzbl (%ecx),%edx
f01053a7:	29 d0                	sub    %edx,%eax
f01053a9:	eb f2                	jmp    f010539d <strncmp+0x39>

f01053ab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01053ab:	55                   	push   %ebp
f01053ac:	89 e5                	mov    %esp,%ebp
f01053ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01053b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01053b5:	0f b6 10             	movzbl (%eax),%edx
f01053b8:	84 d2                	test   %dl,%dl
f01053ba:	74 18                	je     f01053d4 <strchr+0x29>
		if (*s == c)
f01053bc:	38 ca                	cmp    %cl,%dl
f01053be:	75 0a                	jne    f01053ca <strchr+0x1f>
f01053c0:	eb 17                	jmp    f01053d9 <strchr+0x2e>
f01053c2:	38 ca                	cmp    %cl,%dl
f01053c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01053c8:	74 0f                	je     f01053d9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01053ca:	83 c0 01             	add    $0x1,%eax
f01053cd:	0f b6 10             	movzbl (%eax),%edx
f01053d0:	84 d2                	test   %dl,%dl
f01053d2:	75 ee                	jne    f01053c2 <strchr+0x17>
f01053d4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f01053d9:	5d                   	pop    %ebp
f01053da:	c3                   	ret    

f01053db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01053db:	55                   	push   %ebp
f01053dc:	89 e5                	mov    %esp,%ebp
f01053de:	8b 45 08             	mov    0x8(%ebp),%eax
f01053e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01053e5:	0f b6 10             	movzbl (%eax),%edx
f01053e8:	84 d2                	test   %dl,%dl
f01053ea:	74 18                	je     f0105404 <strfind+0x29>
		if (*s == c)
f01053ec:	38 ca                	cmp    %cl,%dl
f01053ee:	75 0a                	jne    f01053fa <strfind+0x1f>
f01053f0:	eb 12                	jmp    f0105404 <strfind+0x29>
f01053f2:	38 ca                	cmp    %cl,%dl
f01053f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01053f8:	74 0a                	je     f0105404 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01053fa:	83 c0 01             	add    $0x1,%eax
f01053fd:	0f b6 10             	movzbl (%eax),%edx
f0105400:	84 d2                	test   %dl,%dl
f0105402:	75 ee                	jne    f01053f2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0105404:	5d                   	pop    %ebp
f0105405:	c3                   	ret    

f0105406 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105406:	55                   	push   %ebp
f0105407:	89 e5                	mov    %esp,%ebp
f0105409:	83 ec 0c             	sub    $0xc,%esp
f010540c:	89 1c 24             	mov    %ebx,(%esp)
f010540f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105413:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105417:	8b 7d 08             	mov    0x8(%ebp),%edi
f010541a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010541d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105420:	85 c9                	test   %ecx,%ecx
f0105422:	74 30                	je     f0105454 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105424:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010542a:	75 25                	jne    f0105451 <memset+0x4b>
f010542c:	f6 c1 03             	test   $0x3,%cl
f010542f:	75 20                	jne    f0105451 <memset+0x4b>
		c &= 0xFF;
f0105431:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105434:	89 d3                	mov    %edx,%ebx
f0105436:	c1 e3 08             	shl    $0x8,%ebx
f0105439:	89 d6                	mov    %edx,%esi
f010543b:	c1 e6 18             	shl    $0x18,%esi
f010543e:	89 d0                	mov    %edx,%eax
f0105440:	c1 e0 10             	shl    $0x10,%eax
f0105443:	09 f0                	or     %esi,%eax
f0105445:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
f0105447:	09 d8                	or     %ebx,%eax
f0105449:	c1 e9 02             	shr    $0x2,%ecx
f010544c:	fc                   	cld    
f010544d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010544f:	eb 03                	jmp    f0105454 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105451:	fc                   	cld    
f0105452:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105454:	89 f8                	mov    %edi,%eax
f0105456:	8b 1c 24             	mov    (%esp),%ebx
f0105459:	8b 74 24 04          	mov    0x4(%esp),%esi
f010545d:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0105461:	89 ec                	mov    %ebp,%esp
f0105463:	5d                   	pop    %ebp
f0105464:	c3                   	ret    

f0105465 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105465:	55                   	push   %ebp
f0105466:	89 e5                	mov    %esp,%ebp
f0105468:	83 ec 08             	sub    $0x8,%esp
f010546b:	89 34 24             	mov    %esi,(%esp)
f010546e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105472:	8b 45 08             	mov    0x8(%ebp),%eax
f0105475:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
f0105478:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f010547b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f010547d:	39 c6                	cmp    %eax,%esi
f010547f:	73 35                	jae    f01054b6 <memmove+0x51>
f0105481:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105484:	39 d0                	cmp    %edx,%eax
f0105486:	73 2e                	jae    f01054b6 <memmove+0x51>
		s += n;
		d += n;
f0105488:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010548a:	f6 c2 03             	test   $0x3,%dl
f010548d:	75 1b                	jne    f01054aa <memmove+0x45>
f010548f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105495:	75 13                	jne    f01054aa <memmove+0x45>
f0105497:	f6 c1 03             	test   $0x3,%cl
f010549a:	75 0e                	jne    f01054aa <memmove+0x45>
			asm volatile("std; rep movsl\n"
f010549c:	83 ef 04             	sub    $0x4,%edi
f010549f:	8d 72 fc             	lea    -0x4(%edx),%esi
f01054a2:	c1 e9 02             	shr    $0x2,%ecx
f01054a5:	fd                   	std    
f01054a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01054a8:	eb 09                	jmp    f01054b3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01054aa:	83 ef 01             	sub    $0x1,%edi
f01054ad:	8d 72 ff             	lea    -0x1(%edx),%esi
f01054b0:	fd                   	std    
f01054b1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01054b3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01054b4:	eb 20                	jmp    f01054d6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01054b6:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01054bc:	75 15                	jne    f01054d3 <memmove+0x6e>
f01054be:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01054c4:	75 0d                	jne    f01054d3 <memmove+0x6e>
f01054c6:	f6 c1 03             	test   $0x3,%cl
f01054c9:	75 08                	jne    f01054d3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
f01054cb:	c1 e9 02             	shr    $0x2,%ecx
f01054ce:	fc                   	cld    
f01054cf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01054d1:	eb 03                	jmp    f01054d6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01054d3:	fc                   	cld    
f01054d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01054d6:	8b 34 24             	mov    (%esp),%esi
f01054d9:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01054dd:	89 ec                	mov    %ebp,%esp
f01054df:	5d                   	pop    %ebp
f01054e0:	c3                   	ret    

f01054e1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f01054e1:	55                   	push   %ebp
f01054e2:	89 e5                	mov    %esp,%ebp
f01054e4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01054e7:	8b 45 10             	mov    0x10(%ebp),%eax
f01054ea:	89 44 24 08          	mov    %eax,0x8(%esp)
f01054ee:	8b 45 0c             	mov    0xc(%ebp),%eax
f01054f1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01054f8:	89 04 24             	mov    %eax,(%esp)
f01054fb:	e8 65 ff ff ff       	call   f0105465 <memmove>
}
f0105500:	c9                   	leave  
f0105501:	c3                   	ret    

f0105502 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105502:	55                   	push   %ebp
f0105503:	89 e5                	mov    %esp,%ebp
f0105505:	57                   	push   %edi
f0105506:	56                   	push   %esi
f0105507:	53                   	push   %ebx
f0105508:	8b 75 08             	mov    0x8(%ebp),%esi
f010550b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010550e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105511:	85 c9                	test   %ecx,%ecx
f0105513:	74 36                	je     f010554b <memcmp+0x49>
		if (*s1 != *s2)
f0105515:	0f b6 06             	movzbl (%esi),%eax
f0105518:	0f b6 1f             	movzbl (%edi),%ebx
f010551b:	38 d8                	cmp    %bl,%al
f010551d:	74 20                	je     f010553f <memcmp+0x3d>
f010551f:	eb 14                	jmp    f0105535 <memcmp+0x33>
f0105521:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0105526:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f010552b:	83 c2 01             	add    $0x1,%edx
f010552e:	83 e9 01             	sub    $0x1,%ecx
f0105531:	38 d8                	cmp    %bl,%al
f0105533:	74 12                	je     f0105547 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0105535:	0f b6 c0             	movzbl %al,%eax
f0105538:	0f b6 db             	movzbl %bl,%ebx
f010553b:	29 d8                	sub    %ebx,%eax
f010553d:	eb 11                	jmp    f0105550 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010553f:	83 e9 01             	sub    $0x1,%ecx
f0105542:	ba 00 00 00 00       	mov    $0x0,%edx
f0105547:	85 c9                	test   %ecx,%ecx
f0105549:	75 d6                	jne    f0105521 <memcmp+0x1f>
f010554b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0105550:	5b                   	pop    %ebx
f0105551:	5e                   	pop    %esi
f0105552:	5f                   	pop    %edi
f0105553:	5d                   	pop    %ebp
f0105554:	c3                   	ret    

f0105555 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105555:	55                   	push   %ebp
f0105556:	89 e5                	mov    %esp,%ebp
f0105558:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010555b:	89 c2                	mov    %eax,%edx
f010555d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105560:	39 d0                	cmp    %edx,%eax
f0105562:	73 15                	jae    f0105579 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105564:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0105568:	38 08                	cmp    %cl,(%eax)
f010556a:	75 06                	jne    f0105572 <memfind+0x1d>
f010556c:	eb 0b                	jmp    f0105579 <memfind+0x24>
f010556e:	38 08                	cmp    %cl,(%eax)
f0105570:	74 07                	je     f0105579 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105572:	83 c0 01             	add    $0x1,%eax
f0105575:	39 c2                	cmp    %eax,%edx
f0105577:	77 f5                	ja     f010556e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105579:	5d                   	pop    %ebp
f010557a:	c3                   	ret    

f010557b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010557b:	55                   	push   %ebp
f010557c:	89 e5                	mov    %esp,%ebp
f010557e:	57                   	push   %edi
f010557f:	56                   	push   %esi
f0105580:	53                   	push   %ebx
f0105581:	83 ec 04             	sub    $0x4,%esp
f0105584:	8b 55 08             	mov    0x8(%ebp),%edx
f0105587:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010558a:	0f b6 02             	movzbl (%edx),%eax
f010558d:	3c 20                	cmp    $0x20,%al
f010558f:	74 04                	je     f0105595 <strtol+0x1a>
f0105591:	3c 09                	cmp    $0x9,%al
f0105593:	75 0e                	jne    f01055a3 <strtol+0x28>
		s++;
f0105595:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105598:	0f b6 02             	movzbl (%edx),%eax
f010559b:	3c 20                	cmp    $0x20,%al
f010559d:	74 f6                	je     f0105595 <strtol+0x1a>
f010559f:	3c 09                	cmp    $0x9,%al
f01055a1:	74 f2                	je     f0105595 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f01055a3:	3c 2b                	cmp    $0x2b,%al
f01055a5:	75 0c                	jne    f01055b3 <strtol+0x38>
		s++;
f01055a7:	83 c2 01             	add    $0x1,%edx
f01055aa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01055b1:	eb 15                	jmp    f01055c8 <strtol+0x4d>
	else if (*s == '-')
f01055b3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01055ba:	3c 2d                	cmp    $0x2d,%al
f01055bc:	75 0a                	jne    f01055c8 <strtol+0x4d>
		s++, neg = 1;
f01055be:	83 c2 01             	add    $0x1,%edx
f01055c1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01055c8:	85 db                	test   %ebx,%ebx
f01055ca:	0f 94 c0             	sete   %al
f01055cd:	74 05                	je     f01055d4 <strtol+0x59>
f01055cf:	83 fb 10             	cmp    $0x10,%ebx
f01055d2:	75 18                	jne    f01055ec <strtol+0x71>
f01055d4:	80 3a 30             	cmpb   $0x30,(%edx)
f01055d7:	75 13                	jne    f01055ec <strtol+0x71>
f01055d9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01055dd:	8d 76 00             	lea    0x0(%esi),%esi
f01055e0:	75 0a                	jne    f01055ec <strtol+0x71>
		s += 2, base = 16;
f01055e2:	83 c2 02             	add    $0x2,%edx
f01055e5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01055ea:	eb 15                	jmp    f0105601 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01055ec:	84 c0                	test   %al,%al
f01055ee:	66 90                	xchg   %ax,%ax
f01055f0:	74 0f                	je     f0105601 <strtol+0x86>
f01055f2:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01055f7:	80 3a 30             	cmpb   $0x30,(%edx)
f01055fa:	75 05                	jne    f0105601 <strtol+0x86>
		s++, base = 8;
f01055fc:	83 c2 01             	add    $0x1,%edx
f01055ff:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105601:	b8 00 00 00 00       	mov    $0x0,%eax
f0105606:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105608:	0f b6 0a             	movzbl (%edx),%ecx
f010560b:	89 cf                	mov    %ecx,%edi
f010560d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0105610:	80 fb 09             	cmp    $0x9,%bl
f0105613:	77 08                	ja     f010561d <strtol+0xa2>
			dig = *s - '0';
f0105615:	0f be c9             	movsbl %cl,%ecx
f0105618:	83 e9 30             	sub    $0x30,%ecx
f010561b:	eb 1e                	jmp    f010563b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f010561d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0105620:	80 fb 19             	cmp    $0x19,%bl
f0105623:	77 08                	ja     f010562d <strtol+0xb2>
			dig = *s - 'a' + 10;
f0105625:	0f be c9             	movsbl %cl,%ecx
f0105628:	83 e9 57             	sub    $0x57,%ecx
f010562b:	eb 0e                	jmp    f010563b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f010562d:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0105630:	80 fb 19             	cmp    $0x19,%bl
f0105633:	77 15                	ja     f010564a <strtol+0xcf>
			dig = *s - 'A' + 10;
f0105635:	0f be c9             	movsbl %cl,%ecx
f0105638:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010563b:	39 f1                	cmp    %esi,%ecx
f010563d:	7d 0b                	jge    f010564a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f010563f:	83 c2 01             	add    $0x1,%edx
f0105642:	0f af c6             	imul   %esi,%eax
f0105645:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0105648:	eb be                	jmp    f0105608 <strtol+0x8d>
f010564a:	89 c1                	mov    %eax,%ecx

	if (endptr)
f010564c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105650:	74 05                	je     f0105657 <strtol+0xdc>
		*endptr = (char *) s;
f0105652:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105655:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0105657:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010565b:	74 04                	je     f0105661 <strtol+0xe6>
f010565d:	89 c8                	mov    %ecx,%eax
f010565f:	f7 d8                	neg    %eax
}
f0105661:	83 c4 04             	add    $0x4,%esp
f0105664:	5b                   	pop    %ebx
f0105665:	5e                   	pop    %esi
f0105666:	5f                   	pop    %edi
f0105667:	5d                   	pop    %ebp
f0105668:	c3                   	ret    
f0105669:	00 00                	add    %al,(%eax)
f010566b:	00 00                	add    %al,(%eax)
f010566d:	00 00                	add    %al,(%eax)
	...

f0105670 <__udivdi3>:
f0105670:	55                   	push   %ebp
f0105671:	89 e5                	mov    %esp,%ebp
f0105673:	57                   	push   %edi
f0105674:	56                   	push   %esi
f0105675:	83 ec 10             	sub    $0x10,%esp
f0105678:	8b 45 14             	mov    0x14(%ebp),%eax
f010567b:	8b 55 08             	mov    0x8(%ebp),%edx
f010567e:	8b 75 10             	mov    0x10(%ebp),%esi
f0105681:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105684:	85 c0                	test   %eax,%eax
f0105686:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0105689:	75 35                	jne    f01056c0 <__udivdi3+0x50>
f010568b:	39 fe                	cmp    %edi,%esi
f010568d:	77 61                	ja     f01056f0 <__udivdi3+0x80>
f010568f:	85 f6                	test   %esi,%esi
f0105691:	75 0b                	jne    f010569e <__udivdi3+0x2e>
f0105693:	b8 01 00 00 00       	mov    $0x1,%eax
f0105698:	31 d2                	xor    %edx,%edx
f010569a:	f7 f6                	div    %esi
f010569c:	89 c6                	mov    %eax,%esi
f010569e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01056a1:	31 d2                	xor    %edx,%edx
f01056a3:	89 f8                	mov    %edi,%eax
f01056a5:	f7 f6                	div    %esi
f01056a7:	89 c7                	mov    %eax,%edi
f01056a9:	89 c8                	mov    %ecx,%eax
f01056ab:	f7 f6                	div    %esi
f01056ad:	89 c1                	mov    %eax,%ecx
f01056af:	89 fa                	mov    %edi,%edx
f01056b1:	89 c8                	mov    %ecx,%eax
f01056b3:	83 c4 10             	add    $0x10,%esp
f01056b6:	5e                   	pop    %esi
f01056b7:	5f                   	pop    %edi
f01056b8:	5d                   	pop    %ebp
f01056b9:	c3                   	ret    
f01056ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01056c0:	39 f8                	cmp    %edi,%eax
f01056c2:	77 1c                	ja     f01056e0 <__udivdi3+0x70>
f01056c4:	0f bd d0             	bsr    %eax,%edx
f01056c7:	83 f2 1f             	xor    $0x1f,%edx
f01056ca:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01056cd:	75 39                	jne    f0105708 <__udivdi3+0x98>
f01056cf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f01056d2:	0f 86 a0 00 00 00    	jbe    f0105778 <__udivdi3+0x108>
f01056d8:	39 f8                	cmp    %edi,%eax
f01056da:	0f 82 98 00 00 00    	jb     f0105778 <__udivdi3+0x108>
f01056e0:	31 ff                	xor    %edi,%edi
f01056e2:	31 c9                	xor    %ecx,%ecx
f01056e4:	89 c8                	mov    %ecx,%eax
f01056e6:	89 fa                	mov    %edi,%edx
f01056e8:	83 c4 10             	add    $0x10,%esp
f01056eb:	5e                   	pop    %esi
f01056ec:	5f                   	pop    %edi
f01056ed:	5d                   	pop    %ebp
f01056ee:	c3                   	ret    
f01056ef:	90                   	nop
f01056f0:	89 d1                	mov    %edx,%ecx
f01056f2:	89 fa                	mov    %edi,%edx
f01056f4:	89 c8                	mov    %ecx,%eax
f01056f6:	31 ff                	xor    %edi,%edi
f01056f8:	f7 f6                	div    %esi
f01056fa:	89 c1                	mov    %eax,%ecx
f01056fc:	89 fa                	mov    %edi,%edx
f01056fe:	89 c8                	mov    %ecx,%eax
f0105700:	83 c4 10             	add    $0x10,%esp
f0105703:	5e                   	pop    %esi
f0105704:	5f                   	pop    %edi
f0105705:	5d                   	pop    %ebp
f0105706:	c3                   	ret    
f0105707:	90                   	nop
f0105708:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010570c:	89 f2                	mov    %esi,%edx
f010570e:	d3 e0                	shl    %cl,%eax
f0105710:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105713:	b8 20 00 00 00       	mov    $0x20,%eax
f0105718:	2b 45 f4             	sub    -0xc(%ebp),%eax
f010571b:	89 c1                	mov    %eax,%ecx
f010571d:	d3 ea                	shr    %cl,%edx
f010571f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0105723:	0b 55 ec             	or     -0x14(%ebp),%edx
f0105726:	d3 e6                	shl    %cl,%esi
f0105728:	89 c1                	mov    %eax,%ecx
f010572a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f010572d:	89 fe                	mov    %edi,%esi
f010572f:	d3 ee                	shr    %cl,%esi
f0105731:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0105735:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0105738:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010573b:	d3 e7                	shl    %cl,%edi
f010573d:	89 c1                	mov    %eax,%ecx
f010573f:	d3 ea                	shr    %cl,%edx
f0105741:	09 d7                	or     %edx,%edi
f0105743:	89 f2                	mov    %esi,%edx
f0105745:	89 f8                	mov    %edi,%eax
f0105747:	f7 75 ec             	divl   -0x14(%ebp)
f010574a:	89 d6                	mov    %edx,%esi
f010574c:	89 c7                	mov    %eax,%edi
f010574e:	f7 65 e8             	mull   -0x18(%ebp)
f0105751:	39 d6                	cmp    %edx,%esi
f0105753:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0105756:	72 30                	jb     f0105788 <__udivdi3+0x118>
f0105758:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010575b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010575f:	d3 e2                	shl    %cl,%edx
f0105761:	39 c2                	cmp    %eax,%edx
f0105763:	73 05                	jae    f010576a <__udivdi3+0xfa>
f0105765:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0105768:	74 1e                	je     f0105788 <__udivdi3+0x118>
f010576a:	89 f9                	mov    %edi,%ecx
f010576c:	31 ff                	xor    %edi,%edi
f010576e:	e9 71 ff ff ff       	jmp    f01056e4 <__udivdi3+0x74>
f0105773:	90                   	nop
f0105774:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105778:	31 ff                	xor    %edi,%edi
f010577a:	b9 01 00 00 00       	mov    $0x1,%ecx
f010577f:	e9 60 ff ff ff       	jmp    f01056e4 <__udivdi3+0x74>
f0105784:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105788:	8d 4f ff             	lea    -0x1(%edi),%ecx
f010578b:	31 ff                	xor    %edi,%edi
f010578d:	89 c8                	mov    %ecx,%eax
f010578f:	89 fa                	mov    %edi,%edx
f0105791:	83 c4 10             	add    $0x10,%esp
f0105794:	5e                   	pop    %esi
f0105795:	5f                   	pop    %edi
f0105796:	5d                   	pop    %ebp
f0105797:	c3                   	ret    
	...

f01057a0 <__umoddi3>:
f01057a0:	55                   	push   %ebp
f01057a1:	89 e5                	mov    %esp,%ebp
f01057a3:	57                   	push   %edi
f01057a4:	56                   	push   %esi
f01057a5:	83 ec 20             	sub    $0x20,%esp
f01057a8:	8b 55 14             	mov    0x14(%ebp),%edx
f01057ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01057ae:	8b 7d 10             	mov    0x10(%ebp),%edi
f01057b1:	8b 75 0c             	mov    0xc(%ebp),%esi
f01057b4:	85 d2                	test   %edx,%edx
f01057b6:	89 c8                	mov    %ecx,%eax
f01057b8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f01057bb:	75 13                	jne    f01057d0 <__umoddi3+0x30>
f01057bd:	39 f7                	cmp    %esi,%edi
f01057bf:	76 3f                	jbe    f0105800 <__umoddi3+0x60>
f01057c1:	89 f2                	mov    %esi,%edx
f01057c3:	f7 f7                	div    %edi
f01057c5:	89 d0                	mov    %edx,%eax
f01057c7:	31 d2                	xor    %edx,%edx
f01057c9:	83 c4 20             	add    $0x20,%esp
f01057cc:	5e                   	pop    %esi
f01057cd:	5f                   	pop    %edi
f01057ce:	5d                   	pop    %ebp
f01057cf:	c3                   	ret    
f01057d0:	39 f2                	cmp    %esi,%edx
f01057d2:	77 4c                	ja     f0105820 <__umoddi3+0x80>
f01057d4:	0f bd ca             	bsr    %edx,%ecx
f01057d7:	83 f1 1f             	xor    $0x1f,%ecx
f01057da:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01057dd:	75 51                	jne    f0105830 <__umoddi3+0x90>
f01057df:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f01057e2:	0f 87 e0 00 00 00    	ja     f01058c8 <__umoddi3+0x128>
f01057e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01057eb:	29 f8                	sub    %edi,%eax
f01057ed:	19 d6                	sbb    %edx,%esi
f01057ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01057f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01057f5:	89 f2                	mov    %esi,%edx
f01057f7:	83 c4 20             	add    $0x20,%esp
f01057fa:	5e                   	pop    %esi
f01057fb:	5f                   	pop    %edi
f01057fc:	5d                   	pop    %ebp
f01057fd:	c3                   	ret    
f01057fe:	66 90                	xchg   %ax,%ax
f0105800:	85 ff                	test   %edi,%edi
f0105802:	75 0b                	jne    f010580f <__umoddi3+0x6f>
f0105804:	b8 01 00 00 00       	mov    $0x1,%eax
f0105809:	31 d2                	xor    %edx,%edx
f010580b:	f7 f7                	div    %edi
f010580d:	89 c7                	mov    %eax,%edi
f010580f:	89 f0                	mov    %esi,%eax
f0105811:	31 d2                	xor    %edx,%edx
f0105813:	f7 f7                	div    %edi
f0105815:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105818:	f7 f7                	div    %edi
f010581a:	eb a9                	jmp    f01057c5 <__umoddi3+0x25>
f010581c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105820:	89 c8                	mov    %ecx,%eax
f0105822:	89 f2                	mov    %esi,%edx
f0105824:	83 c4 20             	add    $0x20,%esp
f0105827:	5e                   	pop    %esi
f0105828:	5f                   	pop    %edi
f0105829:	5d                   	pop    %ebp
f010582a:	c3                   	ret    
f010582b:	90                   	nop
f010582c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105830:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0105834:	d3 e2                	shl    %cl,%edx
f0105836:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0105839:	ba 20 00 00 00       	mov    $0x20,%edx
f010583e:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0105841:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0105844:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0105848:	89 fa                	mov    %edi,%edx
f010584a:	d3 ea                	shr    %cl,%edx
f010584c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0105850:	0b 55 f4             	or     -0xc(%ebp),%edx
f0105853:	d3 e7                	shl    %cl,%edi
f0105855:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0105859:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010585c:	89 f2                	mov    %esi,%edx
f010585e:	89 7d e8             	mov    %edi,-0x18(%ebp)
f0105861:	89 c7                	mov    %eax,%edi
f0105863:	d3 ea                	shr    %cl,%edx
f0105865:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0105869:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010586c:	89 c2                	mov    %eax,%edx
f010586e:	d3 e6                	shl    %cl,%esi
f0105870:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0105874:	d3 ea                	shr    %cl,%edx
f0105876:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010587a:	09 d6                	or     %edx,%esi
f010587c:	89 f0                	mov    %esi,%eax
f010587e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105881:	d3 e7                	shl    %cl,%edi
f0105883:	89 f2                	mov    %esi,%edx
f0105885:	f7 75 f4             	divl   -0xc(%ebp)
f0105888:	89 d6                	mov    %edx,%esi
f010588a:	f7 65 e8             	mull   -0x18(%ebp)
f010588d:	39 d6                	cmp    %edx,%esi
f010588f:	72 2b                	jb     f01058bc <__umoddi3+0x11c>
f0105891:	39 c7                	cmp    %eax,%edi
f0105893:	72 23                	jb     f01058b8 <__umoddi3+0x118>
f0105895:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0105899:	29 c7                	sub    %eax,%edi
f010589b:	19 d6                	sbb    %edx,%esi
f010589d:	89 f0                	mov    %esi,%eax
f010589f:	89 f2                	mov    %esi,%edx
f01058a1:	d3 ef                	shr    %cl,%edi
f01058a3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01058a7:	d3 e0                	shl    %cl,%eax
f01058a9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01058ad:	09 f8                	or     %edi,%eax
f01058af:	d3 ea                	shr    %cl,%edx
f01058b1:	83 c4 20             	add    $0x20,%esp
f01058b4:	5e                   	pop    %esi
f01058b5:	5f                   	pop    %edi
f01058b6:	5d                   	pop    %ebp
f01058b7:	c3                   	ret    
f01058b8:	39 d6                	cmp    %edx,%esi
f01058ba:	75 d9                	jne    f0105895 <__umoddi3+0xf5>
f01058bc:	2b 45 e8             	sub    -0x18(%ebp),%eax
f01058bf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f01058c2:	eb d1                	jmp    f0105895 <__umoddi3+0xf5>
f01058c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01058c8:	39 f2                	cmp    %esi,%edx
f01058ca:	0f 82 18 ff ff ff    	jb     f01057e8 <__umoddi3+0x48>
f01058d0:	e9 1d ff ff ff       	jmp    f01057f2 <__umoddi3+0x52>
