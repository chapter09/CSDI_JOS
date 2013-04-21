
obj/user/testbss:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 eb 00 00 00       	call   80011c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003a:	c7 04 24 38 11 80 00 	movl   $0x801138,(%esp)
  800041:	e8 0b 02 00 00       	call   800251 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
  800046:	b8 01 00 00 00       	mov    $0x1,%eax
  80004b:	ba 20 20 80 00       	mov    $0x802020,%edx
  800050:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  800057:	74 04                	je     80005d <umain+0x29>
  800059:	b0 00                	mov    $0x0,%al
  80005b:	eb 06                	jmp    800063 <umain+0x2f>
  80005d:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
  800061:	74 20                	je     800083 <umain+0x4f>
			panic("bigarray[%d] isn't cleared!\n", i);
  800063:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800067:	c7 44 24 08 b3 11 80 	movl   $0x8011b3,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800076:	00 
  800077:	c7 04 24 d0 11 80 00 	movl   $0x8011d0,(%esp)
  80007e:	e8 fd 00 00 00       	call   800180 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800083:	83 c0 01             	add    $0x1,%eax
  800086:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008b:	75 d0                	jne    80005d <umain+0x29>
  80008d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800092:	ba 20 20 80 00       	mov    $0x802020,%edx
  800097:	89 04 82             	mov    %eax,(%edx,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80009a:	83 c0 01             	add    $0x1,%eax
  80009d:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000a2:	75 f3                	jne    800097 <umain+0x63>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  8000a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8000a9:	ba 20 20 80 00       	mov    $0x802020,%edx
  8000ae:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  8000b5:	74 04                	je     8000bb <umain+0x87>
  8000b7:	b0 00                	mov    $0x0,%al
  8000b9:	eb 05                	jmp    8000c0 <umain+0x8c>
  8000bb:	39 04 82             	cmp    %eax,(%edx,%eax,4)
  8000be:	74 20                	je     8000e0 <umain+0xac>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c4:	c7 44 24 08 58 11 80 	movl   $0x801158,0x8(%esp)
  8000cb:	00 
  8000cc:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000d3:	00 
  8000d4:	c7 04 24 d0 11 80 00 	movl   $0x8011d0,(%esp)
  8000db:	e8 a0 00 00 00       	call   800180 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000e0:	83 c0 01             	add    $0x1,%eax
  8000e3:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000e8:	75 d1                	jne    8000bb <umain+0x87>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000ea:	c7 04 24 80 11 80 00 	movl   $0x801180,(%esp)
  8000f1:	e8 5b 01 00 00       	call   800251 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000f6:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000fd:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  800100:	c7 44 24 08 df 11 80 	movl   $0x8011df,0x8(%esp)
  800107:	00 
  800108:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  80010f:	00 
  800110:	c7 04 24 d0 11 80 00 	movl   $0x8011d0,(%esp)
  800117:	e8 64 00 00 00       	call   800180 <_panic>

0080011c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	83 ec 18             	sub    $0x18,%esp
  800122:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800125:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800128:	8b 75 08             	mov    0x8(%ebp),%esi
  80012b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80012e:	e8 a8 0c 00 00       	call   800ddb <sys_getenvid>
  800133:	25 ff 03 00 00       	and    $0x3ff,%eax
  800138:	6b c0 64             	imul   $0x64,%eax,%eax
  80013b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800140:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800145:	85 f6                	test   %esi,%esi
  800147:	7e 07                	jle    800150 <libmain+0x34>
		binaryname = argv[0];
  800149:	8b 03                	mov    (%ebx),%eax
  80014b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800150:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800154:	89 34 24             	mov    %esi,(%esp)
  800157:	e8 d8 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80015c:	e8 0b 00 00 00       	call   80016c <exit>
}
  800161:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800164:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800167:	89 ec                	mov    %ebp,%esp
  800169:	5d                   	pop    %ebp
  80016a:	c3                   	ret    
	...

0080016c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800172:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800179:	e8 df 0c 00 00       	call   800e5d <sys_env_destroy>
}
  80017e:	c9                   	leave  
  80017f:	c3                   	ret    

00800180 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	56                   	push   %esi
  800184:	53                   	push   %ebx
  800185:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800188:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80018b:	a1 24 20 c0 00       	mov    0xc02024,%eax
  800190:	85 c0                	test   %eax,%eax
  800192:	74 10                	je     8001a4 <_panic+0x24>
		cprintf("%s: ", argv0);
  800194:	89 44 24 04          	mov    %eax,0x4(%esp)
  800198:	c7 04 24 00 12 80 00 	movl   $0x801200,(%esp)
  80019f:	e8 ad 00 00 00       	call   800251 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001a4:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001aa:	e8 2c 0c 00 00       	call   800ddb <sys_getenvid>
  8001af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001bd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c5:	c7 04 24 08 12 80 00 	movl   $0x801208,(%esp)
  8001cc:	e8 80 00 00 00       	call   800251 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d8:	89 04 24             	mov    %eax,(%esp)
  8001db:	e8 10 00 00 00       	call   8001f0 <vcprintf>
	cprintf("\n");
  8001e0:	c7 04 24 ce 11 80 00 	movl   $0x8011ce,(%esp)
  8001e7:	e8 65 00 00 00       	call   800251 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ec:	cc                   	int3   
  8001ed:	eb fd                	jmp    8001ec <_panic+0x6c>
	...

008001f0 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800200:	00 00 00 
	b.cnt = 0;
  800203:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80020a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80020d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800210:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800214:	8b 45 08             	mov    0x8(%ebp),%eax
  800217:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800221:	89 44 24 04          	mov    %eax,0x4(%esp)
  800225:	c7 04 24 6b 02 80 00 	movl   $0x80026b,(%esp)
  80022c:	e8 cc 01 00 00       	call   8003fd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800231:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800237:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800241:	89 04 24             	mov    %eax,(%esp)
  800244:	e8 13 0b 00 00       	call   800d5c <sys_cputs>

	return b.cnt;
}
  800249:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024f:	c9                   	leave  
  800250:	c3                   	ret    

00800251 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800251:	55                   	push   %ebp
  800252:	89 e5                	mov    %esp,%ebp
  800254:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800257:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80025a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	89 04 24             	mov    %eax,(%esp)
  800264:	e8 87 ff ff ff       	call   8001f0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	53                   	push   %ebx
  80026f:	83 ec 14             	sub    $0x14,%esp
  800272:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800275:	8b 03                	mov    (%ebx),%eax
  800277:	8b 55 08             	mov    0x8(%ebp),%edx
  80027a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80027e:	83 c0 01             	add    $0x1,%eax
  800281:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800283:	3d ff 00 00 00       	cmp    $0xff,%eax
  800288:	75 19                	jne    8002a3 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80028a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800291:	00 
  800292:	8d 43 08             	lea    0x8(%ebx),%eax
  800295:	89 04 24             	mov    %eax,(%esp)
  800298:	e8 bf 0a 00 00       	call   800d5c <sys_cputs>
		b->idx = 0;
  80029d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002a7:	83 c4 14             	add    $0x14,%esp
  8002aa:	5b                   	pop    %ebx
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    
  8002ad:	00 00                	add    %al,(%eax)
	...

008002b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 4c             	sub    $0x4c,%esp
  8002b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002bc:	89 d6                	mov    %edx,%esi
  8002be:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002d0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002d3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002db:	39 d1                	cmp    %edx,%ecx
  8002dd:	72 15                	jb     8002f4 <printnum+0x44>
  8002df:	77 07                	ja     8002e8 <printnum+0x38>
  8002e1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002e4:	39 d0                	cmp    %edx,%eax
  8002e6:	76 0c                	jbe    8002f4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e8:	83 eb 01             	sub    $0x1,%ebx
  8002eb:	85 db                	test   %ebx,%ebx
  8002ed:	8d 76 00             	lea    0x0(%esi),%esi
  8002f0:	7f 61                	jg     800353 <printnum+0xa3>
  8002f2:	eb 70                	jmp    800364 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002f8:	83 eb 01             	sub    $0x1,%ebx
  8002fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800303:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800307:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80030b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80030e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800311:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800314:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800318:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031f:	00 
  800320:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800323:	89 04 24             	mov    %eax,(%esp)
  800326:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800329:	89 54 24 04          	mov    %edx,0x4(%esp)
  80032d:	e8 9e 0b 00 00       	call   800ed0 <__udivdi3>
  800332:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800335:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800338:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80033c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800340:	89 04 24             	mov    %eax,(%esp)
  800343:	89 54 24 04          	mov    %edx,0x4(%esp)
  800347:	89 f2                	mov    %esi,%edx
  800349:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80034c:	e8 5f ff ff ff       	call   8002b0 <printnum>
  800351:	eb 11                	jmp    800364 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800353:	89 74 24 04          	mov    %esi,0x4(%esp)
  800357:	89 3c 24             	mov    %edi,(%esp)
  80035a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80035d:	83 eb 01             	sub    $0x1,%ebx
  800360:	85 db                	test   %ebx,%ebx
  800362:	7f ef                	jg     800353 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800364:	89 74 24 04          	mov    %esi,0x4(%esp)
  800368:	8b 74 24 04          	mov    0x4(%esp),%esi
  80036c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80036f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800373:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80037a:	00 
  80037b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80037e:	89 14 24             	mov    %edx,(%esp)
  800381:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800384:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800388:	e8 73 0c 00 00       	call   801000 <__umoddi3>
  80038d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800391:	0f be 80 2b 12 80 00 	movsbl 0x80122b(%eax),%eax
  800398:	89 04 24             	mov    %eax,(%esp)
  80039b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80039e:	83 c4 4c             	add    $0x4c,%esp
  8003a1:	5b                   	pop    %ebx
  8003a2:	5e                   	pop    %esi
  8003a3:	5f                   	pop    %edi
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a9:	83 fa 01             	cmp    $0x1,%edx
  8003ac:	7e 0e                	jle    8003bc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ae:	8b 10                	mov    (%eax),%edx
  8003b0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003b3:	89 08                	mov    %ecx,(%eax)
  8003b5:	8b 02                	mov    (%edx),%eax
  8003b7:	8b 52 04             	mov    0x4(%edx),%edx
  8003ba:	eb 22                	jmp    8003de <getuint+0x38>
	else if (lflag)
  8003bc:	85 d2                	test   %edx,%edx
  8003be:	74 10                	je     8003d0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003c0:	8b 10                	mov    (%eax),%edx
  8003c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c5:	89 08                	mov    %ecx,(%eax)
  8003c7:	8b 02                	mov    (%edx),%eax
  8003c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ce:	eb 0e                	jmp    8003de <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003d0:	8b 10                	mov    (%eax),%edx
  8003d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d5:	89 08                	mov    %ecx,(%eax)
  8003d7:	8b 02                	mov    (%edx),%eax
  8003d9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ea:	8b 10                	mov    (%eax),%edx
  8003ec:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ef:	73 0a                	jae    8003fb <sprintputch+0x1b>
		*b->buf++ = ch;
  8003f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f4:	88 0a                	mov    %cl,(%edx)
  8003f6:	83 c2 01             	add    $0x1,%edx
  8003f9:	89 10                	mov    %edx,(%eax)
}
  8003fb:	5d                   	pop    %ebp
  8003fc:	c3                   	ret    

008003fd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	57                   	push   %edi
  800401:	56                   	push   %esi
  800402:	53                   	push   %ebx
  800403:	83 ec 5c             	sub    $0x5c,%esp
  800406:	8b 7d 08             	mov    0x8(%ebp),%edi
  800409:	8b 75 0c             	mov    0xc(%ebp),%esi
  80040c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80040f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800416:	eb 16                	jmp    80042e <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800418:	85 c0                	test   %eax,%eax
  80041a:	0f 84 4f 04 00 00    	je     80086f <vprintfmt+0x472>
				return;
			putch(ch, putdat);
  800420:	89 74 24 04          	mov    %esi,0x4(%esp)
  800424:	89 04 24             	mov    %eax,(%esp)
  800427:	ff d7                	call   *%edi
  800429:	eb 03                	jmp    80042e <vprintfmt+0x31>
  80042b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80042e:	0f b6 03             	movzbl (%ebx),%eax
  800431:	83 c3 01             	add    $0x1,%ebx
  800434:	83 f8 25             	cmp    $0x25,%eax
  800437:	75 df                	jne    800418 <vprintfmt+0x1b>
  800439:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80043d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800444:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80044b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800452:	b9 00 00 00 00       	mov    $0x0,%ecx
  800457:	eb 06                	jmp    80045f <vprintfmt+0x62>
  800459:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  80045d:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	0f b6 13             	movzbl (%ebx),%edx
  800462:	0f b6 c2             	movzbl %dl,%eax
  800465:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800468:	8d 43 01             	lea    0x1(%ebx),%eax
  80046b:	83 ea 23             	sub    $0x23,%edx
  80046e:	80 fa 55             	cmp    $0x55,%dl
  800471:	0f 87 db 03 00 00    	ja     800852 <vprintfmt+0x455>
  800477:	0f b6 d2             	movzbl %dl,%edx
  80047a:	ff 24 95 34 13 80 00 	jmp    *0x801334(,%edx,4)
  800481:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800485:	eb d6                	jmp    80045d <vprintfmt+0x60>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800487:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80048a:	83 ea 30             	sub    $0x30,%edx
  80048d:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  800490:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800493:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800496:	83 fb 09             	cmp    $0x9,%ebx
  800499:	77 4c                	ja     8004e7 <vprintfmt+0xea>
  80049b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80049e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004a1:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8004a4:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004a7:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8004ab:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004ae:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8004b1:	83 fb 09             	cmp    $0x9,%ebx
  8004b4:	76 eb                	jbe    8004a1 <vprintfmt+0xa4>
  8004b6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004b9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004bc:	eb 29                	jmp    8004e7 <vprintfmt+0xea>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004be:	8b 55 14             	mov    0x14(%ebp),%edx
  8004c1:	8d 5a 04             	lea    0x4(%edx),%ebx
  8004c4:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004c7:	8b 12                	mov    (%edx),%edx
  8004c9:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  8004cc:	eb 19                	jmp    8004e7 <vprintfmt+0xea>

		case '.':
			if (width < 0)
  8004ce:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004d1:	c1 fa 1f             	sar    $0x1f,%edx
  8004d4:	f7 d2                	not    %edx
  8004d6:	21 55 d4             	and    %edx,-0x2c(%ebp)
  8004d9:	eb 82                	jmp    80045d <vprintfmt+0x60>
  8004db:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004e2:	e9 76 ff ff ff       	jmp    80045d <vprintfmt+0x60>

		process_precision:
			if (width < 0)
  8004e7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004eb:	0f 89 6c ff ff ff    	jns    80045d <vprintfmt+0x60>
  8004f1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004f4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004f7:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8004fa:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8004fd:	e9 5b ff ff ff       	jmp    80045d <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800502:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800505:	e9 53 ff ff ff       	jmp    80045d <vprintfmt+0x60>
  80050a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8d 50 04             	lea    0x4(%eax),%edx
  800513:	89 55 14             	mov    %edx,0x14(%ebp)
  800516:	89 74 24 04          	mov    %esi,0x4(%esp)
  80051a:	8b 00                	mov    (%eax),%eax
  80051c:	89 04 24             	mov    %eax,(%esp)
  80051f:	ff d7                	call   *%edi
  800521:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
  800524:	e9 05 ff ff ff       	jmp    80042e <vprintfmt+0x31>
  800529:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 50 04             	lea    0x4(%eax),%edx
  800532:	89 55 14             	mov    %edx,0x14(%ebp)
  800535:	8b 00                	mov    (%eax),%eax
  800537:	89 c2                	mov    %eax,%edx
  800539:	c1 fa 1f             	sar    $0x1f,%edx
  80053c:	31 d0                	xor    %edx,%eax
  80053e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800540:	83 f8 06             	cmp    $0x6,%eax
  800543:	7f 0b                	jg     800550 <vprintfmt+0x153>
  800545:	8b 14 85 8c 14 80 00 	mov    0x80148c(,%eax,4),%edx
  80054c:	85 d2                	test   %edx,%edx
  80054e:	75 20                	jne    800570 <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  800550:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800554:	c7 44 24 08 3c 12 80 	movl   $0x80123c,0x8(%esp)
  80055b:	00 
  80055c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800560:	89 3c 24             	mov    %edi,(%esp)
  800563:	e8 8f 03 00 00       	call   8008f7 <printfmt>
  800568:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80056b:	e9 be fe ff ff       	jmp    80042e <vprintfmt+0x31>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800570:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800574:	c7 44 24 08 45 12 80 	movl   $0x801245,0x8(%esp)
  80057b:	00 
  80057c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800580:	89 3c 24             	mov    %edi,(%esp)
  800583:	e8 6f 03 00 00       	call   8008f7 <printfmt>
  800588:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80058b:	e9 9e fe ff ff       	jmp    80042e <vprintfmt+0x31>
  800590:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800593:	89 c3                	mov    %eax,%ebx
  800595:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800598:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80059b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8d 50 04             	lea    0x4(%eax),%edx
  8005a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a7:	8b 00                	mov    (%eax),%eax
  8005a9:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8005ac:	85 c0                	test   %eax,%eax
  8005ae:	75 07                	jne    8005b7 <vprintfmt+0x1ba>
  8005b0:	c7 45 cc 48 12 80 00 	movl   $0x801248,-0x34(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8005b7:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005bb:	7e 06                	jle    8005c3 <vprintfmt+0x1c6>
  8005bd:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8005c1:	75 13                	jne    8005d6 <vprintfmt+0x1d9>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005c6:	0f be 02             	movsbl (%edx),%eax
  8005c9:	85 c0                	test   %eax,%eax
  8005cb:	0f 85 9f 00 00 00    	jne    800670 <vprintfmt+0x273>
  8005d1:	e9 8f 00 00 00       	jmp    800665 <vprintfmt+0x268>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005da:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005dd:	89 0c 24             	mov    %ecx,(%esp)
  8005e0:	e8 56 03 00 00       	call   80093b <strnlen>
  8005e5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005e8:	29 c2                	sub    %eax,%edx
  8005ea:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005ed:	85 d2                	test   %edx,%edx
  8005ef:	7e d2                	jle    8005c3 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005f1:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8005f5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005f8:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8005fb:	89 d3                	mov    %edx,%ebx
  8005fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800601:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800604:	89 04 24             	mov    %eax,(%esp)
  800607:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800609:	83 eb 01             	sub    $0x1,%ebx
  80060c:	85 db                	test   %ebx,%ebx
  80060e:	7f ed                	jg     8005fd <vprintfmt+0x200>
  800610:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800613:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80061a:	eb a7                	jmp    8005c3 <vprintfmt+0x1c6>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80061c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800620:	74 1b                	je     80063d <vprintfmt+0x240>
  800622:	8d 50 e0             	lea    -0x20(%eax),%edx
  800625:	83 fa 5e             	cmp    $0x5e,%edx
  800628:	76 13                	jbe    80063d <vprintfmt+0x240>
					putch('?', putdat);
  80062a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80062d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800631:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800638:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80063b:	eb 0d                	jmp    80064a <vprintfmt+0x24d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80063d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800640:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800644:	89 04 24             	mov    %eax,(%esp)
  800647:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80064a:	83 ef 01             	sub    $0x1,%edi
  80064d:	0f be 03             	movsbl (%ebx),%eax
  800650:	85 c0                	test   %eax,%eax
  800652:	74 05                	je     800659 <vprintfmt+0x25c>
  800654:	83 c3 01             	add    $0x1,%ebx
  800657:	eb 2e                	jmp    800687 <vprintfmt+0x28a>
  800659:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80065c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80065f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800662:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800665:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800669:	7f 33                	jg     80069e <vprintfmt+0x2a1>
  80066b:	e9 bb fd ff ff       	jmp    80042b <vprintfmt+0x2e>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800670:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800673:	83 c2 01             	add    $0x1,%edx
  800676:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800679:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80067c:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80067f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800682:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800685:	89 d3                	mov    %edx,%ebx
  800687:	85 f6                	test   %esi,%esi
  800689:	78 91                	js     80061c <vprintfmt+0x21f>
  80068b:	83 ee 01             	sub    $0x1,%esi
  80068e:	79 8c                	jns    80061c <vprintfmt+0x21f>
  800690:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800693:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800696:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800699:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80069c:	eb c7                	jmp    800665 <vprintfmt+0x268>
  80069e:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8006a1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006af:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b1:	83 eb 01             	sub    $0x1,%ebx
  8006b4:	85 db                	test   %ebx,%ebx
  8006b6:	7f ec                	jg     8006a4 <vprintfmt+0x2a7>
  8006b8:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8006bb:	e9 6e fd ff ff       	jmp    80042e <vprintfmt+0x31>
  8006c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c3:	83 f9 01             	cmp    $0x1,%ecx
  8006c6:	7e 16                	jle    8006de <vprintfmt+0x2e1>
		return va_arg(*ap, long long);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8d 50 08             	lea    0x8(%eax),%edx
  8006ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d1:	8b 10                	mov    (%eax),%edx
  8006d3:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d6:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8006d9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006dc:	eb 32                	jmp    800710 <vprintfmt+0x313>
	else if (lflag)
  8006de:	85 c9                	test   %ecx,%ecx
  8006e0:	74 18                	je     8006fa <vprintfmt+0x2fd>
		return va_arg(*ap, long);
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	8d 50 04             	lea    0x4(%eax),%edx
  8006e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006eb:	8b 00                	mov    (%eax),%eax
  8006ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f0:	89 c1                	mov    %eax,%ecx
  8006f2:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006f8:	eb 16                	jmp    800710 <vprintfmt+0x313>
	else
		return va_arg(*ap, int);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8d 50 04             	lea    0x4(%eax),%edx
  800700:	89 55 14             	mov    %edx,0x14(%ebp)
  800703:	8b 00                	mov    (%eax),%eax
  800705:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800708:	89 c2                	mov    %eax,%edx
  80070a:	c1 fa 1f             	sar    $0x1f,%edx
  80070d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800710:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800713:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800716:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  80071b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80071f:	0f 89 8a 00 00 00    	jns    8007af <vprintfmt+0x3b2>
				putch('-', putdat);
  800725:	89 74 24 04          	mov    %esi,0x4(%esp)
  800729:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800730:	ff d7                	call   *%edi
				num = -(long long) num;
  800732:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800735:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800738:	f7 d8                	neg    %eax
  80073a:	83 d2 00             	adc    $0x0,%edx
  80073d:	f7 da                	neg    %edx
  80073f:	eb 6e                	jmp    8007af <vprintfmt+0x3b2>
  800741:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800744:	89 ca                	mov    %ecx,%edx
  800746:	8d 45 14             	lea    0x14(%ebp),%eax
  800749:	e8 58 fc ff ff       	call   8003a6 <getuint>
  80074e:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  800753:	eb 5a                	jmp    8007af <vprintfmt+0x3b2>
  800755:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			//break;
			num = getuint(&ap, lflag);
  800758:	89 ca                	mov    %ecx,%edx
  80075a:	8d 45 14             	lea    0x14(%ebp),%eax
  80075d:	e8 44 fc ff ff       	call   8003a6 <getuint>
  800762:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800767:	eb 46                	jmp    8007af <vprintfmt+0x3b2>
  800769:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  80076c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800770:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800777:	ff d7                	call   *%edi
			putch('x', putdat);
  800779:	89 74 24 04          	mov    %esi,0x4(%esp)
  80077d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800784:	ff d7                	call   *%edi
			num = (unsigned long long)
  800786:	8b 45 14             	mov    0x14(%ebp),%eax
  800789:	8d 50 04             	lea    0x4(%eax),%edx
  80078c:	89 55 14             	mov    %edx,0x14(%ebp)
  80078f:	8b 00                	mov    (%eax),%eax
  800791:	ba 00 00 00 00       	mov    $0x0,%edx
  800796:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80079b:	eb 12                	jmp    8007af <vprintfmt+0x3b2>
  80079d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007a0:	89 ca                	mov    %ecx,%edx
  8007a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a5:	e8 fc fb ff ff       	call   8003a6 <getuint>
  8007aa:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007af:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8007b3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8007b7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8007ba:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8007be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007c2:	89 04 24             	mov    %eax,(%esp)
  8007c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007c9:	89 f2                	mov    %esi,%edx
  8007cb:	89 f8                	mov    %edi,%eax
  8007cd:	e8 de fa ff ff       	call   8002b0 <printnum>
  8007d2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
  8007d5:	e9 54 fc ff ff       	jmp    80042e <vprintfmt+0x31>
  8007da:	89 45 e4             	mov    %eax,-0x1c(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			char* tmp = va_arg(ap, char*);
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8d 50 04             	lea    0x4(%eax),%edx
  8007e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e6:	8b 00                	mov    (%eax),%eax
			if(tmp == NULL) {
  8007e8:	85 c0                	test   %eax,%eax
  8007ea:	75 1f                	jne    80080b <vprintfmt+0x40e>
  8007ec:	bb b9 12 80 00       	mov    $0x8012b9,%ebx
  8007f1:	b0 0a                	mov    $0xa,%al
				for(; (ch = *null_error++) != '\0';) {	
					putch(ch, putdat);
  8007f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007f7:	89 04 24             	mov    %eax,(%esp)
  8007fa:	ff d7                	call   *%edi
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			char* tmp = va_arg(ap, char*);
			if(tmp == NULL) {
				for(; (ch = *null_error++) != '\0';) {	
  8007fc:	0f be 03             	movsbl (%ebx),%eax
  8007ff:	83 c3 01             	add    $0x1,%ebx
  800802:	85 c0                	test   %eax,%eax
  800804:	75 ed                	jne    8007f3 <vprintfmt+0x3f6>
  800806:	e9 20 fc ff ff       	jmp    80042b <vprintfmt+0x2e>
					putch(ch, putdat);
				}
				break;
			}
			*tmp = *((signed char*) putdat);
  80080b:	0f b6 16             	movzbl (%esi),%edx
  80080e:	88 10                	mov    %dl,(%eax)
			if(*(signed char*) putdat < 0) {
  800810:	80 3e 00             	cmpb   $0x0,(%esi)
  800813:	0f 89 12 fc ff ff    	jns    80042b <vprintfmt+0x2e>
  800819:	bb f1 12 80 00       	mov    $0x8012f1,%ebx
  80081e:	b8 0a 00 00 00       	mov    $0xa,%eax
				for(; (ch = *overflow_error++) != '\0';) {	
					putch(ch, putdat);
  800823:	89 74 24 04          	mov    %esi,0x4(%esp)
  800827:	89 04 24             	mov    %eax,(%esp)
  80082a:	ff d7                	call   *%edi
				}
				break;
			}
			*tmp = *((signed char*) putdat);
			if(*(signed char*) putdat < 0) {
				for(; (ch = *overflow_error++) != '\0';) {	
  80082c:	0f be 03             	movsbl (%ebx),%eax
  80082f:	83 c3 01             	add    $0x1,%ebx
  800832:	85 c0                	test   %eax,%eax
  800834:	75 ed                	jne    800823 <vprintfmt+0x426>
  800836:	e9 f0 fb ff ff       	jmp    80042b <vprintfmt+0x2e>
  80083b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80083e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800841:	89 74 24 04          	mov    %esi,0x4(%esp)
  800845:	89 14 24             	mov    %edx,(%esp)
  800848:	ff d7                	call   *%edi
  80084a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
  80084d:	e9 dc fb ff ff       	jmp    80042e <vprintfmt+0x31>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800852:	89 74 24 04          	mov    %esi,0x4(%esp)
  800856:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80085d:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80085f:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800862:	80 38 25             	cmpb   $0x25,(%eax)
  800865:	0f 84 c3 fb ff ff    	je     80042e <vprintfmt+0x31>
  80086b:	89 c3                	mov    %eax,%ebx
  80086d:	eb f0                	jmp    80085f <vprintfmt+0x462>
				/* do nothing */;
			break;
		}
	}
}
  80086f:	83 c4 5c             	add    $0x5c,%esp
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5f                   	pop    %edi
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	83 ec 28             	sub    $0x28,%esp
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800883:	85 c0                	test   %eax,%eax
  800885:	74 04                	je     80088b <vsnprintf+0x14>
  800887:	85 d2                	test   %edx,%edx
  800889:	7f 07                	jg     800892 <vsnprintf+0x1b>
  80088b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800890:	eb 3b                	jmp    8008cd <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800892:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800895:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800899:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80089c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b8:	c7 04 24 e0 03 80 00 	movl   $0x8003e0,(%esp)
  8008bf:	e8 39 fb ff ff       	call   8003fd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008cd:	c9                   	leave  
  8008ce:	c3                   	ret    

008008cf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8008d5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8008d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8008df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	89 04 24             	mov    %eax,(%esp)
  8008f0:	e8 82 ff ff ff       	call   800877 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008f5:	c9                   	leave  
  8008f6:	c3                   	ret    

008008f7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8008fd:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800900:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800904:	8b 45 10             	mov    0x10(%ebp),%eax
  800907:	89 44 24 08          	mov    %eax,0x8(%esp)
  80090b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	89 04 24             	mov    %eax,(%esp)
  800918:	e8 e0 fa ff ff       	call   8003fd <vprintfmt>
	va_end(ap);
}
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    
	...

00800920 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800926:	b8 00 00 00 00       	mov    $0x0,%eax
  80092b:	80 3a 00             	cmpb   $0x0,(%edx)
  80092e:	74 09                	je     800939 <strlen+0x19>
		n++;
  800930:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800933:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800937:	75 f7                	jne    800930 <strlen+0x10>
		n++;
	return n;
}
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	53                   	push   %ebx
  80093f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800942:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800945:	85 c9                	test   %ecx,%ecx
  800947:	74 19                	je     800962 <strnlen+0x27>
  800949:	80 3b 00             	cmpb   $0x0,(%ebx)
  80094c:	74 14                	je     800962 <strnlen+0x27>
  80094e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800953:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800956:	39 c8                	cmp    %ecx,%eax
  800958:	74 0d                	je     800967 <strnlen+0x2c>
  80095a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80095e:	75 f3                	jne    800953 <strnlen+0x18>
  800960:	eb 05                	jmp    800967 <strnlen+0x2c>
  800962:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800967:	5b                   	pop    %ebx
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	53                   	push   %ebx
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800974:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800979:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80097d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800980:	83 c2 01             	add    $0x1,%edx
  800983:	84 c9                	test   %cl,%cl
  800985:	75 f2                	jne    800979 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800987:	5b                   	pop    %ebx
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	53                   	push   %ebx
  80098e:	83 ec 08             	sub    $0x8,%esp
  800991:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800994:	89 1c 24             	mov    %ebx,(%esp)
  800997:	e8 84 ff ff ff       	call   800920 <strlen>
	strcpy(dst + len, src);
  80099c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099f:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009a3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8009a6:	89 04 24             	mov    %eax,(%esp)
  8009a9:	e8 bc ff ff ff       	call   80096a <strcpy>
	return dst;
}
  8009ae:	89 d8                	mov    %ebx,%eax
  8009b0:	83 c4 08             	add    $0x8,%esp
  8009b3:	5b                   	pop    %ebx
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	56                   	push   %esi
  8009ba:	53                   	push   %ebx
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c4:	85 f6                	test   %esi,%esi
  8009c6:	74 18                	je     8009e0 <strncpy+0x2a>
  8009c8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009cd:	0f b6 1a             	movzbl (%edx),%ebx
  8009d0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009d3:	80 3a 01             	cmpb   $0x1,(%edx)
  8009d6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d9:	83 c1 01             	add    $0x1,%ecx
  8009dc:	39 ce                	cmp    %ecx,%esi
  8009de:	77 ed                	ja     8009cd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009e0:	5b                   	pop    %ebx
  8009e1:	5e                   	pop    %esi
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
  8009e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009f2:	89 f0                	mov    %esi,%eax
  8009f4:	85 c9                	test   %ecx,%ecx
  8009f6:	74 27                	je     800a1f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8009f8:	83 e9 01             	sub    $0x1,%ecx
  8009fb:	74 1d                	je     800a1a <strlcpy+0x36>
  8009fd:	0f b6 1a             	movzbl (%edx),%ebx
  800a00:	84 db                	test   %bl,%bl
  800a02:	74 16                	je     800a1a <strlcpy+0x36>
			*dst++ = *src++;
  800a04:	88 18                	mov    %bl,(%eax)
  800a06:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a09:	83 e9 01             	sub    $0x1,%ecx
  800a0c:	74 0e                	je     800a1c <strlcpy+0x38>
			*dst++ = *src++;
  800a0e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a11:	0f b6 1a             	movzbl (%edx),%ebx
  800a14:	84 db                	test   %bl,%bl
  800a16:	75 ec                	jne    800a04 <strlcpy+0x20>
  800a18:	eb 02                	jmp    800a1c <strlcpy+0x38>
  800a1a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a1c:	c6 00 00             	movb   $0x0,(%eax)
  800a1f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800a21:	5b                   	pop    %ebx
  800a22:	5e                   	pop    %esi
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a2e:	0f b6 01             	movzbl (%ecx),%eax
  800a31:	84 c0                	test   %al,%al
  800a33:	74 15                	je     800a4a <strcmp+0x25>
  800a35:	3a 02                	cmp    (%edx),%al
  800a37:	75 11                	jne    800a4a <strcmp+0x25>
		p++, q++;
  800a39:	83 c1 01             	add    $0x1,%ecx
  800a3c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a3f:	0f b6 01             	movzbl (%ecx),%eax
  800a42:	84 c0                	test   %al,%al
  800a44:	74 04                	je     800a4a <strcmp+0x25>
  800a46:	3a 02                	cmp    (%edx),%al
  800a48:	74 ef                	je     800a39 <strcmp+0x14>
  800a4a:	0f b6 c0             	movzbl %al,%eax
  800a4d:	0f b6 12             	movzbl (%edx),%edx
  800a50:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	53                   	push   %ebx
  800a58:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a61:	85 c0                	test   %eax,%eax
  800a63:	74 23                	je     800a88 <strncmp+0x34>
  800a65:	0f b6 1a             	movzbl (%edx),%ebx
  800a68:	84 db                	test   %bl,%bl
  800a6a:	74 25                	je     800a91 <strncmp+0x3d>
  800a6c:	3a 19                	cmp    (%ecx),%bl
  800a6e:	75 21                	jne    800a91 <strncmp+0x3d>
  800a70:	83 e8 01             	sub    $0x1,%eax
  800a73:	74 13                	je     800a88 <strncmp+0x34>
		n--, p++, q++;
  800a75:	83 c2 01             	add    $0x1,%edx
  800a78:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a7b:	0f b6 1a             	movzbl (%edx),%ebx
  800a7e:	84 db                	test   %bl,%bl
  800a80:	74 0f                	je     800a91 <strncmp+0x3d>
  800a82:	3a 19                	cmp    (%ecx),%bl
  800a84:	74 ea                	je     800a70 <strncmp+0x1c>
  800a86:	eb 09                	jmp    800a91 <strncmp+0x3d>
  800a88:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a8d:	5b                   	pop    %ebx
  800a8e:	5d                   	pop    %ebp
  800a8f:	90                   	nop
  800a90:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a91:	0f b6 02             	movzbl (%edx),%eax
  800a94:	0f b6 11             	movzbl (%ecx),%edx
  800a97:	29 d0                	sub    %edx,%eax
  800a99:	eb f2                	jmp    800a8d <strncmp+0x39>

00800a9b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa5:	0f b6 10             	movzbl (%eax),%edx
  800aa8:	84 d2                	test   %dl,%dl
  800aaa:	74 18                	je     800ac4 <strchr+0x29>
		if (*s == c)
  800aac:	38 ca                	cmp    %cl,%dl
  800aae:	75 0a                	jne    800aba <strchr+0x1f>
  800ab0:	eb 17                	jmp    800ac9 <strchr+0x2e>
  800ab2:	38 ca                	cmp    %cl,%dl
  800ab4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ab8:	74 0f                	je     800ac9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aba:	83 c0 01             	add    $0x1,%eax
  800abd:	0f b6 10             	movzbl (%eax),%edx
  800ac0:	84 d2                	test   %dl,%dl
  800ac2:	75 ee                	jne    800ab2 <strchr+0x17>
  800ac4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad5:	0f b6 10             	movzbl (%eax),%edx
  800ad8:	84 d2                	test   %dl,%dl
  800ada:	74 18                	je     800af4 <strfind+0x29>
		if (*s == c)
  800adc:	38 ca                	cmp    %cl,%dl
  800ade:	75 0a                	jne    800aea <strfind+0x1f>
  800ae0:	eb 12                	jmp    800af4 <strfind+0x29>
  800ae2:	38 ca                	cmp    %cl,%dl
  800ae4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ae8:	74 0a                	je     800af4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aea:	83 c0 01             	add    $0x1,%eax
  800aed:	0f b6 10             	movzbl (%eax),%edx
  800af0:	84 d2                	test   %dl,%dl
  800af2:	75 ee                	jne    800ae2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	83 ec 0c             	sub    $0xc,%esp
  800afc:	89 1c 24             	mov    %ebx,(%esp)
  800aff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b03:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800b07:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b10:	85 c9                	test   %ecx,%ecx
  800b12:	74 30                	je     800b44 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b14:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b1a:	75 25                	jne    800b41 <memset+0x4b>
  800b1c:	f6 c1 03             	test   $0x3,%cl
  800b1f:	75 20                	jne    800b41 <memset+0x4b>
		c &= 0xFF;
  800b21:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b24:	89 d3                	mov    %edx,%ebx
  800b26:	c1 e3 08             	shl    $0x8,%ebx
  800b29:	89 d6                	mov    %edx,%esi
  800b2b:	c1 e6 18             	shl    $0x18,%esi
  800b2e:	89 d0                	mov    %edx,%eax
  800b30:	c1 e0 10             	shl    $0x10,%eax
  800b33:	09 f0                	or     %esi,%eax
  800b35:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800b37:	09 d8                	or     %ebx,%eax
  800b39:	c1 e9 02             	shr    $0x2,%ecx
  800b3c:	fc                   	cld    
  800b3d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b3f:	eb 03                	jmp    800b44 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b41:	fc                   	cld    
  800b42:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b44:	89 f8                	mov    %edi,%eax
  800b46:	8b 1c 24             	mov    (%esp),%ebx
  800b49:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b4d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b51:	89 ec                	mov    %ebp,%esp
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	83 ec 08             	sub    $0x8,%esp
  800b5b:	89 34 24             	mov    %esi,(%esp)
  800b5e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b62:	8b 45 08             	mov    0x8(%ebp),%eax
  800b65:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800b68:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b6b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b6d:	39 c6                	cmp    %eax,%esi
  800b6f:	73 35                	jae    800ba6 <memmove+0x51>
  800b71:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b74:	39 d0                	cmp    %edx,%eax
  800b76:	73 2e                	jae    800ba6 <memmove+0x51>
		s += n;
		d += n;
  800b78:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7a:	f6 c2 03             	test   $0x3,%dl
  800b7d:	75 1b                	jne    800b9a <memmove+0x45>
  800b7f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b85:	75 13                	jne    800b9a <memmove+0x45>
  800b87:	f6 c1 03             	test   $0x3,%cl
  800b8a:	75 0e                	jne    800b9a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800b8c:	83 ef 04             	sub    $0x4,%edi
  800b8f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b92:	c1 e9 02             	shr    $0x2,%ecx
  800b95:	fd                   	std    
  800b96:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b98:	eb 09                	jmp    800ba3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b9a:	83 ef 01             	sub    $0x1,%edi
  800b9d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ba0:	fd                   	std    
  800ba1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ba3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ba4:	eb 20                	jmp    800bc6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bac:	75 15                	jne    800bc3 <memmove+0x6e>
  800bae:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bb4:	75 0d                	jne    800bc3 <memmove+0x6e>
  800bb6:	f6 c1 03             	test   $0x3,%cl
  800bb9:	75 08                	jne    800bc3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800bbb:	c1 e9 02             	shr    $0x2,%ecx
  800bbe:	fc                   	cld    
  800bbf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc1:	eb 03                	jmp    800bc6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bc3:	fc                   	cld    
  800bc4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bc6:	8b 34 24             	mov    (%esp),%esi
  800bc9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bcd:	89 ec                	mov    %ebp,%esp
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bd7:	8b 45 10             	mov    0x10(%ebp),%eax
  800bda:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bde:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be5:	8b 45 08             	mov    0x8(%ebp),%eax
  800be8:	89 04 24             	mov    %eax,(%esp)
  800beb:	e8 65 ff ff ff       	call   800b55 <memmove>
}
  800bf0:	c9                   	leave  
  800bf1:	c3                   	ret    

00800bf2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	8b 75 08             	mov    0x8(%ebp),%esi
  800bfb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800bfe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c01:	85 c9                	test   %ecx,%ecx
  800c03:	74 36                	je     800c3b <memcmp+0x49>
		if (*s1 != *s2)
  800c05:	0f b6 06             	movzbl (%esi),%eax
  800c08:	0f b6 1f             	movzbl (%edi),%ebx
  800c0b:	38 d8                	cmp    %bl,%al
  800c0d:	74 20                	je     800c2f <memcmp+0x3d>
  800c0f:	eb 14                	jmp    800c25 <memcmp+0x33>
  800c11:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800c16:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800c1b:	83 c2 01             	add    $0x1,%edx
  800c1e:	83 e9 01             	sub    $0x1,%ecx
  800c21:	38 d8                	cmp    %bl,%al
  800c23:	74 12                	je     800c37 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800c25:	0f b6 c0             	movzbl %al,%eax
  800c28:	0f b6 db             	movzbl %bl,%ebx
  800c2b:	29 d8                	sub    %ebx,%eax
  800c2d:	eb 11                	jmp    800c40 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c2f:	83 e9 01             	sub    $0x1,%ecx
  800c32:	ba 00 00 00 00       	mov    $0x0,%edx
  800c37:	85 c9                	test   %ecx,%ecx
  800c39:	75 d6                	jne    800c11 <memcmp+0x1f>
  800c3b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c4b:	89 c2                	mov    %eax,%edx
  800c4d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c50:	39 d0                	cmp    %edx,%eax
  800c52:	73 15                	jae    800c69 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c58:	38 08                	cmp    %cl,(%eax)
  800c5a:	75 06                	jne    800c62 <memfind+0x1d>
  800c5c:	eb 0b                	jmp    800c69 <memfind+0x24>
  800c5e:	38 08                	cmp    %cl,(%eax)
  800c60:	74 07                	je     800c69 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c62:	83 c0 01             	add    $0x1,%eax
  800c65:	39 c2                	cmp    %eax,%edx
  800c67:	77 f5                	ja     800c5e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	83 ec 04             	sub    $0x4,%esp
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c7a:	0f b6 02             	movzbl (%edx),%eax
  800c7d:	3c 20                	cmp    $0x20,%al
  800c7f:	74 04                	je     800c85 <strtol+0x1a>
  800c81:	3c 09                	cmp    $0x9,%al
  800c83:	75 0e                	jne    800c93 <strtol+0x28>
		s++;
  800c85:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c88:	0f b6 02             	movzbl (%edx),%eax
  800c8b:	3c 20                	cmp    $0x20,%al
  800c8d:	74 f6                	je     800c85 <strtol+0x1a>
  800c8f:	3c 09                	cmp    $0x9,%al
  800c91:	74 f2                	je     800c85 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c93:	3c 2b                	cmp    $0x2b,%al
  800c95:	75 0c                	jne    800ca3 <strtol+0x38>
		s++;
  800c97:	83 c2 01             	add    $0x1,%edx
  800c9a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ca1:	eb 15                	jmp    800cb8 <strtol+0x4d>
	else if (*s == '-')
  800ca3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800caa:	3c 2d                	cmp    $0x2d,%al
  800cac:	75 0a                	jne    800cb8 <strtol+0x4d>
		s++, neg = 1;
  800cae:	83 c2 01             	add    $0x1,%edx
  800cb1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cb8:	85 db                	test   %ebx,%ebx
  800cba:	0f 94 c0             	sete   %al
  800cbd:	74 05                	je     800cc4 <strtol+0x59>
  800cbf:	83 fb 10             	cmp    $0x10,%ebx
  800cc2:	75 18                	jne    800cdc <strtol+0x71>
  800cc4:	80 3a 30             	cmpb   $0x30,(%edx)
  800cc7:	75 13                	jne    800cdc <strtol+0x71>
  800cc9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ccd:	8d 76 00             	lea    0x0(%esi),%esi
  800cd0:	75 0a                	jne    800cdc <strtol+0x71>
		s += 2, base = 16;
  800cd2:	83 c2 02             	add    $0x2,%edx
  800cd5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cda:	eb 15                	jmp    800cf1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cdc:	84 c0                	test   %al,%al
  800cde:	66 90                	xchg   %ax,%ax
  800ce0:	74 0f                	je     800cf1 <strtol+0x86>
  800ce2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ce7:	80 3a 30             	cmpb   $0x30,(%edx)
  800cea:	75 05                	jne    800cf1 <strtol+0x86>
		s++, base = 8;
  800cec:	83 c2 01             	add    $0x1,%edx
  800cef:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cf1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cf8:	0f b6 0a             	movzbl (%edx),%ecx
  800cfb:	89 cf                	mov    %ecx,%edi
  800cfd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d00:	80 fb 09             	cmp    $0x9,%bl
  800d03:	77 08                	ja     800d0d <strtol+0xa2>
			dig = *s - '0';
  800d05:	0f be c9             	movsbl %cl,%ecx
  800d08:	83 e9 30             	sub    $0x30,%ecx
  800d0b:	eb 1e                	jmp    800d2b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800d0d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800d10:	80 fb 19             	cmp    $0x19,%bl
  800d13:	77 08                	ja     800d1d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800d15:	0f be c9             	movsbl %cl,%ecx
  800d18:	83 e9 57             	sub    $0x57,%ecx
  800d1b:	eb 0e                	jmp    800d2b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800d1d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800d20:	80 fb 19             	cmp    $0x19,%bl
  800d23:	77 15                	ja     800d3a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800d25:	0f be c9             	movsbl %cl,%ecx
  800d28:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d2b:	39 f1                	cmp    %esi,%ecx
  800d2d:	7d 0b                	jge    800d3a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800d2f:	83 c2 01             	add    $0x1,%edx
  800d32:	0f af c6             	imul   %esi,%eax
  800d35:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800d38:	eb be                	jmp    800cf8 <strtol+0x8d>
  800d3a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800d3c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d40:	74 05                	je     800d47 <strtol+0xdc>
		*endptr = (char *) s;
  800d42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d45:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d47:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800d4b:	74 04                	je     800d51 <strtol+0xe6>
  800d4d:	89 c8                	mov    %ecx,%eax
  800d4f:	f7 d8                	neg    %eax
}
  800d51:	83 c4 04             	add    $0x4,%esp
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    
  800d59:	00 00                	add    %al,(%eax)
	...

00800d5c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	83 ec 08             	sub    $0x8,%esp
  800d62:	89 1c 24             	mov    %ebx,(%esp)
  800d65:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d69:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	89 c3                	mov    %eax,%ebx
  800d76:	89 c7                	mov    %eax,%edi
  800d78:	51                   	push   %ecx
  800d79:	52                   	push   %edx
  800d7a:	53                   	push   %ebx
  800d7b:	54                   	push   %esp
  800d7c:	55                   	push   %ebp
  800d7d:	56                   	push   %esi
  800d7e:	57                   	push   %edi
  800d7f:	8d 35 89 0d 80 00    	lea    0x800d89,%esi
  800d85:	54                   	push   %esp
  800d86:	5d                   	pop    %ebp
  800d87:	0f 34                	sysenter 
  800d89:	5f                   	pop    %edi
  800d8a:	5e                   	pop    %esi
  800d8b:	5d                   	pop    %ebp
  800d8c:	5c                   	pop    %esp
  800d8d:	5b                   	pop    %ebx
  800d8e:	5a                   	pop    %edx
  800d8f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d90:	8b 1c 24             	mov    (%esp),%ebx
  800d93:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d97:	89 ec                	mov    %ebp,%esp
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <sys_cgetc>:

int
sys_cgetc(void)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	83 ec 08             	sub    $0x8,%esp
  800da1:	89 1c 24             	mov    %ebx,(%esp)
  800da4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800da8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dad:	b8 01 00 00 00       	mov    $0x1,%eax
  800db2:	89 d1                	mov    %edx,%ecx
  800db4:	89 d3                	mov    %edx,%ebx
  800db6:	89 d7                	mov    %edx,%edi
  800db8:	51                   	push   %ecx
  800db9:	52                   	push   %edx
  800dba:	53                   	push   %ebx
  800dbb:	54                   	push   %esp
  800dbc:	55                   	push   %ebp
  800dbd:	56                   	push   %esi
  800dbe:	57                   	push   %edi
  800dbf:	8d 35 c9 0d 80 00    	lea    0x800dc9,%esi
  800dc5:	54                   	push   %esp
  800dc6:	5d                   	pop    %ebp
  800dc7:	0f 34                	sysenter 
  800dc9:	5f                   	pop    %edi
  800dca:	5e                   	pop    %esi
  800dcb:	5d                   	pop    %ebp
  800dcc:	5c                   	pop    %esp
  800dcd:	5b                   	pop    %ebx
  800dce:	5a                   	pop    %edx
  800dcf:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dd0:	8b 1c 24             	mov    (%esp),%ebx
  800dd3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800dd7:	89 ec                	mov    %ebp,%esp
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	83 ec 08             	sub    $0x8,%esp
  800de1:	89 1c 24             	mov    %ebx,(%esp)
  800de4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800de8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ded:	b8 02 00 00 00       	mov    $0x2,%eax
  800df2:	89 d1                	mov    %edx,%ecx
  800df4:	89 d3                	mov    %edx,%ebx
  800df6:	89 d7                	mov    %edx,%edi
  800df8:	51                   	push   %ecx
  800df9:	52                   	push   %edx
  800dfa:	53                   	push   %ebx
  800dfb:	54                   	push   %esp
  800dfc:	55                   	push   %ebp
  800dfd:	56                   	push   %esi
  800dfe:	57                   	push   %edi
  800dff:	8d 35 09 0e 80 00    	lea    0x800e09,%esi
  800e05:	54                   	push   %esp
  800e06:	5d                   	pop    %ebp
  800e07:	0f 34                	sysenter 
  800e09:	5f                   	pop    %edi
  800e0a:	5e                   	pop    %esi
  800e0b:	5d                   	pop    %ebp
  800e0c:	5c                   	pop    %esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5a                   	pop    %edx
  800e0f:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e10:	8b 1c 24             	mov    (%esp),%ebx
  800e13:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e17:	89 ec                	mov    %ebp,%esp
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	83 ec 08             	sub    $0x8,%esp
  800e21:	89 1c 24             	mov    %ebx,(%esp)
  800e24:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2d:	b8 04 00 00 00       	mov    $0x4,%eax
  800e32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e35:	8b 55 08             	mov    0x8(%ebp),%edx
  800e38:	89 df                	mov    %ebx,%edi
  800e3a:	51                   	push   %ecx
  800e3b:	52                   	push   %edx
  800e3c:	53                   	push   %ebx
  800e3d:	54                   	push   %esp
  800e3e:	55                   	push   %ebp
  800e3f:	56                   	push   %esi
  800e40:	57                   	push   %edi
  800e41:	8d 35 4b 0e 80 00    	lea    0x800e4b,%esi
  800e47:	54                   	push   %esp
  800e48:	5d                   	pop    %ebp
  800e49:	0f 34                	sysenter 
  800e4b:	5f                   	pop    %edi
  800e4c:	5e                   	pop    %esi
  800e4d:	5d                   	pop    %ebp
  800e4e:	5c                   	pop    %esp
  800e4f:	5b                   	pop    %ebx
  800e50:	5a                   	pop    %edx
  800e51:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800e52:	8b 1c 24             	mov    (%esp),%ebx
  800e55:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e59:	89 ec                	mov    %ebp,%esp
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	83 ec 28             	sub    $0x28,%esp
  800e63:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800e66:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e69:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e6e:	b8 03 00 00 00       	mov    $0x3,%eax
  800e73:	8b 55 08             	mov    0x8(%ebp),%edx
  800e76:	89 cb                	mov    %ecx,%ebx
  800e78:	89 cf                	mov    %ecx,%edi
  800e7a:	51                   	push   %ecx
  800e7b:	52                   	push   %edx
  800e7c:	53                   	push   %ebx
  800e7d:	54                   	push   %esp
  800e7e:	55                   	push   %ebp
  800e7f:	56                   	push   %esi
  800e80:	57                   	push   %edi
  800e81:	8d 35 8b 0e 80 00    	lea    0x800e8b,%esi
  800e87:	54                   	push   %esp
  800e88:	5d                   	pop    %ebp
  800e89:	0f 34                	sysenter 
  800e8b:	5f                   	pop    %edi
  800e8c:	5e                   	pop    %esi
  800e8d:	5d                   	pop    %ebp
  800e8e:	5c                   	pop    %esp
  800e8f:	5b                   	pop    %ebx
  800e90:	5a                   	pop    %edx
  800e91:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800e92:	85 c0                	test   %eax,%eax
  800e94:	7e 28                	jle    800ebe <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e96:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e9a:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ea1:	00 
  800ea2:	c7 44 24 08 a8 14 80 	movl   $0x8014a8,0x8(%esp)
  800ea9:	00 
  800eaa:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  800eb1:	00 
  800eb2:	c7 04 24 c5 14 80 00 	movl   $0x8014c5,(%esp)
  800eb9:	e8 c2 f2 ff ff       	call   800180 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ebe:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800ec1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ec4:	89 ec                	mov    %ebp,%esp
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    
	...

00800ed0 <__udivdi3>:
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	83 ec 10             	sub    $0x10,%esp
  800ed8:	8b 45 14             	mov    0x14(%ebp),%eax
  800edb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ede:	8b 75 10             	mov    0x10(%ebp),%esi
  800ee1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800ee9:	75 35                	jne    800f20 <__udivdi3+0x50>
  800eeb:	39 fe                	cmp    %edi,%esi
  800eed:	77 61                	ja     800f50 <__udivdi3+0x80>
  800eef:	85 f6                	test   %esi,%esi
  800ef1:	75 0b                	jne    800efe <__udivdi3+0x2e>
  800ef3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef8:	31 d2                	xor    %edx,%edx
  800efa:	f7 f6                	div    %esi
  800efc:	89 c6                	mov    %eax,%esi
  800efe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800f01:	31 d2                	xor    %edx,%edx
  800f03:	89 f8                	mov    %edi,%eax
  800f05:	f7 f6                	div    %esi
  800f07:	89 c7                	mov    %eax,%edi
  800f09:	89 c8                	mov    %ecx,%eax
  800f0b:	f7 f6                	div    %esi
  800f0d:	89 c1                	mov    %eax,%ecx
  800f0f:	89 fa                	mov    %edi,%edx
  800f11:	89 c8                	mov    %ecx,%eax
  800f13:	83 c4 10             	add    $0x10,%esp
  800f16:	5e                   	pop    %esi
  800f17:	5f                   	pop    %edi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    
  800f1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f20:	39 f8                	cmp    %edi,%eax
  800f22:	77 1c                	ja     800f40 <__udivdi3+0x70>
  800f24:	0f bd d0             	bsr    %eax,%edx
  800f27:	83 f2 1f             	xor    $0x1f,%edx
  800f2a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800f2d:	75 39                	jne    800f68 <__udivdi3+0x98>
  800f2f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  800f32:	0f 86 a0 00 00 00    	jbe    800fd8 <__udivdi3+0x108>
  800f38:	39 f8                	cmp    %edi,%eax
  800f3a:	0f 82 98 00 00 00    	jb     800fd8 <__udivdi3+0x108>
  800f40:	31 ff                	xor    %edi,%edi
  800f42:	31 c9                	xor    %ecx,%ecx
  800f44:	89 c8                	mov    %ecx,%eax
  800f46:	89 fa                	mov    %edi,%edx
  800f48:	83 c4 10             	add    $0x10,%esp
  800f4b:	5e                   	pop    %esi
  800f4c:	5f                   	pop    %edi
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    
  800f4f:	90                   	nop
  800f50:	89 d1                	mov    %edx,%ecx
  800f52:	89 fa                	mov    %edi,%edx
  800f54:	89 c8                	mov    %ecx,%eax
  800f56:	31 ff                	xor    %edi,%edi
  800f58:	f7 f6                	div    %esi
  800f5a:	89 c1                	mov    %eax,%ecx
  800f5c:	89 fa                	mov    %edi,%edx
  800f5e:	89 c8                	mov    %ecx,%eax
  800f60:	83 c4 10             	add    $0x10,%esp
  800f63:	5e                   	pop    %esi
  800f64:	5f                   	pop    %edi
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    
  800f67:	90                   	nop
  800f68:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800f6c:	89 f2                	mov    %esi,%edx
  800f6e:	d3 e0                	shl    %cl,%eax
  800f70:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f73:	b8 20 00 00 00       	mov    $0x20,%eax
  800f78:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800f7b:	89 c1                	mov    %eax,%ecx
  800f7d:	d3 ea                	shr    %cl,%edx
  800f7f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800f83:	0b 55 ec             	or     -0x14(%ebp),%edx
  800f86:	d3 e6                	shl    %cl,%esi
  800f88:	89 c1                	mov    %eax,%ecx
  800f8a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  800f8d:	89 fe                	mov    %edi,%esi
  800f8f:	d3 ee                	shr    %cl,%esi
  800f91:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800f95:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800f98:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f9b:	d3 e7                	shl    %cl,%edi
  800f9d:	89 c1                	mov    %eax,%ecx
  800f9f:	d3 ea                	shr    %cl,%edx
  800fa1:	09 d7                	or     %edx,%edi
  800fa3:	89 f2                	mov    %esi,%edx
  800fa5:	89 f8                	mov    %edi,%eax
  800fa7:	f7 75 ec             	divl   -0x14(%ebp)
  800faa:	89 d6                	mov    %edx,%esi
  800fac:	89 c7                	mov    %eax,%edi
  800fae:	f7 65 e8             	mull   -0x18(%ebp)
  800fb1:	39 d6                	cmp    %edx,%esi
  800fb3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800fb6:	72 30                	jb     800fe8 <__udivdi3+0x118>
  800fb8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fbb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800fbf:	d3 e2                	shl    %cl,%edx
  800fc1:	39 c2                	cmp    %eax,%edx
  800fc3:	73 05                	jae    800fca <__udivdi3+0xfa>
  800fc5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  800fc8:	74 1e                	je     800fe8 <__udivdi3+0x118>
  800fca:	89 f9                	mov    %edi,%ecx
  800fcc:	31 ff                	xor    %edi,%edi
  800fce:	e9 71 ff ff ff       	jmp    800f44 <__udivdi3+0x74>
  800fd3:	90                   	nop
  800fd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fd8:	31 ff                	xor    %edi,%edi
  800fda:	b9 01 00 00 00       	mov    $0x1,%ecx
  800fdf:	e9 60 ff ff ff       	jmp    800f44 <__udivdi3+0x74>
  800fe4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fe8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  800feb:	31 ff                	xor    %edi,%edi
  800fed:	89 c8                	mov    %ecx,%eax
  800fef:	89 fa                	mov    %edi,%edx
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	5e                   	pop    %esi
  800ff5:	5f                   	pop    %edi
  800ff6:	5d                   	pop    %ebp
  800ff7:	c3                   	ret    
	...

00801000 <__umoddi3>:
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	57                   	push   %edi
  801004:	56                   	push   %esi
  801005:	83 ec 20             	sub    $0x20,%esp
  801008:	8b 55 14             	mov    0x14(%ebp),%edx
  80100b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80100e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801011:	8b 75 0c             	mov    0xc(%ebp),%esi
  801014:	85 d2                	test   %edx,%edx
  801016:	89 c8                	mov    %ecx,%eax
  801018:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80101b:	75 13                	jne    801030 <__umoddi3+0x30>
  80101d:	39 f7                	cmp    %esi,%edi
  80101f:	76 3f                	jbe    801060 <__umoddi3+0x60>
  801021:	89 f2                	mov    %esi,%edx
  801023:	f7 f7                	div    %edi
  801025:	89 d0                	mov    %edx,%eax
  801027:	31 d2                	xor    %edx,%edx
  801029:	83 c4 20             	add    $0x20,%esp
  80102c:	5e                   	pop    %esi
  80102d:	5f                   	pop    %edi
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    
  801030:	39 f2                	cmp    %esi,%edx
  801032:	77 4c                	ja     801080 <__umoddi3+0x80>
  801034:	0f bd ca             	bsr    %edx,%ecx
  801037:	83 f1 1f             	xor    $0x1f,%ecx
  80103a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80103d:	75 51                	jne    801090 <__umoddi3+0x90>
  80103f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801042:	0f 87 e0 00 00 00    	ja     801128 <__umoddi3+0x128>
  801048:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80104b:	29 f8                	sub    %edi,%eax
  80104d:	19 d6                	sbb    %edx,%esi
  80104f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801052:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801055:	89 f2                	mov    %esi,%edx
  801057:	83 c4 20             	add    $0x20,%esp
  80105a:	5e                   	pop    %esi
  80105b:	5f                   	pop    %edi
  80105c:	5d                   	pop    %ebp
  80105d:	c3                   	ret    
  80105e:	66 90                	xchg   %ax,%ax
  801060:	85 ff                	test   %edi,%edi
  801062:	75 0b                	jne    80106f <__umoddi3+0x6f>
  801064:	b8 01 00 00 00       	mov    $0x1,%eax
  801069:	31 d2                	xor    %edx,%edx
  80106b:	f7 f7                	div    %edi
  80106d:	89 c7                	mov    %eax,%edi
  80106f:	89 f0                	mov    %esi,%eax
  801071:	31 d2                	xor    %edx,%edx
  801073:	f7 f7                	div    %edi
  801075:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801078:	f7 f7                	div    %edi
  80107a:	eb a9                	jmp    801025 <__umoddi3+0x25>
  80107c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801080:	89 c8                	mov    %ecx,%eax
  801082:	89 f2                	mov    %esi,%edx
  801084:	83 c4 20             	add    $0x20,%esp
  801087:	5e                   	pop    %esi
  801088:	5f                   	pop    %edi
  801089:	5d                   	pop    %ebp
  80108a:	c3                   	ret    
  80108b:	90                   	nop
  80108c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801090:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801094:	d3 e2                	shl    %cl,%edx
  801096:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801099:	ba 20 00 00 00       	mov    $0x20,%edx
  80109e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8010a1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010a4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8010a8:	89 fa                	mov    %edi,%edx
  8010aa:	d3 ea                	shr    %cl,%edx
  8010ac:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8010b0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8010b3:	d3 e7                	shl    %cl,%edi
  8010b5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8010b9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8010bc:	89 f2                	mov    %esi,%edx
  8010be:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8010c1:	89 c7                	mov    %eax,%edi
  8010c3:	d3 ea                	shr    %cl,%edx
  8010c5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8010c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8010cc:	89 c2                	mov    %eax,%edx
  8010ce:	d3 e6                	shl    %cl,%esi
  8010d0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8010d4:	d3 ea                	shr    %cl,%edx
  8010d6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8010da:	09 d6                	or     %edx,%esi
  8010dc:	89 f0                	mov    %esi,%eax
  8010de:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8010e1:	d3 e7                	shl    %cl,%edi
  8010e3:	89 f2                	mov    %esi,%edx
  8010e5:	f7 75 f4             	divl   -0xc(%ebp)
  8010e8:	89 d6                	mov    %edx,%esi
  8010ea:	f7 65 e8             	mull   -0x18(%ebp)
  8010ed:	39 d6                	cmp    %edx,%esi
  8010ef:	72 2b                	jb     80111c <__umoddi3+0x11c>
  8010f1:	39 c7                	cmp    %eax,%edi
  8010f3:	72 23                	jb     801118 <__umoddi3+0x118>
  8010f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8010f9:	29 c7                	sub    %eax,%edi
  8010fb:	19 d6                	sbb    %edx,%esi
  8010fd:	89 f0                	mov    %esi,%eax
  8010ff:	89 f2                	mov    %esi,%edx
  801101:	d3 ef                	shr    %cl,%edi
  801103:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801107:	d3 e0                	shl    %cl,%eax
  801109:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80110d:	09 f8                	or     %edi,%eax
  80110f:	d3 ea                	shr    %cl,%edx
  801111:	83 c4 20             	add    $0x20,%esp
  801114:	5e                   	pop    %esi
  801115:	5f                   	pop    %edi
  801116:	5d                   	pop    %ebp
  801117:	c3                   	ret    
  801118:	39 d6                	cmp    %edx,%esi
  80111a:	75 d9                	jne    8010f5 <__umoddi3+0xf5>
  80111c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80111f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801122:	eb d1                	jmp    8010f5 <__umoddi3+0xf5>
  801124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801128:	39 f2                	cmp    %esi,%edx
  80112a:	0f 82 18 ff ff ff    	jb     801048 <__umoddi3+0x48>
  801130:	e9 1d ff ff ff       	jmp    801052 <__umoddi3+0x52>
