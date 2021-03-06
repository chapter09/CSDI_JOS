
obj/user/faultreadkernel:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  80003a:	a1 00 00 10 f0       	mov    0xf0100000,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 78 10 80 00 	movl   $0x801078,(%esp)
  80004a:	e8 ca 00 00 00       	call   800119 <cprintf>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80005d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800060:	8b 75 08             	mov    0x8(%ebp),%esi
  800063:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800066:	e8 40 0c 00 00       	call   800cab <sys_getenvid>
  80006b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800070:	6b c0 64             	imul   $0x64,%eax,%eax
  800073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800078:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 f6                	test   %esi,%esi
  80007f:	7e 07                	jle    800088 <libmain+0x34>
		binaryname = argv[0];
  800081:	8b 03                	mov    (%ebx),%eax
  800083:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800088:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008c:	89 34 24             	mov    %esi,(%esp)
  80008f:	e8 a0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800094:	e8 0b 00 00 00       	call   8000a4 <exit>
}
  800099:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80009c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009f:	89 ec                	mov    %ebp,%esp
  8000a1:	5d                   	pop    %ebp
  8000a2:	c3                   	ret    
	...

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b1:	e8 77 0c 00 00       	call   800d2d <sys_env_destroy>
}
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000c1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000c8:	00 00 00 
	b.cnt = 0;
  8000cb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000d2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8000df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000e3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8000e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ed:	c7 04 24 33 01 80 00 	movl   $0x800133,(%esp)
  8000f4:	e8 d4 01 00 00       	call   8002cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8000f9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8000ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800103:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800109:	89 04 24             	mov    %eax,(%esp)
  80010c:	e8 1b 0b 00 00       	call   800c2c <sys_cputs>

	return b.cnt;
}
  800111:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800117:	c9                   	leave  
  800118:	c3                   	ret    

00800119 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80011f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800122:	89 44 24 04          	mov    %eax,0x4(%esp)
  800126:	8b 45 08             	mov    0x8(%ebp),%eax
  800129:	89 04 24             	mov    %eax,(%esp)
  80012c:	e8 87 ff ff ff       	call   8000b8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800131:	c9                   	leave  
  800132:	c3                   	ret    

00800133 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	53                   	push   %ebx
  800137:	83 ec 14             	sub    $0x14,%esp
  80013a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80013d:	8b 03                	mov    (%ebx),%eax
  80013f:	8b 55 08             	mov    0x8(%ebp),%edx
  800142:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800146:	83 c0 01             	add    $0x1,%eax
  800149:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80014b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800150:	75 19                	jne    80016b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800152:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800159:	00 
  80015a:	8d 43 08             	lea    0x8(%ebx),%eax
  80015d:	89 04 24             	mov    %eax,(%esp)
  800160:	e8 c7 0a 00 00       	call   800c2c <sys_cputs>
		b->idx = 0;
  800165:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80016b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80016f:	83 c4 14             	add    $0x14,%esp
  800172:	5b                   	pop    %ebx
  800173:	5d                   	pop    %ebp
  800174:	c3                   	ret    
	...

00800180 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 4c             	sub    $0x4c,%esp
  800189:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80018c:	89 d6                	mov    %edx,%esi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800194:	8b 55 0c             	mov    0xc(%ebp),%edx
  800197:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80019a:	8b 45 10             	mov    0x10(%ebp),%eax
  80019d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001a0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ab:	39 d1                	cmp    %edx,%ecx
  8001ad:	72 15                	jb     8001c4 <printnum+0x44>
  8001af:	77 07                	ja     8001b8 <printnum+0x38>
  8001b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001b4:	39 d0                	cmp    %edx,%eax
  8001b6:	76 0c                	jbe    8001c4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001b8:	83 eb 01             	sub    $0x1,%ebx
  8001bb:	85 db                	test   %ebx,%ebx
  8001bd:	8d 76 00             	lea    0x0(%esi),%esi
  8001c0:	7f 61                	jg     800223 <printnum+0xa3>
  8001c2:	eb 70                	jmp    800234 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001c8:	83 eb 01             	sub    $0x1,%ebx
  8001cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8001d7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8001db:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8001de:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8001e1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ef:	00 
  8001f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8001f3:	89 04 24             	mov    %eax,(%esp)
  8001f6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8001f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001fd:	e8 0e 0c 00 00       	call   800e10 <__udivdi3>
  800202:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800205:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800208:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80020c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800210:	89 04 24             	mov    %eax,(%esp)
  800213:	89 54 24 04          	mov    %edx,0x4(%esp)
  800217:	89 f2                	mov    %esi,%edx
  800219:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80021c:	e8 5f ff ff ff       	call   800180 <printnum>
  800221:	eb 11                	jmp    800234 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	89 74 24 04          	mov    %esi,0x4(%esp)
  800227:	89 3c 24             	mov    %edi,(%esp)
  80022a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022d:	83 eb 01             	sub    $0x1,%ebx
  800230:	85 db                	test   %ebx,%ebx
  800232:	7f ef                	jg     800223 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800234:	89 74 24 04          	mov    %esi,0x4(%esp)
  800238:	8b 74 24 04          	mov    0x4(%esp),%esi
  80023c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80023f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800243:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80024a:	00 
  80024b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80024e:	89 14 24             	mov    %edx,(%esp)
  800251:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800254:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800258:	e8 e3 0c 00 00       	call   800f40 <__umoddi3>
  80025d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800261:	0f be 80 a9 10 80 00 	movsbl 0x8010a9(%eax),%eax
  800268:	89 04 24             	mov    %eax,(%esp)
  80026b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80026e:	83 c4 4c             	add    $0x4c,%esp
  800271:	5b                   	pop    %ebx
  800272:	5e                   	pop    %esi
  800273:	5f                   	pop    %edi
  800274:	5d                   	pop    %ebp
  800275:	c3                   	ret    

00800276 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800279:	83 fa 01             	cmp    $0x1,%edx
  80027c:	7e 0e                	jle    80028c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	8d 4a 08             	lea    0x8(%edx),%ecx
  800283:	89 08                	mov    %ecx,(%eax)
  800285:	8b 02                	mov    (%edx),%eax
  800287:	8b 52 04             	mov    0x4(%edx),%edx
  80028a:	eb 22                	jmp    8002ae <getuint+0x38>
	else if (lflag)
  80028c:	85 d2                	test   %edx,%edx
  80028e:	74 10                	je     8002a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800290:	8b 10                	mov    (%eax),%edx
  800292:	8d 4a 04             	lea    0x4(%edx),%ecx
  800295:	89 08                	mov    %ecx,(%eax)
  800297:	8b 02                	mov    (%edx),%eax
  800299:	ba 00 00 00 00       	mov    $0x0,%edx
  80029e:	eb 0e                	jmp    8002ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a0:	8b 10                	mov    (%eax),%edx
  8002a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 02                	mov    (%edx),%eax
  8002a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ba:	8b 10                	mov    (%eax),%edx
  8002bc:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bf:	73 0a                	jae    8002cb <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c4:	88 0a                	mov    %cl,(%edx)
  8002c6:	83 c2 01             	add    $0x1,%edx
  8002c9:	89 10                	mov    %edx,(%eax)
}
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    

008002cd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	57                   	push   %edi
  8002d1:	56                   	push   %esi
  8002d2:	53                   	push   %ebx
  8002d3:	83 ec 5c             	sub    $0x5c,%esp
  8002d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8002df:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002e6:	eb 16                	jmp    8002fe <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e8:	85 c0                	test   %eax,%eax
  8002ea:	0f 84 4f 04 00 00    	je     80073f <vprintfmt+0x472>
				return;
			putch(ch, putdat);
  8002f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f4:	89 04 24             	mov    %eax,(%esp)
  8002f7:	ff d7                	call   *%edi
  8002f9:	eb 03                	jmp    8002fe <vprintfmt+0x31>
  8002fb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002fe:	0f b6 03             	movzbl (%ebx),%eax
  800301:	83 c3 01             	add    $0x1,%ebx
  800304:	83 f8 25             	cmp    $0x25,%eax
  800307:	75 df                	jne    8002e8 <vprintfmt+0x1b>
  800309:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80030d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800314:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80031b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800322:	b9 00 00 00 00       	mov    $0x0,%ecx
  800327:	eb 06                	jmp    80032f <vprintfmt+0x62>
  800329:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  80032d:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032f:	0f b6 13             	movzbl (%ebx),%edx
  800332:	0f b6 c2             	movzbl %dl,%eax
  800335:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800338:	8d 43 01             	lea    0x1(%ebx),%eax
  80033b:	83 ea 23             	sub    $0x23,%edx
  80033e:	80 fa 55             	cmp    $0x55,%dl
  800341:	0f 87 db 03 00 00    	ja     800722 <vprintfmt+0x455>
  800347:	0f b6 d2             	movzbl %dl,%edx
  80034a:	ff 24 95 b4 11 80 00 	jmp    *0x8011b4(,%edx,4)
  800351:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800355:	eb d6                	jmp    80032d <vprintfmt+0x60>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800357:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80035a:	83 ea 30             	sub    $0x30,%edx
  80035d:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  800360:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800363:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800366:	83 fb 09             	cmp    $0x9,%ebx
  800369:	77 4c                	ja     8003b7 <vprintfmt+0xea>
  80036b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80036e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800371:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800374:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800377:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  80037b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80037e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800381:	83 fb 09             	cmp    $0x9,%ebx
  800384:	76 eb                	jbe    800371 <vprintfmt+0xa4>
  800386:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800389:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80038c:	eb 29                	jmp    8003b7 <vprintfmt+0xea>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80038e:	8b 55 14             	mov    0x14(%ebp),%edx
  800391:	8d 5a 04             	lea    0x4(%edx),%ebx
  800394:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800397:	8b 12                	mov    (%edx),%edx
  800399:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  80039c:	eb 19                	jmp    8003b7 <vprintfmt+0xea>

		case '.':
			if (width < 0)
  80039e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003a1:	c1 fa 1f             	sar    $0x1f,%edx
  8003a4:	f7 d2                	not    %edx
  8003a6:	21 55 d4             	and    %edx,-0x2c(%ebp)
  8003a9:	eb 82                	jmp    80032d <vprintfmt+0x60>
  8003ab:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003b2:	e9 76 ff ff ff       	jmp    80032d <vprintfmt+0x60>

		process_precision:
			if (width < 0)
  8003b7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003bb:	0f 89 6c ff ff ff    	jns    80032d <vprintfmt+0x60>
  8003c1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8003c4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003c7:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8003ca:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8003cd:	e9 5b ff ff ff       	jmp    80032d <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d2:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8003d5:	e9 53 ff ff ff       	jmp    80032d <vprintfmt+0x60>
  8003da:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e0:	8d 50 04             	lea    0x4(%eax),%edx
  8003e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003ea:	8b 00                	mov    (%eax),%eax
  8003ec:	89 04 24             	mov    %eax,(%esp)
  8003ef:	ff d7                	call   *%edi
  8003f1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
  8003f4:	e9 05 ff ff ff       	jmp    8002fe <vprintfmt+0x31>
  8003f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ff:	8d 50 04             	lea    0x4(%eax),%edx
  800402:	89 55 14             	mov    %edx,0x14(%ebp)
  800405:	8b 00                	mov    (%eax),%eax
  800407:	89 c2                	mov    %eax,%edx
  800409:	c1 fa 1f             	sar    $0x1f,%edx
  80040c:	31 d0                	xor    %edx,%eax
  80040e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800410:	83 f8 06             	cmp    $0x6,%eax
  800413:	7f 0b                	jg     800420 <vprintfmt+0x153>
  800415:	8b 14 85 0c 13 80 00 	mov    0x80130c(,%eax,4),%edx
  80041c:	85 d2                	test   %edx,%edx
  80041e:	75 20                	jne    800440 <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  800420:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800424:	c7 44 24 08 ba 10 80 	movl   $0x8010ba,0x8(%esp)
  80042b:	00 
  80042c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800430:	89 3c 24             	mov    %edi,(%esp)
  800433:	e8 8f 03 00 00       	call   8007c7 <printfmt>
  800438:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043b:	e9 be fe ff ff       	jmp    8002fe <vprintfmt+0x31>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800440:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800444:	c7 44 24 08 c3 10 80 	movl   $0x8010c3,0x8(%esp)
  80044b:	00 
  80044c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800450:	89 3c 24             	mov    %edi,(%esp)
  800453:	e8 6f 03 00 00       	call   8007c7 <printfmt>
  800458:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80045b:	e9 9e fe ff ff       	jmp    8002fe <vprintfmt+0x31>
  800460:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800463:	89 c3                	mov    %eax,%ebx
  800465:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800468:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80046b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80046e:	8b 45 14             	mov    0x14(%ebp),%eax
  800471:	8d 50 04             	lea    0x4(%eax),%edx
  800474:	89 55 14             	mov    %edx,0x14(%ebp)
  800477:	8b 00                	mov    (%eax),%eax
  800479:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80047c:	85 c0                	test   %eax,%eax
  80047e:	75 07                	jne    800487 <vprintfmt+0x1ba>
  800480:	c7 45 cc c6 10 80 00 	movl   $0x8010c6,-0x34(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800487:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80048b:	7e 06                	jle    800493 <vprintfmt+0x1c6>
  80048d:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800491:	75 13                	jne    8004a6 <vprintfmt+0x1d9>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800493:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800496:	0f be 02             	movsbl (%edx),%eax
  800499:	85 c0                	test   %eax,%eax
  80049b:	0f 85 9f 00 00 00    	jne    800540 <vprintfmt+0x273>
  8004a1:	e9 8f 00 00 00       	jmp    800535 <vprintfmt+0x268>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004aa:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004ad:	89 0c 24             	mov    %ecx,(%esp)
  8004b0:	e8 56 03 00 00       	call   80080b <strnlen>
  8004b5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004b8:	29 c2                	sub    %eax,%edx
  8004ba:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004bd:	85 d2                	test   %edx,%edx
  8004bf:	7e d2                	jle    800493 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004c1:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8004c5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004c8:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8004cb:	89 d3                	mov    %edx,%ebx
  8004cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d4:	89 04 24             	mov    %eax,(%esp)
  8004d7:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d9:	83 eb 01             	sub    $0x1,%ebx
  8004dc:	85 db                	test   %ebx,%ebx
  8004de:	7f ed                	jg     8004cd <vprintfmt+0x200>
  8004e0:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8004e3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8004ea:	eb a7                	jmp    800493 <vprintfmt+0x1c6>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ec:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f0:	74 1b                	je     80050d <vprintfmt+0x240>
  8004f2:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004f5:	83 fa 5e             	cmp    $0x5e,%edx
  8004f8:	76 13                	jbe    80050d <vprintfmt+0x240>
					putch('?', putdat);
  8004fa:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8004fd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800501:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800508:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80050b:	eb 0d                	jmp    80051a <vprintfmt+0x24d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80050d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800510:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800514:	89 04 24             	mov    %eax,(%esp)
  800517:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051a:	83 ef 01             	sub    $0x1,%edi
  80051d:	0f be 03             	movsbl (%ebx),%eax
  800520:	85 c0                	test   %eax,%eax
  800522:	74 05                	je     800529 <vprintfmt+0x25c>
  800524:	83 c3 01             	add    $0x1,%ebx
  800527:	eb 2e                	jmp    800557 <vprintfmt+0x28a>
  800529:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80052c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80052f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800532:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800535:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800539:	7f 33                	jg     80056e <vprintfmt+0x2a1>
  80053b:	e9 bb fd ff ff       	jmp    8002fb <vprintfmt+0x2e>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800540:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800543:	83 c2 01             	add    $0x1,%edx
  800546:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800549:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80054c:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80054f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800552:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800555:	89 d3                	mov    %edx,%ebx
  800557:	85 f6                	test   %esi,%esi
  800559:	78 91                	js     8004ec <vprintfmt+0x21f>
  80055b:	83 ee 01             	sub    $0x1,%esi
  80055e:	79 8c                	jns    8004ec <vprintfmt+0x21f>
  800560:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800563:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800566:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800569:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80056c:	eb c7                	jmp    800535 <vprintfmt+0x268>
  80056e:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800571:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800574:	89 74 24 04          	mov    %esi,0x4(%esp)
  800578:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80057f:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800581:	83 eb 01             	sub    $0x1,%ebx
  800584:	85 db                	test   %ebx,%ebx
  800586:	7f ec                	jg     800574 <vprintfmt+0x2a7>
  800588:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80058b:	e9 6e fd ff ff       	jmp    8002fe <vprintfmt+0x31>
  800590:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800593:	83 f9 01             	cmp    $0x1,%ecx
  800596:	7e 16                	jle    8005ae <vprintfmt+0x2e1>
		return va_arg(*ap, long long);
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8d 50 08             	lea    0x8(%eax),%edx
  80059e:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a1:	8b 10                	mov    (%eax),%edx
  8005a3:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a6:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005a9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ac:	eb 32                	jmp    8005e0 <vprintfmt+0x313>
	else if (lflag)
  8005ae:	85 c9                	test   %ecx,%ecx
  8005b0:	74 18                	je     8005ca <vprintfmt+0x2fd>
		return va_arg(*ap, long);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8d 50 04             	lea    0x4(%eax),%edx
  8005b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bb:	8b 00                	mov    (%eax),%eax
  8005bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c0:	89 c1                	mov    %eax,%ecx
  8005c2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c8:	eb 16                	jmp    8005e0 <vprintfmt+0x313>
	else
		return va_arg(*ap, int);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 04             	lea    0x4(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d8:	89 c2                	mov    %eax,%edx
  8005da:	c1 fa 1f             	sar    $0x1f,%edx
  8005dd:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005e3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005e6:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  8005eb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ef:	0f 89 8a 00 00 00    	jns    80067f <vprintfmt+0x3b2>
				putch('-', putdat);
  8005f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800600:	ff d7                	call   *%edi
				num = -(long long) num;
  800602:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800605:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800608:	f7 d8                	neg    %eax
  80060a:	83 d2 00             	adc    $0x0,%edx
  80060d:	f7 da                	neg    %edx
  80060f:	eb 6e                	jmp    80067f <vprintfmt+0x3b2>
  800611:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800614:	89 ca                	mov    %ecx,%edx
  800616:	8d 45 14             	lea    0x14(%ebp),%eax
  800619:	e8 58 fc ff ff       	call   800276 <getuint>
  80061e:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  800623:	eb 5a                	jmp    80067f <vprintfmt+0x3b2>
  800625:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			//break;
			num = getuint(&ap, lflag);
  800628:	89 ca                	mov    %ecx,%edx
  80062a:	8d 45 14             	lea    0x14(%ebp),%eax
  80062d:	e8 44 fc ff ff       	call   800276 <getuint>
  800632:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800637:	eb 46                	jmp    80067f <vprintfmt+0x3b2>
  800639:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  80063c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800640:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800647:	ff d7                	call   *%edi
			putch('x', putdat);
  800649:	89 74 24 04          	mov    %esi,0x4(%esp)
  80064d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800654:	ff d7                	call   *%edi
			num = (unsigned long long)
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 50 04             	lea    0x4(%eax),%edx
  80065c:	89 55 14             	mov    %edx,0x14(%ebp)
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	ba 00 00 00 00       	mov    $0x0,%edx
  800666:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80066b:	eb 12                	jmp    80067f <vprintfmt+0x3b2>
  80066d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800670:	89 ca                	mov    %ecx,%edx
  800672:	8d 45 14             	lea    0x14(%ebp),%eax
  800675:	e8 fc fb ff ff       	call   800276 <getuint>
  80067a:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067f:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800683:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800687:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80068a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80068e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800692:	89 04 24             	mov    %eax,(%esp)
  800695:	89 54 24 04          	mov    %edx,0x4(%esp)
  800699:	89 f2                	mov    %esi,%edx
  80069b:	89 f8                	mov    %edi,%eax
  80069d:	e8 de fa ff ff       	call   800180 <printnum>
  8006a2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
  8006a5:	e9 54 fc ff ff       	jmp    8002fe <vprintfmt+0x31>
  8006aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			char* tmp = va_arg(ap, char*);
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8d 50 04             	lea    0x4(%eax),%edx
  8006b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b6:	8b 00                	mov    (%eax),%eax
			if(tmp == NULL) {
  8006b8:	85 c0                	test   %eax,%eax
  8006ba:	75 1f                	jne    8006db <vprintfmt+0x40e>
  8006bc:	bb 39 11 80 00       	mov    $0x801139,%ebx
  8006c1:	b0 0a                	mov    $0xa,%al
				for(; (ch = *null_error++) != '\0';) {	
					putch(ch, putdat);
  8006c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006c7:	89 04 24             	mov    %eax,(%esp)
  8006ca:	ff d7                	call   *%edi
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			char* tmp = va_arg(ap, char*);
			if(tmp == NULL) {
				for(; (ch = *null_error++) != '\0';) {	
  8006cc:	0f be 03             	movsbl (%ebx),%eax
  8006cf:	83 c3 01             	add    $0x1,%ebx
  8006d2:	85 c0                	test   %eax,%eax
  8006d4:	75 ed                	jne    8006c3 <vprintfmt+0x3f6>
  8006d6:	e9 20 fc ff ff       	jmp    8002fb <vprintfmt+0x2e>
					putch(ch, putdat);
				}
				break;
			}
			*tmp = *((signed char*) putdat);
  8006db:	0f b6 16             	movzbl (%esi),%edx
  8006de:	88 10                	mov    %dl,(%eax)
			if(*(signed char*) putdat < 0) {
  8006e0:	80 3e 00             	cmpb   $0x0,(%esi)
  8006e3:	0f 89 12 fc ff ff    	jns    8002fb <vprintfmt+0x2e>
  8006e9:	bb 71 11 80 00       	mov    $0x801171,%ebx
  8006ee:	b8 0a 00 00 00       	mov    $0xa,%eax
				for(; (ch = *overflow_error++) != '\0';) {	
					putch(ch, putdat);
  8006f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006f7:	89 04 24             	mov    %eax,(%esp)
  8006fa:	ff d7                	call   *%edi
				}
				break;
			}
			*tmp = *((signed char*) putdat);
			if(*(signed char*) putdat < 0) {
				for(; (ch = *overflow_error++) != '\0';) {	
  8006fc:	0f be 03             	movsbl (%ebx),%eax
  8006ff:	83 c3 01             	add    $0x1,%ebx
  800702:	85 c0                	test   %eax,%eax
  800704:	75 ed                	jne    8006f3 <vprintfmt+0x426>
  800706:	e9 f0 fb ff ff       	jmp    8002fb <vprintfmt+0x2e>
  80070b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80070e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800711:	89 74 24 04          	mov    %esi,0x4(%esp)
  800715:	89 14 24             	mov    %edx,(%esp)
  800718:	ff d7                	call   *%edi
  80071a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
  80071d:	e9 dc fb ff ff       	jmp    8002fe <vprintfmt+0x31>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800722:	89 74 24 04          	mov    %esi,0x4(%esp)
  800726:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80072d:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80072f:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800732:	80 38 25             	cmpb   $0x25,(%eax)
  800735:	0f 84 c3 fb ff ff    	je     8002fe <vprintfmt+0x31>
  80073b:	89 c3                	mov    %eax,%ebx
  80073d:	eb f0                	jmp    80072f <vprintfmt+0x462>
				/* do nothing */;
			break;
		}
	}
}
  80073f:	83 c4 5c             	add    $0x5c,%esp
  800742:	5b                   	pop    %ebx
  800743:	5e                   	pop    %esi
  800744:	5f                   	pop    %edi
  800745:	5d                   	pop    %ebp
  800746:	c3                   	ret    

00800747 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	83 ec 28             	sub    $0x28,%esp
  80074d:	8b 45 08             	mov    0x8(%ebp),%eax
  800750:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800753:	85 c0                	test   %eax,%eax
  800755:	74 04                	je     80075b <vsnprintf+0x14>
  800757:	85 d2                	test   %edx,%edx
  800759:	7f 07                	jg     800762 <vsnprintf+0x1b>
  80075b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800760:	eb 3b                	jmp    80079d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800762:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800765:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800769:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80076c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800773:	8b 45 14             	mov    0x14(%ebp),%eax
  800776:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077a:	8b 45 10             	mov    0x10(%ebp),%eax
  80077d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800781:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800784:	89 44 24 04          	mov    %eax,0x4(%esp)
  800788:	c7 04 24 b0 02 80 00 	movl   $0x8002b0,(%esp)
  80078f:	e8 39 fb ff ff       	call   8002cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800794:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800797:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80079d:	c9                   	leave  
  80079e:	c3                   	ret    

0080079f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8007a5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8007a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8007af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bd:	89 04 24             	mov    %eax,(%esp)
  8007c0:	e8 82 ff ff ff       	call   800747 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8007cd:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8007d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e5:	89 04 24             	mov    %eax,(%esp)
  8007e8:	e8 e0 fa ff ff       	call   8002cd <vprintfmt>
	va_end(ap);
}
  8007ed:	c9                   	leave  
  8007ee:	c3                   	ret    
	...

008007f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007fe:	74 09                	je     800809 <strlen+0x19>
		n++;
  800800:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800803:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800807:	75 f7                	jne    800800 <strlen+0x10>
		n++;
	return n;
}
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	53                   	push   %ebx
  80080f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800812:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800815:	85 c9                	test   %ecx,%ecx
  800817:	74 19                	je     800832 <strnlen+0x27>
  800819:	80 3b 00             	cmpb   $0x0,(%ebx)
  80081c:	74 14                	je     800832 <strnlen+0x27>
  80081e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800823:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800826:	39 c8                	cmp    %ecx,%eax
  800828:	74 0d                	je     800837 <strnlen+0x2c>
  80082a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80082e:	75 f3                	jne    800823 <strnlen+0x18>
  800830:	eb 05                	jmp    800837 <strnlen+0x2c>
  800832:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800837:	5b                   	pop    %ebx
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	8b 45 08             	mov    0x8(%ebp),%eax
  800841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800844:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800849:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80084d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800850:	83 c2 01             	add    $0x1,%edx
  800853:	84 c9                	test   %cl,%cl
  800855:	75 f2                	jne    800849 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800857:	5b                   	pop    %ebx
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	53                   	push   %ebx
  80085e:	83 ec 08             	sub    $0x8,%esp
  800861:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800864:	89 1c 24             	mov    %ebx,(%esp)
  800867:	e8 84 ff ff ff       	call   8007f0 <strlen>
	strcpy(dst + len, src);
  80086c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800873:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800876:	89 04 24             	mov    %eax,(%esp)
  800879:	e8 bc ff ff ff       	call   80083a <strcpy>
	return dst;
}
  80087e:	89 d8                	mov    %ebx,%eax
  800880:	83 c4 08             	add    $0x8,%esp
  800883:	5b                   	pop    %ebx
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	56                   	push   %esi
  80088a:	53                   	push   %ebx
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800891:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800894:	85 f6                	test   %esi,%esi
  800896:	74 18                	je     8008b0 <strncpy+0x2a>
  800898:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80089d:	0f b6 1a             	movzbl (%edx),%ebx
  8008a0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008a3:	80 3a 01             	cmpb   $0x1,(%edx)
  8008a6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a9:	83 c1 01             	add    $0x1,%ecx
  8008ac:	39 ce                	cmp    %ecx,%esi
  8008ae:	77 ed                	ja     80089d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008b0:	5b                   	pop    %ebx
  8008b1:	5e                   	pop    %esi
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	56                   	push   %esi
  8008b8:	53                   	push   %ebx
  8008b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c2:	89 f0                	mov    %esi,%eax
  8008c4:	85 c9                	test   %ecx,%ecx
  8008c6:	74 27                	je     8008ef <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8008c8:	83 e9 01             	sub    $0x1,%ecx
  8008cb:	74 1d                	je     8008ea <strlcpy+0x36>
  8008cd:	0f b6 1a             	movzbl (%edx),%ebx
  8008d0:	84 db                	test   %bl,%bl
  8008d2:	74 16                	je     8008ea <strlcpy+0x36>
			*dst++ = *src++;
  8008d4:	88 18                	mov    %bl,(%eax)
  8008d6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008d9:	83 e9 01             	sub    $0x1,%ecx
  8008dc:	74 0e                	je     8008ec <strlcpy+0x38>
			*dst++ = *src++;
  8008de:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008e1:	0f b6 1a             	movzbl (%edx),%ebx
  8008e4:	84 db                	test   %bl,%bl
  8008e6:	75 ec                	jne    8008d4 <strlcpy+0x20>
  8008e8:	eb 02                	jmp    8008ec <strlcpy+0x38>
  8008ea:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008ec:	c6 00 00             	movb   $0x0,(%eax)
  8008ef:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8008f1:	5b                   	pop    %ebx
  8008f2:	5e                   	pop    %esi
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008fe:	0f b6 01             	movzbl (%ecx),%eax
  800901:	84 c0                	test   %al,%al
  800903:	74 15                	je     80091a <strcmp+0x25>
  800905:	3a 02                	cmp    (%edx),%al
  800907:	75 11                	jne    80091a <strcmp+0x25>
		p++, q++;
  800909:	83 c1 01             	add    $0x1,%ecx
  80090c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80090f:	0f b6 01             	movzbl (%ecx),%eax
  800912:	84 c0                	test   %al,%al
  800914:	74 04                	je     80091a <strcmp+0x25>
  800916:	3a 02                	cmp    (%edx),%al
  800918:	74 ef                	je     800909 <strcmp+0x14>
  80091a:	0f b6 c0             	movzbl %al,%eax
  80091d:	0f b6 12             	movzbl (%edx),%edx
  800920:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	53                   	push   %ebx
  800928:	8b 55 08             	mov    0x8(%ebp),%edx
  80092b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800931:	85 c0                	test   %eax,%eax
  800933:	74 23                	je     800958 <strncmp+0x34>
  800935:	0f b6 1a             	movzbl (%edx),%ebx
  800938:	84 db                	test   %bl,%bl
  80093a:	74 25                	je     800961 <strncmp+0x3d>
  80093c:	3a 19                	cmp    (%ecx),%bl
  80093e:	75 21                	jne    800961 <strncmp+0x3d>
  800940:	83 e8 01             	sub    $0x1,%eax
  800943:	74 13                	je     800958 <strncmp+0x34>
		n--, p++, q++;
  800945:	83 c2 01             	add    $0x1,%edx
  800948:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80094b:	0f b6 1a             	movzbl (%edx),%ebx
  80094e:	84 db                	test   %bl,%bl
  800950:	74 0f                	je     800961 <strncmp+0x3d>
  800952:	3a 19                	cmp    (%ecx),%bl
  800954:	74 ea                	je     800940 <strncmp+0x1c>
  800956:	eb 09                	jmp    800961 <strncmp+0x3d>
  800958:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80095d:	5b                   	pop    %ebx
  80095e:	5d                   	pop    %ebp
  80095f:	90                   	nop
  800960:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800961:	0f b6 02             	movzbl (%edx),%eax
  800964:	0f b6 11             	movzbl (%ecx),%edx
  800967:	29 d0                	sub    %edx,%eax
  800969:	eb f2                	jmp    80095d <strncmp+0x39>

0080096b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800975:	0f b6 10             	movzbl (%eax),%edx
  800978:	84 d2                	test   %dl,%dl
  80097a:	74 18                	je     800994 <strchr+0x29>
		if (*s == c)
  80097c:	38 ca                	cmp    %cl,%dl
  80097e:	75 0a                	jne    80098a <strchr+0x1f>
  800980:	eb 17                	jmp    800999 <strchr+0x2e>
  800982:	38 ca                	cmp    %cl,%dl
  800984:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800988:	74 0f                	je     800999 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80098a:	83 c0 01             	add    $0x1,%eax
  80098d:	0f b6 10             	movzbl (%eax),%edx
  800990:	84 d2                	test   %dl,%dl
  800992:	75 ee                	jne    800982 <strchr+0x17>
  800994:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a5:	0f b6 10             	movzbl (%eax),%edx
  8009a8:	84 d2                	test   %dl,%dl
  8009aa:	74 18                	je     8009c4 <strfind+0x29>
		if (*s == c)
  8009ac:	38 ca                	cmp    %cl,%dl
  8009ae:	75 0a                	jne    8009ba <strfind+0x1f>
  8009b0:	eb 12                	jmp    8009c4 <strfind+0x29>
  8009b2:	38 ca                	cmp    %cl,%dl
  8009b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009b8:	74 0a                	je     8009c4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	0f b6 10             	movzbl (%eax),%edx
  8009c0:	84 d2                	test   %dl,%dl
  8009c2:	75 ee                	jne    8009b2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	83 ec 0c             	sub    $0xc,%esp
  8009cc:	89 1c 24             	mov    %ebx,(%esp)
  8009cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009d3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8009d7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009e0:	85 c9                	test   %ecx,%ecx
  8009e2:	74 30                	je     800a14 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ea:	75 25                	jne    800a11 <memset+0x4b>
  8009ec:	f6 c1 03             	test   $0x3,%cl
  8009ef:	75 20                	jne    800a11 <memset+0x4b>
		c &= 0xFF;
  8009f1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009f4:	89 d3                	mov    %edx,%ebx
  8009f6:	c1 e3 08             	shl    $0x8,%ebx
  8009f9:	89 d6                	mov    %edx,%esi
  8009fb:	c1 e6 18             	shl    $0x18,%esi
  8009fe:	89 d0                	mov    %edx,%eax
  800a00:	c1 e0 10             	shl    $0x10,%eax
  800a03:	09 f0                	or     %esi,%eax
  800a05:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a07:	09 d8                	or     %ebx,%eax
  800a09:	c1 e9 02             	shr    $0x2,%ecx
  800a0c:	fc                   	cld    
  800a0d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a0f:	eb 03                	jmp    800a14 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a11:	fc                   	cld    
  800a12:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a14:	89 f8                	mov    %edi,%eax
  800a16:	8b 1c 24             	mov    (%esp),%ebx
  800a19:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a1d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a21:	89 ec                	mov    %ebp,%esp
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	83 ec 08             	sub    $0x8,%esp
  800a2b:	89 34 24             	mov    %esi,(%esp)
  800a2e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800a38:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a3b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a3d:	39 c6                	cmp    %eax,%esi
  800a3f:	73 35                	jae    800a76 <memmove+0x51>
  800a41:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a44:	39 d0                	cmp    %edx,%eax
  800a46:	73 2e                	jae    800a76 <memmove+0x51>
		s += n;
		d += n;
  800a48:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4a:	f6 c2 03             	test   $0x3,%dl
  800a4d:	75 1b                	jne    800a6a <memmove+0x45>
  800a4f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a55:	75 13                	jne    800a6a <memmove+0x45>
  800a57:	f6 c1 03             	test   $0x3,%cl
  800a5a:	75 0e                	jne    800a6a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a5c:	83 ef 04             	sub    $0x4,%edi
  800a5f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a62:	c1 e9 02             	shr    $0x2,%ecx
  800a65:	fd                   	std    
  800a66:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a68:	eb 09                	jmp    800a73 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a6a:	83 ef 01             	sub    $0x1,%edi
  800a6d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a70:	fd                   	std    
  800a71:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a73:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a74:	eb 20                	jmp    800a96 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a76:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a7c:	75 15                	jne    800a93 <memmove+0x6e>
  800a7e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a84:	75 0d                	jne    800a93 <memmove+0x6e>
  800a86:	f6 c1 03             	test   $0x3,%cl
  800a89:	75 08                	jne    800a93 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800a8b:	c1 e9 02             	shr    $0x2,%ecx
  800a8e:	fc                   	cld    
  800a8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a91:	eb 03                	jmp    800a96 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a93:	fc                   	cld    
  800a94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a96:	8b 34 24             	mov    (%esp),%esi
  800a99:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a9d:	89 ec                	mov    %ebp,%esp
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aa7:	8b 45 10             	mov    0x10(%ebp),%eax
  800aaa:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aae:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab8:	89 04 24             	mov    %eax,(%esp)
  800abb:	e8 65 ff ff ff       	call   800a25 <memmove>
}
  800ac0:	c9                   	leave  
  800ac1:	c3                   	ret    

00800ac2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	57                   	push   %edi
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
  800ac8:	8b 75 08             	mov    0x8(%ebp),%esi
  800acb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ace:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad1:	85 c9                	test   %ecx,%ecx
  800ad3:	74 36                	je     800b0b <memcmp+0x49>
		if (*s1 != *s2)
  800ad5:	0f b6 06             	movzbl (%esi),%eax
  800ad8:	0f b6 1f             	movzbl (%edi),%ebx
  800adb:	38 d8                	cmp    %bl,%al
  800add:	74 20                	je     800aff <memcmp+0x3d>
  800adf:	eb 14                	jmp    800af5 <memcmp+0x33>
  800ae1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800ae6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800aeb:	83 c2 01             	add    $0x1,%edx
  800aee:	83 e9 01             	sub    $0x1,%ecx
  800af1:	38 d8                	cmp    %bl,%al
  800af3:	74 12                	je     800b07 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800af5:	0f b6 c0             	movzbl %al,%eax
  800af8:	0f b6 db             	movzbl %bl,%ebx
  800afb:	29 d8                	sub    %ebx,%eax
  800afd:	eb 11                	jmp    800b10 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aff:	83 e9 01             	sub    $0x1,%ecx
  800b02:	ba 00 00 00 00       	mov    $0x0,%edx
  800b07:	85 c9                	test   %ecx,%ecx
  800b09:	75 d6                	jne    800ae1 <memcmp+0x1f>
  800b0b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5f                   	pop    %edi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b1b:	89 c2                	mov    %eax,%edx
  800b1d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b20:	39 d0                	cmp    %edx,%eax
  800b22:	73 15                	jae    800b39 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b24:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b28:	38 08                	cmp    %cl,(%eax)
  800b2a:	75 06                	jne    800b32 <memfind+0x1d>
  800b2c:	eb 0b                	jmp    800b39 <memfind+0x24>
  800b2e:	38 08                	cmp    %cl,(%eax)
  800b30:	74 07                	je     800b39 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b32:	83 c0 01             	add    $0x1,%eax
  800b35:	39 c2                	cmp    %eax,%edx
  800b37:	77 f5                	ja     800b2e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
  800b41:	83 ec 04             	sub    $0x4,%esp
  800b44:	8b 55 08             	mov    0x8(%ebp),%edx
  800b47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b4a:	0f b6 02             	movzbl (%edx),%eax
  800b4d:	3c 20                	cmp    $0x20,%al
  800b4f:	74 04                	je     800b55 <strtol+0x1a>
  800b51:	3c 09                	cmp    $0x9,%al
  800b53:	75 0e                	jne    800b63 <strtol+0x28>
		s++;
  800b55:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b58:	0f b6 02             	movzbl (%edx),%eax
  800b5b:	3c 20                	cmp    $0x20,%al
  800b5d:	74 f6                	je     800b55 <strtol+0x1a>
  800b5f:	3c 09                	cmp    $0x9,%al
  800b61:	74 f2                	je     800b55 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b63:	3c 2b                	cmp    $0x2b,%al
  800b65:	75 0c                	jne    800b73 <strtol+0x38>
		s++;
  800b67:	83 c2 01             	add    $0x1,%edx
  800b6a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b71:	eb 15                	jmp    800b88 <strtol+0x4d>
	else if (*s == '-')
  800b73:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b7a:	3c 2d                	cmp    $0x2d,%al
  800b7c:	75 0a                	jne    800b88 <strtol+0x4d>
		s++, neg = 1;
  800b7e:	83 c2 01             	add    $0x1,%edx
  800b81:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b88:	85 db                	test   %ebx,%ebx
  800b8a:	0f 94 c0             	sete   %al
  800b8d:	74 05                	je     800b94 <strtol+0x59>
  800b8f:	83 fb 10             	cmp    $0x10,%ebx
  800b92:	75 18                	jne    800bac <strtol+0x71>
  800b94:	80 3a 30             	cmpb   $0x30,(%edx)
  800b97:	75 13                	jne    800bac <strtol+0x71>
  800b99:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b9d:	8d 76 00             	lea    0x0(%esi),%esi
  800ba0:	75 0a                	jne    800bac <strtol+0x71>
		s += 2, base = 16;
  800ba2:	83 c2 02             	add    $0x2,%edx
  800ba5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800baa:	eb 15                	jmp    800bc1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bac:	84 c0                	test   %al,%al
  800bae:	66 90                	xchg   %ax,%ax
  800bb0:	74 0f                	je     800bc1 <strtol+0x86>
  800bb2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bb7:	80 3a 30             	cmpb   $0x30,(%edx)
  800bba:	75 05                	jne    800bc1 <strtol+0x86>
		s++, base = 8;
  800bbc:	83 c2 01             	add    $0x1,%edx
  800bbf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bc8:	0f b6 0a             	movzbl (%edx),%ecx
  800bcb:	89 cf                	mov    %ecx,%edi
  800bcd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bd0:	80 fb 09             	cmp    $0x9,%bl
  800bd3:	77 08                	ja     800bdd <strtol+0xa2>
			dig = *s - '0';
  800bd5:	0f be c9             	movsbl %cl,%ecx
  800bd8:	83 e9 30             	sub    $0x30,%ecx
  800bdb:	eb 1e                	jmp    800bfb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800bdd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800be0:	80 fb 19             	cmp    $0x19,%bl
  800be3:	77 08                	ja     800bed <strtol+0xb2>
			dig = *s - 'a' + 10;
  800be5:	0f be c9             	movsbl %cl,%ecx
  800be8:	83 e9 57             	sub    $0x57,%ecx
  800beb:	eb 0e                	jmp    800bfb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800bed:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800bf0:	80 fb 19             	cmp    $0x19,%bl
  800bf3:	77 15                	ja     800c0a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800bf5:	0f be c9             	movsbl %cl,%ecx
  800bf8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bfb:	39 f1                	cmp    %esi,%ecx
  800bfd:	7d 0b                	jge    800c0a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800bff:	83 c2 01             	add    $0x1,%edx
  800c02:	0f af c6             	imul   %esi,%eax
  800c05:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c08:	eb be                	jmp    800bc8 <strtol+0x8d>
  800c0a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c0c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c10:	74 05                	je     800c17 <strtol+0xdc>
		*endptr = (char *) s;
  800c12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c15:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c17:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c1b:	74 04                	je     800c21 <strtol+0xe6>
  800c1d:	89 c8                	mov    %ecx,%eax
  800c1f:	f7 d8                	neg    %eax
}
  800c21:	83 c4 04             	add    $0x4,%esp
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    
  800c29:	00 00                	add    %al,(%eax)
	...

00800c2c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	83 ec 08             	sub    $0x8,%esp
  800c32:	89 1c 24             	mov    %ebx,(%esp)
  800c35:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c39:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	89 c3                	mov    %eax,%ebx
  800c46:	89 c7                	mov    %eax,%edi
  800c48:	51                   	push   %ecx
  800c49:	52                   	push   %edx
  800c4a:	53                   	push   %ebx
  800c4b:	54                   	push   %esp
  800c4c:	55                   	push   %ebp
  800c4d:	56                   	push   %esi
  800c4e:	57                   	push   %edi
  800c4f:	8d 35 59 0c 80 00    	lea    0x800c59,%esi
  800c55:	54                   	push   %esp
  800c56:	5d                   	pop    %ebp
  800c57:	0f 34                	sysenter 
  800c59:	5f                   	pop    %edi
  800c5a:	5e                   	pop    %esi
  800c5b:	5d                   	pop    %ebp
  800c5c:	5c                   	pop    %esp
  800c5d:	5b                   	pop    %ebx
  800c5e:	5a                   	pop    %edx
  800c5f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c60:	8b 1c 24             	mov    (%esp),%ebx
  800c63:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c67:	89 ec                	mov    %ebp,%esp
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <sys_cgetc>:

int
sys_cgetc(void)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	83 ec 08             	sub    $0x8,%esp
  800c71:	89 1c 24             	mov    %ebx,(%esp)
  800c74:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c78:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c82:	89 d1                	mov    %edx,%ecx
  800c84:	89 d3                	mov    %edx,%ebx
  800c86:	89 d7                	mov    %edx,%edi
  800c88:	51                   	push   %ecx
  800c89:	52                   	push   %edx
  800c8a:	53                   	push   %ebx
  800c8b:	54                   	push   %esp
  800c8c:	55                   	push   %ebp
  800c8d:	56                   	push   %esi
  800c8e:	57                   	push   %edi
  800c8f:	8d 35 99 0c 80 00    	lea    0x800c99,%esi
  800c95:	54                   	push   %esp
  800c96:	5d                   	pop    %ebp
  800c97:	0f 34                	sysenter 
  800c99:	5f                   	pop    %edi
  800c9a:	5e                   	pop    %esi
  800c9b:	5d                   	pop    %ebp
  800c9c:	5c                   	pop    %esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5a                   	pop    %edx
  800c9f:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ca0:	8b 1c 24             	mov    (%esp),%ebx
  800ca3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ca7:	89 ec                	mov    %ebp,%esp
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	83 ec 08             	sub    $0x8,%esp
  800cb1:	89 1c 24             	mov    %ebx,(%esp)
  800cb4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800cb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbd:	b8 02 00 00 00       	mov    $0x2,%eax
  800cc2:	89 d1                	mov    %edx,%ecx
  800cc4:	89 d3                	mov    %edx,%ebx
  800cc6:	89 d7                	mov    %edx,%edi
  800cc8:	51                   	push   %ecx
  800cc9:	52                   	push   %edx
  800cca:	53                   	push   %ebx
  800ccb:	54                   	push   %esp
  800ccc:	55                   	push   %ebp
  800ccd:	56                   	push   %esi
  800cce:	57                   	push   %edi
  800ccf:	8d 35 d9 0c 80 00    	lea    0x800cd9,%esi
  800cd5:	54                   	push   %esp
  800cd6:	5d                   	pop    %ebp
  800cd7:	0f 34                	sysenter 
  800cd9:	5f                   	pop    %edi
  800cda:	5e                   	pop    %esi
  800cdb:	5d                   	pop    %ebp
  800cdc:	5c                   	pop    %esp
  800cdd:	5b                   	pop    %ebx
  800cde:	5a                   	pop    %edx
  800cdf:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ce0:	8b 1c 24             	mov    (%esp),%ebx
  800ce3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ce7:	89 ec                	mov    %ebp,%esp
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	83 ec 08             	sub    $0x8,%esp
  800cf1:	89 1c 24             	mov    %ebx,(%esp)
  800cf4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800cf8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfd:	b8 04 00 00 00       	mov    $0x4,%eax
  800d02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d05:	8b 55 08             	mov    0x8(%ebp),%edx
  800d08:	89 df                	mov    %ebx,%edi
  800d0a:	51                   	push   %ecx
  800d0b:	52                   	push   %edx
  800d0c:	53                   	push   %ebx
  800d0d:	54                   	push   %esp
  800d0e:	55                   	push   %ebp
  800d0f:	56                   	push   %esi
  800d10:	57                   	push   %edi
  800d11:	8d 35 1b 0d 80 00    	lea    0x800d1b,%esi
  800d17:	54                   	push   %esp
  800d18:	5d                   	pop    %ebp
  800d19:	0f 34                	sysenter 
  800d1b:	5f                   	pop    %edi
  800d1c:	5e                   	pop    %esi
  800d1d:	5d                   	pop    %ebp
  800d1e:	5c                   	pop    %esp
  800d1f:	5b                   	pop    %ebx
  800d20:	5a                   	pop    %edx
  800d21:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800d22:	8b 1c 24             	mov    (%esp),%ebx
  800d25:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d29:	89 ec                	mov    %ebp,%esp
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	83 ec 28             	sub    $0x28,%esp
  800d33:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800d36:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3e:	b8 03 00 00 00       	mov    $0x3,%eax
  800d43:	8b 55 08             	mov    0x8(%ebp),%edx
  800d46:	89 cb                	mov    %ecx,%ebx
  800d48:	89 cf                	mov    %ecx,%edi
  800d4a:	51                   	push   %ecx
  800d4b:	52                   	push   %edx
  800d4c:	53                   	push   %ebx
  800d4d:	54                   	push   %esp
  800d4e:	55                   	push   %ebp
  800d4f:	56                   	push   %esi
  800d50:	57                   	push   %edi
  800d51:	8d 35 5b 0d 80 00    	lea    0x800d5b,%esi
  800d57:	54                   	push   %esp
  800d58:	5d                   	pop    %ebp
  800d59:	0f 34                	sysenter 
  800d5b:	5f                   	pop    %edi
  800d5c:	5e                   	pop    %esi
  800d5d:	5d                   	pop    %ebp
  800d5e:	5c                   	pop    %esp
  800d5f:	5b                   	pop    %ebx
  800d60:	5a                   	pop    %edx
  800d61:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800d62:	85 c0                	test   %eax,%eax
  800d64:	7e 28                	jle    800d8e <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d66:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d6a:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d71:	00 
  800d72:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800d79:	00 
  800d7a:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  800d81:	00 
  800d82:	c7 04 24 45 13 80 00 	movl   $0x801345,(%esp)
  800d89:	e8 0a 00 00 00       	call   800d98 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d8e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800d91:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d94:	89 ec                	mov    %ebp,%esp
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	56                   	push   %esi
  800d9c:	53                   	push   %ebx
  800d9d:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800da0:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800da3:	a1 08 20 80 00       	mov    0x802008,%eax
  800da8:	85 c0                	test   %eax,%eax
  800daa:	74 10                	je     800dbc <_panic+0x24>
		cprintf("%s: ", argv0);
  800dac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800db0:	c7 04 24 53 13 80 00 	movl   $0x801353,(%esp)
  800db7:	e8 5d f3 ff ff       	call   800119 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800dbc:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800dc2:	e8 e4 fe ff ff       	call   800cab <sys_getenvid>
  800dc7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dca:	89 54 24 10          	mov    %edx,0x10(%esp)
  800dce:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800dd5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800dd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ddd:	c7 04 24 5c 13 80 00 	movl   $0x80135c,(%esp)
  800de4:	e8 30 f3 ff ff       	call   800119 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800de9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ded:	8b 45 10             	mov    0x10(%ebp),%eax
  800df0:	89 04 24             	mov    %eax,(%esp)
  800df3:	e8 c0 f2 ff ff       	call   8000b8 <vcprintf>
	cprintf("\n");
  800df8:	c7 04 24 58 13 80 00 	movl   $0x801358,(%esp)
  800dff:	e8 15 f3 ff ff       	call   800119 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e04:	cc                   	int3   
  800e05:	eb fd                	jmp    800e04 <_panic+0x6c>
	...

00800e10 <__udivdi3>:
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	57                   	push   %edi
  800e14:	56                   	push   %esi
  800e15:	83 ec 10             	sub    $0x10,%esp
  800e18:	8b 45 14             	mov    0x14(%ebp),%eax
  800e1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1e:	8b 75 10             	mov    0x10(%ebp),%esi
  800e21:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e24:	85 c0                	test   %eax,%eax
  800e26:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800e29:	75 35                	jne    800e60 <__udivdi3+0x50>
  800e2b:	39 fe                	cmp    %edi,%esi
  800e2d:	77 61                	ja     800e90 <__udivdi3+0x80>
  800e2f:	85 f6                	test   %esi,%esi
  800e31:	75 0b                	jne    800e3e <__udivdi3+0x2e>
  800e33:	b8 01 00 00 00       	mov    $0x1,%eax
  800e38:	31 d2                	xor    %edx,%edx
  800e3a:	f7 f6                	div    %esi
  800e3c:	89 c6                	mov    %eax,%esi
  800e3e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800e41:	31 d2                	xor    %edx,%edx
  800e43:	89 f8                	mov    %edi,%eax
  800e45:	f7 f6                	div    %esi
  800e47:	89 c7                	mov    %eax,%edi
  800e49:	89 c8                	mov    %ecx,%eax
  800e4b:	f7 f6                	div    %esi
  800e4d:	89 c1                	mov    %eax,%ecx
  800e4f:	89 fa                	mov    %edi,%edx
  800e51:	89 c8                	mov    %ecx,%eax
  800e53:	83 c4 10             	add    $0x10,%esp
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    
  800e5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e60:	39 f8                	cmp    %edi,%eax
  800e62:	77 1c                	ja     800e80 <__udivdi3+0x70>
  800e64:	0f bd d0             	bsr    %eax,%edx
  800e67:	83 f2 1f             	xor    $0x1f,%edx
  800e6a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800e6d:	75 39                	jne    800ea8 <__udivdi3+0x98>
  800e6f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  800e72:	0f 86 a0 00 00 00    	jbe    800f18 <__udivdi3+0x108>
  800e78:	39 f8                	cmp    %edi,%eax
  800e7a:	0f 82 98 00 00 00    	jb     800f18 <__udivdi3+0x108>
  800e80:	31 ff                	xor    %edi,%edi
  800e82:	31 c9                	xor    %ecx,%ecx
  800e84:	89 c8                	mov    %ecx,%eax
  800e86:	89 fa                	mov    %edi,%edx
  800e88:	83 c4 10             	add    $0x10,%esp
  800e8b:	5e                   	pop    %esi
  800e8c:	5f                   	pop    %edi
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    
  800e8f:	90                   	nop
  800e90:	89 d1                	mov    %edx,%ecx
  800e92:	89 fa                	mov    %edi,%edx
  800e94:	89 c8                	mov    %ecx,%eax
  800e96:	31 ff                	xor    %edi,%edi
  800e98:	f7 f6                	div    %esi
  800e9a:	89 c1                	mov    %eax,%ecx
  800e9c:	89 fa                	mov    %edi,%edx
  800e9e:	89 c8                	mov    %ecx,%eax
  800ea0:	83 c4 10             	add    $0x10,%esp
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    
  800ea7:	90                   	nop
  800ea8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800eac:	89 f2                	mov    %esi,%edx
  800eae:	d3 e0                	shl    %cl,%eax
  800eb0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800eb3:	b8 20 00 00 00       	mov    $0x20,%eax
  800eb8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800ebb:	89 c1                	mov    %eax,%ecx
  800ebd:	d3 ea                	shr    %cl,%edx
  800ebf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800ec3:	0b 55 ec             	or     -0x14(%ebp),%edx
  800ec6:	d3 e6                	shl    %cl,%esi
  800ec8:	89 c1                	mov    %eax,%ecx
  800eca:	89 75 e8             	mov    %esi,-0x18(%ebp)
  800ecd:	89 fe                	mov    %edi,%esi
  800ecf:	d3 ee                	shr    %cl,%esi
  800ed1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800ed5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800ed8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800edb:	d3 e7                	shl    %cl,%edi
  800edd:	89 c1                	mov    %eax,%ecx
  800edf:	d3 ea                	shr    %cl,%edx
  800ee1:	09 d7                	or     %edx,%edi
  800ee3:	89 f2                	mov    %esi,%edx
  800ee5:	89 f8                	mov    %edi,%eax
  800ee7:	f7 75 ec             	divl   -0x14(%ebp)
  800eea:	89 d6                	mov    %edx,%esi
  800eec:	89 c7                	mov    %eax,%edi
  800eee:	f7 65 e8             	mull   -0x18(%ebp)
  800ef1:	39 d6                	cmp    %edx,%esi
  800ef3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800ef6:	72 30                	jb     800f28 <__udivdi3+0x118>
  800ef8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800efb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800eff:	d3 e2                	shl    %cl,%edx
  800f01:	39 c2                	cmp    %eax,%edx
  800f03:	73 05                	jae    800f0a <__udivdi3+0xfa>
  800f05:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  800f08:	74 1e                	je     800f28 <__udivdi3+0x118>
  800f0a:	89 f9                	mov    %edi,%ecx
  800f0c:	31 ff                	xor    %edi,%edi
  800f0e:	e9 71 ff ff ff       	jmp    800e84 <__udivdi3+0x74>
  800f13:	90                   	nop
  800f14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f18:	31 ff                	xor    %edi,%edi
  800f1a:	b9 01 00 00 00       	mov    $0x1,%ecx
  800f1f:	e9 60 ff ff ff       	jmp    800e84 <__udivdi3+0x74>
  800f24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f28:	8d 4f ff             	lea    -0x1(%edi),%ecx
  800f2b:	31 ff                	xor    %edi,%edi
  800f2d:	89 c8                	mov    %ecx,%eax
  800f2f:	89 fa                	mov    %edi,%edx
  800f31:	83 c4 10             	add    $0x10,%esp
  800f34:	5e                   	pop    %esi
  800f35:	5f                   	pop    %edi
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    
	...

00800f40 <__umoddi3>:
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	57                   	push   %edi
  800f44:	56                   	push   %esi
  800f45:	83 ec 20             	sub    $0x20,%esp
  800f48:	8b 55 14             	mov    0x14(%ebp),%edx
  800f4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f4e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800f51:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f54:	85 d2                	test   %edx,%edx
  800f56:	89 c8                	mov    %ecx,%eax
  800f58:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800f5b:	75 13                	jne    800f70 <__umoddi3+0x30>
  800f5d:	39 f7                	cmp    %esi,%edi
  800f5f:	76 3f                	jbe    800fa0 <__umoddi3+0x60>
  800f61:	89 f2                	mov    %esi,%edx
  800f63:	f7 f7                	div    %edi
  800f65:	89 d0                	mov    %edx,%eax
  800f67:	31 d2                	xor    %edx,%edx
  800f69:	83 c4 20             	add    $0x20,%esp
  800f6c:	5e                   	pop    %esi
  800f6d:	5f                   	pop    %edi
  800f6e:	5d                   	pop    %ebp
  800f6f:	c3                   	ret    
  800f70:	39 f2                	cmp    %esi,%edx
  800f72:	77 4c                	ja     800fc0 <__umoddi3+0x80>
  800f74:	0f bd ca             	bsr    %edx,%ecx
  800f77:	83 f1 1f             	xor    $0x1f,%ecx
  800f7a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f7d:	75 51                	jne    800fd0 <__umoddi3+0x90>
  800f7f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  800f82:	0f 87 e0 00 00 00    	ja     801068 <__umoddi3+0x128>
  800f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f8b:	29 f8                	sub    %edi,%eax
  800f8d:	19 d6                	sbb    %edx,%esi
  800f8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f95:	89 f2                	mov    %esi,%edx
  800f97:	83 c4 20             	add    $0x20,%esp
  800f9a:	5e                   	pop    %esi
  800f9b:	5f                   	pop    %edi
  800f9c:	5d                   	pop    %ebp
  800f9d:	c3                   	ret    
  800f9e:	66 90                	xchg   %ax,%ax
  800fa0:	85 ff                	test   %edi,%edi
  800fa2:	75 0b                	jne    800faf <__umoddi3+0x6f>
  800fa4:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa9:	31 d2                	xor    %edx,%edx
  800fab:	f7 f7                	div    %edi
  800fad:	89 c7                	mov    %eax,%edi
  800faf:	89 f0                	mov    %esi,%eax
  800fb1:	31 d2                	xor    %edx,%edx
  800fb3:	f7 f7                	div    %edi
  800fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb8:	f7 f7                	div    %edi
  800fba:	eb a9                	jmp    800f65 <__umoddi3+0x25>
  800fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fc0:	89 c8                	mov    %ecx,%eax
  800fc2:	89 f2                	mov    %esi,%edx
  800fc4:	83 c4 20             	add    $0x20,%esp
  800fc7:	5e                   	pop    %esi
  800fc8:	5f                   	pop    %edi
  800fc9:	5d                   	pop    %ebp
  800fca:	c3                   	ret    
  800fcb:	90                   	nop
  800fcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fd0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800fd4:	d3 e2                	shl    %cl,%edx
  800fd6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800fd9:	ba 20 00 00 00       	mov    $0x20,%edx
  800fde:	2b 55 f0             	sub    -0x10(%ebp),%edx
  800fe1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800fe4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800fe8:	89 fa                	mov    %edi,%edx
  800fea:	d3 ea                	shr    %cl,%edx
  800fec:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800ff0:	0b 55 f4             	or     -0xc(%ebp),%edx
  800ff3:	d3 e7                	shl    %cl,%edi
  800ff5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800ff9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800ffc:	89 f2                	mov    %esi,%edx
  800ffe:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801001:	89 c7                	mov    %eax,%edi
  801003:	d3 ea                	shr    %cl,%edx
  801005:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801009:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80100c:	89 c2                	mov    %eax,%edx
  80100e:	d3 e6                	shl    %cl,%esi
  801010:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801014:	d3 ea                	shr    %cl,%edx
  801016:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80101a:	09 d6                	or     %edx,%esi
  80101c:	89 f0                	mov    %esi,%eax
  80101e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801021:	d3 e7                	shl    %cl,%edi
  801023:	89 f2                	mov    %esi,%edx
  801025:	f7 75 f4             	divl   -0xc(%ebp)
  801028:	89 d6                	mov    %edx,%esi
  80102a:	f7 65 e8             	mull   -0x18(%ebp)
  80102d:	39 d6                	cmp    %edx,%esi
  80102f:	72 2b                	jb     80105c <__umoddi3+0x11c>
  801031:	39 c7                	cmp    %eax,%edi
  801033:	72 23                	jb     801058 <__umoddi3+0x118>
  801035:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801039:	29 c7                	sub    %eax,%edi
  80103b:	19 d6                	sbb    %edx,%esi
  80103d:	89 f0                	mov    %esi,%eax
  80103f:	89 f2                	mov    %esi,%edx
  801041:	d3 ef                	shr    %cl,%edi
  801043:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801047:	d3 e0                	shl    %cl,%eax
  801049:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80104d:	09 f8                	or     %edi,%eax
  80104f:	d3 ea                	shr    %cl,%edx
  801051:	83 c4 20             	add    $0x20,%esp
  801054:	5e                   	pop    %esi
  801055:	5f                   	pop    %edi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    
  801058:	39 d6                	cmp    %edx,%esi
  80105a:	75 d9                	jne    801035 <__umoddi3+0xf5>
  80105c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80105f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801062:	eb d1                	jmp    801035 <__umoddi3+0xf5>
  801064:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801068:	39 f2                	cmp    %esi,%edx
  80106a:	0f 82 18 ff ff ff    	jb     800f88 <__umoddi3+0x48>
  801070:	e9 1d ff ff ff       	jmp    800f92 <__umoddi3+0x52>
