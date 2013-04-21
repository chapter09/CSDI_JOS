
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  80003a:	c7 04 24 88 10 80 00 	movl   $0x801088,(%esp)
  800041:	e8 df 00 00 00       	call   800125 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 04 20 80 00       	mov    0x802004,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 96 10 80 00 	movl   $0x801096,(%esp)
  800059:	e8 c7 00 00 00       	call   800125 <cprintf>
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	83 ec 18             	sub    $0x18,%esp
  800066:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800069:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80006c:	8b 75 08             	mov    0x8(%ebp),%esi
  80006f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800072:	e8 44 0c 00 00       	call   800cbb <sys_getenvid>
  800077:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007c:	6b c0 64             	imul   $0x64,%eax,%eax
  80007f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800084:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800089:	85 f6                	test   %esi,%esi
  80008b:	7e 07                	jle    800094 <libmain+0x34>
		binaryname = argv[0];
  80008d:	8b 03                	mov    (%ebx),%eax
  80008f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800094:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800098:	89 34 24             	mov    %esi,(%esp)
  80009b:	e8 94 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a0:	e8 0b 00 00 00       	call   8000b0 <exit>
}
  8000a5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000ab:	89 ec                	mov    %ebp,%esp
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000bd:	e8 7b 0c 00 00       	call   800d3d <sys_env_destroy>
}
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000cd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000d4:	00 00 00 
	b.cnt = 0;
  8000d7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8000eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8000f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f9:	c7 04 24 3f 01 80 00 	movl   $0x80013f,(%esp)
  800100:	e8 d8 01 00 00       	call   8002dd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800105:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80010b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80010f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800115:	89 04 24             	mov    %eax,(%esp)
  800118:	e8 1f 0b 00 00       	call   800c3c <sys_cputs>

	return b.cnt;
}
  80011d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800123:	c9                   	leave  
  800124:	c3                   	ret    

00800125 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80012b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80012e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800132:	8b 45 08             	mov    0x8(%ebp),%eax
  800135:	89 04 24             	mov    %eax,(%esp)
  800138:	e8 87 ff ff ff       	call   8000c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80013d:	c9                   	leave  
  80013e:	c3                   	ret    

0080013f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	53                   	push   %ebx
  800143:	83 ec 14             	sub    $0x14,%esp
  800146:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800149:	8b 03                	mov    (%ebx),%eax
  80014b:	8b 55 08             	mov    0x8(%ebp),%edx
  80014e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800152:	83 c0 01             	add    $0x1,%eax
  800155:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800157:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015c:	75 19                	jne    800177 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80015e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800165:	00 
  800166:	8d 43 08             	lea    0x8(%ebx),%eax
  800169:	89 04 24             	mov    %eax,(%esp)
  80016c:	e8 cb 0a 00 00       	call   800c3c <sys_cputs>
		b->idx = 0;
  800171:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800177:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017b:	83 c4 14             	add    $0x14,%esp
  80017e:	5b                   	pop    %ebx
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    
	...

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 4c             	sub    $0x4c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d6                	mov    %edx,%esi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001b0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001bb:	39 d1                	cmp    %edx,%ecx
  8001bd:	72 15                	jb     8001d4 <printnum+0x44>
  8001bf:	77 07                	ja     8001c8 <printnum+0x38>
  8001c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001c4:	39 d0                	cmp    %edx,%eax
  8001c6:	76 0c                	jbe    8001d4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c8:	83 eb 01             	sub    $0x1,%ebx
  8001cb:	85 db                	test   %ebx,%ebx
  8001cd:	8d 76 00             	lea    0x0(%esi),%esi
  8001d0:	7f 61                	jg     800233 <printnum+0xa3>
  8001d2:	eb 70                	jmp    800244 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001d8:	83 eb 01             	sub    $0x1,%ebx
  8001db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8001e7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8001eb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8001ee:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8001f1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ff:	00 
  800200:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800203:	89 04 24             	mov    %eax,(%esp)
  800206:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800209:	89 54 24 04          	mov    %edx,0x4(%esp)
  80020d:	e8 0e 0c 00 00       	call   800e20 <__udivdi3>
  800212:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800215:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800218:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80021c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800220:	89 04 24             	mov    %eax,(%esp)
  800223:	89 54 24 04          	mov    %edx,0x4(%esp)
  800227:	89 f2                	mov    %esi,%edx
  800229:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80022c:	e8 5f ff ff ff       	call   800190 <printnum>
  800231:	eb 11                	jmp    800244 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800233:	89 74 24 04          	mov    %esi,0x4(%esp)
  800237:	89 3c 24             	mov    %edi,(%esp)
  80023a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f ef                	jg     800233 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	89 74 24 04          	mov    %esi,0x4(%esp)
  800248:	8b 74 24 04          	mov    0x4(%esp),%esi
  80024c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80024f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800253:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80025a:	00 
  80025b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80025e:	89 14 24             	mov    %edx,(%esp)
  800261:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800264:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800268:	e8 e3 0c 00 00       	call   800f50 <__umoddi3>
  80026d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800271:	0f be 80 b7 10 80 00 	movsbl 0x8010b7(%eax),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80027e:	83 c4 4c             	add    $0x4c,%esp
  800281:	5b                   	pop    %ebx
  800282:	5e                   	pop    %esi
  800283:	5f                   	pop    %edi
  800284:	5d                   	pop    %ebp
  800285:	c3                   	ret    

00800286 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800289:	83 fa 01             	cmp    $0x1,%edx
  80028c:	7e 0e                	jle    80029c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80028e:	8b 10                	mov    (%eax),%edx
  800290:	8d 4a 08             	lea    0x8(%edx),%ecx
  800293:	89 08                	mov    %ecx,(%eax)
  800295:	8b 02                	mov    (%edx),%eax
  800297:	8b 52 04             	mov    0x4(%edx),%edx
  80029a:	eb 22                	jmp    8002be <getuint+0x38>
	else if (lflag)
  80029c:	85 d2                	test   %edx,%edx
  80029e:	74 10                	je     8002b0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002a0:	8b 10                	mov    (%eax),%edx
  8002a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 02                	mov    (%edx),%eax
  8002a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ae:	eb 0e                	jmp    8002be <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002b0:	8b 10                	mov    (%eax),%edx
  8002b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b5:	89 08                	mov    %ecx,(%eax)
  8002b7:	8b 02                	mov    (%edx),%eax
  8002b9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002be:	5d                   	pop    %ebp
  8002bf:	c3                   	ret    

008002c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ca:	8b 10                	mov    (%eax),%edx
  8002cc:	3b 50 04             	cmp    0x4(%eax),%edx
  8002cf:	73 0a                	jae    8002db <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d4:	88 0a                	mov    %cl,(%edx)
  8002d6:	83 c2 01             	add    $0x1,%edx
  8002d9:	89 10                	mov    %edx,(%eax)
}
  8002db:	5d                   	pop    %ebp
  8002dc:	c3                   	ret    

008002dd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
  8002e0:	57                   	push   %edi
  8002e1:	56                   	push   %esi
  8002e2:	53                   	push   %ebx
  8002e3:	83 ec 5c             	sub    $0x5c,%esp
  8002e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8002ef:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002f6:	eb 16                	jmp    80030e <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f8:	85 c0                	test   %eax,%eax
  8002fa:	0f 84 4f 04 00 00    	je     80074f <vprintfmt+0x472>
				return;
			putch(ch, putdat);
  800300:	89 74 24 04          	mov    %esi,0x4(%esp)
  800304:	89 04 24             	mov    %eax,(%esp)
  800307:	ff d7                	call   *%edi
  800309:	eb 03                	jmp    80030e <vprintfmt+0x31>
  80030b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030e:	0f b6 03             	movzbl (%ebx),%eax
  800311:	83 c3 01             	add    $0x1,%ebx
  800314:	83 f8 25             	cmp    $0x25,%eax
  800317:	75 df                	jne    8002f8 <vprintfmt+0x1b>
  800319:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80031d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800324:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800332:	b9 00 00 00 00       	mov    $0x0,%ecx
  800337:	eb 06                	jmp    80033f <vprintfmt+0x62>
  800339:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  80033d:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033f:	0f b6 13             	movzbl (%ebx),%edx
  800342:	0f b6 c2             	movzbl %dl,%eax
  800345:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800348:	8d 43 01             	lea    0x1(%ebx),%eax
  80034b:	83 ea 23             	sub    $0x23,%edx
  80034e:	80 fa 55             	cmp    $0x55,%dl
  800351:	0f 87 db 03 00 00    	ja     800732 <vprintfmt+0x455>
  800357:	0f b6 d2             	movzbl %dl,%edx
  80035a:	ff 24 95 c0 11 80 00 	jmp    *0x8011c0(,%edx,4)
  800361:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800365:	eb d6                	jmp    80033d <vprintfmt+0x60>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800367:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80036a:	83 ea 30             	sub    $0x30,%edx
  80036d:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  800370:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800373:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800376:	83 fb 09             	cmp    $0x9,%ebx
  800379:	77 4c                	ja     8003c7 <vprintfmt+0xea>
  80037b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80037e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800381:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800384:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800387:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  80038b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80038e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800391:	83 fb 09             	cmp    $0x9,%ebx
  800394:	76 eb                	jbe    800381 <vprintfmt+0xa4>
  800396:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800399:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80039c:	eb 29                	jmp    8003c7 <vprintfmt+0xea>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80039e:	8b 55 14             	mov    0x14(%ebp),%edx
  8003a1:	8d 5a 04             	lea    0x4(%edx),%ebx
  8003a4:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8003a7:	8b 12                	mov    (%edx),%edx
  8003a9:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  8003ac:	eb 19                	jmp    8003c7 <vprintfmt+0xea>

		case '.':
			if (width < 0)
  8003ae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003b1:	c1 fa 1f             	sar    $0x1f,%edx
  8003b4:	f7 d2                	not    %edx
  8003b6:	21 55 d4             	and    %edx,-0x2c(%ebp)
  8003b9:	eb 82                	jmp    80033d <vprintfmt+0x60>
  8003bb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003c2:	e9 76 ff ff ff       	jmp    80033d <vprintfmt+0x60>

		process_precision:
			if (width < 0)
  8003c7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003cb:	0f 89 6c ff ff ff    	jns    80033d <vprintfmt+0x60>
  8003d1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8003d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003d7:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8003da:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8003dd:	e9 5b ff ff ff       	jmp    80033d <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e2:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8003e5:	e9 53 ff ff ff       	jmp    80033d <vprintfmt+0x60>
  8003ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f0:	8d 50 04             	lea    0x4(%eax),%edx
  8003f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003fa:	8b 00                	mov    (%eax),%eax
  8003fc:	89 04 24             	mov    %eax,(%esp)
  8003ff:	ff d7                	call   *%edi
  800401:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
  800404:	e9 05 ff ff ff       	jmp    80030e <vprintfmt+0x31>
  800409:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 50 04             	lea    0x4(%eax),%edx
  800412:	89 55 14             	mov    %edx,0x14(%ebp)
  800415:	8b 00                	mov    (%eax),%eax
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 fa 1f             	sar    $0x1f,%edx
  80041c:	31 d0                	xor    %edx,%eax
  80041e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800420:	83 f8 06             	cmp    $0x6,%eax
  800423:	7f 0b                	jg     800430 <vprintfmt+0x153>
  800425:	8b 14 85 18 13 80 00 	mov    0x801318(,%eax,4),%edx
  80042c:	85 d2                	test   %edx,%edx
  80042e:	75 20                	jne    800450 <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  800430:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800434:	c7 44 24 08 c8 10 80 	movl   $0x8010c8,0x8(%esp)
  80043b:	00 
  80043c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800440:	89 3c 24             	mov    %edi,(%esp)
  800443:	e8 8f 03 00 00       	call   8007d7 <printfmt>
  800448:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044b:	e9 be fe ff ff       	jmp    80030e <vprintfmt+0x31>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800450:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800454:	c7 44 24 08 d1 10 80 	movl   $0x8010d1,0x8(%esp)
  80045b:	00 
  80045c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800460:	89 3c 24             	mov    %edi,(%esp)
  800463:	e8 6f 03 00 00       	call   8007d7 <printfmt>
  800468:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80046b:	e9 9e fe ff ff       	jmp    80030e <vprintfmt+0x31>
  800470:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800473:	89 c3                	mov    %eax,%ebx
  800475:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800478:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80047b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047e:	8b 45 14             	mov    0x14(%ebp),%eax
  800481:	8d 50 04             	lea    0x4(%eax),%edx
  800484:	89 55 14             	mov    %edx,0x14(%ebp)
  800487:	8b 00                	mov    (%eax),%eax
  800489:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80048c:	85 c0                	test   %eax,%eax
  80048e:	75 07                	jne    800497 <vprintfmt+0x1ba>
  800490:	c7 45 cc d4 10 80 00 	movl   $0x8010d4,-0x34(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800497:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80049b:	7e 06                	jle    8004a3 <vprintfmt+0x1c6>
  80049d:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8004a1:	75 13                	jne    8004b6 <vprintfmt+0x1d9>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8004a6:	0f be 02             	movsbl (%edx),%eax
  8004a9:	85 c0                	test   %eax,%eax
  8004ab:	0f 85 9f 00 00 00    	jne    800550 <vprintfmt+0x273>
  8004b1:	e9 8f 00 00 00       	jmp    800545 <vprintfmt+0x268>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004ba:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004bd:	89 0c 24             	mov    %ecx,(%esp)
  8004c0:	e8 56 03 00 00       	call   80081b <strnlen>
  8004c5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004c8:	29 c2                	sub    %eax,%edx
  8004ca:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004cd:	85 d2                	test   %edx,%edx
  8004cf:	7e d2                	jle    8004a3 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004d1:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8004d5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004d8:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8004db:	89 d3                	mov    %edx,%ebx
  8004dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e4:	89 04 24             	mov    %eax,(%esp)
  8004e7:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e9:	83 eb 01             	sub    $0x1,%ebx
  8004ec:	85 db                	test   %ebx,%ebx
  8004ee:	7f ed                	jg     8004dd <vprintfmt+0x200>
  8004f0:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8004f3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8004fa:	eb a7                	jmp    8004a3 <vprintfmt+0x1c6>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800500:	74 1b                	je     80051d <vprintfmt+0x240>
  800502:	8d 50 e0             	lea    -0x20(%eax),%edx
  800505:	83 fa 5e             	cmp    $0x5e,%edx
  800508:	76 13                	jbe    80051d <vprintfmt+0x240>
					putch('?', putdat);
  80050a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80050d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800511:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800518:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051b:	eb 0d                	jmp    80052a <vprintfmt+0x24d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  80051d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800520:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800524:	89 04 24             	mov    %eax,(%esp)
  800527:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052a:	83 ef 01             	sub    $0x1,%edi
  80052d:	0f be 03             	movsbl (%ebx),%eax
  800530:	85 c0                	test   %eax,%eax
  800532:	74 05                	je     800539 <vprintfmt+0x25c>
  800534:	83 c3 01             	add    $0x1,%ebx
  800537:	eb 2e                	jmp    800567 <vprintfmt+0x28a>
  800539:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80053c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80053f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800542:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800545:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800549:	7f 33                	jg     80057e <vprintfmt+0x2a1>
  80054b:	e9 bb fd ff ff       	jmp    80030b <vprintfmt+0x2e>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800550:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800553:	83 c2 01             	add    $0x1,%edx
  800556:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800559:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80055c:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80055f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800562:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800565:	89 d3                	mov    %edx,%ebx
  800567:	85 f6                	test   %esi,%esi
  800569:	78 91                	js     8004fc <vprintfmt+0x21f>
  80056b:	83 ee 01             	sub    $0x1,%esi
  80056e:	79 8c                	jns    8004fc <vprintfmt+0x21f>
  800570:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800573:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800576:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800579:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80057c:	eb c7                	jmp    800545 <vprintfmt+0x268>
  80057e:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800581:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800584:	89 74 24 04          	mov    %esi,0x4(%esp)
  800588:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80058f:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800591:	83 eb 01             	sub    $0x1,%ebx
  800594:	85 db                	test   %ebx,%ebx
  800596:	7f ec                	jg     800584 <vprintfmt+0x2a7>
  800598:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80059b:	e9 6e fd ff ff       	jmp    80030e <vprintfmt+0x31>
  8005a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a3:	83 f9 01             	cmp    $0x1,%ecx
  8005a6:	7e 16                	jle    8005be <vprintfmt+0x2e1>
		return va_arg(*ap, long long);
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8d 50 08             	lea    0x8(%eax),%edx
  8005ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b1:	8b 10                	mov    (%eax),%edx
  8005b3:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b6:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005bc:	eb 32                	jmp    8005f0 <vprintfmt+0x313>
	else if (lflag)
  8005be:	85 c9                	test   %ecx,%ecx
  8005c0:	74 18                	je     8005da <vprintfmt+0x2fd>
		return va_arg(*ap, long);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 50 04             	lea    0x4(%eax),%edx
  8005c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cb:	8b 00                	mov    (%eax),%eax
  8005cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d0:	89 c1                	mov    %eax,%ecx
  8005d2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d8:	eb 16                	jmp    8005f0 <vprintfmt+0x313>
	else
		return va_arg(*ap, int);
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8d 50 04             	lea    0x4(%eax),%edx
  8005e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e3:	8b 00                	mov    (%eax),%eax
  8005e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e8:	89 c2                	mov    %eax,%edx
  8005ea:	c1 fa 1f             	sar    $0x1f,%edx
  8005ed:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005f6:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  8005fb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ff:	0f 89 8a 00 00 00    	jns    80068f <vprintfmt+0x3b2>
				putch('-', putdat);
  800605:	89 74 24 04          	mov    %esi,0x4(%esp)
  800609:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800610:	ff d7                	call   *%edi
				num = -(long long) num;
  800612:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800615:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800618:	f7 d8                	neg    %eax
  80061a:	83 d2 00             	adc    $0x0,%edx
  80061d:	f7 da                	neg    %edx
  80061f:	eb 6e                	jmp    80068f <vprintfmt+0x3b2>
  800621:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800624:	89 ca                	mov    %ecx,%edx
  800626:	8d 45 14             	lea    0x14(%ebp),%eax
  800629:	e8 58 fc ff ff       	call   800286 <getuint>
  80062e:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  800633:	eb 5a                	jmp    80068f <vprintfmt+0x3b2>
  800635:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			//break;
			num = getuint(&ap, lflag);
  800638:	89 ca                	mov    %ecx,%edx
  80063a:	8d 45 14             	lea    0x14(%ebp),%eax
  80063d:	e8 44 fc ff ff       	call   800286 <getuint>
  800642:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800647:	eb 46                	jmp    80068f <vprintfmt+0x3b2>
  800649:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  80064c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800650:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800657:	ff d7                	call   *%edi
			putch('x', putdat);
  800659:	89 74 24 04          	mov    %esi,0x4(%esp)
  80065d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800664:	ff d7                	call   *%edi
			num = (unsigned long long)
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8d 50 04             	lea    0x4(%eax),%edx
  80066c:	89 55 14             	mov    %edx,0x14(%ebp)
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	ba 00 00 00 00       	mov    $0x0,%edx
  800676:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80067b:	eb 12                	jmp    80068f <vprintfmt+0x3b2>
  80067d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800680:	89 ca                	mov    %ecx,%edx
  800682:	8d 45 14             	lea    0x14(%ebp),%eax
  800685:	e8 fc fb ff ff       	call   800286 <getuint>
  80068a:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80068f:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800693:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800697:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80069a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80069e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8006a2:	89 04 24             	mov    %eax,(%esp)
  8006a5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006a9:	89 f2                	mov    %esi,%edx
  8006ab:	89 f8                	mov    %edi,%eax
  8006ad:	e8 de fa ff ff       	call   800190 <printnum>
  8006b2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
  8006b5:	e9 54 fc ff ff       	jmp    80030e <vprintfmt+0x31>
  8006ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			char* tmp = va_arg(ap, char*);
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8d 50 04             	lea    0x4(%eax),%edx
  8006c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c6:	8b 00                	mov    (%eax),%eax
			if(tmp == NULL) {
  8006c8:	85 c0                	test   %eax,%eax
  8006ca:	75 1f                	jne    8006eb <vprintfmt+0x40e>
  8006cc:	bb 45 11 80 00       	mov    $0x801145,%ebx
  8006d1:	b0 0a                	mov    $0xa,%al
				for(; (ch = *null_error++) != '\0';) {	
					putch(ch, putdat);
  8006d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d7:	89 04 24             	mov    %eax,(%esp)
  8006da:	ff d7                	call   *%edi
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			char* tmp = va_arg(ap, char*);
			if(tmp == NULL) {
				for(; (ch = *null_error++) != '\0';) {	
  8006dc:	0f be 03             	movsbl (%ebx),%eax
  8006df:	83 c3 01             	add    $0x1,%ebx
  8006e2:	85 c0                	test   %eax,%eax
  8006e4:	75 ed                	jne    8006d3 <vprintfmt+0x3f6>
  8006e6:	e9 20 fc ff ff       	jmp    80030b <vprintfmt+0x2e>
					putch(ch, putdat);
				}
				break;
			}
			*tmp = *((signed char*) putdat);
  8006eb:	0f b6 16             	movzbl (%esi),%edx
  8006ee:	88 10                	mov    %dl,(%eax)
			if(*(signed char*) putdat < 0) {
  8006f0:	80 3e 00             	cmpb   $0x0,(%esi)
  8006f3:	0f 89 12 fc ff ff    	jns    80030b <vprintfmt+0x2e>
  8006f9:	bb 7d 11 80 00       	mov    $0x80117d,%ebx
  8006fe:	b8 0a 00 00 00       	mov    $0xa,%eax
				for(; (ch = *overflow_error++) != '\0';) {	
					putch(ch, putdat);
  800703:	89 74 24 04          	mov    %esi,0x4(%esp)
  800707:	89 04 24             	mov    %eax,(%esp)
  80070a:	ff d7                	call   *%edi
				}
				break;
			}
			*tmp = *((signed char*) putdat);
			if(*(signed char*) putdat < 0) {
				for(; (ch = *overflow_error++) != '\0';) {	
  80070c:	0f be 03             	movsbl (%ebx),%eax
  80070f:	83 c3 01             	add    $0x1,%ebx
  800712:	85 c0                	test   %eax,%eax
  800714:	75 ed                	jne    800703 <vprintfmt+0x426>
  800716:	e9 f0 fb ff ff       	jmp    80030b <vprintfmt+0x2e>
  80071b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80071e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800721:	89 74 24 04          	mov    %esi,0x4(%esp)
  800725:	89 14 24             	mov    %edx,(%esp)
  800728:	ff d7                	call   *%edi
  80072a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
  80072d:	e9 dc fb ff ff       	jmp    80030e <vprintfmt+0x31>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800732:	89 74 24 04          	mov    %esi,0x4(%esp)
  800736:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80073d:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073f:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800742:	80 38 25             	cmpb   $0x25,(%eax)
  800745:	0f 84 c3 fb ff ff    	je     80030e <vprintfmt+0x31>
  80074b:	89 c3                	mov    %eax,%ebx
  80074d:	eb f0                	jmp    80073f <vprintfmt+0x462>
				/* do nothing */;
			break;
		}
	}
}
  80074f:	83 c4 5c             	add    $0x5c,%esp
  800752:	5b                   	pop    %ebx
  800753:	5e                   	pop    %esi
  800754:	5f                   	pop    %edi
  800755:	5d                   	pop    %ebp
  800756:	c3                   	ret    

00800757 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	83 ec 28             	sub    $0x28,%esp
  80075d:	8b 45 08             	mov    0x8(%ebp),%eax
  800760:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800763:	85 c0                	test   %eax,%eax
  800765:	74 04                	je     80076b <vsnprintf+0x14>
  800767:	85 d2                	test   %edx,%edx
  800769:	7f 07                	jg     800772 <vsnprintf+0x1b>
  80076b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800770:	eb 3b                	jmp    8007ad <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800772:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800775:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800779:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80077c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80078a:	8b 45 10             	mov    0x10(%ebp),%eax
  80078d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800791:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800794:	89 44 24 04          	mov    %eax,0x4(%esp)
  800798:	c7 04 24 c0 02 80 00 	movl   $0x8002c0,(%esp)
  80079f:	e8 39 fb ff ff       	call   8002dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007ad:	c9                   	leave  
  8007ae:	c3                   	ret    

008007af <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8007b5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8007b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8007bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cd:	89 04 24             	mov    %eax,(%esp)
  8007d0:	e8 82 ff ff ff       	call   800757 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d5:	c9                   	leave  
  8007d6:	c3                   	ret    

008007d7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8007dd:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8007e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f5:	89 04 24             	mov    %eax,(%esp)
  8007f8:	e8 e0 fa ff ff       	call   8002dd <vprintfmt>
	va_end(ap);
}
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    
	...

00800800 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800806:	b8 00 00 00 00       	mov    $0x0,%eax
  80080b:	80 3a 00             	cmpb   $0x0,(%edx)
  80080e:	74 09                	je     800819 <strlen+0x19>
		n++;
  800810:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800813:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800817:	75 f7                	jne    800810 <strlen+0x10>
		n++;
	return n;
}
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800825:	85 c9                	test   %ecx,%ecx
  800827:	74 19                	je     800842 <strnlen+0x27>
  800829:	80 3b 00             	cmpb   $0x0,(%ebx)
  80082c:	74 14                	je     800842 <strnlen+0x27>
  80082e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800833:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800836:	39 c8                	cmp    %ecx,%eax
  800838:	74 0d                	je     800847 <strnlen+0x2c>
  80083a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80083e:	75 f3                	jne    800833 <strnlen+0x18>
  800840:	eb 05                	jmp    800847 <strnlen+0x2c>
  800842:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800847:	5b                   	pop    %ebx
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	53                   	push   %ebx
  80084e:	8b 45 08             	mov    0x8(%ebp),%eax
  800851:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800854:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800859:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80085d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800860:	83 c2 01             	add    $0x1,%edx
  800863:	84 c9                	test   %cl,%cl
  800865:	75 f2                	jne    800859 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800867:	5b                   	pop    %ebx
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	53                   	push   %ebx
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800874:	89 1c 24             	mov    %ebx,(%esp)
  800877:	e8 84 ff ff ff       	call   800800 <strlen>
	strcpy(dst + len, src);
  80087c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800883:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800886:	89 04 24             	mov    %eax,(%esp)
  800889:	e8 bc ff ff ff       	call   80084a <strcpy>
	return dst;
}
  80088e:	89 d8                	mov    %ebx,%eax
  800890:	83 c4 08             	add    $0x8,%esp
  800893:	5b                   	pop    %ebx
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	56                   	push   %esi
  80089a:	53                   	push   %ebx
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a4:	85 f6                	test   %esi,%esi
  8008a6:	74 18                	je     8008c0 <strncpy+0x2a>
  8008a8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008ad:	0f b6 1a             	movzbl (%edx),%ebx
  8008b0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b3:	80 3a 01             	cmpb   $0x1,(%edx)
  8008b6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b9:	83 c1 01             	add    $0x1,%ecx
  8008bc:	39 ce                	cmp    %ecx,%esi
  8008be:	77 ed                	ja     8008ad <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008c0:	5b                   	pop    %ebx
  8008c1:	5e                   	pop    %esi
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	56                   	push   %esi
  8008c8:	53                   	push   %ebx
  8008c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d2:	89 f0                	mov    %esi,%eax
  8008d4:	85 c9                	test   %ecx,%ecx
  8008d6:	74 27                	je     8008ff <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8008d8:	83 e9 01             	sub    $0x1,%ecx
  8008db:	74 1d                	je     8008fa <strlcpy+0x36>
  8008dd:	0f b6 1a             	movzbl (%edx),%ebx
  8008e0:	84 db                	test   %bl,%bl
  8008e2:	74 16                	je     8008fa <strlcpy+0x36>
			*dst++ = *src++;
  8008e4:	88 18                	mov    %bl,(%eax)
  8008e6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008e9:	83 e9 01             	sub    $0x1,%ecx
  8008ec:	74 0e                	je     8008fc <strlcpy+0x38>
			*dst++ = *src++;
  8008ee:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008f1:	0f b6 1a             	movzbl (%edx),%ebx
  8008f4:	84 db                	test   %bl,%bl
  8008f6:	75 ec                	jne    8008e4 <strlcpy+0x20>
  8008f8:	eb 02                	jmp    8008fc <strlcpy+0x38>
  8008fa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008fc:	c6 00 00             	movb   $0x0,(%eax)
  8008ff:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800901:	5b                   	pop    %ebx
  800902:	5e                   	pop    %esi
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80090e:	0f b6 01             	movzbl (%ecx),%eax
  800911:	84 c0                	test   %al,%al
  800913:	74 15                	je     80092a <strcmp+0x25>
  800915:	3a 02                	cmp    (%edx),%al
  800917:	75 11                	jne    80092a <strcmp+0x25>
		p++, q++;
  800919:	83 c1 01             	add    $0x1,%ecx
  80091c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80091f:	0f b6 01             	movzbl (%ecx),%eax
  800922:	84 c0                	test   %al,%al
  800924:	74 04                	je     80092a <strcmp+0x25>
  800926:	3a 02                	cmp    (%edx),%al
  800928:	74 ef                	je     800919 <strcmp+0x14>
  80092a:	0f b6 c0             	movzbl %al,%eax
  80092d:	0f b6 12             	movzbl (%edx),%edx
  800930:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	53                   	push   %ebx
  800938:	8b 55 08             	mov    0x8(%ebp),%edx
  80093b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800941:	85 c0                	test   %eax,%eax
  800943:	74 23                	je     800968 <strncmp+0x34>
  800945:	0f b6 1a             	movzbl (%edx),%ebx
  800948:	84 db                	test   %bl,%bl
  80094a:	74 25                	je     800971 <strncmp+0x3d>
  80094c:	3a 19                	cmp    (%ecx),%bl
  80094e:	75 21                	jne    800971 <strncmp+0x3d>
  800950:	83 e8 01             	sub    $0x1,%eax
  800953:	74 13                	je     800968 <strncmp+0x34>
		n--, p++, q++;
  800955:	83 c2 01             	add    $0x1,%edx
  800958:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80095b:	0f b6 1a             	movzbl (%edx),%ebx
  80095e:	84 db                	test   %bl,%bl
  800960:	74 0f                	je     800971 <strncmp+0x3d>
  800962:	3a 19                	cmp    (%ecx),%bl
  800964:	74 ea                	je     800950 <strncmp+0x1c>
  800966:	eb 09                	jmp    800971 <strncmp+0x3d>
  800968:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80096d:	5b                   	pop    %ebx
  80096e:	5d                   	pop    %ebp
  80096f:	90                   	nop
  800970:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800971:	0f b6 02             	movzbl (%edx),%eax
  800974:	0f b6 11             	movzbl (%ecx),%edx
  800977:	29 d0                	sub    %edx,%eax
  800979:	eb f2                	jmp    80096d <strncmp+0x39>

0080097b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800985:	0f b6 10             	movzbl (%eax),%edx
  800988:	84 d2                	test   %dl,%dl
  80098a:	74 18                	je     8009a4 <strchr+0x29>
		if (*s == c)
  80098c:	38 ca                	cmp    %cl,%dl
  80098e:	75 0a                	jne    80099a <strchr+0x1f>
  800990:	eb 17                	jmp    8009a9 <strchr+0x2e>
  800992:	38 ca                	cmp    %cl,%dl
  800994:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800998:	74 0f                	je     8009a9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80099a:	83 c0 01             	add    $0x1,%eax
  80099d:	0f b6 10             	movzbl (%eax),%edx
  8009a0:	84 d2                	test   %dl,%dl
  8009a2:	75 ee                	jne    800992 <strchr+0x17>
  8009a4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b5:	0f b6 10             	movzbl (%eax),%edx
  8009b8:	84 d2                	test   %dl,%dl
  8009ba:	74 18                	je     8009d4 <strfind+0x29>
		if (*s == c)
  8009bc:	38 ca                	cmp    %cl,%dl
  8009be:	75 0a                	jne    8009ca <strfind+0x1f>
  8009c0:	eb 12                	jmp    8009d4 <strfind+0x29>
  8009c2:	38 ca                	cmp    %cl,%dl
  8009c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009c8:	74 0a                	je     8009d4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	0f b6 10             	movzbl (%eax),%edx
  8009d0:	84 d2                	test   %dl,%dl
  8009d2:	75 ee                	jne    8009c2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	83 ec 0c             	sub    $0xc,%esp
  8009dc:	89 1c 24             	mov    %ebx,(%esp)
  8009df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009e3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8009e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f0:	85 c9                	test   %ecx,%ecx
  8009f2:	74 30                	je     800a24 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fa:	75 25                	jne    800a21 <memset+0x4b>
  8009fc:	f6 c1 03             	test   $0x3,%cl
  8009ff:	75 20                	jne    800a21 <memset+0x4b>
		c &= 0xFF;
  800a01:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a04:	89 d3                	mov    %edx,%ebx
  800a06:	c1 e3 08             	shl    $0x8,%ebx
  800a09:	89 d6                	mov    %edx,%esi
  800a0b:	c1 e6 18             	shl    $0x18,%esi
  800a0e:	89 d0                	mov    %edx,%eax
  800a10:	c1 e0 10             	shl    $0x10,%eax
  800a13:	09 f0                	or     %esi,%eax
  800a15:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a17:	09 d8                	or     %ebx,%eax
  800a19:	c1 e9 02             	shr    $0x2,%ecx
  800a1c:	fc                   	cld    
  800a1d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a1f:	eb 03                	jmp    800a24 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a21:	fc                   	cld    
  800a22:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a24:	89 f8                	mov    %edi,%eax
  800a26:	8b 1c 24             	mov    (%esp),%ebx
  800a29:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a2d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a31:	89 ec                	mov    %ebp,%esp
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	83 ec 08             	sub    $0x8,%esp
  800a3b:	89 34 24             	mov    %esi,(%esp)
  800a3e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a42:	8b 45 08             	mov    0x8(%ebp),%eax
  800a45:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800a48:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a4b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a4d:	39 c6                	cmp    %eax,%esi
  800a4f:	73 35                	jae    800a86 <memmove+0x51>
  800a51:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a54:	39 d0                	cmp    %edx,%eax
  800a56:	73 2e                	jae    800a86 <memmove+0x51>
		s += n;
		d += n;
  800a58:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5a:	f6 c2 03             	test   $0x3,%dl
  800a5d:	75 1b                	jne    800a7a <memmove+0x45>
  800a5f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a65:	75 13                	jne    800a7a <memmove+0x45>
  800a67:	f6 c1 03             	test   $0x3,%cl
  800a6a:	75 0e                	jne    800a7a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a6c:	83 ef 04             	sub    $0x4,%edi
  800a6f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a72:	c1 e9 02             	shr    $0x2,%ecx
  800a75:	fd                   	std    
  800a76:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a78:	eb 09                	jmp    800a83 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a7a:	83 ef 01             	sub    $0x1,%edi
  800a7d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a80:	fd                   	std    
  800a81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a83:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a84:	eb 20                	jmp    800aa6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a86:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a8c:	75 15                	jne    800aa3 <memmove+0x6e>
  800a8e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a94:	75 0d                	jne    800aa3 <memmove+0x6e>
  800a96:	f6 c1 03             	test   $0x3,%cl
  800a99:	75 08                	jne    800aa3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800a9b:	c1 e9 02             	shr    $0x2,%ecx
  800a9e:	fc                   	cld    
  800a9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa1:	eb 03                	jmp    800aa6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa3:	fc                   	cld    
  800aa4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa6:	8b 34 24             	mov    (%esp),%esi
  800aa9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800aad:	89 ec                	mov    %ebp,%esp
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab7:	8b 45 10             	mov    0x10(%ebp),%eax
  800aba:	89 44 24 08          	mov    %eax,0x8(%esp)
  800abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac8:	89 04 24             	mov    %eax,(%esp)
  800acb:	e8 65 ff ff ff       	call   800a35 <memmove>
}
  800ad0:	c9                   	leave  
  800ad1:	c3                   	ret    

00800ad2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	57                   	push   %edi
  800ad6:	56                   	push   %esi
  800ad7:	53                   	push   %ebx
  800ad8:	8b 75 08             	mov    0x8(%ebp),%esi
  800adb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ade:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae1:	85 c9                	test   %ecx,%ecx
  800ae3:	74 36                	je     800b1b <memcmp+0x49>
		if (*s1 != *s2)
  800ae5:	0f b6 06             	movzbl (%esi),%eax
  800ae8:	0f b6 1f             	movzbl (%edi),%ebx
  800aeb:	38 d8                	cmp    %bl,%al
  800aed:	74 20                	je     800b0f <memcmp+0x3d>
  800aef:	eb 14                	jmp    800b05 <memcmp+0x33>
  800af1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800af6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800afb:	83 c2 01             	add    $0x1,%edx
  800afe:	83 e9 01             	sub    $0x1,%ecx
  800b01:	38 d8                	cmp    %bl,%al
  800b03:	74 12                	je     800b17 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b05:	0f b6 c0             	movzbl %al,%eax
  800b08:	0f b6 db             	movzbl %bl,%ebx
  800b0b:	29 d8                	sub    %ebx,%eax
  800b0d:	eb 11                	jmp    800b20 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b0f:	83 e9 01             	sub    $0x1,%ecx
  800b12:	ba 00 00 00 00       	mov    $0x0,%edx
  800b17:	85 c9                	test   %ecx,%ecx
  800b19:	75 d6                	jne    800af1 <memcmp+0x1f>
  800b1b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b2b:	89 c2                	mov    %eax,%edx
  800b2d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b30:	39 d0                	cmp    %edx,%eax
  800b32:	73 15                	jae    800b49 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b34:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b38:	38 08                	cmp    %cl,(%eax)
  800b3a:	75 06                	jne    800b42 <memfind+0x1d>
  800b3c:	eb 0b                	jmp    800b49 <memfind+0x24>
  800b3e:	38 08                	cmp    %cl,(%eax)
  800b40:	74 07                	je     800b49 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b42:	83 c0 01             	add    $0x1,%eax
  800b45:	39 c2                	cmp    %eax,%edx
  800b47:	77 f5                	ja     800b3e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	57                   	push   %edi
  800b4f:	56                   	push   %esi
  800b50:	53                   	push   %ebx
  800b51:	83 ec 04             	sub    $0x4,%esp
  800b54:	8b 55 08             	mov    0x8(%ebp),%edx
  800b57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b5a:	0f b6 02             	movzbl (%edx),%eax
  800b5d:	3c 20                	cmp    $0x20,%al
  800b5f:	74 04                	je     800b65 <strtol+0x1a>
  800b61:	3c 09                	cmp    $0x9,%al
  800b63:	75 0e                	jne    800b73 <strtol+0x28>
		s++;
  800b65:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b68:	0f b6 02             	movzbl (%edx),%eax
  800b6b:	3c 20                	cmp    $0x20,%al
  800b6d:	74 f6                	je     800b65 <strtol+0x1a>
  800b6f:	3c 09                	cmp    $0x9,%al
  800b71:	74 f2                	je     800b65 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b73:	3c 2b                	cmp    $0x2b,%al
  800b75:	75 0c                	jne    800b83 <strtol+0x38>
		s++;
  800b77:	83 c2 01             	add    $0x1,%edx
  800b7a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b81:	eb 15                	jmp    800b98 <strtol+0x4d>
	else if (*s == '-')
  800b83:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b8a:	3c 2d                	cmp    $0x2d,%al
  800b8c:	75 0a                	jne    800b98 <strtol+0x4d>
		s++, neg = 1;
  800b8e:	83 c2 01             	add    $0x1,%edx
  800b91:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b98:	85 db                	test   %ebx,%ebx
  800b9a:	0f 94 c0             	sete   %al
  800b9d:	74 05                	je     800ba4 <strtol+0x59>
  800b9f:	83 fb 10             	cmp    $0x10,%ebx
  800ba2:	75 18                	jne    800bbc <strtol+0x71>
  800ba4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ba7:	75 13                	jne    800bbc <strtol+0x71>
  800ba9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bad:	8d 76 00             	lea    0x0(%esi),%esi
  800bb0:	75 0a                	jne    800bbc <strtol+0x71>
		s += 2, base = 16;
  800bb2:	83 c2 02             	add    $0x2,%edx
  800bb5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bba:	eb 15                	jmp    800bd1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bbc:	84 c0                	test   %al,%al
  800bbe:	66 90                	xchg   %ax,%ax
  800bc0:	74 0f                	je     800bd1 <strtol+0x86>
  800bc2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bc7:	80 3a 30             	cmpb   $0x30,(%edx)
  800bca:	75 05                	jne    800bd1 <strtol+0x86>
		s++, base = 8;
  800bcc:	83 c2 01             	add    $0x1,%edx
  800bcf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bd8:	0f b6 0a             	movzbl (%edx),%ecx
  800bdb:	89 cf                	mov    %ecx,%edi
  800bdd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800be0:	80 fb 09             	cmp    $0x9,%bl
  800be3:	77 08                	ja     800bed <strtol+0xa2>
			dig = *s - '0';
  800be5:	0f be c9             	movsbl %cl,%ecx
  800be8:	83 e9 30             	sub    $0x30,%ecx
  800beb:	eb 1e                	jmp    800c0b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800bed:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800bf0:	80 fb 19             	cmp    $0x19,%bl
  800bf3:	77 08                	ja     800bfd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800bf5:	0f be c9             	movsbl %cl,%ecx
  800bf8:	83 e9 57             	sub    $0x57,%ecx
  800bfb:	eb 0e                	jmp    800c0b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800bfd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c00:	80 fb 19             	cmp    $0x19,%bl
  800c03:	77 15                	ja     800c1a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c05:	0f be c9             	movsbl %cl,%ecx
  800c08:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c0b:	39 f1                	cmp    %esi,%ecx
  800c0d:	7d 0b                	jge    800c1a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c0f:	83 c2 01             	add    $0x1,%edx
  800c12:	0f af c6             	imul   %esi,%eax
  800c15:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c18:	eb be                	jmp    800bd8 <strtol+0x8d>
  800c1a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c1c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c20:	74 05                	je     800c27 <strtol+0xdc>
		*endptr = (char *) s;
  800c22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c25:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c27:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c2b:	74 04                	je     800c31 <strtol+0xe6>
  800c2d:	89 c8                	mov    %ecx,%eax
  800c2f:	f7 d8                	neg    %eax
}
  800c31:	83 c4 04             	add    $0x4,%esp
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    
  800c39:	00 00                	add    %al,(%eax)
	...

00800c3c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	83 ec 08             	sub    $0x8,%esp
  800c42:	89 1c 24             	mov    %ebx,(%esp)
  800c45:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c49:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c51:	8b 55 08             	mov    0x8(%ebp),%edx
  800c54:	89 c3                	mov    %eax,%ebx
  800c56:	89 c7                	mov    %eax,%edi
  800c58:	51                   	push   %ecx
  800c59:	52                   	push   %edx
  800c5a:	53                   	push   %ebx
  800c5b:	54                   	push   %esp
  800c5c:	55                   	push   %ebp
  800c5d:	56                   	push   %esi
  800c5e:	57                   	push   %edi
  800c5f:	8d 35 69 0c 80 00    	lea    0x800c69,%esi
  800c65:	54                   	push   %esp
  800c66:	5d                   	pop    %ebp
  800c67:	0f 34                	sysenter 
  800c69:	5f                   	pop    %edi
  800c6a:	5e                   	pop    %esi
  800c6b:	5d                   	pop    %ebp
  800c6c:	5c                   	pop    %esp
  800c6d:	5b                   	pop    %ebx
  800c6e:	5a                   	pop    %edx
  800c6f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c70:	8b 1c 24             	mov    (%esp),%ebx
  800c73:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c77:	89 ec                	mov    %ebp,%esp
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <sys_cgetc>:

int
sys_cgetc(void)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	83 ec 08             	sub    $0x8,%esp
  800c81:	89 1c 24             	mov    %ebx,(%esp)
  800c84:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c88:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c92:	89 d1                	mov    %edx,%ecx
  800c94:	89 d3                	mov    %edx,%ebx
  800c96:	89 d7                	mov    %edx,%edi
  800c98:	51                   	push   %ecx
  800c99:	52                   	push   %edx
  800c9a:	53                   	push   %ebx
  800c9b:	54                   	push   %esp
  800c9c:	55                   	push   %ebp
  800c9d:	56                   	push   %esi
  800c9e:	57                   	push   %edi
  800c9f:	8d 35 a9 0c 80 00    	lea    0x800ca9,%esi
  800ca5:	54                   	push   %esp
  800ca6:	5d                   	pop    %ebp
  800ca7:	0f 34                	sysenter 
  800ca9:	5f                   	pop    %edi
  800caa:	5e                   	pop    %esi
  800cab:	5d                   	pop    %ebp
  800cac:	5c                   	pop    %esp
  800cad:	5b                   	pop    %ebx
  800cae:	5a                   	pop    %edx
  800caf:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cb0:	8b 1c 24             	mov    (%esp),%ebx
  800cb3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800cb7:	89 ec                	mov    %ebp,%esp
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	83 ec 08             	sub    $0x8,%esp
  800cc1:	89 1c 24             	mov    %ebx,(%esp)
  800cc4:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800cc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccd:	b8 02 00 00 00       	mov    $0x2,%eax
  800cd2:	89 d1                	mov    %edx,%ecx
  800cd4:	89 d3                	mov    %edx,%ebx
  800cd6:	89 d7                	mov    %edx,%edi
  800cd8:	51                   	push   %ecx
  800cd9:	52                   	push   %edx
  800cda:	53                   	push   %ebx
  800cdb:	54                   	push   %esp
  800cdc:	55                   	push   %ebp
  800cdd:	56                   	push   %esi
  800cde:	57                   	push   %edi
  800cdf:	8d 35 e9 0c 80 00    	lea    0x800ce9,%esi
  800ce5:	54                   	push   %esp
  800ce6:	5d                   	pop    %ebp
  800ce7:	0f 34                	sysenter 
  800ce9:	5f                   	pop    %edi
  800cea:	5e                   	pop    %esi
  800ceb:	5d                   	pop    %ebp
  800cec:	5c                   	pop    %esp
  800ced:	5b                   	pop    %ebx
  800cee:	5a                   	pop    %edx
  800cef:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cf0:	8b 1c 24             	mov    (%esp),%ebx
  800cf3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800cf7:	89 ec                	mov    %ebp,%esp
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	83 ec 08             	sub    $0x8,%esp
  800d01:	89 1c 24             	mov    %ebx,(%esp)
  800d04:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0d:	b8 04 00 00 00       	mov    $0x4,%eax
  800d12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d15:	8b 55 08             	mov    0x8(%ebp),%edx
  800d18:	89 df                	mov    %ebx,%edi
  800d1a:	51                   	push   %ecx
  800d1b:	52                   	push   %edx
  800d1c:	53                   	push   %ebx
  800d1d:	54                   	push   %esp
  800d1e:	55                   	push   %ebp
  800d1f:	56                   	push   %esi
  800d20:	57                   	push   %edi
  800d21:	8d 35 2b 0d 80 00    	lea    0x800d2b,%esi
  800d27:	54                   	push   %esp
  800d28:	5d                   	pop    %ebp
  800d29:	0f 34                	sysenter 
  800d2b:	5f                   	pop    %edi
  800d2c:	5e                   	pop    %esi
  800d2d:	5d                   	pop    %ebp
  800d2e:	5c                   	pop    %esp
  800d2f:	5b                   	pop    %ebx
  800d30:	5a                   	pop    %edx
  800d31:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800d32:	8b 1c 24             	mov    (%esp),%ebx
  800d35:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d39:	89 ec                	mov    %ebp,%esp
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	83 ec 28             	sub    $0x28,%esp
  800d43:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800d46:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d49:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4e:	b8 03 00 00 00       	mov    $0x3,%eax
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
  800d56:	89 cb                	mov    %ecx,%ebx
  800d58:	89 cf                	mov    %ecx,%edi
  800d5a:	51                   	push   %ecx
  800d5b:	52                   	push   %edx
  800d5c:	53                   	push   %ebx
  800d5d:	54                   	push   %esp
  800d5e:	55                   	push   %ebp
  800d5f:	56                   	push   %esi
  800d60:	57                   	push   %edi
  800d61:	8d 35 6b 0d 80 00    	lea    0x800d6b,%esi
  800d67:	54                   	push   %esp
  800d68:	5d                   	pop    %ebp
  800d69:	0f 34                	sysenter 
  800d6b:	5f                   	pop    %edi
  800d6c:	5e                   	pop    %esi
  800d6d:	5d                   	pop    %ebp
  800d6e:	5c                   	pop    %esp
  800d6f:	5b                   	pop    %ebx
  800d70:	5a                   	pop    %edx
  800d71:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800d72:	85 c0                	test   %eax,%eax
  800d74:	7e 28                	jle    800d9e <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d76:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7a:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d81:	00 
  800d82:	c7 44 24 08 34 13 80 	movl   $0x801334,0x8(%esp)
  800d89:	00 
  800d8a:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  800d91:	00 
  800d92:	c7 04 24 51 13 80 00 	movl   $0x801351,(%esp)
  800d99:	e8 0a 00 00 00       	call   800da8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d9e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800da1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800da4:	89 ec                	mov    %ebp,%esp
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
  800dad:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800db0:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800db3:	a1 08 20 80 00       	mov    0x802008,%eax
  800db8:	85 c0                	test   %eax,%eax
  800dba:	74 10                	je     800dcc <_panic+0x24>
		cprintf("%s: ", argv0);
  800dbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dc0:	c7 04 24 5f 13 80 00 	movl   $0x80135f,(%esp)
  800dc7:	e8 59 f3 ff ff       	call   800125 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800dcc:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800dd2:	e8 e4 fe ff ff       	call   800cbb <sys_getenvid>
  800dd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dda:	89 54 24 10          	mov    %edx,0x10(%esp)
  800dde:	8b 55 08             	mov    0x8(%ebp),%edx
  800de1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800de5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800de9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ded:	c7 04 24 64 13 80 00 	movl   $0x801364,(%esp)
  800df4:	e8 2c f3 ff ff       	call   800125 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800df9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dfd:	8b 45 10             	mov    0x10(%ebp),%eax
  800e00:	89 04 24             	mov    %eax,(%esp)
  800e03:	e8 bc f2 ff ff       	call   8000c4 <vcprintf>
	cprintf("\n");
  800e08:	c7 04 24 94 10 80 00 	movl   $0x801094,(%esp)
  800e0f:	e8 11 f3 ff ff       	call   800125 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e14:	cc                   	int3   
  800e15:	eb fd                	jmp    800e14 <_panic+0x6c>
	...

00800e20 <__udivdi3>:
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	57                   	push   %edi
  800e24:	56                   	push   %esi
  800e25:	83 ec 10             	sub    $0x10,%esp
  800e28:	8b 45 14             	mov    0x14(%ebp),%eax
  800e2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2e:	8b 75 10             	mov    0x10(%ebp),%esi
  800e31:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e34:	85 c0                	test   %eax,%eax
  800e36:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800e39:	75 35                	jne    800e70 <__udivdi3+0x50>
  800e3b:	39 fe                	cmp    %edi,%esi
  800e3d:	77 61                	ja     800ea0 <__udivdi3+0x80>
  800e3f:	85 f6                	test   %esi,%esi
  800e41:	75 0b                	jne    800e4e <__udivdi3+0x2e>
  800e43:	b8 01 00 00 00       	mov    $0x1,%eax
  800e48:	31 d2                	xor    %edx,%edx
  800e4a:	f7 f6                	div    %esi
  800e4c:	89 c6                	mov    %eax,%esi
  800e4e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800e51:	31 d2                	xor    %edx,%edx
  800e53:	89 f8                	mov    %edi,%eax
  800e55:	f7 f6                	div    %esi
  800e57:	89 c7                	mov    %eax,%edi
  800e59:	89 c8                	mov    %ecx,%eax
  800e5b:	f7 f6                	div    %esi
  800e5d:	89 c1                	mov    %eax,%ecx
  800e5f:	89 fa                	mov    %edi,%edx
  800e61:	89 c8                	mov    %ecx,%eax
  800e63:	83 c4 10             	add    $0x10,%esp
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    
  800e6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e70:	39 f8                	cmp    %edi,%eax
  800e72:	77 1c                	ja     800e90 <__udivdi3+0x70>
  800e74:	0f bd d0             	bsr    %eax,%edx
  800e77:	83 f2 1f             	xor    $0x1f,%edx
  800e7a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800e7d:	75 39                	jne    800eb8 <__udivdi3+0x98>
  800e7f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  800e82:	0f 86 a0 00 00 00    	jbe    800f28 <__udivdi3+0x108>
  800e88:	39 f8                	cmp    %edi,%eax
  800e8a:	0f 82 98 00 00 00    	jb     800f28 <__udivdi3+0x108>
  800e90:	31 ff                	xor    %edi,%edi
  800e92:	31 c9                	xor    %ecx,%ecx
  800e94:	89 c8                	mov    %ecx,%eax
  800e96:	89 fa                	mov    %edi,%edx
  800e98:	83 c4 10             	add    $0x10,%esp
  800e9b:	5e                   	pop    %esi
  800e9c:	5f                   	pop    %edi
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    
  800e9f:	90                   	nop
  800ea0:	89 d1                	mov    %edx,%ecx
  800ea2:	89 fa                	mov    %edi,%edx
  800ea4:	89 c8                	mov    %ecx,%eax
  800ea6:	31 ff                	xor    %edi,%edi
  800ea8:	f7 f6                	div    %esi
  800eaa:	89 c1                	mov    %eax,%ecx
  800eac:	89 fa                	mov    %edi,%edx
  800eae:	89 c8                	mov    %ecx,%eax
  800eb0:	83 c4 10             	add    $0x10,%esp
  800eb3:	5e                   	pop    %esi
  800eb4:	5f                   	pop    %edi
  800eb5:	5d                   	pop    %ebp
  800eb6:	c3                   	ret    
  800eb7:	90                   	nop
  800eb8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800ebc:	89 f2                	mov    %esi,%edx
  800ebe:	d3 e0                	shl    %cl,%eax
  800ec0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ec3:	b8 20 00 00 00       	mov    $0x20,%eax
  800ec8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800ecb:	89 c1                	mov    %eax,%ecx
  800ecd:	d3 ea                	shr    %cl,%edx
  800ecf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800ed3:	0b 55 ec             	or     -0x14(%ebp),%edx
  800ed6:	d3 e6                	shl    %cl,%esi
  800ed8:	89 c1                	mov    %eax,%ecx
  800eda:	89 75 e8             	mov    %esi,-0x18(%ebp)
  800edd:	89 fe                	mov    %edi,%esi
  800edf:	d3 ee                	shr    %cl,%esi
  800ee1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800ee5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800ee8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800eeb:	d3 e7                	shl    %cl,%edi
  800eed:	89 c1                	mov    %eax,%ecx
  800eef:	d3 ea                	shr    %cl,%edx
  800ef1:	09 d7                	or     %edx,%edi
  800ef3:	89 f2                	mov    %esi,%edx
  800ef5:	89 f8                	mov    %edi,%eax
  800ef7:	f7 75 ec             	divl   -0x14(%ebp)
  800efa:	89 d6                	mov    %edx,%esi
  800efc:	89 c7                	mov    %eax,%edi
  800efe:	f7 65 e8             	mull   -0x18(%ebp)
  800f01:	39 d6                	cmp    %edx,%esi
  800f03:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800f06:	72 30                	jb     800f38 <__udivdi3+0x118>
  800f08:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f0b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800f0f:	d3 e2                	shl    %cl,%edx
  800f11:	39 c2                	cmp    %eax,%edx
  800f13:	73 05                	jae    800f1a <__udivdi3+0xfa>
  800f15:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  800f18:	74 1e                	je     800f38 <__udivdi3+0x118>
  800f1a:	89 f9                	mov    %edi,%ecx
  800f1c:	31 ff                	xor    %edi,%edi
  800f1e:	e9 71 ff ff ff       	jmp    800e94 <__udivdi3+0x74>
  800f23:	90                   	nop
  800f24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f28:	31 ff                	xor    %edi,%edi
  800f2a:	b9 01 00 00 00       	mov    $0x1,%ecx
  800f2f:	e9 60 ff ff ff       	jmp    800e94 <__udivdi3+0x74>
  800f34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f38:	8d 4f ff             	lea    -0x1(%edi),%ecx
  800f3b:	31 ff                	xor    %edi,%edi
  800f3d:	89 c8                	mov    %ecx,%eax
  800f3f:	89 fa                	mov    %edi,%edx
  800f41:	83 c4 10             	add    $0x10,%esp
  800f44:	5e                   	pop    %esi
  800f45:	5f                   	pop    %edi
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    
	...

00800f50 <__umoddi3>:
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	57                   	push   %edi
  800f54:	56                   	push   %esi
  800f55:	83 ec 20             	sub    $0x20,%esp
  800f58:	8b 55 14             	mov    0x14(%ebp),%edx
  800f5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f5e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800f61:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f64:	85 d2                	test   %edx,%edx
  800f66:	89 c8                	mov    %ecx,%eax
  800f68:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800f6b:	75 13                	jne    800f80 <__umoddi3+0x30>
  800f6d:	39 f7                	cmp    %esi,%edi
  800f6f:	76 3f                	jbe    800fb0 <__umoddi3+0x60>
  800f71:	89 f2                	mov    %esi,%edx
  800f73:	f7 f7                	div    %edi
  800f75:	89 d0                	mov    %edx,%eax
  800f77:	31 d2                	xor    %edx,%edx
  800f79:	83 c4 20             	add    $0x20,%esp
  800f7c:	5e                   	pop    %esi
  800f7d:	5f                   	pop    %edi
  800f7e:	5d                   	pop    %ebp
  800f7f:	c3                   	ret    
  800f80:	39 f2                	cmp    %esi,%edx
  800f82:	77 4c                	ja     800fd0 <__umoddi3+0x80>
  800f84:	0f bd ca             	bsr    %edx,%ecx
  800f87:	83 f1 1f             	xor    $0x1f,%ecx
  800f8a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f8d:	75 51                	jne    800fe0 <__umoddi3+0x90>
  800f8f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  800f92:	0f 87 e0 00 00 00    	ja     801078 <__umoddi3+0x128>
  800f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f9b:	29 f8                	sub    %edi,%eax
  800f9d:	19 d6                	sbb    %edx,%esi
  800f9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800fa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fa5:	89 f2                	mov    %esi,%edx
  800fa7:	83 c4 20             	add    $0x20,%esp
  800faa:	5e                   	pop    %esi
  800fab:	5f                   	pop    %edi
  800fac:	5d                   	pop    %ebp
  800fad:	c3                   	ret    
  800fae:	66 90                	xchg   %ax,%ax
  800fb0:	85 ff                	test   %edi,%edi
  800fb2:	75 0b                	jne    800fbf <__umoddi3+0x6f>
  800fb4:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb9:	31 d2                	xor    %edx,%edx
  800fbb:	f7 f7                	div    %edi
  800fbd:	89 c7                	mov    %eax,%edi
  800fbf:	89 f0                	mov    %esi,%eax
  800fc1:	31 d2                	xor    %edx,%edx
  800fc3:	f7 f7                	div    %edi
  800fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc8:	f7 f7                	div    %edi
  800fca:	eb a9                	jmp    800f75 <__umoddi3+0x25>
  800fcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fd0:	89 c8                	mov    %ecx,%eax
  800fd2:	89 f2                	mov    %esi,%edx
  800fd4:	83 c4 20             	add    $0x20,%esp
  800fd7:	5e                   	pop    %esi
  800fd8:	5f                   	pop    %edi
  800fd9:	5d                   	pop    %ebp
  800fda:	c3                   	ret    
  800fdb:	90                   	nop
  800fdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fe0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800fe4:	d3 e2                	shl    %cl,%edx
  800fe6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800fe9:	ba 20 00 00 00       	mov    $0x20,%edx
  800fee:	2b 55 f0             	sub    -0x10(%ebp),%edx
  800ff1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800ff4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800ff8:	89 fa                	mov    %edi,%edx
  800ffa:	d3 ea                	shr    %cl,%edx
  800ffc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801000:	0b 55 f4             	or     -0xc(%ebp),%edx
  801003:	d3 e7                	shl    %cl,%edi
  801005:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801009:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80100c:	89 f2                	mov    %esi,%edx
  80100e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801011:	89 c7                	mov    %eax,%edi
  801013:	d3 ea                	shr    %cl,%edx
  801015:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801019:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80101c:	89 c2                	mov    %eax,%edx
  80101e:	d3 e6                	shl    %cl,%esi
  801020:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801024:	d3 ea                	shr    %cl,%edx
  801026:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80102a:	09 d6                	or     %edx,%esi
  80102c:	89 f0                	mov    %esi,%eax
  80102e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801031:	d3 e7                	shl    %cl,%edi
  801033:	89 f2                	mov    %esi,%edx
  801035:	f7 75 f4             	divl   -0xc(%ebp)
  801038:	89 d6                	mov    %edx,%esi
  80103a:	f7 65 e8             	mull   -0x18(%ebp)
  80103d:	39 d6                	cmp    %edx,%esi
  80103f:	72 2b                	jb     80106c <__umoddi3+0x11c>
  801041:	39 c7                	cmp    %eax,%edi
  801043:	72 23                	jb     801068 <__umoddi3+0x118>
  801045:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801049:	29 c7                	sub    %eax,%edi
  80104b:	19 d6                	sbb    %edx,%esi
  80104d:	89 f0                	mov    %esi,%eax
  80104f:	89 f2                	mov    %esi,%edx
  801051:	d3 ef                	shr    %cl,%edi
  801053:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801057:	d3 e0                	shl    %cl,%eax
  801059:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80105d:	09 f8                	or     %edi,%eax
  80105f:	d3 ea                	shr    %cl,%edx
  801061:	83 c4 20             	add    $0x20,%esp
  801064:	5e                   	pop    %esi
  801065:	5f                   	pop    %edi
  801066:	5d                   	pop    %ebp
  801067:	c3                   	ret    
  801068:	39 d6                	cmp    %edx,%esi
  80106a:	75 d9                	jne    801045 <__umoddi3+0xf5>
  80106c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80106f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801072:	eb d1                	jmp    801045 <__umoddi3+0xf5>
  801074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801078:	39 f2                	cmp    %esi,%edx
  80107a:	0f 82 18 ff ff ff    	jb     800f98 <__umoddi3+0x48>
  801080:	e9 1d ff ff ff       	jmp    800fa2 <__umoddi3+0x52>
