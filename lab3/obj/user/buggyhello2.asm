
obj/user/buggyhello2:     file format elf32-i386


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

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800041:	00 
  800042:	a1 00 20 80 00       	mov    0x802000,%eax
  800047:	89 04 24             	mov    %eax,(%esp)
  80004a:	e8 69 00 00 00       	call   8000b8 <sys_cputs>
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
  800066:	e8 cc 00 00 00       	call   800137 <sys_getenvid>
  80006b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800070:	6b c0 64             	imul   $0x64,%eax,%eax
  800073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800078:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 f6                	test   %esi,%esi
  80007f:	7e 07                	jle    800088 <libmain+0x34>
		binaryname = argv[0];
  800081:	8b 03                	mov    (%ebx),%eax
  800083:	a3 04 20 80 00       	mov    %eax,0x802004

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
  8000b1:	e8 03 01 00 00       	call   8001b9 <sys_env_destroy>
}
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	89 1c 24             	mov    %ebx,(%esp)
  8000c1:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d0:	89 c3                	mov    %eax,%ebx
  8000d2:	89 c7                	mov    %eax,%edi
  8000d4:	51                   	push   %ecx
  8000d5:	52                   	push   %edx
  8000d6:	53                   	push   %ebx
  8000d7:	54                   	push   %esp
  8000d8:	55                   	push   %ebp
  8000d9:	56                   	push   %esi
  8000da:	57                   	push   %edi
  8000db:	8d 35 e5 00 80 00    	lea    0x8000e5,%esi
  8000e1:	54                   	push   %esp
  8000e2:	5d                   	pop    %ebp
  8000e3:	0f 34                	sysenter 
  8000e5:	5f                   	pop    %edi
  8000e6:	5e                   	pop    %esi
  8000e7:	5d                   	pop    %ebp
  8000e8:	5c                   	pop    %esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5a                   	pop    %edx
  8000eb:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ec:	8b 1c 24             	mov    (%esp),%ebx
  8000ef:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8000f3:	89 ec                	mov    %ebp,%esp
  8000f5:	5d                   	pop    %ebp
  8000f6:	c3                   	ret    

008000f7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	83 ec 08             	sub    $0x8,%esp
  8000fd:	89 1c 24             	mov    %ebx,(%esp)
  800100:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800104:	ba 00 00 00 00       	mov    $0x0,%edx
  800109:	b8 01 00 00 00       	mov    $0x1,%eax
  80010e:	89 d1                	mov    %edx,%ecx
  800110:	89 d3                	mov    %edx,%ebx
  800112:	89 d7                	mov    %edx,%edi
  800114:	51                   	push   %ecx
  800115:	52                   	push   %edx
  800116:	53                   	push   %ebx
  800117:	54                   	push   %esp
  800118:	55                   	push   %ebp
  800119:	56                   	push   %esi
  80011a:	57                   	push   %edi
  80011b:	8d 35 25 01 80 00    	lea    0x800125,%esi
  800121:	54                   	push   %esp
  800122:	5d                   	pop    %ebp
  800123:	0f 34                	sysenter 
  800125:	5f                   	pop    %edi
  800126:	5e                   	pop    %esi
  800127:	5d                   	pop    %ebp
  800128:	5c                   	pop    %esp
  800129:	5b                   	pop    %ebx
  80012a:	5a                   	pop    %edx
  80012b:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80012c:	8b 1c 24             	mov    (%esp),%ebx
  80012f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800133:	89 ec                	mov    %ebp,%esp
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	83 ec 08             	sub    $0x8,%esp
  80013d:	89 1c 24             	mov    %ebx,(%esp)
  800140:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800144:	ba 00 00 00 00       	mov    $0x0,%edx
  800149:	b8 02 00 00 00       	mov    $0x2,%eax
  80014e:	89 d1                	mov    %edx,%ecx
  800150:	89 d3                	mov    %edx,%ebx
  800152:	89 d7                	mov    %edx,%edi
  800154:	51                   	push   %ecx
  800155:	52                   	push   %edx
  800156:	53                   	push   %ebx
  800157:	54                   	push   %esp
  800158:	55                   	push   %ebp
  800159:	56                   	push   %esi
  80015a:	57                   	push   %edi
  80015b:	8d 35 65 01 80 00    	lea    0x800165,%esi
  800161:	54                   	push   %esp
  800162:	5d                   	pop    %ebp
  800163:	0f 34                	sysenter 
  800165:	5f                   	pop    %edi
  800166:	5e                   	pop    %esi
  800167:	5d                   	pop    %ebp
  800168:	5c                   	pop    %esp
  800169:	5b                   	pop    %ebx
  80016a:	5a                   	pop    %edx
  80016b:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016c:	8b 1c 24             	mov    (%esp),%ebx
  80016f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800173:	89 ec                	mov    %ebp,%esp
  800175:	5d                   	pop    %ebp
  800176:	c3                   	ret    

00800177 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	83 ec 08             	sub    $0x8,%esp
  80017d:	89 1c 24             	mov    %ebx,(%esp)
  800180:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800184:	bb 00 00 00 00       	mov    $0x0,%ebx
  800189:	b8 04 00 00 00       	mov    $0x4,%eax
  80018e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800191:	8b 55 08             	mov    0x8(%ebp),%edx
  800194:	89 df                	mov    %ebx,%edi
  800196:	51                   	push   %ecx
  800197:	52                   	push   %edx
  800198:	53                   	push   %ebx
  800199:	54                   	push   %esp
  80019a:	55                   	push   %ebp
  80019b:	56                   	push   %esi
  80019c:	57                   	push   %edi
  80019d:	8d 35 a7 01 80 00    	lea    0x8001a7,%esi
  8001a3:	54                   	push   %esp
  8001a4:	5d                   	pop    %ebp
  8001a5:	0f 34                	sysenter 
  8001a7:	5f                   	pop    %edi
  8001a8:	5e                   	pop    %esi
  8001a9:	5d                   	pop    %ebp
  8001aa:	5c                   	pop    %esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5a                   	pop    %edx
  8001ad:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8001ae:	8b 1c 24             	mov    (%esp),%ebx
  8001b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8001b5:	89 ec                	mov    %ebp,%esp
  8001b7:	5d                   	pop    %ebp
  8001b8:	c3                   	ret    

008001b9 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	83 ec 28             	sub    $0x28,%esp
  8001bf:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8001c2:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ca:	b8 03 00 00 00       	mov    $0x3,%eax
  8001cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d2:	89 cb                	mov    %ecx,%ebx
  8001d4:	89 cf                	mov    %ecx,%edi
  8001d6:	51                   	push   %ecx
  8001d7:	52                   	push   %edx
  8001d8:	53                   	push   %ebx
  8001d9:	54                   	push   %esp
  8001da:	55                   	push   %ebp
  8001db:	56                   	push   %esi
  8001dc:	57                   	push   %edi
  8001dd:	8d 35 e7 01 80 00    	lea    0x8001e7,%esi
  8001e3:	54                   	push   %esp
  8001e4:	5d                   	pop    %ebp
  8001e5:	0f 34                	sysenter 
  8001e7:	5f                   	pop    %edi
  8001e8:	5e                   	pop    %esi
  8001e9:	5d                   	pop    %ebp
  8001ea:	5c                   	pop    %esp
  8001eb:	5b                   	pop    %ebx
  8001ec:	5a                   	pop    %edx
  8001ed:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8001ee:	85 c0                	test   %eax,%eax
  8001f0:	7e 28                	jle    80021a <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f6:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8001fd:	00 
  8001fe:	c7 44 24 08 90 10 80 	movl   $0x801090,0x8(%esp)
  800205:	00 
  800206:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  80020d:	00 
  80020e:	c7 04 24 ad 10 80 00 	movl   $0x8010ad,(%esp)
  800215:	e8 0a 00 00 00       	call   800224 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80021a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80021d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800220:	89 ec                	mov    %ebp,%esp
  800222:	5d                   	pop    %ebp
  800223:	c3                   	ret    

00800224 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	56                   	push   %esi
  800228:	53                   	push   %ebx
  800229:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80022c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80022f:	a1 0c 20 80 00       	mov    0x80200c,%eax
  800234:	85 c0                	test   %eax,%eax
  800236:	74 10                	je     800248 <_panic+0x24>
		cprintf("%s: ", argv0);
  800238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023c:	c7 04 24 bb 10 80 00 	movl   $0x8010bb,(%esp)
  800243:	e8 ad 00 00 00       	call   8002f5 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800248:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  80024e:	e8 e4 fe ff ff       	call   800137 <sys_getenvid>
  800253:	8b 55 0c             	mov    0xc(%ebp),%edx
  800256:	89 54 24 10          	mov    %edx,0x10(%esp)
  80025a:	8b 55 08             	mov    0x8(%ebp),%edx
  80025d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800261:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800265:	89 44 24 04          	mov    %eax,0x4(%esp)
  800269:	c7 04 24 c0 10 80 00 	movl   $0x8010c0,(%esp)
  800270:	e8 80 00 00 00       	call   8002f5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800275:	89 74 24 04          	mov    %esi,0x4(%esp)
  800279:	8b 45 10             	mov    0x10(%ebp),%eax
  80027c:	89 04 24             	mov    %eax,(%esp)
  80027f:	e8 10 00 00 00       	call   800294 <vcprintf>
	cprintf("\n");
  800284:	c7 04 24 84 10 80 00 	movl   $0x801084,(%esp)
  80028b:	e8 65 00 00 00       	call   8002f5 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800290:	cc                   	int3   
  800291:	eb fd                	jmp    800290 <_panic+0x6c>
	...

00800294 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80029d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002a4:	00 00 00 
	b.cnt = 0;
  8002a7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ae:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002bf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c9:	c7 04 24 0f 03 80 00 	movl   $0x80030f,(%esp)
  8002d0:	e8 d8 01 00 00       	call   8004ad <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d5:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002df:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e5:	89 04 24             	mov    %eax,(%esp)
  8002e8:	e8 cb fd ff ff       	call   8000b8 <sys_cputs>

	return b.cnt;
}
  8002ed:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002f3:	c9                   	leave  
  8002f4:	c3                   	ret    

008002f5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8002fb:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8002fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800302:	8b 45 08             	mov    0x8(%ebp),%eax
  800305:	89 04 24             	mov    %eax,(%esp)
  800308:	e8 87 ff ff ff       	call   800294 <vcprintf>
	va_end(ap);

	return cnt;
}
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	53                   	push   %ebx
  800313:	83 ec 14             	sub    $0x14,%esp
  800316:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800319:	8b 03                	mov    (%ebx),%eax
  80031b:	8b 55 08             	mov    0x8(%ebp),%edx
  80031e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800322:	83 c0 01             	add    $0x1,%eax
  800325:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800327:	3d ff 00 00 00       	cmp    $0xff,%eax
  80032c:	75 19                	jne    800347 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80032e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800335:	00 
  800336:	8d 43 08             	lea    0x8(%ebx),%eax
  800339:	89 04 24             	mov    %eax,(%esp)
  80033c:	e8 77 fd ff ff       	call   8000b8 <sys_cputs>
		b->idx = 0;
  800341:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800347:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80034b:	83 c4 14             	add    $0x14,%esp
  80034e:	5b                   	pop    %ebx
  80034f:	5d                   	pop    %ebp
  800350:	c3                   	ret    
	...

00800360 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	57                   	push   %edi
  800364:	56                   	push   %esi
  800365:	53                   	push   %ebx
  800366:	83 ec 4c             	sub    $0x4c,%esp
  800369:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036c:	89 d6                	mov    %edx,%esi
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800374:	8b 55 0c             	mov    0xc(%ebp),%edx
  800377:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80037a:	8b 45 10             	mov    0x10(%ebp),%eax
  80037d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800380:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800383:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800386:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038b:	39 d1                	cmp    %edx,%ecx
  80038d:	72 15                	jb     8003a4 <printnum+0x44>
  80038f:	77 07                	ja     800398 <printnum+0x38>
  800391:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800394:	39 d0                	cmp    %edx,%eax
  800396:	76 0c                	jbe    8003a4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800398:	83 eb 01             	sub    $0x1,%ebx
  80039b:	85 db                	test   %ebx,%ebx
  80039d:	8d 76 00             	lea    0x0(%esi),%esi
  8003a0:	7f 61                	jg     800403 <printnum+0xa3>
  8003a2:	eb 70                	jmp    800414 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003a4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8003a8:	83 eb 01             	sub    $0x1,%ebx
  8003ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8003b7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8003bb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8003be:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8003c1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8003c4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003cf:	00 
  8003d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003d3:	89 04 24             	mov    %eax,(%esp)
  8003d6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003dd:	e8 2e 0a 00 00       	call   800e10 <__udivdi3>
  8003e2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003e5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8003e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003ec:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003f0:	89 04 24             	mov    %eax,(%esp)
  8003f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003f7:	89 f2                	mov    %esi,%edx
  8003f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003fc:	e8 5f ff ff ff       	call   800360 <printnum>
  800401:	eb 11                	jmp    800414 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800403:	89 74 24 04          	mov    %esi,0x4(%esp)
  800407:	89 3c 24             	mov    %edi,(%esp)
  80040a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80040d:	83 eb 01             	sub    $0x1,%ebx
  800410:	85 db                	test   %ebx,%ebx
  800412:	7f ef                	jg     800403 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800414:	89 74 24 04          	mov    %esi,0x4(%esp)
  800418:	8b 74 24 04          	mov    0x4(%esp),%esi
  80041c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80041f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800423:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80042a:	00 
  80042b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80042e:	89 14 24             	mov    %edx,(%esp)
  800431:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800434:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800438:	e8 03 0b 00 00       	call   800f40 <__umoddi3>
  80043d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800441:	0f be 80 e3 10 80 00 	movsbl 0x8010e3(%eax),%eax
  800448:	89 04 24             	mov    %eax,(%esp)
  80044b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80044e:	83 c4 4c             	add    $0x4c,%esp
  800451:	5b                   	pop    %ebx
  800452:	5e                   	pop    %esi
  800453:	5f                   	pop    %edi
  800454:	5d                   	pop    %ebp
  800455:	c3                   	ret    

00800456 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800456:	55                   	push   %ebp
  800457:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800459:	83 fa 01             	cmp    $0x1,%edx
  80045c:	7e 0e                	jle    80046c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80045e:	8b 10                	mov    (%eax),%edx
  800460:	8d 4a 08             	lea    0x8(%edx),%ecx
  800463:	89 08                	mov    %ecx,(%eax)
  800465:	8b 02                	mov    (%edx),%eax
  800467:	8b 52 04             	mov    0x4(%edx),%edx
  80046a:	eb 22                	jmp    80048e <getuint+0x38>
	else if (lflag)
  80046c:	85 d2                	test   %edx,%edx
  80046e:	74 10                	je     800480 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800470:	8b 10                	mov    (%eax),%edx
  800472:	8d 4a 04             	lea    0x4(%edx),%ecx
  800475:	89 08                	mov    %ecx,(%eax)
  800477:	8b 02                	mov    (%edx),%eax
  800479:	ba 00 00 00 00       	mov    $0x0,%edx
  80047e:	eb 0e                	jmp    80048e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800480:	8b 10                	mov    (%eax),%edx
  800482:	8d 4a 04             	lea    0x4(%edx),%ecx
  800485:	89 08                	mov    %ecx,(%eax)
  800487:	8b 02                	mov    (%edx),%eax
  800489:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80048e:	5d                   	pop    %ebp
  80048f:	c3                   	ret    

00800490 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800496:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80049a:	8b 10                	mov    (%eax),%edx
  80049c:	3b 50 04             	cmp    0x4(%eax),%edx
  80049f:	73 0a                	jae    8004ab <sprintputch+0x1b>
		*b->buf++ = ch;
  8004a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004a4:	88 0a                	mov    %cl,(%edx)
  8004a6:	83 c2 01             	add    $0x1,%edx
  8004a9:	89 10                	mov    %edx,(%eax)
}
  8004ab:	5d                   	pop    %ebp
  8004ac:	c3                   	ret    

008004ad <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004ad:	55                   	push   %ebp
  8004ae:	89 e5                	mov    %esp,%ebp
  8004b0:	57                   	push   %edi
  8004b1:	56                   	push   %esi
  8004b2:	53                   	push   %ebx
  8004b3:	83 ec 5c             	sub    $0x5c,%esp
  8004b6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004b9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004bf:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8004c6:	eb 16                	jmp    8004de <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	0f 84 4f 04 00 00    	je     80091f <vprintfmt+0x472>
				return;
			putch(ch, putdat);
  8004d0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d4:	89 04 24             	mov    %eax,(%esp)
  8004d7:	ff d7                	call   *%edi
  8004d9:	eb 03                	jmp    8004de <vprintfmt+0x31>
  8004db:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004de:	0f b6 03             	movzbl (%ebx),%eax
  8004e1:	83 c3 01             	add    $0x1,%ebx
  8004e4:	83 f8 25             	cmp    $0x25,%eax
  8004e7:	75 df                	jne    8004c8 <vprintfmt+0x1b>
  8004e9:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  8004ed:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004f4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004fb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800502:	b9 00 00 00 00       	mov    $0x0,%ecx
  800507:	eb 06                	jmp    80050f <vprintfmt+0x62>
  800509:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  80050d:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	0f b6 13             	movzbl (%ebx),%edx
  800512:	0f b6 c2             	movzbl %dl,%eax
  800515:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800518:	8d 43 01             	lea    0x1(%ebx),%eax
  80051b:	83 ea 23             	sub    $0x23,%edx
  80051e:	80 fa 55             	cmp    $0x55,%dl
  800521:	0f 87 db 03 00 00    	ja     800902 <vprintfmt+0x455>
  800527:	0f b6 d2             	movzbl %dl,%edx
  80052a:	ff 24 95 ec 11 80 00 	jmp    *0x8011ec(,%edx,4)
  800531:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800535:	eb d6                	jmp    80050d <vprintfmt+0x60>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800537:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80053a:	83 ea 30             	sub    $0x30,%edx
  80053d:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  800540:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800543:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800546:	83 fb 09             	cmp    $0x9,%ebx
  800549:	77 4c                	ja     800597 <vprintfmt+0xea>
  80054b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80054e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800551:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800554:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800557:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  80055b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80055e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800561:	83 fb 09             	cmp    $0x9,%ebx
  800564:	76 eb                	jbe    800551 <vprintfmt+0xa4>
  800566:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800569:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80056c:	eb 29                	jmp    800597 <vprintfmt+0xea>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80056e:	8b 55 14             	mov    0x14(%ebp),%edx
  800571:	8d 5a 04             	lea    0x4(%edx),%ebx
  800574:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800577:	8b 12                	mov    (%edx),%edx
  800579:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  80057c:	eb 19                	jmp    800597 <vprintfmt+0xea>

		case '.':
			if (width < 0)
  80057e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800581:	c1 fa 1f             	sar    $0x1f,%edx
  800584:	f7 d2                	not    %edx
  800586:	21 55 d4             	and    %edx,-0x2c(%ebp)
  800589:	eb 82                	jmp    80050d <vprintfmt+0x60>
  80058b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800592:	e9 76 ff ff ff       	jmp    80050d <vprintfmt+0x60>

		process_precision:
			if (width < 0)
  800597:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80059b:	0f 89 6c ff ff ff    	jns    80050d <vprintfmt+0x60>
  8005a1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005a4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005a7:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8005aa:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005ad:	e9 5b ff ff ff       	jmp    80050d <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005b2:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8005b5:	e9 53 ff ff ff       	jmp    80050d <vprintfmt+0x60>
  8005ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8d 50 04             	lea    0x4(%eax),%edx
  8005c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ca:	8b 00                	mov    (%eax),%eax
  8005cc:	89 04 24             	mov    %eax,(%esp)
  8005cf:	ff d7                	call   *%edi
  8005d1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
  8005d4:	e9 05 ff ff ff       	jmp    8004de <vprintfmt+0x31>
  8005d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 50 04             	lea    0x4(%eax),%edx
  8005e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e5:	8b 00                	mov    (%eax),%eax
  8005e7:	89 c2                	mov    %eax,%edx
  8005e9:	c1 fa 1f             	sar    $0x1f,%edx
  8005ec:	31 d0                	xor    %edx,%eax
  8005ee:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005f0:	83 f8 06             	cmp    $0x6,%eax
  8005f3:	7f 0b                	jg     800600 <vprintfmt+0x153>
  8005f5:	8b 14 85 44 13 80 00 	mov    0x801344(,%eax,4),%edx
  8005fc:	85 d2                	test   %edx,%edx
  8005fe:	75 20                	jne    800620 <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  800600:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800604:	c7 44 24 08 f4 10 80 	movl   $0x8010f4,0x8(%esp)
  80060b:	00 
  80060c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800610:	89 3c 24             	mov    %edi,(%esp)
  800613:	e8 8f 03 00 00       	call   8009a7 <printfmt>
  800618:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80061b:	e9 be fe ff ff       	jmp    8004de <vprintfmt+0x31>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800620:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800624:	c7 44 24 08 fd 10 80 	movl   $0x8010fd,0x8(%esp)
  80062b:	00 
  80062c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800630:	89 3c 24             	mov    %edi,(%esp)
  800633:	e8 6f 03 00 00       	call   8009a7 <printfmt>
  800638:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80063b:	e9 9e fe ff ff       	jmp    8004de <vprintfmt+0x31>
  800640:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800643:	89 c3                	mov    %eax,%ebx
  800645:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800648:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80064b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8d 50 04             	lea    0x4(%eax),%edx
  800654:	89 55 14             	mov    %edx,0x14(%ebp)
  800657:	8b 00                	mov    (%eax),%eax
  800659:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80065c:	85 c0                	test   %eax,%eax
  80065e:	75 07                	jne    800667 <vprintfmt+0x1ba>
  800660:	c7 45 cc 00 11 80 00 	movl   $0x801100,-0x34(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800667:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80066b:	7e 06                	jle    800673 <vprintfmt+0x1c6>
  80066d:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800671:	75 13                	jne    800686 <vprintfmt+0x1d9>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800673:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800676:	0f be 02             	movsbl (%edx),%eax
  800679:	85 c0                	test   %eax,%eax
  80067b:	0f 85 9f 00 00 00    	jne    800720 <vprintfmt+0x273>
  800681:	e9 8f 00 00 00       	jmp    800715 <vprintfmt+0x268>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800686:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80068a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80068d:	89 0c 24             	mov    %ecx,(%esp)
  800690:	e8 56 03 00 00       	call   8009eb <strnlen>
  800695:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800698:	29 c2                	sub    %eax,%edx
  80069a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80069d:	85 d2                	test   %edx,%edx
  80069f:	7e d2                	jle    800673 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8006a1:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8006a5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006a8:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8006ab:	89 d3                	mov    %edx,%ebx
  8006ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006b4:	89 04 24             	mov    %eax,(%esp)
  8006b7:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b9:	83 eb 01             	sub    $0x1,%ebx
  8006bc:	85 db                	test   %ebx,%ebx
  8006be:	7f ed                	jg     8006ad <vprintfmt+0x200>
  8006c0:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8006c3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8006ca:	eb a7                	jmp    800673 <vprintfmt+0x1c6>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006cc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006d0:	74 1b                	je     8006ed <vprintfmt+0x240>
  8006d2:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006d5:	83 fa 5e             	cmp    $0x5e,%edx
  8006d8:	76 13                	jbe    8006ed <vprintfmt+0x240>
					putch('?', putdat);
  8006da:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8006dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006e1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006e8:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006eb:	eb 0d                	jmp    8006fa <vprintfmt+0x24d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8006ed:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006f0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006f4:	89 04 24             	mov    %eax,(%esp)
  8006f7:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fa:	83 ef 01             	sub    $0x1,%edi
  8006fd:	0f be 03             	movsbl (%ebx),%eax
  800700:	85 c0                	test   %eax,%eax
  800702:	74 05                	je     800709 <vprintfmt+0x25c>
  800704:	83 c3 01             	add    $0x1,%ebx
  800707:	eb 2e                	jmp    800737 <vprintfmt+0x28a>
  800709:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80070c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80070f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800712:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800715:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800719:	7f 33                	jg     80074e <vprintfmt+0x2a1>
  80071b:	e9 bb fd ff ff       	jmp    8004db <vprintfmt+0x2e>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800720:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800723:	83 c2 01             	add    $0x1,%edx
  800726:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800729:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80072c:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80072f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800732:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800735:	89 d3                	mov    %edx,%ebx
  800737:	85 f6                	test   %esi,%esi
  800739:	78 91                	js     8006cc <vprintfmt+0x21f>
  80073b:	83 ee 01             	sub    $0x1,%esi
  80073e:	79 8c                	jns    8006cc <vprintfmt+0x21f>
  800740:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800743:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800746:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800749:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80074c:	eb c7                	jmp    800715 <vprintfmt+0x268>
  80074e:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800751:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800754:	89 74 24 04          	mov    %esi,0x4(%esp)
  800758:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80075f:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800761:	83 eb 01             	sub    $0x1,%ebx
  800764:	85 db                	test   %ebx,%ebx
  800766:	7f ec                	jg     800754 <vprintfmt+0x2a7>
  800768:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80076b:	e9 6e fd ff ff       	jmp    8004de <vprintfmt+0x31>
  800770:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800773:	83 f9 01             	cmp    $0x1,%ecx
  800776:	7e 16                	jle    80078e <vprintfmt+0x2e1>
		return va_arg(*ap, long long);
  800778:	8b 45 14             	mov    0x14(%ebp),%eax
  80077b:	8d 50 08             	lea    0x8(%eax),%edx
  80077e:	89 55 14             	mov    %edx,0x14(%ebp)
  800781:	8b 10                	mov    (%eax),%edx
  800783:	8b 48 04             	mov    0x4(%eax),%ecx
  800786:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800789:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80078c:	eb 32                	jmp    8007c0 <vprintfmt+0x313>
	else if (lflag)
  80078e:	85 c9                	test   %ecx,%ecx
  800790:	74 18                	je     8007aa <vprintfmt+0x2fd>
		return va_arg(*ap, long);
  800792:	8b 45 14             	mov    0x14(%ebp),%eax
  800795:	8d 50 04             	lea    0x4(%eax),%edx
  800798:	89 55 14             	mov    %edx,0x14(%ebp)
  80079b:	8b 00                	mov    (%eax),%eax
  80079d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a0:	89 c1                	mov    %eax,%ecx
  8007a2:	c1 f9 1f             	sar    $0x1f,%ecx
  8007a5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007a8:	eb 16                	jmp    8007c0 <vprintfmt+0x313>
	else
		return va_arg(*ap, int);
  8007aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ad:	8d 50 04             	lea    0x4(%eax),%edx
  8007b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b3:	8b 00                	mov    (%eax),%eax
  8007b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b8:	89 c2                	mov    %eax,%edx
  8007ba:	c1 fa 1f             	sar    $0x1f,%edx
  8007bd:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007c3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007c6:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  8007cb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007cf:	0f 89 8a 00 00 00    	jns    80085f <vprintfmt+0x3b2>
				putch('-', putdat);
  8007d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007e0:	ff d7                	call   *%edi
				num = -(long long) num;
  8007e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007e5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007e8:	f7 d8                	neg    %eax
  8007ea:	83 d2 00             	adc    $0x0,%edx
  8007ed:	f7 da                	neg    %edx
  8007ef:	eb 6e                	jmp    80085f <vprintfmt+0x3b2>
  8007f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007f4:	89 ca                	mov    %ecx,%edx
  8007f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f9:	e8 58 fc ff ff       	call   800456 <getuint>
  8007fe:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  800803:	eb 5a                	jmp    80085f <vprintfmt+0x3b2>
  800805:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			//break;
			num = getuint(&ap, lflag);
  800808:	89 ca                	mov    %ecx,%edx
  80080a:	8d 45 14             	lea    0x14(%ebp),%eax
  80080d:	e8 44 fc ff ff       	call   800456 <getuint>
  800812:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800817:	eb 46                	jmp    80085f <vprintfmt+0x3b2>
  800819:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  80081c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800820:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800827:	ff d7                	call   *%edi
			putch('x', putdat);
  800829:	89 74 24 04          	mov    %esi,0x4(%esp)
  80082d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800834:	ff d7                	call   *%edi
			num = (unsigned long long)
  800836:	8b 45 14             	mov    0x14(%ebp),%eax
  800839:	8d 50 04             	lea    0x4(%eax),%edx
  80083c:	89 55 14             	mov    %edx,0x14(%ebp)
  80083f:	8b 00                	mov    (%eax),%eax
  800841:	ba 00 00 00 00       	mov    $0x0,%edx
  800846:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80084b:	eb 12                	jmp    80085f <vprintfmt+0x3b2>
  80084d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800850:	89 ca                	mov    %ecx,%edx
  800852:	8d 45 14             	lea    0x14(%ebp),%eax
  800855:	e8 fc fb ff ff       	call   800456 <getuint>
  80085a:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80085f:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800863:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800867:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80086a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80086e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800872:	89 04 24             	mov    %eax,(%esp)
  800875:	89 54 24 04          	mov    %edx,0x4(%esp)
  800879:	89 f2                	mov    %esi,%edx
  80087b:	89 f8                	mov    %edi,%eax
  80087d:	e8 de fa ff ff       	call   800360 <printnum>
  800882:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
  800885:	e9 54 fc ff ff       	jmp    8004de <vprintfmt+0x31>
  80088a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			char* tmp = va_arg(ap, char*);
  80088d:	8b 45 14             	mov    0x14(%ebp),%eax
  800890:	8d 50 04             	lea    0x4(%eax),%edx
  800893:	89 55 14             	mov    %edx,0x14(%ebp)
  800896:	8b 00                	mov    (%eax),%eax
			if(tmp == NULL) {
  800898:	85 c0                	test   %eax,%eax
  80089a:	75 1f                	jne    8008bb <vprintfmt+0x40e>
  80089c:	bb 71 11 80 00       	mov    $0x801171,%ebx
  8008a1:	b0 0a                	mov    $0xa,%al
				for(; (ch = *null_error++) != '\0';) {	
					putch(ch, putdat);
  8008a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008a7:	89 04 24             	mov    %eax,(%esp)
  8008aa:	ff d7                	call   *%edi
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			char* tmp = va_arg(ap, char*);
			if(tmp == NULL) {
				for(; (ch = *null_error++) != '\0';) {	
  8008ac:	0f be 03             	movsbl (%ebx),%eax
  8008af:	83 c3 01             	add    $0x1,%ebx
  8008b2:	85 c0                	test   %eax,%eax
  8008b4:	75 ed                	jne    8008a3 <vprintfmt+0x3f6>
  8008b6:	e9 20 fc ff ff       	jmp    8004db <vprintfmt+0x2e>
					putch(ch, putdat);
				}
				break;
			}
			*tmp = *((signed char*) putdat);
  8008bb:	0f b6 16             	movzbl (%esi),%edx
  8008be:	88 10                	mov    %dl,(%eax)
			if(*(signed char*) putdat < 0) {
  8008c0:	80 3e 00             	cmpb   $0x0,(%esi)
  8008c3:	0f 89 12 fc ff ff    	jns    8004db <vprintfmt+0x2e>
  8008c9:	bb a9 11 80 00       	mov    $0x8011a9,%ebx
  8008ce:	b8 0a 00 00 00       	mov    $0xa,%eax
				for(; (ch = *overflow_error++) != '\0';) {	
					putch(ch, putdat);
  8008d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008d7:	89 04 24             	mov    %eax,(%esp)
  8008da:	ff d7                	call   *%edi
				}
				break;
			}
			*tmp = *((signed char*) putdat);
			if(*(signed char*) putdat < 0) {
				for(; (ch = *overflow_error++) != '\0';) {	
  8008dc:	0f be 03             	movsbl (%ebx),%eax
  8008df:	83 c3 01             	add    $0x1,%ebx
  8008e2:	85 c0                	test   %eax,%eax
  8008e4:	75 ed                	jne    8008d3 <vprintfmt+0x426>
  8008e6:	e9 f0 fb ff ff       	jmp    8004db <vprintfmt+0x2e>
  8008eb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008f5:	89 14 24             	mov    %edx,(%esp)
  8008f8:	ff d7                	call   *%edi
  8008fa:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
  8008fd:	e9 dc fb ff ff       	jmp    8004de <vprintfmt+0x31>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800902:	89 74 24 04          	mov    %esi,0x4(%esp)
  800906:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80090d:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80090f:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800912:	80 38 25             	cmpb   $0x25,(%eax)
  800915:	0f 84 c3 fb ff ff    	je     8004de <vprintfmt+0x31>
  80091b:	89 c3                	mov    %eax,%ebx
  80091d:	eb f0                	jmp    80090f <vprintfmt+0x462>
				/* do nothing */;
			break;
		}
	}
}
  80091f:	83 c4 5c             	add    $0x5c,%esp
  800922:	5b                   	pop    %ebx
  800923:	5e                   	pop    %esi
  800924:	5f                   	pop    %edi
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	83 ec 28             	sub    $0x28,%esp
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800933:	85 c0                	test   %eax,%eax
  800935:	74 04                	je     80093b <vsnprintf+0x14>
  800937:	85 d2                	test   %edx,%edx
  800939:	7f 07                	jg     800942 <vsnprintf+0x1b>
  80093b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800940:	eb 3b                	jmp    80097d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800942:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800945:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800949:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80094c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800953:	8b 45 14             	mov    0x14(%ebp),%eax
  800956:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80095a:	8b 45 10             	mov    0x10(%ebp),%eax
  80095d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800961:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800964:	89 44 24 04          	mov    %eax,0x4(%esp)
  800968:	c7 04 24 90 04 80 00 	movl   $0x800490,(%esp)
  80096f:	e8 39 fb ff ff       	call   8004ad <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800974:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800977:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80097a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800985:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800988:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80098c:	8b 45 10             	mov    0x10(%ebp),%eax
  80098f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800993:	8b 45 0c             	mov    0xc(%ebp),%eax
  800996:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	89 04 24             	mov    %eax,(%esp)
  8009a0:	e8 82 ff ff ff       	call   800927 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009a5:	c9                   	leave  
  8009a6:	c3                   	ret    

008009a7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8009ad:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8009b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	89 04 24             	mov    %eax,(%esp)
  8009c8:	e8 e0 fa ff ff       	call   8004ad <vprintfmt>
	va_end(ap);
}
  8009cd:	c9                   	leave  
  8009ce:	c3                   	ret    
	...

008009d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009db:	80 3a 00             	cmpb   $0x0,(%edx)
  8009de:	74 09                	je     8009e9 <strlen+0x19>
		n++;
  8009e0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009e3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009e7:	75 f7                	jne    8009e0 <strlen+0x10>
		n++;
	return n;
}
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	53                   	push   %ebx
  8009ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009f5:	85 c9                	test   %ecx,%ecx
  8009f7:	74 19                	je     800a12 <strnlen+0x27>
  8009f9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009fc:	74 14                	je     800a12 <strnlen+0x27>
  8009fe:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a03:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a06:	39 c8                	cmp    %ecx,%eax
  800a08:	74 0d                	je     800a17 <strnlen+0x2c>
  800a0a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800a0e:	75 f3                	jne    800a03 <strnlen+0x18>
  800a10:	eb 05                	jmp    800a17 <strnlen+0x2c>
  800a12:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a17:	5b                   	pop    %ebx
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	53                   	push   %ebx
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a24:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a29:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a2d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a30:	83 c2 01             	add    $0x1,%edx
  800a33:	84 c9                	test   %cl,%cl
  800a35:	75 f2                	jne    800a29 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a37:	5b                   	pop    %ebx
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	53                   	push   %ebx
  800a3e:	83 ec 08             	sub    $0x8,%esp
  800a41:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a44:	89 1c 24             	mov    %ebx,(%esp)
  800a47:	e8 84 ff ff ff       	call   8009d0 <strlen>
	strcpy(dst + len, src);
  800a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a53:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800a56:	89 04 24             	mov    %eax,(%esp)
  800a59:	e8 bc ff ff ff       	call   800a1a <strcpy>
	return dst;
}
  800a5e:	89 d8                	mov    %ebx,%eax
  800a60:	83 c4 08             	add    $0x8,%esp
  800a63:	5b                   	pop    %ebx
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	56                   	push   %esi
  800a6a:	53                   	push   %ebx
  800a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a71:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a74:	85 f6                	test   %esi,%esi
  800a76:	74 18                	je     800a90 <strncpy+0x2a>
  800a78:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a7d:	0f b6 1a             	movzbl (%edx),%ebx
  800a80:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a83:	80 3a 01             	cmpb   $0x1,(%edx)
  800a86:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a89:	83 c1 01             	add    $0x1,%ecx
  800a8c:	39 ce                	cmp    %ecx,%esi
  800a8e:	77 ed                	ja     800a7d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a90:	5b                   	pop    %ebx
  800a91:	5e                   	pop    %esi
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	56                   	push   %esi
  800a98:	53                   	push   %ebx
  800a99:	8b 75 08             	mov    0x8(%ebp),%esi
  800a9c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aa2:	89 f0                	mov    %esi,%eax
  800aa4:	85 c9                	test   %ecx,%ecx
  800aa6:	74 27                	je     800acf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800aa8:	83 e9 01             	sub    $0x1,%ecx
  800aab:	74 1d                	je     800aca <strlcpy+0x36>
  800aad:	0f b6 1a             	movzbl (%edx),%ebx
  800ab0:	84 db                	test   %bl,%bl
  800ab2:	74 16                	je     800aca <strlcpy+0x36>
			*dst++ = *src++;
  800ab4:	88 18                	mov    %bl,(%eax)
  800ab6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ab9:	83 e9 01             	sub    $0x1,%ecx
  800abc:	74 0e                	je     800acc <strlcpy+0x38>
			*dst++ = *src++;
  800abe:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ac1:	0f b6 1a             	movzbl (%edx),%ebx
  800ac4:	84 db                	test   %bl,%bl
  800ac6:	75 ec                	jne    800ab4 <strlcpy+0x20>
  800ac8:	eb 02                	jmp    800acc <strlcpy+0x38>
  800aca:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800acc:	c6 00 00             	movb   $0x0,(%eax)
  800acf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800ad1:	5b                   	pop    %ebx
  800ad2:	5e                   	pop    %esi
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800adb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ade:	0f b6 01             	movzbl (%ecx),%eax
  800ae1:	84 c0                	test   %al,%al
  800ae3:	74 15                	je     800afa <strcmp+0x25>
  800ae5:	3a 02                	cmp    (%edx),%al
  800ae7:	75 11                	jne    800afa <strcmp+0x25>
		p++, q++;
  800ae9:	83 c1 01             	add    $0x1,%ecx
  800aec:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aef:	0f b6 01             	movzbl (%ecx),%eax
  800af2:	84 c0                	test   %al,%al
  800af4:	74 04                	je     800afa <strcmp+0x25>
  800af6:	3a 02                	cmp    (%edx),%al
  800af8:	74 ef                	je     800ae9 <strcmp+0x14>
  800afa:	0f b6 c0             	movzbl %al,%eax
  800afd:	0f b6 12             	movzbl (%edx),%edx
  800b00:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	53                   	push   %ebx
  800b08:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800b11:	85 c0                	test   %eax,%eax
  800b13:	74 23                	je     800b38 <strncmp+0x34>
  800b15:	0f b6 1a             	movzbl (%edx),%ebx
  800b18:	84 db                	test   %bl,%bl
  800b1a:	74 25                	je     800b41 <strncmp+0x3d>
  800b1c:	3a 19                	cmp    (%ecx),%bl
  800b1e:	75 21                	jne    800b41 <strncmp+0x3d>
  800b20:	83 e8 01             	sub    $0x1,%eax
  800b23:	74 13                	je     800b38 <strncmp+0x34>
		n--, p++, q++;
  800b25:	83 c2 01             	add    $0x1,%edx
  800b28:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b2b:	0f b6 1a             	movzbl (%edx),%ebx
  800b2e:	84 db                	test   %bl,%bl
  800b30:	74 0f                	je     800b41 <strncmp+0x3d>
  800b32:	3a 19                	cmp    (%ecx),%bl
  800b34:	74 ea                	je     800b20 <strncmp+0x1c>
  800b36:	eb 09                	jmp    800b41 <strncmp+0x3d>
  800b38:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b3d:	5b                   	pop    %ebx
  800b3e:	5d                   	pop    %ebp
  800b3f:	90                   	nop
  800b40:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b41:	0f b6 02             	movzbl (%edx),%eax
  800b44:	0f b6 11             	movzbl (%ecx),%edx
  800b47:	29 d0                	sub    %edx,%eax
  800b49:	eb f2                	jmp    800b3d <strncmp+0x39>

00800b4b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b55:	0f b6 10             	movzbl (%eax),%edx
  800b58:	84 d2                	test   %dl,%dl
  800b5a:	74 18                	je     800b74 <strchr+0x29>
		if (*s == c)
  800b5c:	38 ca                	cmp    %cl,%dl
  800b5e:	75 0a                	jne    800b6a <strchr+0x1f>
  800b60:	eb 17                	jmp    800b79 <strchr+0x2e>
  800b62:	38 ca                	cmp    %cl,%dl
  800b64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b68:	74 0f                	je     800b79 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b6a:	83 c0 01             	add    $0x1,%eax
  800b6d:	0f b6 10             	movzbl (%eax),%edx
  800b70:	84 d2                	test   %dl,%dl
  800b72:	75 ee                	jne    800b62 <strchr+0x17>
  800b74:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b85:	0f b6 10             	movzbl (%eax),%edx
  800b88:	84 d2                	test   %dl,%dl
  800b8a:	74 18                	je     800ba4 <strfind+0x29>
		if (*s == c)
  800b8c:	38 ca                	cmp    %cl,%dl
  800b8e:	75 0a                	jne    800b9a <strfind+0x1f>
  800b90:	eb 12                	jmp    800ba4 <strfind+0x29>
  800b92:	38 ca                	cmp    %cl,%dl
  800b94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b98:	74 0a                	je     800ba4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b9a:	83 c0 01             	add    $0x1,%eax
  800b9d:	0f b6 10             	movzbl (%eax),%edx
  800ba0:	84 d2                	test   %dl,%dl
  800ba2:	75 ee                	jne    800b92 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	83 ec 0c             	sub    $0xc,%esp
  800bac:	89 1c 24             	mov    %ebx,(%esp)
  800baf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bb3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800bb7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bc0:	85 c9                	test   %ecx,%ecx
  800bc2:	74 30                	je     800bf4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bc4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bca:	75 25                	jne    800bf1 <memset+0x4b>
  800bcc:	f6 c1 03             	test   $0x3,%cl
  800bcf:	75 20                	jne    800bf1 <memset+0x4b>
		c &= 0xFF;
  800bd1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bd4:	89 d3                	mov    %edx,%ebx
  800bd6:	c1 e3 08             	shl    $0x8,%ebx
  800bd9:	89 d6                	mov    %edx,%esi
  800bdb:	c1 e6 18             	shl    $0x18,%esi
  800bde:	89 d0                	mov    %edx,%eax
  800be0:	c1 e0 10             	shl    $0x10,%eax
  800be3:	09 f0                	or     %esi,%eax
  800be5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800be7:	09 d8                	or     %ebx,%eax
  800be9:	c1 e9 02             	shr    $0x2,%ecx
  800bec:	fc                   	cld    
  800bed:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bef:	eb 03                	jmp    800bf4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bf1:	fc                   	cld    
  800bf2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bf4:	89 f8                	mov    %edi,%eax
  800bf6:	8b 1c 24             	mov    (%esp),%ebx
  800bf9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bfd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c01:	89 ec                	mov    %ebp,%esp
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	83 ec 08             	sub    $0x8,%esp
  800c0b:	89 34 24             	mov    %esi,(%esp)
  800c0e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c12:	8b 45 08             	mov    0x8(%ebp),%eax
  800c15:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800c18:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800c1b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800c1d:	39 c6                	cmp    %eax,%esi
  800c1f:	73 35                	jae    800c56 <memmove+0x51>
  800c21:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c24:	39 d0                	cmp    %edx,%eax
  800c26:	73 2e                	jae    800c56 <memmove+0x51>
		s += n;
		d += n;
  800c28:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c2a:	f6 c2 03             	test   $0x3,%dl
  800c2d:	75 1b                	jne    800c4a <memmove+0x45>
  800c2f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c35:	75 13                	jne    800c4a <memmove+0x45>
  800c37:	f6 c1 03             	test   $0x3,%cl
  800c3a:	75 0e                	jne    800c4a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800c3c:	83 ef 04             	sub    $0x4,%edi
  800c3f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c42:	c1 e9 02             	shr    $0x2,%ecx
  800c45:	fd                   	std    
  800c46:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c48:	eb 09                	jmp    800c53 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c4a:	83 ef 01             	sub    $0x1,%edi
  800c4d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c50:	fd                   	std    
  800c51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c53:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c54:	eb 20                	jmp    800c76 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c56:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c5c:	75 15                	jne    800c73 <memmove+0x6e>
  800c5e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c64:	75 0d                	jne    800c73 <memmove+0x6e>
  800c66:	f6 c1 03             	test   $0x3,%cl
  800c69:	75 08                	jne    800c73 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800c6b:	c1 e9 02             	shr    $0x2,%ecx
  800c6e:	fc                   	cld    
  800c6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c71:	eb 03                	jmp    800c76 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c73:	fc                   	cld    
  800c74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c76:	8b 34 24             	mov    (%esp),%esi
  800c79:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c7d:	89 ec                	mov    %ebp,%esp
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c87:	8b 45 10             	mov    0x10(%ebp),%eax
  800c8a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c91:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c95:	8b 45 08             	mov    0x8(%ebp),%eax
  800c98:	89 04 24             	mov    %eax,(%esp)
  800c9b:	e8 65 ff ff ff       	call   800c05 <memmove>
}
  800ca0:	c9                   	leave  
  800ca1:	c3                   	ret    

00800ca2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	8b 75 08             	mov    0x8(%ebp),%esi
  800cab:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800cae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cb1:	85 c9                	test   %ecx,%ecx
  800cb3:	74 36                	je     800ceb <memcmp+0x49>
		if (*s1 != *s2)
  800cb5:	0f b6 06             	movzbl (%esi),%eax
  800cb8:	0f b6 1f             	movzbl (%edi),%ebx
  800cbb:	38 d8                	cmp    %bl,%al
  800cbd:	74 20                	je     800cdf <memcmp+0x3d>
  800cbf:	eb 14                	jmp    800cd5 <memcmp+0x33>
  800cc1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800cc6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800ccb:	83 c2 01             	add    $0x1,%edx
  800cce:	83 e9 01             	sub    $0x1,%ecx
  800cd1:	38 d8                	cmp    %bl,%al
  800cd3:	74 12                	je     800ce7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800cd5:	0f b6 c0             	movzbl %al,%eax
  800cd8:	0f b6 db             	movzbl %bl,%ebx
  800cdb:	29 d8                	sub    %ebx,%eax
  800cdd:	eb 11                	jmp    800cf0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cdf:	83 e9 01             	sub    $0x1,%ecx
  800ce2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce7:	85 c9                	test   %ecx,%ecx
  800ce9:	75 d6                	jne    800cc1 <memcmp+0x1f>
  800ceb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cfb:	89 c2                	mov    %eax,%edx
  800cfd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d00:	39 d0                	cmp    %edx,%eax
  800d02:	73 15                	jae    800d19 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d04:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800d08:	38 08                	cmp    %cl,(%eax)
  800d0a:	75 06                	jne    800d12 <memfind+0x1d>
  800d0c:	eb 0b                	jmp    800d19 <memfind+0x24>
  800d0e:	38 08                	cmp    %cl,(%eax)
  800d10:	74 07                	je     800d19 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d12:	83 c0 01             	add    $0x1,%eax
  800d15:	39 c2                	cmp    %eax,%edx
  800d17:	77 f5                	ja     800d0e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
  800d21:	83 ec 04             	sub    $0x4,%esp
  800d24:	8b 55 08             	mov    0x8(%ebp),%edx
  800d27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d2a:	0f b6 02             	movzbl (%edx),%eax
  800d2d:	3c 20                	cmp    $0x20,%al
  800d2f:	74 04                	je     800d35 <strtol+0x1a>
  800d31:	3c 09                	cmp    $0x9,%al
  800d33:	75 0e                	jne    800d43 <strtol+0x28>
		s++;
  800d35:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d38:	0f b6 02             	movzbl (%edx),%eax
  800d3b:	3c 20                	cmp    $0x20,%al
  800d3d:	74 f6                	je     800d35 <strtol+0x1a>
  800d3f:	3c 09                	cmp    $0x9,%al
  800d41:	74 f2                	je     800d35 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d43:	3c 2b                	cmp    $0x2b,%al
  800d45:	75 0c                	jne    800d53 <strtol+0x38>
		s++;
  800d47:	83 c2 01             	add    $0x1,%edx
  800d4a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d51:	eb 15                	jmp    800d68 <strtol+0x4d>
	else if (*s == '-')
  800d53:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d5a:	3c 2d                	cmp    $0x2d,%al
  800d5c:	75 0a                	jne    800d68 <strtol+0x4d>
		s++, neg = 1;
  800d5e:	83 c2 01             	add    $0x1,%edx
  800d61:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d68:	85 db                	test   %ebx,%ebx
  800d6a:	0f 94 c0             	sete   %al
  800d6d:	74 05                	je     800d74 <strtol+0x59>
  800d6f:	83 fb 10             	cmp    $0x10,%ebx
  800d72:	75 18                	jne    800d8c <strtol+0x71>
  800d74:	80 3a 30             	cmpb   $0x30,(%edx)
  800d77:	75 13                	jne    800d8c <strtol+0x71>
  800d79:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d7d:	8d 76 00             	lea    0x0(%esi),%esi
  800d80:	75 0a                	jne    800d8c <strtol+0x71>
		s += 2, base = 16;
  800d82:	83 c2 02             	add    $0x2,%edx
  800d85:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d8a:	eb 15                	jmp    800da1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d8c:	84 c0                	test   %al,%al
  800d8e:	66 90                	xchg   %ax,%ax
  800d90:	74 0f                	je     800da1 <strtol+0x86>
  800d92:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d97:	80 3a 30             	cmpb   $0x30,(%edx)
  800d9a:	75 05                	jne    800da1 <strtol+0x86>
		s++, base = 8;
  800d9c:	83 c2 01             	add    $0x1,%edx
  800d9f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800da1:	b8 00 00 00 00       	mov    $0x0,%eax
  800da6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800da8:	0f b6 0a             	movzbl (%edx),%ecx
  800dab:	89 cf                	mov    %ecx,%edi
  800dad:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800db0:	80 fb 09             	cmp    $0x9,%bl
  800db3:	77 08                	ja     800dbd <strtol+0xa2>
			dig = *s - '0';
  800db5:	0f be c9             	movsbl %cl,%ecx
  800db8:	83 e9 30             	sub    $0x30,%ecx
  800dbb:	eb 1e                	jmp    800ddb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800dbd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800dc0:	80 fb 19             	cmp    $0x19,%bl
  800dc3:	77 08                	ja     800dcd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800dc5:	0f be c9             	movsbl %cl,%ecx
  800dc8:	83 e9 57             	sub    $0x57,%ecx
  800dcb:	eb 0e                	jmp    800ddb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800dcd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800dd0:	80 fb 19             	cmp    $0x19,%bl
  800dd3:	77 15                	ja     800dea <strtol+0xcf>
			dig = *s - 'A' + 10;
  800dd5:	0f be c9             	movsbl %cl,%ecx
  800dd8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ddb:	39 f1                	cmp    %esi,%ecx
  800ddd:	7d 0b                	jge    800dea <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800ddf:	83 c2 01             	add    $0x1,%edx
  800de2:	0f af c6             	imul   %esi,%eax
  800de5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800de8:	eb be                	jmp    800da8 <strtol+0x8d>
  800dea:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800dec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800df0:	74 05                	je     800df7 <strtol+0xdc>
		*endptr = (char *) s;
  800df2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800df5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800df7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800dfb:	74 04                	je     800e01 <strtol+0xe6>
  800dfd:	89 c8                	mov    %ecx,%eax
  800dff:	f7 d8                	neg    %eax
}
  800e01:	83 c4 04             	add    $0x4,%esp
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    
  800e09:	00 00                	add    %al,(%eax)
  800e0b:	00 00                	add    %al,(%eax)
  800e0d:	00 00                	add    %al,(%eax)
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
