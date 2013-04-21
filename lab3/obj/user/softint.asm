
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
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
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	5d                   	pop    %ebp
  80003a:	c3                   	ret    
	...

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	83 ec 18             	sub    $0x18,%esp
  800042:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800045:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800048:	8b 75 08             	mov    0x8(%ebp),%esi
  80004b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80004e:	e8 cc 00 00 00       	call   80011f <sys_getenvid>
  800053:	25 ff 03 00 00       	and    $0x3ff,%eax
  800058:	6b c0 64             	imul   $0x64,%eax,%eax
  80005b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800060:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800065:	85 f6                	test   %esi,%esi
  800067:	7e 07                	jle    800070 <libmain+0x34>
		binaryname = argv[0];
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800070:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800074:	89 34 24             	mov    %esi,(%esp)
  800077:	e8 b8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007c:	e8 0b 00 00 00       	call   80008c <exit>
}
  800081:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800084:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800087:	89 ec                	mov    %ebp,%esp
  800089:	5d                   	pop    %ebp
  80008a:	c3                   	ret    
	...

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800092:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800099:	e8 03 01 00 00       	call   8001a1 <sys_env_destroy>
}
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 08             	sub    $0x8,%esp
  8000a6:	89 1c 24             	mov    %ebx,(%esp)
  8000a9:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	51                   	push   %ecx
  8000bd:	52                   	push   %edx
  8000be:	53                   	push   %ebx
  8000bf:	54                   	push   %esp
  8000c0:	55                   	push   %ebp
  8000c1:	56                   	push   %esi
  8000c2:	57                   	push   %edi
  8000c3:	8d 35 cd 00 80 00    	lea    0x8000cd,%esi
  8000c9:	54                   	push   %esp
  8000ca:	5d                   	pop    %ebp
  8000cb:	0f 34                	sysenter 
  8000cd:	5f                   	pop    %edi
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	5c                   	pop    %esp
  8000d1:	5b                   	pop    %ebx
  8000d2:	5a                   	pop    %edx
  8000d3:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d4:	8b 1c 24             	mov    (%esp),%ebx
  8000d7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8000db:	89 ec                	mov    %ebp,%esp
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_cgetc>:

int
sys_cgetc(void)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	89 1c 24             	mov    %ebx,(%esp)
  8000e8:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f6:	89 d1                	mov    %edx,%ecx
  8000f8:	89 d3                	mov    %edx,%ebx
  8000fa:	89 d7                	mov    %edx,%edi
  8000fc:	51                   	push   %ecx
  8000fd:	52                   	push   %edx
  8000fe:	53                   	push   %ebx
  8000ff:	54                   	push   %esp
  800100:	55                   	push   %ebp
  800101:	56                   	push   %esi
  800102:	57                   	push   %edi
  800103:	8d 35 0d 01 80 00    	lea    0x80010d,%esi
  800109:	54                   	push   %esp
  80010a:	5d                   	pop    %ebp
  80010b:	0f 34                	sysenter 
  80010d:	5f                   	pop    %edi
  80010e:	5e                   	pop    %esi
  80010f:	5d                   	pop    %ebp
  800110:	5c                   	pop    %esp
  800111:	5b                   	pop    %ebx
  800112:	5a                   	pop    %edx
  800113:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800114:	8b 1c 24             	mov    (%esp),%ebx
  800117:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80011b:	89 ec                	mov    %ebp,%esp
  80011d:	5d                   	pop    %ebp
  80011e:	c3                   	ret    

0080011f <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80011f:	55                   	push   %ebp
  800120:	89 e5                	mov    %esp,%ebp
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	89 1c 24             	mov    %ebx,(%esp)
  800128:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80012c:	ba 00 00 00 00       	mov    $0x0,%edx
  800131:	b8 02 00 00 00       	mov    $0x2,%eax
  800136:	89 d1                	mov    %edx,%ecx
  800138:	89 d3                	mov    %edx,%ebx
  80013a:	89 d7                	mov    %edx,%edi
  80013c:	51                   	push   %ecx
  80013d:	52                   	push   %edx
  80013e:	53                   	push   %ebx
  80013f:	54                   	push   %esp
  800140:	55                   	push   %ebp
  800141:	56                   	push   %esi
  800142:	57                   	push   %edi
  800143:	8d 35 4d 01 80 00    	lea    0x80014d,%esi
  800149:	54                   	push   %esp
  80014a:	5d                   	pop    %ebp
  80014b:	0f 34                	sysenter 
  80014d:	5f                   	pop    %edi
  80014e:	5e                   	pop    %esi
  80014f:	5d                   	pop    %ebp
  800150:	5c                   	pop    %esp
  800151:	5b                   	pop    %ebx
  800152:	5a                   	pop    %edx
  800153:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800154:	8b 1c 24             	mov    (%esp),%ebx
  800157:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80015b:	89 ec                	mov    %ebp,%esp
  80015d:	5d                   	pop    %ebp
  80015e:	c3                   	ret    

0080015f <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	83 ec 08             	sub    $0x8,%esp
  800165:	89 1c 24             	mov    %ebx,(%esp)
  800168:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80016c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800171:	b8 04 00 00 00       	mov    $0x4,%eax
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	89 df                	mov    %ebx,%edi
  80017e:	51                   	push   %ecx
  80017f:	52                   	push   %edx
  800180:	53                   	push   %ebx
  800181:	54                   	push   %esp
  800182:	55                   	push   %ebp
  800183:	56                   	push   %esi
  800184:	57                   	push   %edi
  800185:	8d 35 8f 01 80 00    	lea    0x80018f,%esi
  80018b:	54                   	push   %esp
  80018c:	5d                   	pop    %ebp
  80018d:	0f 34                	sysenter 
  80018f:	5f                   	pop    %edi
  800190:	5e                   	pop    %esi
  800191:	5d                   	pop    %ebp
  800192:	5c                   	pop    %esp
  800193:	5b                   	pop    %ebx
  800194:	5a                   	pop    %edx
  800195:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800196:	8b 1c 24             	mov    (%esp),%ebx
  800199:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80019d:	89 ec                	mov    %ebp,%esp
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	83 ec 28             	sub    $0x28,%esp
  8001a7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8001aa:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001b2:	b8 03 00 00 00       	mov    $0x3,%eax
  8001b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ba:	89 cb                	mov    %ecx,%ebx
  8001bc:	89 cf                	mov    %ecx,%edi
  8001be:	51                   	push   %ecx
  8001bf:	52                   	push   %edx
  8001c0:	53                   	push   %ebx
  8001c1:	54                   	push   %esp
  8001c2:	55                   	push   %ebp
  8001c3:	56                   	push   %esi
  8001c4:	57                   	push   %edi
  8001c5:	8d 35 cf 01 80 00    	lea    0x8001cf,%esi
  8001cb:	54                   	push   %esp
  8001cc:	5d                   	pop    %ebp
  8001cd:	0f 34                	sysenter 
  8001cf:	5f                   	pop    %edi
  8001d0:	5e                   	pop    %esi
  8001d1:	5d                   	pop    %ebp
  8001d2:	5c                   	pop    %esp
  8001d3:	5b                   	pop    %ebx
  8001d4:	5a                   	pop    %edx
  8001d5:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8001d6:	85 c0                	test   %eax,%eax
  8001d8:	7e 28                	jle    800202 <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001da:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001de:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8001e5:	00 
  8001e6:	c7 44 24 08 62 10 80 	movl   $0x801062,0x8(%esp)
  8001ed:	00 
  8001ee:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  8001f5:	00 
  8001f6:	c7 04 24 7f 10 80 00 	movl   $0x80107f,(%esp)
  8001fd:	e8 0a 00 00 00       	call   80020c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800202:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800205:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800208:	89 ec                	mov    %ebp,%esp
  80020a:	5d                   	pop    %ebp
  80020b:	c3                   	ret    

0080020c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	56                   	push   %esi
  800210:	53                   	push   %ebx
  800211:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800214:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800217:	a1 08 20 80 00       	mov    0x802008,%eax
  80021c:	85 c0                	test   %eax,%eax
  80021e:	74 10                	je     800230 <_panic+0x24>
		cprintf("%s: ", argv0);
  800220:	89 44 24 04          	mov    %eax,0x4(%esp)
  800224:	c7 04 24 8d 10 80 00 	movl   $0x80108d,(%esp)
  80022b:	e8 ad 00 00 00       	call   8002dd <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800230:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800236:	e8 e4 fe ff ff       	call   80011f <sys_getenvid>
  80023b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800242:	8b 55 08             	mov    0x8(%ebp),%edx
  800245:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800249:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80024d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800251:	c7 04 24 94 10 80 00 	movl   $0x801094,(%esp)
  800258:	e8 80 00 00 00       	call   8002dd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800261:	8b 45 10             	mov    0x10(%ebp),%eax
  800264:	89 04 24             	mov    %eax,(%esp)
  800267:	e8 10 00 00 00       	call   80027c <vcprintf>
	cprintf("\n");
  80026c:	c7 04 24 92 10 80 00 	movl   $0x801092,(%esp)
  800273:	e8 65 00 00 00       	call   8002dd <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800278:	cc                   	int3   
  800279:	eb fd                	jmp    800278 <_panic+0x6c>
	...

0080027c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800285:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80028c:	00 00 00 
	b.cnt = 0;
  80028f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800296:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800299:	8b 45 0c             	mov    0xc(%ebp),%eax
  80029c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b1:	c7 04 24 f7 02 80 00 	movl   $0x8002f7,(%esp)
  8002b8:	e8 d0 01 00 00       	call   80048d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002bd:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002cd:	89 04 24             	mov    %eax,(%esp)
  8002d0:	e8 cb fd ff ff       	call   8000a0 <sys_cputs>

	return b.cnt;
}
  8002d5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002db:	c9                   	leave  
  8002dc:	c3                   	ret    

008002dd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
  8002e0:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8002e3:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8002e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ed:	89 04 24             	mov    %eax,(%esp)
  8002f0:	e8 87 ff ff ff       	call   80027c <vcprintf>
	va_end(ap);

	return cnt;
}
  8002f5:	c9                   	leave  
  8002f6:	c3                   	ret    

008002f7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	53                   	push   %ebx
  8002fb:	83 ec 14             	sub    $0x14,%esp
  8002fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800301:	8b 03                	mov    (%ebx),%eax
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80030a:	83 c0 01             	add    $0x1,%eax
  80030d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80030f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800314:	75 19                	jne    80032f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800316:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80031d:	00 
  80031e:	8d 43 08             	lea    0x8(%ebx),%eax
  800321:	89 04 24             	mov    %eax,(%esp)
  800324:	e8 77 fd ff ff       	call   8000a0 <sys_cputs>
		b->idx = 0;
  800329:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80032f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800333:	83 c4 14             	add    $0x14,%esp
  800336:	5b                   	pop    %ebx
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    
  800339:	00 00                	add    %al,(%eax)
  80033b:	00 00                	add    %al,(%eax)
  80033d:	00 00                	add    %al,(%eax)
	...

00800340 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	57                   	push   %edi
  800344:	56                   	push   %esi
  800345:	53                   	push   %ebx
  800346:	83 ec 4c             	sub    $0x4c,%esp
  800349:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034c:	89 d6                	mov    %edx,%esi
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800354:	8b 55 0c             	mov    0xc(%ebp),%edx
  800357:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80035a:	8b 45 10             	mov    0x10(%ebp),%eax
  80035d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800360:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800363:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800366:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036b:	39 d1                	cmp    %edx,%ecx
  80036d:	72 15                	jb     800384 <printnum+0x44>
  80036f:	77 07                	ja     800378 <printnum+0x38>
  800371:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800374:	39 d0                	cmp    %edx,%eax
  800376:	76 0c                	jbe    800384 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800378:	83 eb 01             	sub    $0x1,%ebx
  80037b:	85 db                	test   %ebx,%ebx
  80037d:	8d 76 00             	lea    0x0(%esi),%esi
  800380:	7f 61                	jg     8003e3 <printnum+0xa3>
  800382:	eb 70                	jmp    8003f4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800384:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800388:	83 eb 01             	sub    $0x1,%ebx
  80038b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80038f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800393:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800397:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80039b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80039e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8003a1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8003a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003a8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003af:	00 
  8003b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003b3:	89 04 24             	mov    %eax,(%esp)
  8003b6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003bd:	e8 2e 0a 00 00       	call   800df0 <__udivdi3>
  8003c2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003c5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8003c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003cc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003d0:	89 04 24             	mov    %eax,(%esp)
  8003d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003d7:	89 f2                	mov    %esi,%edx
  8003d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003dc:	e8 5f ff ff ff       	call   800340 <printnum>
  8003e1:	eb 11                	jmp    8003f4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003e7:	89 3c 24             	mov    %edi,(%esp)
  8003ea:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003ed:	83 eb 01             	sub    $0x1,%ebx
  8003f0:	85 db                	test   %ebx,%ebx
  8003f2:	7f ef                	jg     8003e3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003f8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800403:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80040a:	00 
  80040b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80040e:	89 14 24             	mov    %edx,(%esp)
  800411:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800414:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800418:	e8 03 0b 00 00       	call   800f20 <__umoddi3>
  80041d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800421:	0f be 80 b7 10 80 00 	movsbl 0x8010b7(%eax),%eax
  800428:	89 04 24             	mov    %eax,(%esp)
  80042b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80042e:	83 c4 4c             	add    $0x4c,%esp
  800431:	5b                   	pop    %ebx
  800432:	5e                   	pop    %esi
  800433:	5f                   	pop    %edi
  800434:	5d                   	pop    %ebp
  800435:	c3                   	ret    

00800436 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800436:	55                   	push   %ebp
  800437:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800439:	83 fa 01             	cmp    $0x1,%edx
  80043c:	7e 0e                	jle    80044c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80043e:	8b 10                	mov    (%eax),%edx
  800440:	8d 4a 08             	lea    0x8(%edx),%ecx
  800443:	89 08                	mov    %ecx,(%eax)
  800445:	8b 02                	mov    (%edx),%eax
  800447:	8b 52 04             	mov    0x4(%edx),%edx
  80044a:	eb 22                	jmp    80046e <getuint+0x38>
	else if (lflag)
  80044c:	85 d2                	test   %edx,%edx
  80044e:	74 10                	je     800460 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800450:	8b 10                	mov    (%eax),%edx
  800452:	8d 4a 04             	lea    0x4(%edx),%ecx
  800455:	89 08                	mov    %ecx,(%eax)
  800457:	8b 02                	mov    (%edx),%eax
  800459:	ba 00 00 00 00       	mov    $0x0,%edx
  80045e:	eb 0e                	jmp    80046e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800460:	8b 10                	mov    (%eax),%edx
  800462:	8d 4a 04             	lea    0x4(%edx),%ecx
  800465:	89 08                	mov    %ecx,(%eax)
  800467:	8b 02                	mov    (%edx),%eax
  800469:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80046e:	5d                   	pop    %ebp
  80046f:	c3                   	ret    

00800470 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800470:	55                   	push   %ebp
  800471:	89 e5                	mov    %esp,%ebp
  800473:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800476:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80047a:	8b 10                	mov    (%eax),%edx
  80047c:	3b 50 04             	cmp    0x4(%eax),%edx
  80047f:	73 0a                	jae    80048b <sprintputch+0x1b>
		*b->buf++ = ch;
  800481:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800484:	88 0a                	mov    %cl,(%edx)
  800486:	83 c2 01             	add    $0x1,%edx
  800489:	89 10                	mov    %edx,(%eax)
}
  80048b:	5d                   	pop    %ebp
  80048c:	c3                   	ret    

0080048d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80048d:	55                   	push   %ebp
  80048e:	89 e5                	mov    %esp,%ebp
  800490:	57                   	push   %edi
  800491:	56                   	push   %esi
  800492:	53                   	push   %ebx
  800493:	83 ec 5c             	sub    $0x5c,%esp
  800496:	8b 7d 08             	mov    0x8(%ebp),%edi
  800499:	8b 75 0c             	mov    0xc(%ebp),%esi
  80049c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80049f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8004a6:	eb 16                	jmp    8004be <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004a8:	85 c0                	test   %eax,%eax
  8004aa:	0f 84 4f 04 00 00    	je     8008ff <vprintfmt+0x472>
				return;
			putch(ch, putdat);
  8004b0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004b4:	89 04 24             	mov    %eax,(%esp)
  8004b7:	ff d7                	call   *%edi
  8004b9:	eb 03                	jmp    8004be <vprintfmt+0x31>
  8004bb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004be:	0f b6 03             	movzbl (%ebx),%eax
  8004c1:	83 c3 01             	add    $0x1,%ebx
  8004c4:	83 f8 25             	cmp    $0x25,%eax
  8004c7:	75 df                	jne    8004a8 <vprintfmt+0x1b>
  8004c9:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  8004cd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004d4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004db:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8004e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004e7:	eb 06                	jmp    8004ef <vprintfmt+0x62>
  8004e9:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  8004ed:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ef:	0f b6 13             	movzbl (%ebx),%edx
  8004f2:	0f b6 c2             	movzbl %dl,%eax
  8004f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004f8:	8d 43 01             	lea    0x1(%ebx),%eax
  8004fb:	83 ea 23             	sub    $0x23,%edx
  8004fe:	80 fa 55             	cmp    $0x55,%dl
  800501:	0f 87 db 03 00 00    	ja     8008e2 <vprintfmt+0x455>
  800507:	0f b6 d2             	movzbl %dl,%edx
  80050a:	ff 24 95 c0 11 80 00 	jmp    *0x8011c0(,%edx,4)
  800511:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800515:	eb d6                	jmp    8004ed <vprintfmt+0x60>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800517:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80051a:	83 ea 30             	sub    $0x30,%edx
  80051d:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  800520:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800523:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800526:	83 fb 09             	cmp    $0x9,%ebx
  800529:	77 4c                	ja     800577 <vprintfmt+0xea>
  80052b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80052e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800531:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800534:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800537:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  80053b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80053e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800541:	83 fb 09             	cmp    $0x9,%ebx
  800544:	76 eb                	jbe    800531 <vprintfmt+0xa4>
  800546:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800549:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80054c:	eb 29                	jmp    800577 <vprintfmt+0xea>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80054e:	8b 55 14             	mov    0x14(%ebp),%edx
  800551:	8d 5a 04             	lea    0x4(%edx),%ebx
  800554:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800557:	8b 12                	mov    (%edx),%edx
  800559:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  80055c:	eb 19                	jmp    800577 <vprintfmt+0xea>

		case '.':
			if (width < 0)
  80055e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800561:	c1 fa 1f             	sar    $0x1f,%edx
  800564:	f7 d2                	not    %edx
  800566:	21 55 d4             	and    %edx,-0x2c(%ebp)
  800569:	eb 82                	jmp    8004ed <vprintfmt+0x60>
  80056b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800572:	e9 76 ff ff ff       	jmp    8004ed <vprintfmt+0x60>

		process_precision:
			if (width < 0)
  800577:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80057b:	0f 89 6c ff ff ff    	jns    8004ed <vprintfmt+0x60>
  800581:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800584:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800587:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80058a:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80058d:	e9 5b ff ff ff       	jmp    8004ed <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800592:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800595:	e9 53 ff ff ff       	jmp    8004ed <vprintfmt+0x60>
  80059a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8d 50 04             	lea    0x4(%eax),%edx
  8005a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005aa:	8b 00                	mov    (%eax),%eax
  8005ac:	89 04 24             	mov    %eax,(%esp)
  8005af:	ff d7                	call   *%edi
  8005b1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
  8005b4:	e9 05 ff ff ff       	jmp    8004be <vprintfmt+0x31>
  8005b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8d 50 04             	lea    0x4(%eax),%edx
  8005c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c5:	8b 00                	mov    (%eax),%eax
  8005c7:	89 c2                	mov    %eax,%edx
  8005c9:	c1 fa 1f             	sar    $0x1f,%edx
  8005cc:	31 d0                	xor    %edx,%eax
  8005ce:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005d0:	83 f8 06             	cmp    $0x6,%eax
  8005d3:	7f 0b                	jg     8005e0 <vprintfmt+0x153>
  8005d5:	8b 14 85 18 13 80 00 	mov    0x801318(,%eax,4),%edx
  8005dc:	85 d2                	test   %edx,%edx
  8005de:	75 20                	jne    800600 <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  8005e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005e4:	c7 44 24 08 c8 10 80 	movl   $0x8010c8,0x8(%esp)
  8005eb:	00 
  8005ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f0:	89 3c 24             	mov    %edi,(%esp)
  8005f3:	e8 8f 03 00 00       	call   800987 <printfmt>
  8005f8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005fb:	e9 be fe ff ff       	jmp    8004be <vprintfmt+0x31>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800600:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800604:	c7 44 24 08 d1 10 80 	movl   $0x8010d1,0x8(%esp)
  80060b:	00 
  80060c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800610:	89 3c 24             	mov    %edi,(%esp)
  800613:	e8 6f 03 00 00       	call   800987 <printfmt>
  800618:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80061b:	e9 9e fe ff ff       	jmp    8004be <vprintfmt+0x31>
  800620:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800623:	89 c3                	mov    %eax,%ebx
  800625:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800628:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80062b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8d 50 04             	lea    0x4(%eax),%edx
  800634:	89 55 14             	mov    %edx,0x14(%ebp)
  800637:	8b 00                	mov    (%eax),%eax
  800639:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80063c:	85 c0                	test   %eax,%eax
  80063e:	75 07                	jne    800647 <vprintfmt+0x1ba>
  800640:	c7 45 cc d4 10 80 00 	movl   $0x8010d4,-0x34(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800647:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80064b:	7e 06                	jle    800653 <vprintfmt+0x1c6>
  80064d:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800651:	75 13                	jne    800666 <vprintfmt+0x1d9>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800653:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800656:	0f be 02             	movsbl (%edx),%eax
  800659:	85 c0                	test   %eax,%eax
  80065b:	0f 85 9f 00 00 00    	jne    800700 <vprintfmt+0x273>
  800661:	e9 8f 00 00 00       	jmp    8006f5 <vprintfmt+0x268>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800666:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80066a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80066d:	89 0c 24             	mov    %ecx,(%esp)
  800670:	e8 56 03 00 00       	call   8009cb <strnlen>
  800675:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800678:	29 c2                	sub    %eax,%edx
  80067a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80067d:	85 d2                	test   %edx,%edx
  80067f:	7e d2                	jle    800653 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800681:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800685:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800688:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  80068b:	89 d3                	mov    %edx,%ebx
  80068d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800691:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800694:	89 04 24             	mov    %eax,(%esp)
  800697:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800699:	83 eb 01             	sub    $0x1,%ebx
  80069c:	85 db                	test   %ebx,%ebx
  80069e:	7f ed                	jg     80068d <vprintfmt+0x200>
  8006a0:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8006a3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8006aa:	eb a7                	jmp    800653 <vprintfmt+0x1c6>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006ac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006b0:	74 1b                	je     8006cd <vprintfmt+0x240>
  8006b2:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006b5:	83 fa 5e             	cmp    $0x5e,%edx
  8006b8:	76 13                	jbe    8006cd <vprintfmt+0x240>
					putch('?', putdat);
  8006ba:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8006bd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006c1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006c8:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006cb:	eb 0d                	jmp    8006da <vprintfmt+0x24d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8006cd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006d0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006d4:	89 04 24             	mov    %eax,(%esp)
  8006d7:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006da:	83 ef 01             	sub    $0x1,%edi
  8006dd:	0f be 03             	movsbl (%ebx),%eax
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	74 05                	je     8006e9 <vprintfmt+0x25c>
  8006e4:	83 c3 01             	add    $0x1,%ebx
  8006e7:	eb 2e                	jmp    800717 <vprintfmt+0x28a>
  8006e9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006ec:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006ef:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8006f2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006f5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006f9:	7f 33                	jg     80072e <vprintfmt+0x2a1>
  8006fb:	e9 bb fd ff ff       	jmp    8004bb <vprintfmt+0x2e>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800700:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800703:	83 c2 01             	add    $0x1,%edx
  800706:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800709:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80070c:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80070f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800712:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800715:	89 d3                	mov    %edx,%ebx
  800717:	85 f6                	test   %esi,%esi
  800719:	78 91                	js     8006ac <vprintfmt+0x21f>
  80071b:	83 ee 01             	sub    $0x1,%esi
  80071e:	79 8c                	jns    8006ac <vprintfmt+0x21f>
  800720:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800723:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800726:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800729:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80072c:	eb c7                	jmp    8006f5 <vprintfmt+0x268>
  80072e:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800731:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800734:	89 74 24 04          	mov    %esi,0x4(%esp)
  800738:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80073f:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800741:	83 eb 01             	sub    $0x1,%ebx
  800744:	85 db                	test   %ebx,%ebx
  800746:	7f ec                	jg     800734 <vprintfmt+0x2a7>
  800748:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80074b:	e9 6e fd ff ff       	jmp    8004be <vprintfmt+0x31>
  800750:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800753:	83 f9 01             	cmp    $0x1,%ecx
  800756:	7e 16                	jle    80076e <vprintfmt+0x2e1>
		return va_arg(*ap, long long);
  800758:	8b 45 14             	mov    0x14(%ebp),%eax
  80075b:	8d 50 08             	lea    0x8(%eax),%edx
  80075e:	89 55 14             	mov    %edx,0x14(%ebp)
  800761:	8b 10                	mov    (%eax),%edx
  800763:	8b 48 04             	mov    0x4(%eax),%ecx
  800766:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800769:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80076c:	eb 32                	jmp    8007a0 <vprintfmt+0x313>
	else if (lflag)
  80076e:	85 c9                	test   %ecx,%ecx
  800770:	74 18                	je     80078a <vprintfmt+0x2fd>
		return va_arg(*ap, long);
  800772:	8b 45 14             	mov    0x14(%ebp),%eax
  800775:	8d 50 04             	lea    0x4(%eax),%edx
  800778:	89 55 14             	mov    %edx,0x14(%ebp)
  80077b:	8b 00                	mov    (%eax),%eax
  80077d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800780:	89 c1                	mov    %eax,%ecx
  800782:	c1 f9 1f             	sar    $0x1f,%ecx
  800785:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800788:	eb 16                	jmp    8007a0 <vprintfmt+0x313>
	else
		return va_arg(*ap, int);
  80078a:	8b 45 14             	mov    0x14(%ebp),%eax
  80078d:	8d 50 04             	lea    0x4(%eax),%edx
  800790:	89 55 14             	mov    %edx,0x14(%ebp)
  800793:	8b 00                	mov    (%eax),%eax
  800795:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800798:	89 c2                	mov    %eax,%edx
  80079a:	c1 fa 1f             	sar    $0x1f,%edx
  80079d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007a0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007a3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007a6:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  8007ab:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007af:	0f 89 8a 00 00 00    	jns    80083f <vprintfmt+0x3b2>
				putch('-', putdat);
  8007b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007c0:	ff d7                	call   *%edi
				num = -(long long) num;
  8007c2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007c5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007c8:	f7 d8                	neg    %eax
  8007ca:	83 d2 00             	adc    $0x0,%edx
  8007cd:	f7 da                	neg    %edx
  8007cf:	eb 6e                	jmp    80083f <vprintfmt+0x3b2>
  8007d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007d4:	89 ca                	mov    %ecx,%edx
  8007d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d9:	e8 58 fc ff ff       	call   800436 <getuint>
  8007de:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  8007e3:	eb 5a                	jmp    80083f <vprintfmt+0x3b2>
  8007e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			//break;
			num = getuint(&ap, lflag);
  8007e8:	89 ca                	mov    %ecx,%edx
  8007ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ed:	e8 44 fc ff ff       	call   800436 <getuint>
  8007f2:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  8007f7:	eb 46                	jmp    80083f <vprintfmt+0x3b2>
  8007f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8007fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800800:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800807:	ff d7                	call   *%edi
			putch('x', putdat);
  800809:	89 74 24 04          	mov    %esi,0x4(%esp)
  80080d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800814:	ff d7                	call   *%edi
			num = (unsigned long long)
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	8d 50 04             	lea    0x4(%eax),%edx
  80081c:	89 55 14             	mov    %edx,0x14(%ebp)
  80081f:	8b 00                	mov    (%eax),%eax
  800821:	ba 00 00 00 00       	mov    $0x0,%edx
  800826:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80082b:	eb 12                	jmp    80083f <vprintfmt+0x3b2>
  80082d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800830:	89 ca                	mov    %ecx,%edx
  800832:	8d 45 14             	lea    0x14(%ebp),%eax
  800835:	e8 fc fb ff ff       	call   800436 <getuint>
  80083a:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80083f:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800843:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800847:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80084a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80084e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800852:	89 04 24             	mov    %eax,(%esp)
  800855:	89 54 24 04          	mov    %edx,0x4(%esp)
  800859:	89 f2                	mov    %esi,%edx
  80085b:	89 f8                	mov    %edi,%eax
  80085d:	e8 de fa ff ff       	call   800340 <printnum>
  800862:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
  800865:	e9 54 fc ff ff       	jmp    8004be <vprintfmt+0x31>
  80086a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			char* tmp = va_arg(ap, char*);
  80086d:	8b 45 14             	mov    0x14(%ebp),%eax
  800870:	8d 50 04             	lea    0x4(%eax),%edx
  800873:	89 55 14             	mov    %edx,0x14(%ebp)
  800876:	8b 00                	mov    (%eax),%eax
			if(tmp == NULL) {
  800878:	85 c0                	test   %eax,%eax
  80087a:	75 1f                	jne    80089b <vprintfmt+0x40e>
  80087c:	bb 45 11 80 00       	mov    $0x801145,%ebx
  800881:	b0 0a                	mov    $0xa,%al
				for(; (ch = *null_error++) != '\0';) {	
					putch(ch, putdat);
  800883:	89 74 24 04          	mov    %esi,0x4(%esp)
  800887:	89 04 24             	mov    %eax,(%esp)
  80088a:	ff d7                	call   *%edi
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			char* tmp = va_arg(ap, char*);
			if(tmp == NULL) {
				for(; (ch = *null_error++) != '\0';) {	
  80088c:	0f be 03             	movsbl (%ebx),%eax
  80088f:	83 c3 01             	add    $0x1,%ebx
  800892:	85 c0                	test   %eax,%eax
  800894:	75 ed                	jne    800883 <vprintfmt+0x3f6>
  800896:	e9 20 fc ff ff       	jmp    8004bb <vprintfmt+0x2e>
					putch(ch, putdat);
				}
				break;
			}
			*tmp = *((signed char*) putdat);
  80089b:	0f b6 16             	movzbl (%esi),%edx
  80089e:	88 10                	mov    %dl,(%eax)
			if(*(signed char*) putdat < 0) {
  8008a0:	80 3e 00             	cmpb   $0x0,(%esi)
  8008a3:	0f 89 12 fc ff ff    	jns    8004bb <vprintfmt+0x2e>
  8008a9:	bb 7d 11 80 00       	mov    $0x80117d,%ebx
  8008ae:	b8 0a 00 00 00       	mov    $0xa,%eax
				for(; (ch = *overflow_error++) != '\0';) {	
					putch(ch, putdat);
  8008b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008b7:	89 04 24             	mov    %eax,(%esp)
  8008ba:	ff d7                	call   *%edi
				}
				break;
			}
			*tmp = *((signed char*) putdat);
			if(*(signed char*) putdat < 0) {
				for(; (ch = *overflow_error++) != '\0';) {	
  8008bc:	0f be 03             	movsbl (%ebx),%eax
  8008bf:	83 c3 01             	add    $0x1,%ebx
  8008c2:	85 c0                	test   %eax,%eax
  8008c4:	75 ed                	jne    8008b3 <vprintfmt+0x426>
  8008c6:	e9 f0 fb ff ff       	jmp    8004bb <vprintfmt+0x2e>
  8008cb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008d5:	89 14 24             	mov    %edx,(%esp)
  8008d8:	ff d7                	call   *%edi
  8008da:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
  8008dd:	e9 dc fb ff ff       	jmp    8004be <vprintfmt+0x31>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008e6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008ed:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ef:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8008f2:	80 38 25             	cmpb   $0x25,(%eax)
  8008f5:	0f 84 c3 fb ff ff    	je     8004be <vprintfmt+0x31>
  8008fb:	89 c3                	mov    %eax,%ebx
  8008fd:	eb f0                	jmp    8008ef <vprintfmt+0x462>
				/* do nothing */;
			break;
		}
	}
}
  8008ff:	83 c4 5c             	add    $0x5c,%esp
  800902:	5b                   	pop    %ebx
  800903:	5e                   	pop    %esi
  800904:	5f                   	pop    %edi
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	83 ec 28             	sub    $0x28,%esp
  80090d:	8b 45 08             	mov    0x8(%ebp),%eax
  800910:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800913:	85 c0                	test   %eax,%eax
  800915:	74 04                	je     80091b <vsnprintf+0x14>
  800917:	85 d2                	test   %edx,%edx
  800919:	7f 07                	jg     800922 <vsnprintf+0x1b>
  80091b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800920:	eb 3b                	jmp    80095d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800922:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800925:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800929:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80092c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800933:	8b 45 14             	mov    0x14(%ebp),%eax
  800936:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80093a:	8b 45 10             	mov    0x10(%ebp),%eax
  80093d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800941:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800944:	89 44 24 04          	mov    %eax,0x4(%esp)
  800948:	c7 04 24 70 04 80 00 	movl   $0x800470,(%esp)
  80094f:	e8 39 fb ff ff       	call   80048d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800954:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800957:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80095a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80095d:	c9                   	leave  
  80095e:	c3                   	ret    

0080095f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800965:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800968:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80096c:	8b 45 10             	mov    0x10(%ebp),%eax
  80096f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800973:	8b 45 0c             	mov    0xc(%ebp),%eax
  800976:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	89 04 24             	mov    %eax,(%esp)
  800980:	e8 82 ff ff ff       	call   800907 <vsnprintf>
	va_end(ap);

	return rc;
}
  800985:	c9                   	leave  
  800986:	c3                   	ret    

00800987 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  80098d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800990:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800994:	8b 45 10             	mov    0x10(%ebp),%eax
  800997:	89 44 24 08          	mov    %eax,0x8(%esp)
  80099b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a5:	89 04 24             	mov    %eax,(%esp)
  8009a8:	e8 e0 fa ff ff       	call   80048d <vprintfmt>
	va_end(ap);
}
  8009ad:	c9                   	leave  
  8009ae:	c3                   	ret    
	...

008009b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009bb:	80 3a 00             	cmpb   $0x0,(%edx)
  8009be:	74 09                	je     8009c9 <strlen+0x19>
		n++;
  8009c0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009c7:	75 f7                	jne    8009c0 <strlen+0x10>
		n++;
	return n;
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	53                   	push   %ebx
  8009cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d5:	85 c9                	test   %ecx,%ecx
  8009d7:	74 19                	je     8009f2 <strnlen+0x27>
  8009d9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009dc:	74 14                	je     8009f2 <strnlen+0x27>
  8009de:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009e3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e6:	39 c8                	cmp    %ecx,%eax
  8009e8:	74 0d                	je     8009f7 <strnlen+0x2c>
  8009ea:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8009ee:	75 f3                	jne    8009e3 <strnlen+0x18>
  8009f0:	eb 05                	jmp    8009f7 <strnlen+0x2c>
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009f7:	5b                   	pop    %ebx
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	53                   	push   %ebx
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a04:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a09:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a0d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a10:	83 c2 01             	add    $0x1,%edx
  800a13:	84 c9                	test   %cl,%cl
  800a15:	75 f2                	jne    800a09 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a17:	5b                   	pop    %ebx
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	53                   	push   %ebx
  800a1e:	83 ec 08             	sub    $0x8,%esp
  800a21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a24:	89 1c 24             	mov    %ebx,(%esp)
  800a27:	e8 84 ff ff ff       	call   8009b0 <strlen>
	strcpy(dst + len, src);
  800a2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a33:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800a36:	89 04 24             	mov    %eax,(%esp)
  800a39:	e8 bc ff ff ff       	call   8009fa <strcpy>
	return dst;
}
  800a3e:	89 d8                	mov    %ebx,%eax
  800a40:	83 c4 08             	add    $0x8,%esp
  800a43:	5b                   	pop    %ebx
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	56                   	push   %esi
  800a4a:	53                   	push   %ebx
  800a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a51:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a54:	85 f6                	test   %esi,%esi
  800a56:	74 18                	je     800a70 <strncpy+0x2a>
  800a58:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a5d:	0f b6 1a             	movzbl (%edx),%ebx
  800a60:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a63:	80 3a 01             	cmpb   $0x1,(%edx)
  800a66:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a69:	83 c1 01             	add    $0x1,%ecx
  800a6c:	39 ce                	cmp    %ecx,%esi
  800a6e:	77 ed                	ja     800a5d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	56                   	push   %esi
  800a78:	53                   	push   %ebx
  800a79:	8b 75 08             	mov    0x8(%ebp),%esi
  800a7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a82:	89 f0                	mov    %esi,%eax
  800a84:	85 c9                	test   %ecx,%ecx
  800a86:	74 27                	je     800aaf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800a88:	83 e9 01             	sub    $0x1,%ecx
  800a8b:	74 1d                	je     800aaa <strlcpy+0x36>
  800a8d:	0f b6 1a             	movzbl (%edx),%ebx
  800a90:	84 db                	test   %bl,%bl
  800a92:	74 16                	je     800aaa <strlcpy+0x36>
			*dst++ = *src++;
  800a94:	88 18                	mov    %bl,(%eax)
  800a96:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a99:	83 e9 01             	sub    $0x1,%ecx
  800a9c:	74 0e                	je     800aac <strlcpy+0x38>
			*dst++ = *src++;
  800a9e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800aa1:	0f b6 1a             	movzbl (%edx),%ebx
  800aa4:	84 db                	test   %bl,%bl
  800aa6:	75 ec                	jne    800a94 <strlcpy+0x20>
  800aa8:	eb 02                	jmp    800aac <strlcpy+0x38>
  800aaa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800aac:	c6 00 00             	movb   $0x0,(%eax)
  800aaf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800ab1:	5b                   	pop    %ebx
  800ab2:	5e                   	pop    %esi
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800abb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800abe:	0f b6 01             	movzbl (%ecx),%eax
  800ac1:	84 c0                	test   %al,%al
  800ac3:	74 15                	je     800ada <strcmp+0x25>
  800ac5:	3a 02                	cmp    (%edx),%al
  800ac7:	75 11                	jne    800ada <strcmp+0x25>
		p++, q++;
  800ac9:	83 c1 01             	add    $0x1,%ecx
  800acc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800acf:	0f b6 01             	movzbl (%ecx),%eax
  800ad2:	84 c0                	test   %al,%al
  800ad4:	74 04                	je     800ada <strcmp+0x25>
  800ad6:	3a 02                	cmp    (%edx),%al
  800ad8:	74 ef                	je     800ac9 <strcmp+0x14>
  800ada:	0f b6 c0             	movzbl %al,%eax
  800add:	0f b6 12             	movzbl (%edx),%edx
  800ae0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	53                   	push   %ebx
  800ae8:	8b 55 08             	mov    0x8(%ebp),%edx
  800aeb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aee:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800af1:	85 c0                	test   %eax,%eax
  800af3:	74 23                	je     800b18 <strncmp+0x34>
  800af5:	0f b6 1a             	movzbl (%edx),%ebx
  800af8:	84 db                	test   %bl,%bl
  800afa:	74 25                	je     800b21 <strncmp+0x3d>
  800afc:	3a 19                	cmp    (%ecx),%bl
  800afe:	75 21                	jne    800b21 <strncmp+0x3d>
  800b00:	83 e8 01             	sub    $0x1,%eax
  800b03:	74 13                	je     800b18 <strncmp+0x34>
		n--, p++, q++;
  800b05:	83 c2 01             	add    $0x1,%edx
  800b08:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b0b:	0f b6 1a             	movzbl (%edx),%ebx
  800b0e:	84 db                	test   %bl,%bl
  800b10:	74 0f                	je     800b21 <strncmp+0x3d>
  800b12:	3a 19                	cmp    (%ecx),%bl
  800b14:	74 ea                	je     800b00 <strncmp+0x1c>
  800b16:	eb 09                	jmp    800b21 <strncmp+0x3d>
  800b18:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b1d:	5b                   	pop    %ebx
  800b1e:	5d                   	pop    %ebp
  800b1f:	90                   	nop
  800b20:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b21:	0f b6 02             	movzbl (%edx),%eax
  800b24:	0f b6 11             	movzbl (%ecx),%edx
  800b27:	29 d0                	sub    %edx,%eax
  800b29:	eb f2                	jmp    800b1d <strncmp+0x39>

00800b2b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b35:	0f b6 10             	movzbl (%eax),%edx
  800b38:	84 d2                	test   %dl,%dl
  800b3a:	74 18                	je     800b54 <strchr+0x29>
		if (*s == c)
  800b3c:	38 ca                	cmp    %cl,%dl
  800b3e:	75 0a                	jne    800b4a <strchr+0x1f>
  800b40:	eb 17                	jmp    800b59 <strchr+0x2e>
  800b42:	38 ca                	cmp    %cl,%dl
  800b44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b48:	74 0f                	je     800b59 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b4a:	83 c0 01             	add    $0x1,%eax
  800b4d:	0f b6 10             	movzbl (%eax),%edx
  800b50:	84 d2                	test   %dl,%dl
  800b52:	75 ee                	jne    800b42 <strchr+0x17>
  800b54:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b65:	0f b6 10             	movzbl (%eax),%edx
  800b68:	84 d2                	test   %dl,%dl
  800b6a:	74 18                	je     800b84 <strfind+0x29>
		if (*s == c)
  800b6c:	38 ca                	cmp    %cl,%dl
  800b6e:	75 0a                	jne    800b7a <strfind+0x1f>
  800b70:	eb 12                	jmp    800b84 <strfind+0x29>
  800b72:	38 ca                	cmp    %cl,%dl
  800b74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b78:	74 0a                	je     800b84 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b7a:	83 c0 01             	add    $0x1,%eax
  800b7d:	0f b6 10             	movzbl (%eax),%edx
  800b80:	84 d2                	test   %dl,%dl
  800b82:	75 ee                	jne    800b72 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	83 ec 0c             	sub    $0xc,%esp
  800b8c:	89 1c 24             	mov    %ebx,(%esp)
  800b8f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b93:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800b97:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ba0:	85 c9                	test   %ecx,%ecx
  800ba2:	74 30                	je     800bd4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ba4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800baa:	75 25                	jne    800bd1 <memset+0x4b>
  800bac:	f6 c1 03             	test   $0x3,%cl
  800baf:	75 20                	jne    800bd1 <memset+0x4b>
		c &= 0xFF;
  800bb1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bb4:	89 d3                	mov    %edx,%ebx
  800bb6:	c1 e3 08             	shl    $0x8,%ebx
  800bb9:	89 d6                	mov    %edx,%esi
  800bbb:	c1 e6 18             	shl    $0x18,%esi
  800bbe:	89 d0                	mov    %edx,%eax
  800bc0:	c1 e0 10             	shl    $0x10,%eax
  800bc3:	09 f0                	or     %esi,%eax
  800bc5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800bc7:	09 d8                	or     %ebx,%eax
  800bc9:	c1 e9 02             	shr    $0x2,%ecx
  800bcc:	fc                   	cld    
  800bcd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bcf:	eb 03                	jmp    800bd4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bd1:	fc                   	cld    
  800bd2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bd4:	89 f8                	mov    %edi,%eax
  800bd6:	8b 1c 24             	mov    (%esp),%ebx
  800bd9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bdd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800be1:	89 ec                	mov    %ebp,%esp
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	83 ec 08             	sub    $0x8,%esp
  800beb:	89 34 24             	mov    %esi,(%esp)
  800bee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bf2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800bf8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800bfb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800bfd:	39 c6                	cmp    %eax,%esi
  800bff:	73 35                	jae    800c36 <memmove+0x51>
  800c01:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c04:	39 d0                	cmp    %edx,%eax
  800c06:	73 2e                	jae    800c36 <memmove+0x51>
		s += n;
		d += n;
  800c08:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c0a:	f6 c2 03             	test   $0x3,%dl
  800c0d:	75 1b                	jne    800c2a <memmove+0x45>
  800c0f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c15:	75 13                	jne    800c2a <memmove+0x45>
  800c17:	f6 c1 03             	test   $0x3,%cl
  800c1a:	75 0e                	jne    800c2a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800c1c:	83 ef 04             	sub    $0x4,%edi
  800c1f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c22:	c1 e9 02             	shr    $0x2,%ecx
  800c25:	fd                   	std    
  800c26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c28:	eb 09                	jmp    800c33 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c2a:	83 ef 01             	sub    $0x1,%edi
  800c2d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c30:	fd                   	std    
  800c31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c33:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c34:	eb 20                	jmp    800c56 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c36:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c3c:	75 15                	jne    800c53 <memmove+0x6e>
  800c3e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c44:	75 0d                	jne    800c53 <memmove+0x6e>
  800c46:	f6 c1 03             	test   $0x3,%cl
  800c49:	75 08                	jne    800c53 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800c4b:	c1 e9 02             	shr    $0x2,%ecx
  800c4e:	fc                   	cld    
  800c4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c51:	eb 03                	jmp    800c56 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c53:	fc                   	cld    
  800c54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c56:	8b 34 24             	mov    (%esp),%esi
  800c59:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c5d:	89 ec                	mov    %ebp,%esp
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c67:	8b 45 10             	mov    0x10(%ebp),%eax
  800c6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c75:	8b 45 08             	mov    0x8(%ebp),%eax
  800c78:	89 04 24             	mov    %eax,(%esp)
  800c7b:	e8 65 ff ff ff       	call   800be5 <memmove>
}
  800c80:	c9                   	leave  
  800c81:	c3                   	ret    

00800c82 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	8b 75 08             	mov    0x8(%ebp),%esi
  800c8b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c91:	85 c9                	test   %ecx,%ecx
  800c93:	74 36                	je     800ccb <memcmp+0x49>
		if (*s1 != *s2)
  800c95:	0f b6 06             	movzbl (%esi),%eax
  800c98:	0f b6 1f             	movzbl (%edi),%ebx
  800c9b:	38 d8                	cmp    %bl,%al
  800c9d:	74 20                	je     800cbf <memcmp+0x3d>
  800c9f:	eb 14                	jmp    800cb5 <memcmp+0x33>
  800ca1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800ca6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800cab:	83 c2 01             	add    $0x1,%edx
  800cae:	83 e9 01             	sub    $0x1,%ecx
  800cb1:	38 d8                	cmp    %bl,%al
  800cb3:	74 12                	je     800cc7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800cb5:	0f b6 c0             	movzbl %al,%eax
  800cb8:	0f b6 db             	movzbl %bl,%ebx
  800cbb:	29 d8                	sub    %ebx,%eax
  800cbd:	eb 11                	jmp    800cd0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cbf:	83 e9 01             	sub    $0x1,%ecx
  800cc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc7:	85 c9                	test   %ecx,%ecx
  800cc9:	75 d6                	jne    800ca1 <memcmp+0x1f>
  800ccb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cdb:	89 c2                	mov    %eax,%edx
  800cdd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ce0:	39 d0                	cmp    %edx,%eax
  800ce2:	73 15                	jae    800cf9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ce4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ce8:	38 08                	cmp    %cl,(%eax)
  800cea:	75 06                	jne    800cf2 <memfind+0x1d>
  800cec:	eb 0b                	jmp    800cf9 <memfind+0x24>
  800cee:	38 08                	cmp    %cl,(%eax)
  800cf0:	74 07                	je     800cf9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cf2:	83 c0 01             	add    $0x1,%eax
  800cf5:	39 c2                	cmp    %eax,%edx
  800cf7:	77 f5                	ja     800cee <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	83 ec 04             	sub    $0x4,%esp
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d0a:	0f b6 02             	movzbl (%edx),%eax
  800d0d:	3c 20                	cmp    $0x20,%al
  800d0f:	74 04                	je     800d15 <strtol+0x1a>
  800d11:	3c 09                	cmp    $0x9,%al
  800d13:	75 0e                	jne    800d23 <strtol+0x28>
		s++;
  800d15:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d18:	0f b6 02             	movzbl (%edx),%eax
  800d1b:	3c 20                	cmp    $0x20,%al
  800d1d:	74 f6                	je     800d15 <strtol+0x1a>
  800d1f:	3c 09                	cmp    $0x9,%al
  800d21:	74 f2                	je     800d15 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d23:	3c 2b                	cmp    $0x2b,%al
  800d25:	75 0c                	jne    800d33 <strtol+0x38>
		s++;
  800d27:	83 c2 01             	add    $0x1,%edx
  800d2a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d31:	eb 15                	jmp    800d48 <strtol+0x4d>
	else if (*s == '-')
  800d33:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d3a:	3c 2d                	cmp    $0x2d,%al
  800d3c:	75 0a                	jne    800d48 <strtol+0x4d>
		s++, neg = 1;
  800d3e:	83 c2 01             	add    $0x1,%edx
  800d41:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d48:	85 db                	test   %ebx,%ebx
  800d4a:	0f 94 c0             	sete   %al
  800d4d:	74 05                	je     800d54 <strtol+0x59>
  800d4f:	83 fb 10             	cmp    $0x10,%ebx
  800d52:	75 18                	jne    800d6c <strtol+0x71>
  800d54:	80 3a 30             	cmpb   $0x30,(%edx)
  800d57:	75 13                	jne    800d6c <strtol+0x71>
  800d59:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d5d:	8d 76 00             	lea    0x0(%esi),%esi
  800d60:	75 0a                	jne    800d6c <strtol+0x71>
		s += 2, base = 16;
  800d62:	83 c2 02             	add    $0x2,%edx
  800d65:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d6a:	eb 15                	jmp    800d81 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d6c:	84 c0                	test   %al,%al
  800d6e:	66 90                	xchg   %ax,%ax
  800d70:	74 0f                	je     800d81 <strtol+0x86>
  800d72:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d77:	80 3a 30             	cmpb   $0x30,(%edx)
  800d7a:	75 05                	jne    800d81 <strtol+0x86>
		s++, base = 8;
  800d7c:	83 c2 01             	add    $0x1,%edx
  800d7f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d81:	b8 00 00 00 00       	mov    $0x0,%eax
  800d86:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d88:	0f b6 0a             	movzbl (%edx),%ecx
  800d8b:	89 cf                	mov    %ecx,%edi
  800d8d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d90:	80 fb 09             	cmp    $0x9,%bl
  800d93:	77 08                	ja     800d9d <strtol+0xa2>
			dig = *s - '0';
  800d95:	0f be c9             	movsbl %cl,%ecx
  800d98:	83 e9 30             	sub    $0x30,%ecx
  800d9b:	eb 1e                	jmp    800dbb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800d9d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800da0:	80 fb 19             	cmp    $0x19,%bl
  800da3:	77 08                	ja     800dad <strtol+0xb2>
			dig = *s - 'a' + 10;
  800da5:	0f be c9             	movsbl %cl,%ecx
  800da8:	83 e9 57             	sub    $0x57,%ecx
  800dab:	eb 0e                	jmp    800dbb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800dad:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800db0:	80 fb 19             	cmp    $0x19,%bl
  800db3:	77 15                	ja     800dca <strtol+0xcf>
			dig = *s - 'A' + 10;
  800db5:	0f be c9             	movsbl %cl,%ecx
  800db8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800dbb:	39 f1                	cmp    %esi,%ecx
  800dbd:	7d 0b                	jge    800dca <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800dbf:	83 c2 01             	add    $0x1,%edx
  800dc2:	0f af c6             	imul   %esi,%eax
  800dc5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800dc8:	eb be                	jmp    800d88 <strtol+0x8d>
  800dca:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800dcc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dd0:	74 05                	je     800dd7 <strtol+0xdc>
		*endptr = (char *) s;
  800dd2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dd5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800dd7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800ddb:	74 04                	je     800de1 <strtol+0xe6>
  800ddd:	89 c8                	mov    %ecx,%eax
  800ddf:	f7 d8                	neg    %eax
}
  800de1:	83 c4 04             	add    $0x4,%esp
  800de4:	5b                   	pop    %ebx
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    
  800de9:	00 00                	add    %al,(%eax)
  800deb:	00 00                	add    %al,(%eax)
  800ded:	00 00                	add    %al,(%eax)
	...

00800df0 <__udivdi3>:
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	57                   	push   %edi
  800df4:	56                   	push   %esi
  800df5:	83 ec 10             	sub    $0x10,%esp
  800df8:	8b 45 14             	mov    0x14(%ebp),%eax
  800dfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfe:	8b 75 10             	mov    0x10(%ebp),%esi
  800e01:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e04:	85 c0                	test   %eax,%eax
  800e06:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800e09:	75 35                	jne    800e40 <__udivdi3+0x50>
  800e0b:	39 fe                	cmp    %edi,%esi
  800e0d:	77 61                	ja     800e70 <__udivdi3+0x80>
  800e0f:	85 f6                	test   %esi,%esi
  800e11:	75 0b                	jne    800e1e <__udivdi3+0x2e>
  800e13:	b8 01 00 00 00       	mov    $0x1,%eax
  800e18:	31 d2                	xor    %edx,%edx
  800e1a:	f7 f6                	div    %esi
  800e1c:	89 c6                	mov    %eax,%esi
  800e1e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800e21:	31 d2                	xor    %edx,%edx
  800e23:	89 f8                	mov    %edi,%eax
  800e25:	f7 f6                	div    %esi
  800e27:	89 c7                	mov    %eax,%edi
  800e29:	89 c8                	mov    %ecx,%eax
  800e2b:	f7 f6                	div    %esi
  800e2d:	89 c1                	mov    %eax,%ecx
  800e2f:	89 fa                	mov    %edi,%edx
  800e31:	89 c8                	mov    %ecx,%eax
  800e33:	83 c4 10             	add    $0x10,%esp
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    
  800e3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e40:	39 f8                	cmp    %edi,%eax
  800e42:	77 1c                	ja     800e60 <__udivdi3+0x70>
  800e44:	0f bd d0             	bsr    %eax,%edx
  800e47:	83 f2 1f             	xor    $0x1f,%edx
  800e4a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800e4d:	75 39                	jne    800e88 <__udivdi3+0x98>
  800e4f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  800e52:	0f 86 a0 00 00 00    	jbe    800ef8 <__udivdi3+0x108>
  800e58:	39 f8                	cmp    %edi,%eax
  800e5a:	0f 82 98 00 00 00    	jb     800ef8 <__udivdi3+0x108>
  800e60:	31 ff                	xor    %edi,%edi
  800e62:	31 c9                	xor    %ecx,%ecx
  800e64:	89 c8                	mov    %ecx,%eax
  800e66:	89 fa                	mov    %edi,%edx
  800e68:	83 c4 10             	add    $0x10,%esp
  800e6b:	5e                   	pop    %esi
  800e6c:	5f                   	pop    %edi
  800e6d:	5d                   	pop    %ebp
  800e6e:	c3                   	ret    
  800e6f:	90                   	nop
  800e70:	89 d1                	mov    %edx,%ecx
  800e72:	89 fa                	mov    %edi,%edx
  800e74:	89 c8                	mov    %ecx,%eax
  800e76:	31 ff                	xor    %edi,%edi
  800e78:	f7 f6                	div    %esi
  800e7a:	89 c1                	mov    %eax,%ecx
  800e7c:	89 fa                	mov    %edi,%edx
  800e7e:	89 c8                	mov    %ecx,%eax
  800e80:	83 c4 10             	add    $0x10,%esp
  800e83:	5e                   	pop    %esi
  800e84:	5f                   	pop    %edi
  800e85:	5d                   	pop    %ebp
  800e86:	c3                   	ret    
  800e87:	90                   	nop
  800e88:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800e8c:	89 f2                	mov    %esi,%edx
  800e8e:	d3 e0                	shl    %cl,%eax
  800e90:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e93:	b8 20 00 00 00       	mov    $0x20,%eax
  800e98:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800e9b:	89 c1                	mov    %eax,%ecx
  800e9d:	d3 ea                	shr    %cl,%edx
  800e9f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800ea3:	0b 55 ec             	or     -0x14(%ebp),%edx
  800ea6:	d3 e6                	shl    %cl,%esi
  800ea8:	89 c1                	mov    %eax,%ecx
  800eaa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  800ead:	89 fe                	mov    %edi,%esi
  800eaf:	d3 ee                	shr    %cl,%esi
  800eb1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800eb5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800eb8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ebb:	d3 e7                	shl    %cl,%edi
  800ebd:	89 c1                	mov    %eax,%ecx
  800ebf:	d3 ea                	shr    %cl,%edx
  800ec1:	09 d7                	or     %edx,%edi
  800ec3:	89 f2                	mov    %esi,%edx
  800ec5:	89 f8                	mov    %edi,%eax
  800ec7:	f7 75 ec             	divl   -0x14(%ebp)
  800eca:	89 d6                	mov    %edx,%esi
  800ecc:	89 c7                	mov    %eax,%edi
  800ece:	f7 65 e8             	mull   -0x18(%ebp)
  800ed1:	39 d6                	cmp    %edx,%esi
  800ed3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800ed6:	72 30                	jb     800f08 <__udivdi3+0x118>
  800ed8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800edb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800edf:	d3 e2                	shl    %cl,%edx
  800ee1:	39 c2                	cmp    %eax,%edx
  800ee3:	73 05                	jae    800eea <__udivdi3+0xfa>
  800ee5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  800ee8:	74 1e                	je     800f08 <__udivdi3+0x118>
  800eea:	89 f9                	mov    %edi,%ecx
  800eec:	31 ff                	xor    %edi,%edi
  800eee:	e9 71 ff ff ff       	jmp    800e64 <__udivdi3+0x74>
  800ef3:	90                   	nop
  800ef4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ef8:	31 ff                	xor    %edi,%edi
  800efa:	b9 01 00 00 00       	mov    $0x1,%ecx
  800eff:	e9 60 ff ff ff       	jmp    800e64 <__udivdi3+0x74>
  800f04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f08:	8d 4f ff             	lea    -0x1(%edi),%ecx
  800f0b:	31 ff                	xor    %edi,%edi
  800f0d:	89 c8                	mov    %ecx,%eax
  800f0f:	89 fa                	mov    %edi,%edx
  800f11:	83 c4 10             	add    $0x10,%esp
  800f14:	5e                   	pop    %esi
  800f15:	5f                   	pop    %edi
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    
	...

00800f20 <__umoddi3>:
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	57                   	push   %edi
  800f24:	56                   	push   %esi
  800f25:	83 ec 20             	sub    $0x20,%esp
  800f28:	8b 55 14             	mov    0x14(%ebp),%edx
  800f2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f2e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800f31:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f34:	85 d2                	test   %edx,%edx
  800f36:	89 c8                	mov    %ecx,%eax
  800f38:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800f3b:	75 13                	jne    800f50 <__umoddi3+0x30>
  800f3d:	39 f7                	cmp    %esi,%edi
  800f3f:	76 3f                	jbe    800f80 <__umoddi3+0x60>
  800f41:	89 f2                	mov    %esi,%edx
  800f43:	f7 f7                	div    %edi
  800f45:	89 d0                	mov    %edx,%eax
  800f47:	31 d2                	xor    %edx,%edx
  800f49:	83 c4 20             	add    $0x20,%esp
  800f4c:	5e                   	pop    %esi
  800f4d:	5f                   	pop    %edi
  800f4e:	5d                   	pop    %ebp
  800f4f:	c3                   	ret    
  800f50:	39 f2                	cmp    %esi,%edx
  800f52:	77 4c                	ja     800fa0 <__umoddi3+0x80>
  800f54:	0f bd ca             	bsr    %edx,%ecx
  800f57:	83 f1 1f             	xor    $0x1f,%ecx
  800f5a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f5d:	75 51                	jne    800fb0 <__umoddi3+0x90>
  800f5f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  800f62:	0f 87 e0 00 00 00    	ja     801048 <__umoddi3+0x128>
  800f68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f6b:	29 f8                	sub    %edi,%eax
  800f6d:	19 d6                	sbb    %edx,%esi
  800f6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f75:	89 f2                	mov    %esi,%edx
  800f77:	83 c4 20             	add    $0x20,%esp
  800f7a:	5e                   	pop    %esi
  800f7b:	5f                   	pop    %edi
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    
  800f7e:	66 90                	xchg   %ax,%ax
  800f80:	85 ff                	test   %edi,%edi
  800f82:	75 0b                	jne    800f8f <__umoddi3+0x6f>
  800f84:	b8 01 00 00 00       	mov    $0x1,%eax
  800f89:	31 d2                	xor    %edx,%edx
  800f8b:	f7 f7                	div    %edi
  800f8d:	89 c7                	mov    %eax,%edi
  800f8f:	89 f0                	mov    %esi,%eax
  800f91:	31 d2                	xor    %edx,%edx
  800f93:	f7 f7                	div    %edi
  800f95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f98:	f7 f7                	div    %edi
  800f9a:	eb a9                	jmp    800f45 <__umoddi3+0x25>
  800f9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fa0:	89 c8                	mov    %ecx,%eax
  800fa2:	89 f2                	mov    %esi,%edx
  800fa4:	83 c4 20             	add    $0x20,%esp
  800fa7:	5e                   	pop    %esi
  800fa8:	5f                   	pop    %edi
  800fa9:	5d                   	pop    %ebp
  800faa:	c3                   	ret    
  800fab:	90                   	nop
  800fac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fb0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800fb4:	d3 e2                	shl    %cl,%edx
  800fb6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800fb9:	ba 20 00 00 00       	mov    $0x20,%edx
  800fbe:	2b 55 f0             	sub    -0x10(%ebp),%edx
  800fc1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800fc4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800fc8:	89 fa                	mov    %edi,%edx
  800fca:	d3 ea                	shr    %cl,%edx
  800fcc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800fd0:	0b 55 f4             	or     -0xc(%ebp),%edx
  800fd3:	d3 e7                	shl    %cl,%edi
  800fd5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800fd9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800fdc:	89 f2                	mov    %esi,%edx
  800fde:	89 7d e8             	mov    %edi,-0x18(%ebp)
  800fe1:	89 c7                	mov    %eax,%edi
  800fe3:	d3 ea                	shr    %cl,%edx
  800fe5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800fe9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800fec:	89 c2                	mov    %eax,%edx
  800fee:	d3 e6                	shl    %cl,%esi
  800ff0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800ff4:	d3 ea                	shr    %cl,%edx
  800ff6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800ffa:	09 d6                	or     %edx,%esi
  800ffc:	89 f0                	mov    %esi,%eax
  800ffe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801001:	d3 e7                	shl    %cl,%edi
  801003:	89 f2                	mov    %esi,%edx
  801005:	f7 75 f4             	divl   -0xc(%ebp)
  801008:	89 d6                	mov    %edx,%esi
  80100a:	f7 65 e8             	mull   -0x18(%ebp)
  80100d:	39 d6                	cmp    %edx,%esi
  80100f:	72 2b                	jb     80103c <__umoddi3+0x11c>
  801011:	39 c7                	cmp    %eax,%edi
  801013:	72 23                	jb     801038 <__umoddi3+0x118>
  801015:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801019:	29 c7                	sub    %eax,%edi
  80101b:	19 d6                	sbb    %edx,%esi
  80101d:	89 f0                	mov    %esi,%eax
  80101f:	89 f2                	mov    %esi,%edx
  801021:	d3 ef                	shr    %cl,%edi
  801023:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801027:	d3 e0                	shl    %cl,%eax
  801029:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80102d:	09 f8                	or     %edi,%eax
  80102f:	d3 ea                	shr    %cl,%edx
  801031:	83 c4 20             	add    $0x20,%esp
  801034:	5e                   	pop    %esi
  801035:	5f                   	pop    %edi
  801036:	5d                   	pop    %ebp
  801037:	c3                   	ret    
  801038:	39 d6                	cmp    %edx,%esi
  80103a:	75 d9                	jne    801015 <__umoddi3+0xf5>
  80103c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80103f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801042:	eb d1                	jmp    801015 <__umoddi3+0xf5>
  801044:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801048:	39 f2                	cmp    %esi,%edx
  80104a:	0f 82 18 ff ff ff    	jb     800f68 <__umoddi3+0x48>
  801050:	e9 1d ff ff ff       	jmp    800f72 <__umoddi3+0x52>
