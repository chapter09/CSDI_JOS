
obj/user/faultwrite:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0 = 0;
  800037:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003e:	00 00 00 
}
  800041:	5d                   	pop    %ebp
  800042:	c3                   	ret    
	...

00800044 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	83 ec 18             	sub    $0x18,%esp
  80004a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80004d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800050:	8b 75 08             	mov    0x8(%ebp),%esi
  800053:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800056:	e8 cc 00 00 00       	call   800127 <sys_getenvid>
  80005b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800060:	6b c0 64             	imul   $0x64,%eax,%eax
  800063:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800068:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006d:	85 f6                	test   %esi,%esi
  80006f:	7e 07                	jle    800078 <libmain+0x34>
		binaryname = argv[0];
  800071:	8b 03                	mov    (%ebx),%eax
  800073:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800078:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80007c:	89 34 24             	mov    %esi,(%esp)
  80007f:	e8 b0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800084:	e8 0b 00 00 00       	call   800094 <exit>
}
  800089:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80008c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80008f:	89 ec                	mov    %ebp,%esp
  800091:	5d                   	pop    %ebp
  800092:	c3                   	ret    
	...

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a1:	e8 03 01 00 00       	call   8001a9 <sys_env_destroy>
}
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	89 1c 24             	mov    %ebx,(%esp)
  8000b1:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c0:	89 c3                	mov    %eax,%ebx
  8000c2:	89 c7                	mov    %eax,%edi
  8000c4:	51                   	push   %ecx
  8000c5:	52                   	push   %edx
  8000c6:	53                   	push   %ebx
  8000c7:	54                   	push   %esp
  8000c8:	55                   	push   %ebp
  8000c9:	56                   	push   %esi
  8000ca:	57                   	push   %edi
  8000cb:	8d 35 d5 00 80 00    	lea    0x8000d5,%esi
  8000d1:	54                   	push   %esp
  8000d2:	5d                   	pop    %ebp
  8000d3:	0f 34                	sysenter 
  8000d5:	5f                   	pop    %edi
  8000d6:	5e                   	pop    %esi
  8000d7:	5d                   	pop    %ebp
  8000d8:	5c                   	pop    %esp
  8000d9:	5b                   	pop    %ebx
  8000da:	5a                   	pop    %edx
  8000db:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000dc:	8b 1c 24             	mov    (%esp),%ebx
  8000df:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8000e3:	89 ec                	mov    %ebp,%esp
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 08             	sub    $0x8,%esp
  8000ed:	89 1c 24             	mov    %ebx,(%esp)
  8000f0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000fe:	89 d1                	mov    %edx,%ecx
  800100:	89 d3                	mov    %edx,%ebx
  800102:	89 d7                	mov    %edx,%edi
  800104:	51                   	push   %ecx
  800105:	52                   	push   %edx
  800106:	53                   	push   %ebx
  800107:	54                   	push   %esp
  800108:	55                   	push   %ebp
  800109:	56                   	push   %esi
  80010a:	57                   	push   %edi
  80010b:	8d 35 15 01 80 00    	lea    0x800115,%esi
  800111:	54                   	push   %esp
  800112:	5d                   	pop    %ebp
  800113:	0f 34                	sysenter 
  800115:	5f                   	pop    %edi
  800116:	5e                   	pop    %esi
  800117:	5d                   	pop    %ebp
  800118:	5c                   	pop    %esp
  800119:	5b                   	pop    %ebx
  80011a:	5a                   	pop    %edx
  80011b:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80011c:	8b 1c 24             	mov    (%esp),%ebx
  80011f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800123:	89 ec                	mov    %ebp,%esp
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 08             	sub    $0x8,%esp
  80012d:	89 1c 24             	mov    %ebx,(%esp)
  800130:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800134:	ba 00 00 00 00       	mov    $0x0,%edx
  800139:	b8 02 00 00 00       	mov    $0x2,%eax
  80013e:	89 d1                	mov    %edx,%ecx
  800140:	89 d3                	mov    %edx,%ebx
  800142:	89 d7                	mov    %edx,%edi
  800144:	51                   	push   %ecx
  800145:	52                   	push   %edx
  800146:	53                   	push   %ebx
  800147:	54                   	push   %esp
  800148:	55                   	push   %ebp
  800149:	56                   	push   %esi
  80014a:	57                   	push   %edi
  80014b:	8d 35 55 01 80 00    	lea    0x800155,%esi
  800151:	54                   	push   %esp
  800152:	5d                   	pop    %ebp
  800153:	0f 34                	sysenter 
  800155:	5f                   	pop    %edi
  800156:	5e                   	pop    %esi
  800157:	5d                   	pop    %ebp
  800158:	5c                   	pop    %esp
  800159:	5b                   	pop    %ebx
  80015a:	5a                   	pop    %edx
  80015b:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015c:	8b 1c 24             	mov    (%esp),%ebx
  80015f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800163:	89 ec                	mov    %ebp,%esp
  800165:	5d                   	pop    %ebp
  800166:	c3                   	ret    

00800167 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	83 ec 08             	sub    $0x8,%esp
  80016d:	89 1c 24             	mov    %ebx,(%esp)
  800170:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800174:	bb 00 00 00 00       	mov    $0x0,%ebx
  800179:	b8 04 00 00 00       	mov    $0x4,%eax
  80017e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800181:	8b 55 08             	mov    0x8(%ebp),%edx
  800184:	89 df                	mov    %ebx,%edi
  800186:	51                   	push   %ecx
  800187:	52                   	push   %edx
  800188:	53                   	push   %ebx
  800189:	54                   	push   %esp
  80018a:	55                   	push   %ebp
  80018b:	56                   	push   %esi
  80018c:	57                   	push   %edi
  80018d:	8d 35 97 01 80 00    	lea    0x800197,%esi
  800193:	54                   	push   %esp
  800194:	5d                   	pop    %ebp
  800195:	0f 34                	sysenter 
  800197:	5f                   	pop    %edi
  800198:	5e                   	pop    %esi
  800199:	5d                   	pop    %ebp
  80019a:	5c                   	pop    %esp
  80019b:	5b                   	pop    %ebx
  80019c:	5a                   	pop    %edx
  80019d:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80019e:	8b 1c 24             	mov    (%esp),%ebx
  8001a1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8001a5:	89 ec                	mov    %ebp,%esp
  8001a7:	5d                   	pop    %ebp
  8001a8:	c3                   	ret    

008001a9 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	83 ec 28             	sub    $0x28,%esp
  8001af:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8001b2:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ba:	b8 03 00 00 00       	mov    $0x3,%eax
  8001bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c2:	89 cb                	mov    %ecx,%ebx
  8001c4:	89 cf                	mov    %ecx,%edi
  8001c6:	51                   	push   %ecx
  8001c7:	52                   	push   %edx
  8001c8:	53                   	push   %ebx
  8001c9:	54                   	push   %esp
  8001ca:	55                   	push   %ebp
  8001cb:	56                   	push   %esi
  8001cc:	57                   	push   %edi
  8001cd:	8d 35 d7 01 80 00    	lea    0x8001d7,%esi
  8001d3:	54                   	push   %esp
  8001d4:	5d                   	pop    %ebp
  8001d5:	0f 34                	sysenter 
  8001d7:	5f                   	pop    %edi
  8001d8:	5e                   	pop    %esi
  8001d9:	5d                   	pop    %ebp
  8001da:	5c                   	pop    %esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5a                   	pop    %edx
  8001dd:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8001de:	85 c0                	test   %eax,%eax
  8001e0:	7e 28                	jle    80020a <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001e6:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8001ed:	00 
  8001ee:	c7 44 24 08 72 10 80 	movl   $0x801072,0x8(%esp)
  8001f5:	00 
  8001f6:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  8001fd:	00 
  8001fe:	c7 04 24 8f 10 80 00 	movl   $0x80108f,(%esp)
  800205:	e8 0a 00 00 00       	call   800214 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80020a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80020d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800210:	89 ec                	mov    %ebp,%esp
  800212:	5d                   	pop    %ebp
  800213:	c3                   	ret    

00800214 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	56                   	push   %esi
  800218:	53                   	push   %ebx
  800219:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80021c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80021f:	a1 08 20 80 00       	mov    0x802008,%eax
  800224:	85 c0                	test   %eax,%eax
  800226:	74 10                	je     800238 <_panic+0x24>
		cprintf("%s: ", argv0);
  800228:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022c:	c7 04 24 9d 10 80 00 	movl   $0x80109d,(%esp)
  800233:	e8 ad 00 00 00       	call   8002e5 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800238:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80023e:	e8 e4 fe ff ff       	call   800127 <sys_getenvid>
  800243:	8b 55 0c             	mov    0xc(%ebp),%edx
  800246:	89 54 24 10          	mov    %edx,0x10(%esp)
  80024a:	8b 55 08             	mov    0x8(%ebp),%edx
  80024d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800251:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800255:	89 44 24 04          	mov    %eax,0x4(%esp)
  800259:	c7 04 24 a4 10 80 00 	movl   $0x8010a4,(%esp)
  800260:	e8 80 00 00 00       	call   8002e5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800265:	89 74 24 04          	mov    %esi,0x4(%esp)
  800269:	8b 45 10             	mov    0x10(%ebp),%eax
  80026c:	89 04 24             	mov    %eax,(%esp)
  80026f:	e8 10 00 00 00       	call   800284 <vcprintf>
	cprintf("\n");
  800274:	c7 04 24 a2 10 80 00 	movl   $0x8010a2,(%esp)
  80027b:	e8 65 00 00 00       	call   8002e5 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800280:	cc                   	int3   
  800281:	eb fd                	jmp    800280 <_panic+0x6c>
	...

00800284 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80028d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800294:	00 00 00 
	b.cnt = 0;
  800297:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80029e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002af:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b9:	c7 04 24 ff 02 80 00 	movl   $0x8002ff,(%esp)
  8002c0:	e8 d8 01 00 00       	call   80049d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002c5:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cf:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002d5:	89 04 24             	mov    %eax,(%esp)
  8002d8:	e8 cb fd ff ff       	call   8000a8 <sys_cputs>

	return b.cnt;
}
  8002dd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002e3:	c9                   	leave  
  8002e4:	c3                   	ret    

008002e5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8002eb:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8002ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f5:	89 04 24             	mov    %eax,(%esp)
  8002f8:	e8 87 ff ff ff       	call   800284 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002fd:	c9                   	leave  
  8002fe:	c3                   	ret    

008002ff <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	53                   	push   %ebx
  800303:	83 ec 14             	sub    $0x14,%esp
  800306:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800309:	8b 03                	mov    (%ebx),%eax
  80030b:	8b 55 08             	mov    0x8(%ebp),%edx
  80030e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800312:	83 c0 01             	add    $0x1,%eax
  800315:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800317:	3d ff 00 00 00       	cmp    $0xff,%eax
  80031c:	75 19                	jne    800337 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80031e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800325:	00 
  800326:	8d 43 08             	lea    0x8(%ebx),%eax
  800329:	89 04 24             	mov    %eax,(%esp)
  80032c:	e8 77 fd ff ff       	call   8000a8 <sys_cputs>
		b->idx = 0;
  800331:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800337:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80033b:	83 c4 14             	add    $0x14,%esp
  80033e:	5b                   	pop    %ebx
  80033f:	5d                   	pop    %ebp
  800340:	c3                   	ret    
	...

00800350 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	57                   	push   %edi
  800354:	56                   	push   %esi
  800355:	53                   	push   %ebx
  800356:	83 ec 4c             	sub    $0x4c,%esp
  800359:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035c:	89 d6                	mov    %edx,%esi
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800364:	8b 55 0c             	mov    0xc(%ebp),%edx
  800367:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80036a:	8b 45 10             	mov    0x10(%ebp),%eax
  80036d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800370:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800373:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800376:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037b:	39 d1                	cmp    %edx,%ecx
  80037d:	72 15                	jb     800394 <printnum+0x44>
  80037f:	77 07                	ja     800388 <printnum+0x38>
  800381:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800384:	39 d0                	cmp    %edx,%eax
  800386:	76 0c                	jbe    800394 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800388:	83 eb 01             	sub    $0x1,%ebx
  80038b:	85 db                	test   %ebx,%ebx
  80038d:	8d 76 00             	lea    0x0(%esi),%esi
  800390:	7f 61                	jg     8003f3 <printnum+0xa3>
  800392:	eb 70                	jmp    800404 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800394:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800398:	83 eb 01             	sub    $0x1,%ebx
  80039b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80039f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8003a7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8003ab:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8003ae:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8003b1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8003b4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003b8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003bf:	00 
  8003c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003c3:	89 04 24             	mov    %eax,(%esp)
  8003c6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003cd:	e8 2e 0a 00 00       	call   800e00 <__udivdi3>
  8003d2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003d5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8003d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003dc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003e0:	89 04 24             	mov    %eax,(%esp)
  8003e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003e7:	89 f2                	mov    %esi,%edx
  8003e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ec:	e8 5f ff ff ff       	call   800350 <printnum>
  8003f1:	eb 11                	jmp    800404 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003f7:	89 3c 24             	mov    %edi,(%esp)
  8003fa:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003fd:	83 eb 01             	sub    $0x1,%ebx
  800400:	85 db                	test   %ebx,%ebx
  800402:	7f ef                	jg     8003f3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800404:	89 74 24 04          	mov    %esi,0x4(%esp)
  800408:	8b 74 24 04          	mov    0x4(%esp),%esi
  80040c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80040f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800413:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80041a:	00 
  80041b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80041e:	89 14 24             	mov    %edx,(%esp)
  800421:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800424:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800428:	e8 03 0b 00 00       	call   800f30 <__umoddi3>
  80042d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800431:	0f be 80 c7 10 80 00 	movsbl 0x8010c7(%eax),%eax
  800438:	89 04 24             	mov    %eax,(%esp)
  80043b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80043e:	83 c4 4c             	add    $0x4c,%esp
  800441:	5b                   	pop    %ebx
  800442:	5e                   	pop    %esi
  800443:	5f                   	pop    %edi
  800444:	5d                   	pop    %ebp
  800445:	c3                   	ret    

00800446 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800449:	83 fa 01             	cmp    $0x1,%edx
  80044c:	7e 0e                	jle    80045c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80044e:	8b 10                	mov    (%eax),%edx
  800450:	8d 4a 08             	lea    0x8(%edx),%ecx
  800453:	89 08                	mov    %ecx,(%eax)
  800455:	8b 02                	mov    (%edx),%eax
  800457:	8b 52 04             	mov    0x4(%edx),%edx
  80045a:	eb 22                	jmp    80047e <getuint+0x38>
	else if (lflag)
  80045c:	85 d2                	test   %edx,%edx
  80045e:	74 10                	je     800470 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800460:	8b 10                	mov    (%eax),%edx
  800462:	8d 4a 04             	lea    0x4(%edx),%ecx
  800465:	89 08                	mov    %ecx,(%eax)
  800467:	8b 02                	mov    (%edx),%eax
  800469:	ba 00 00 00 00       	mov    $0x0,%edx
  80046e:	eb 0e                	jmp    80047e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800470:	8b 10                	mov    (%eax),%edx
  800472:	8d 4a 04             	lea    0x4(%edx),%ecx
  800475:	89 08                	mov    %ecx,(%eax)
  800477:	8b 02                	mov    (%edx),%eax
  800479:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80047e:	5d                   	pop    %ebp
  80047f:	c3                   	ret    

00800480 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800486:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80048a:	8b 10                	mov    (%eax),%edx
  80048c:	3b 50 04             	cmp    0x4(%eax),%edx
  80048f:	73 0a                	jae    80049b <sprintputch+0x1b>
		*b->buf++ = ch;
  800491:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800494:	88 0a                	mov    %cl,(%edx)
  800496:	83 c2 01             	add    $0x1,%edx
  800499:	89 10                	mov    %edx,(%eax)
}
  80049b:	5d                   	pop    %ebp
  80049c:	c3                   	ret    

0080049d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80049d:	55                   	push   %ebp
  80049e:	89 e5                	mov    %esp,%ebp
  8004a0:	57                   	push   %edi
  8004a1:	56                   	push   %esi
  8004a2:	53                   	push   %ebx
  8004a3:	83 ec 5c             	sub    $0x5c,%esp
  8004a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004a9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004af:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8004b6:	eb 16                	jmp    8004ce <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004b8:	85 c0                	test   %eax,%eax
  8004ba:	0f 84 4f 04 00 00    	je     80090f <vprintfmt+0x472>
				return;
			putch(ch, putdat);
  8004c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004c4:	89 04 24             	mov    %eax,(%esp)
  8004c7:	ff d7                	call   *%edi
  8004c9:	eb 03                	jmp    8004ce <vprintfmt+0x31>
  8004cb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ce:	0f b6 03             	movzbl (%ebx),%eax
  8004d1:	83 c3 01             	add    $0x1,%ebx
  8004d4:	83 f8 25             	cmp    $0x25,%eax
  8004d7:	75 df                	jne    8004b8 <vprintfmt+0x1b>
  8004d9:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  8004dd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004e4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004eb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8004f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004f7:	eb 06                	jmp    8004ff <vprintfmt+0x62>
  8004f9:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  8004fd:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ff:	0f b6 13             	movzbl (%ebx),%edx
  800502:	0f b6 c2             	movzbl %dl,%eax
  800505:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800508:	8d 43 01             	lea    0x1(%ebx),%eax
  80050b:	83 ea 23             	sub    $0x23,%edx
  80050e:	80 fa 55             	cmp    $0x55,%dl
  800511:	0f 87 db 03 00 00    	ja     8008f2 <vprintfmt+0x455>
  800517:	0f b6 d2             	movzbl %dl,%edx
  80051a:	ff 24 95 d0 11 80 00 	jmp    *0x8011d0(,%edx,4)
  800521:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800525:	eb d6                	jmp    8004fd <vprintfmt+0x60>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800527:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80052a:	83 ea 30             	sub    $0x30,%edx
  80052d:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  800530:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800533:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800536:	83 fb 09             	cmp    $0x9,%ebx
  800539:	77 4c                	ja     800587 <vprintfmt+0xea>
  80053b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80053e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800541:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800544:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800547:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  80054b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80054e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800551:	83 fb 09             	cmp    $0x9,%ebx
  800554:	76 eb                	jbe    800541 <vprintfmt+0xa4>
  800556:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800559:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80055c:	eb 29                	jmp    800587 <vprintfmt+0xea>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80055e:	8b 55 14             	mov    0x14(%ebp),%edx
  800561:	8d 5a 04             	lea    0x4(%edx),%ebx
  800564:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800567:	8b 12                	mov    (%edx),%edx
  800569:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  80056c:	eb 19                	jmp    800587 <vprintfmt+0xea>

		case '.':
			if (width < 0)
  80056e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800571:	c1 fa 1f             	sar    $0x1f,%edx
  800574:	f7 d2                	not    %edx
  800576:	21 55 d4             	and    %edx,-0x2c(%ebp)
  800579:	eb 82                	jmp    8004fd <vprintfmt+0x60>
  80057b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800582:	e9 76 ff ff ff       	jmp    8004fd <vprintfmt+0x60>

		process_precision:
			if (width < 0)
  800587:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80058b:	0f 89 6c ff ff ff    	jns    8004fd <vprintfmt+0x60>
  800591:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800594:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800597:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80059a:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80059d:	e9 5b ff ff ff       	jmp    8004fd <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005a2:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8005a5:	e9 53 ff ff ff       	jmp    8004fd <vprintfmt+0x60>
  8005aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8d 50 04             	lea    0x4(%eax),%edx
  8005b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ba:	8b 00                	mov    (%eax),%eax
  8005bc:	89 04 24             	mov    %eax,(%esp)
  8005bf:	ff d7                	call   *%edi
  8005c1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
  8005c4:	e9 05 ff ff ff       	jmp    8004ce <vprintfmt+0x31>
  8005c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 50 04             	lea    0x4(%eax),%edx
  8005d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d5:	8b 00                	mov    (%eax),%eax
  8005d7:	89 c2                	mov    %eax,%edx
  8005d9:	c1 fa 1f             	sar    $0x1f,%edx
  8005dc:	31 d0                	xor    %edx,%eax
  8005de:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005e0:	83 f8 06             	cmp    $0x6,%eax
  8005e3:	7f 0b                	jg     8005f0 <vprintfmt+0x153>
  8005e5:	8b 14 85 28 13 80 00 	mov    0x801328(,%eax,4),%edx
  8005ec:	85 d2                	test   %edx,%edx
  8005ee:	75 20                	jne    800610 <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  8005f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005f4:	c7 44 24 08 d8 10 80 	movl   $0x8010d8,0x8(%esp)
  8005fb:	00 
  8005fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800600:	89 3c 24             	mov    %edi,(%esp)
  800603:	e8 8f 03 00 00       	call   800997 <printfmt>
  800608:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80060b:	e9 be fe ff ff       	jmp    8004ce <vprintfmt+0x31>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800610:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800614:	c7 44 24 08 e1 10 80 	movl   $0x8010e1,0x8(%esp)
  80061b:	00 
  80061c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800620:	89 3c 24             	mov    %edi,(%esp)
  800623:	e8 6f 03 00 00       	call   800997 <printfmt>
  800628:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80062b:	e9 9e fe ff ff       	jmp    8004ce <vprintfmt+0x31>
  800630:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800633:	89 c3                	mov    %eax,%ebx
  800635:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800638:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80063b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8d 50 04             	lea    0x4(%eax),%edx
  800644:	89 55 14             	mov    %edx,0x14(%ebp)
  800647:	8b 00                	mov    (%eax),%eax
  800649:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80064c:	85 c0                	test   %eax,%eax
  80064e:	75 07                	jne    800657 <vprintfmt+0x1ba>
  800650:	c7 45 cc e4 10 80 00 	movl   $0x8010e4,-0x34(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800657:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80065b:	7e 06                	jle    800663 <vprintfmt+0x1c6>
  80065d:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800661:	75 13                	jne    800676 <vprintfmt+0x1d9>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800663:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800666:	0f be 02             	movsbl (%edx),%eax
  800669:	85 c0                	test   %eax,%eax
  80066b:	0f 85 9f 00 00 00    	jne    800710 <vprintfmt+0x273>
  800671:	e9 8f 00 00 00       	jmp    800705 <vprintfmt+0x268>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800676:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80067a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80067d:	89 0c 24             	mov    %ecx,(%esp)
  800680:	e8 56 03 00 00       	call   8009db <strnlen>
  800685:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800688:	29 c2                	sub    %eax,%edx
  80068a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80068d:	85 d2                	test   %edx,%edx
  80068f:	7e d2                	jle    800663 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800691:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800695:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800698:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  80069b:	89 d3                	mov    %edx,%ebx
  80069d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006a4:	89 04 24             	mov    %eax,(%esp)
  8006a7:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a9:	83 eb 01             	sub    $0x1,%ebx
  8006ac:	85 db                	test   %ebx,%ebx
  8006ae:	7f ed                	jg     80069d <vprintfmt+0x200>
  8006b0:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8006b3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8006ba:	eb a7                	jmp    800663 <vprintfmt+0x1c6>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006bc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006c0:	74 1b                	je     8006dd <vprintfmt+0x240>
  8006c2:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006c5:	83 fa 5e             	cmp    $0x5e,%edx
  8006c8:	76 13                	jbe    8006dd <vprintfmt+0x240>
					putch('?', putdat);
  8006ca:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8006cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006d1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006d8:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006db:	eb 0d                	jmp    8006ea <vprintfmt+0x24d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8006dd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006e0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006e4:	89 04 24             	mov    %eax,(%esp)
  8006e7:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ea:	83 ef 01             	sub    $0x1,%edi
  8006ed:	0f be 03             	movsbl (%ebx),%eax
  8006f0:	85 c0                	test   %eax,%eax
  8006f2:	74 05                	je     8006f9 <vprintfmt+0x25c>
  8006f4:	83 c3 01             	add    $0x1,%ebx
  8006f7:	eb 2e                	jmp    800727 <vprintfmt+0x28a>
  8006f9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006fc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006ff:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800702:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800705:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800709:	7f 33                	jg     80073e <vprintfmt+0x2a1>
  80070b:	e9 bb fd ff ff       	jmp    8004cb <vprintfmt+0x2e>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800710:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800713:	83 c2 01             	add    $0x1,%edx
  800716:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800719:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80071c:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80071f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800722:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800725:	89 d3                	mov    %edx,%ebx
  800727:	85 f6                	test   %esi,%esi
  800729:	78 91                	js     8006bc <vprintfmt+0x21f>
  80072b:	83 ee 01             	sub    $0x1,%esi
  80072e:	79 8c                	jns    8006bc <vprintfmt+0x21f>
  800730:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800733:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800736:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800739:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80073c:	eb c7                	jmp    800705 <vprintfmt+0x268>
  80073e:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800741:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800744:	89 74 24 04          	mov    %esi,0x4(%esp)
  800748:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80074f:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800751:	83 eb 01             	sub    $0x1,%ebx
  800754:	85 db                	test   %ebx,%ebx
  800756:	7f ec                	jg     800744 <vprintfmt+0x2a7>
  800758:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80075b:	e9 6e fd ff ff       	jmp    8004ce <vprintfmt+0x31>
  800760:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800763:	83 f9 01             	cmp    $0x1,%ecx
  800766:	7e 16                	jle    80077e <vprintfmt+0x2e1>
		return va_arg(*ap, long long);
  800768:	8b 45 14             	mov    0x14(%ebp),%eax
  80076b:	8d 50 08             	lea    0x8(%eax),%edx
  80076e:	89 55 14             	mov    %edx,0x14(%ebp)
  800771:	8b 10                	mov    (%eax),%edx
  800773:	8b 48 04             	mov    0x4(%eax),%ecx
  800776:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800779:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80077c:	eb 32                	jmp    8007b0 <vprintfmt+0x313>
	else if (lflag)
  80077e:	85 c9                	test   %ecx,%ecx
  800780:	74 18                	je     80079a <vprintfmt+0x2fd>
		return va_arg(*ap, long);
  800782:	8b 45 14             	mov    0x14(%ebp),%eax
  800785:	8d 50 04             	lea    0x4(%eax),%edx
  800788:	89 55 14             	mov    %edx,0x14(%ebp)
  80078b:	8b 00                	mov    (%eax),%eax
  80078d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800790:	89 c1                	mov    %eax,%ecx
  800792:	c1 f9 1f             	sar    $0x1f,%ecx
  800795:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800798:	eb 16                	jmp    8007b0 <vprintfmt+0x313>
	else
		return va_arg(*ap, int);
  80079a:	8b 45 14             	mov    0x14(%ebp),%eax
  80079d:	8d 50 04             	lea    0x4(%eax),%edx
  8007a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a3:	8b 00                	mov    (%eax),%eax
  8007a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a8:	89 c2                	mov    %eax,%edx
  8007aa:	c1 fa 1f             	sar    $0x1f,%edx
  8007ad:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007b6:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  8007bb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007bf:	0f 89 8a 00 00 00    	jns    80084f <vprintfmt+0x3b2>
				putch('-', putdat);
  8007c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007d0:	ff d7                	call   *%edi
				num = -(long long) num;
  8007d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007d5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007d8:	f7 d8                	neg    %eax
  8007da:	83 d2 00             	adc    $0x0,%edx
  8007dd:	f7 da                	neg    %edx
  8007df:	eb 6e                	jmp    80084f <vprintfmt+0x3b2>
  8007e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007e4:	89 ca                	mov    %ecx,%edx
  8007e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e9:	e8 58 fc ff ff       	call   800446 <getuint>
  8007ee:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  8007f3:	eb 5a                	jmp    80084f <vprintfmt+0x3b2>
  8007f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			//break;
			num = getuint(&ap, lflag);
  8007f8:	89 ca                	mov    %ecx,%edx
  8007fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8007fd:	e8 44 fc ff ff       	call   800446 <getuint>
  800802:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800807:	eb 46                	jmp    80084f <vprintfmt+0x3b2>
  800809:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  80080c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800810:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800817:	ff d7                	call   *%edi
			putch('x', putdat);
  800819:	89 74 24 04          	mov    %esi,0x4(%esp)
  80081d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800824:	ff d7                	call   *%edi
			num = (unsigned long long)
  800826:	8b 45 14             	mov    0x14(%ebp),%eax
  800829:	8d 50 04             	lea    0x4(%eax),%edx
  80082c:	89 55 14             	mov    %edx,0x14(%ebp)
  80082f:	8b 00                	mov    (%eax),%eax
  800831:	ba 00 00 00 00       	mov    $0x0,%edx
  800836:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80083b:	eb 12                	jmp    80084f <vprintfmt+0x3b2>
  80083d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800840:	89 ca                	mov    %ecx,%edx
  800842:	8d 45 14             	lea    0x14(%ebp),%eax
  800845:	e8 fc fb ff ff       	call   800446 <getuint>
  80084a:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80084f:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800853:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800857:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80085a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80085e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800862:	89 04 24             	mov    %eax,(%esp)
  800865:	89 54 24 04          	mov    %edx,0x4(%esp)
  800869:	89 f2                	mov    %esi,%edx
  80086b:	89 f8                	mov    %edi,%eax
  80086d:	e8 de fa ff ff       	call   800350 <printnum>
  800872:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
  800875:	e9 54 fc ff ff       	jmp    8004ce <vprintfmt+0x31>
  80087a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			char* tmp = va_arg(ap, char*);
  80087d:	8b 45 14             	mov    0x14(%ebp),%eax
  800880:	8d 50 04             	lea    0x4(%eax),%edx
  800883:	89 55 14             	mov    %edx,0x14(%ebp)
  800886:	8b 00                	mov    (%eax),%eax
			if(tmp == NULL) {
  800888:	85 c0                	test   %eax,%eax
  80088a:	75 1f                	jne    8008ab <vprintfmt+0x40e>
  80088c:	bb 55 11 80 00       	mov    $0x801155,%ebx
  800891:	b0 0a                	mov    $0xa,%al
				for(; (ch = *null_error++) != '\0';) {	
					putch(ch, putdat);
  800893:	89 74 24 04          	mov    %esi,0x4(%esp)
  800897:	89 04 24             	mov    %eax,(%esp)
  80089a:	ff d7                	call   *%edi
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			char* tmp = va_arg(ap, char*);
			if(tmp == NULL) {
				for(; (ch = *null_error++) != '\0';) {	
  80089c:	0f be 03             	movsbl (%ebx),%eax
  80089f:	83 c3 01             	add    $0x1,%ebx
  8008a2:	85 c0                	test   %eax,%eax
  8008a4:	75 ed                	jne    800893 <vprintfmt+0x3f6>
  8008a6:	e9 20 fc ff ff       	jmp    8004cb <vprintfmt+0x2e>
					putch(ch, putdat);
				}
				break;
			}
			*tmp = *((signed char*) putdat);
  8008ab:	0f b6 16             	movzbl (%esi),%edx
  8008ae:	88 10                	mov    %dl,(%eax)
			if(*(signed char*) putdat < 0) {
  8008b0:	80 3e 00             	cmpb   $0x0,(%esi)
  8008b3:	0f 89 12 fc ff ff    	jns    8004cb <vprintfmt+0x2e>
  8008b9:	bb 8d 11 80 00       	mov    $0x80118d,%ebx
  8008be:	b8 0a 00 00 00       	mov    $0xa,%eax
				for(; (ch = *overflow_error++) != '\0';) {	
					putch(ch, putdat);
  8008c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008c7:	89 04 24             	mov    %eax,(%esp)
  8008ca:	ff d7                	call   *%edi
				}
				break;
			}
			*tmp = *((signed char*) putdat);
			if(*(signed char*) putdat < 0) {
				for(; (ch = *overflow_error++) != '\0';) {	
  8008cc:	0f be 03             	movsbl (%ebx),%eax
  8008cf:	83 c3 01             	add    $0x1,%ebx
  8008d2:	85 c0                	test   %eax,%eax
  8008d4:	75 ed                	jne    8008c3 <vprintfmt+0x426>
  8008d6:	e9 f0 fb ff ff       	jmp    8004cb <vprintfmt+0x2e>
  8008db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008e5:	89 14 24             	mov    %edx,(%esp)
  8008e8:	ff d7                	call   *%edi
  8008ea:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
  8008ed:	e9 dc fb ff ff       	jmp    8004ce <vprintfmt+0x31>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008f6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008fd:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ff:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800902:	80 38 25             	cmpb   $0x25,(%eax)
  800905:	0f 84 c3 fb ff ff    	je     8004ce <vprintfmt+0x31>
  80090b:	89 c3                	mov    %eax,%ebx
  80090d:	eb f0                	jmp    8008ff <vprintfmt+0x462>
				/* do nothing */;
			break;
		}
	}
}
  80090f:	83 c4 5c             	add    $0x5c,%esp
  800912:	5b                   	pop    %ebx
  800913:	5e                   	pop    %esi
  800914:	5f                   	pop    %edi
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	83 ec 28             	sub    $0x28,%esp
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800923:	85 c0                	test   %eax,%eax
  800925:	74 04                	je     80092b <vsnprintf+0x14>
  800927:	85 d2                	test   %edx,%edx
  800929:	7f 07                	jg     800932 <vsnprintf+0x1b>
  80092b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800930:	eb 3b                	jmp    80096d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800932:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800935:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800939:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80093c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800943:	8b 45 14             	mov    0x14(%ebp),%eax
  800946:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80094a:	8b 45 10             	mov    0x10(%ebp),%eax
  80094d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800951:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800954:	89 44 24 04          	mov    %eax,0x4(%esp)
  800958:	c7 04 24 80 04 80 00 	movl   $0x800480,(%esp)
  80095f:	e8 39 fb ff ff       	call   80049d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800964:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800967:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80096a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800975:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800978:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80097c:	8b 45 10             	mov    0x10(%ebp),%eax
  80097f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800983:	8b 45 0c             	mov    0xc(%ebp),%eax
  800986:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	89 04 24             	mov    %eax,(%esp)
  800990:	e8 82 ff ff ff       	call   800917 <vsnprintf>
	va_end(ap);

	return rc;
}
  800995:	c9                   	leave  
  800996:	c3                   	ret    

00800997 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  80099d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8009a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b5:	89 04 24             	mov    %eax,(%esp)
  8009b8:	e8 e0 fa ff ff       	call   80049d <vprintfmt>
	va_end(ap);
}
  8009bd:	c9                   	leave  
  8009be:	c3                   	ret    
	...

008009c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cb:	80 3a 00             	cmpb   $0x0,(%edx)
  8009ce:	74 09                	je     8009d9 <strlen+0x19>
		n++;
  8009d0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009d7:	75 f7                	jne    8009d0 <strlen+0x10>
		n++;
	return n;
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	53                   	push   %ebx
  8009df:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e5:	85 c9                	test   %ecx,%ecx
  8009e7:	74 19                	je     800a02 <strnlen+0x27>
  8009e9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009ec:	74 14                	je     800a02 <strnlen+0x27>
  8009ee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009f3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009f6:	39 c8                	cmp    %ecx,%eax
  8009f8:	74 0d                	je     800a07 <strnlen+0x2c>
  8009fa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8009fe:	75 f3                	jne    8009f3 <strnlen+0x18>
  800a00:	eb 05                	jmp    800a07 <strnlen+0x2c>
  800a02:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a07:	5b                   	pop    %ebx
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	53                   	push   %ebx
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a14:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a19:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a1d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a20:	83 c2 01             	add    $0x1,%edx
  800a23:	84 c9                	test   %cl,%cl
  800a25:	75 f2                	jne    800a19 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a27:	5b                   	pop    %ebx
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	53                   	push   %ebx
  800a2e:	83 ec 08             	sub    $0x8,%esp
  800a31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a34:	89 1c 24             	mov    %ebx,(%esp)
  800a37:	e8 84 ff ff ff       	call   8009c0 <strlen>
	strcpy(dst + len, src);
  800a3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a43:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800a46:	89 04 24             	mov    %eax,(%esp)
  800a49:	e8 bc ff ff ff       	call   800a0a <strcpy>
	return dst;
}
  800a4e:	89 d8                	mov    %ebx,%eax
  800a50:	83 c4 08             	add    $0x8,%esp
  800a53:	5b                   	pop    %ebx
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	56                   	push   %esi
  800a5a:	53                   	push   %ebx
  800a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a61:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a64:	85 f6                	test   %esi,%esi
  800a66:	74 18                	je     800a80 <strncpy+0x2a>
  800a68:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a6d:	0f b6 1a             	movzbl (%edx),%ebx
  800a70:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a73:	80 3a 01             	cmpb   $0x1,(%edx)
  800a76:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a79:	83 c1 01             	add    $0x1,%ecx
  800a7c:	39 ce                	cmp    %ecx,%esi
  800a7e:	77 ed                	ja     800a6d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
  800a89:	8b 75 08             	mov    0x8(%ebp),%esi
  800a8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a92:	89 f0                	mov    %esi,%eax
  800a94:	85 c9                	test   %ecx,%ecx
  800a96:	74 27                	je     800abf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800a98:	83 e9 01             	sub    $0x1,%ecx
  800a9b:	74 1d                	je     800aba <strlcpy+0x36>
  800a9d:	0f b6 1a             	movzbl (%edx),%ebx
  800aa0:	84 db                	test   %bl,%bl
  800aa2:	74 16                	je     800aba <strlcpy+0x36>
			*dst++ = *src++;
  800aa4:	88 18                	mov    %bl,(%eax)
  800aa6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800aa9:	83 e9 01             	sub    $0x1,%ecx
  800aac:	74 0e                	je     800abc <strlcpy+0x38>
			*dst++ = *src++;
  800aae:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ab1:	0f b6 1a             	movzbl (%edx),%ebx
  800ab4:	84 db                	test   %bl,%bl
  800ab6:	75 ec                	jne    800aa4 <strlcpy+0x20>
  800ab8:	eb 02                	jmp    800abc <strlcpy+0x38>
  800aba:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800abc:	c6 00 00             	movb   $0x0,(%eax)
  800abf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800ac1:	5b                   	pop    %ebx
  800ac2:	5e                   	pop    %esi
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800acb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ace:	0f b6 01             	movzbl (%ecx),%eax
  800ad1:	84 c0                	test   %al,%al
  800ad3:	74 15                	je     800aea <strcmp+0x25>
  800ad5:	3a 02                	cmp    (%edx),%al
  800ad7:	75 11                	jne    800aea <strcmp+0x25>
		p++, q++;
  800ad9:	83 c1 01             	add    $0x1,%ecx
  800adc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800adf:	0f b6 01             	movzbl (%ecx),%eax
  800ae2:	84 c0                	test   %al,%al
  800ae4:	74 04                	je     800aea <strcmp+0x25>
  800ae6:	3a 02                	cmp    (%edx),%al
  800ae8:	74 ef                	je     800ad9 <strcmp+0x14>
  800aea:	0f b6 c0             	movzbl %al,%eax
  800aed:	0f b6 12             	movzbl (%edx),%edx
  800af0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	53                   	push   %ebx
  800af8:	8b 55 08             	mov    0x8(%ebp),%edx
  800afb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800b01:	85 c0                	test   %eax,%eax
  800b03:	74 23                	je     800b28 <strncmp+0x34>
  800b05:	0f b6 1a             	movzbl (%edx),%ebx
  800b08:	84 db                	test   %bl,%bl
  800b0a:	74 25                	je     800b31 <strncmp+0x3d>
  800b0c:	3a 19                	cmp    (%ecx),%bl
  800b0e:	75 21                	jne    800b31 <strncmp+0x3d>
  800b10:	83 e8 01             	sub    $0x1,%eax
  800b13:	74 13                	je     800b28 <strncmp+0x34>
		n--, p++, q++;
  800b15:	83 c2 01             	add    $0x1,%edx
  800b18:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b1b:	0f b6 1a             	movzbl (%edx),%ebx
  800b1e:	84 db                	test   %bl,%bl
  800b20:	74 0f                	je     800b31 <strncmp+0x3d>
  800b22:	3a 19                	cmp    (%ecx),%bl
  800b24:	74 ea                	je     800b10 <strncmp+0x1c>
  800b26:	eb 09                	jmp    800b31 <strncmp+0x3d>
  800b28:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b2d:	5b                   	pop    %ebx
  800b2e:	5d                   	pop    %ebp
  800b2f:	90                   	nop
  800b30:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b31:	0f b6 02             	movzbl (%edx),%eax
  800b34:	0f b6 11             	movzbl (%ecx),%edx
  800b37:	29 d0                	sub    %edx,%eax
  800b39:	eb f2                	jmp    800b2d <strncmp+0x39>

00800b3b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b45:	0f b6 10             	movzbl (%eax),%edx
  800b48:	84 d2                	test   %dl,%dl
  800b4a:	74 18                	je     800b64 <strchr+0x29>
		if (*s == c)
  800b4c:	38 ca                	cmp    %cl,%dl
  800b4e:	75 0a                	jne    800b5a <strchr+0x1f>
  800b50:	eb 17                	jmp    800b69 <strchr+0x2e>
  800b52:	38 ca                	cmp    %cl,%dl
  800b54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b58:	74 0f                	je     800b69 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b5a:	83 c0 01             	add    $0x1,%eax
  800b5d:	0f b6 10             	movzbl (%eax),%edx
  800b60:	84 d2                	test   %dl,%dl
  800b62:	75 ee                	jne    800b52 <strchr+0x17>
  800b64:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b75:	0f b6 10             	movzbl (%eax),%edx
  800b78:	84 d2                	test   %dl,%dl
  800b7a:	74 18                	je     800b94 <strfind+0x29>
		if (*s == c)
  800b7c:	38 ca                	cmp    %cl,%dl
  800b7e:	75 0a                	jne    800b8a <strfind+0x1f>
  800b80:	eb 12                	jmp    800b94 <strfind+0x29>
  800b82:	38 ca                	cmp    %cl,%dl
  800b84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b88:	74 0a                	je     800b94 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b8a:	83 c0 01             	add    $0x1,%eax
  800b8d:	0f b6 10             	movzbl (%eax),%edx
  800b90:	84 d2                	test   %dl,%dl
  800b92:	75 ee                	jne    800b82 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	83 ec 0c             	sub    $0xc,%esp
  800b9c:	89 1c 24             	mov    %ebx,(%esp)
  800b9f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ba3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ba7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800baa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bb0:	85 c9                	test   %ecx,%ecx
  800bb2:	74 30                	je     800be4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bb4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bba:	75 25                	jne    800be1 <memset+0x4b>
  800bbc:	f6 c1 03             	test   $0x3,%cl
  800bbf:	75 20                	jne    800be1 <memset+0x4b>
		c &= 0xFF;
  800bc1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bc4:	89 d3                	mov    %edx,%ebx
  800bc6:	c1 e3 08             	shl    $0x8,%ebx
  800bc9:	89 d6                	mov    %edx,%esi
  800bcb:	c1 e6 18             	shl    $0x18,%esi
  800bce:	89 d0                	mov    %edx,%eax
  800bd0:	c1 e0 10             	shl    $0x10,%eax
  800bd3:	09 f0                	or     %esi,%eax
  800bd5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800bd7:	09 d8                	or     %ebx,%eax
  800bd9:	c1 e9 02             	shr    $0x2,%ecx
  800bdc:	fc                   	cld    
  800bdd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bdf:	eb 03                	jmp    800be4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800be1:	fc                   	cld    
  800be2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800be4:	89 f8                	mov    %edi,%eax
  800be6:	8b 1c 24             	mov    (%esp),%ebx
  800be9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bed:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800bf1:	89 ec                	mov    %ebp,%esp
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	83 ec 08             	sub    $0x8,%esp
  800bfb:	89 34 24             	mov    %esi,(%esp)
  800bfe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c02:	8b 45 08             	mov    0x8(%ebp),%eax
  800c05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800c08:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800c0b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800c0d:	39 c6                	cmp    %eax,%esi
  800c0f:	73 35                	jae    800c46 <memmove+0x51>
  800c11:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c14:	39 d0                	cmp    %edx,%eax
  800c16:	73 2e                	jae    800c46 <memmove+0x51>
		s += n;
		d += n;
  800c18:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c1a:	f6 c2 03             	test   $0x3,%dl
  800c1d:	75 1b                	jne    800c3a <memmove+0x45>
  800c1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c25:	75 13                	jne    800c3a <memmove+0x45>
  800c27:	f6 c1 03             	test   $0x3,%cl
  800c2a:	75 0e                	jne    800c3a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800c2c:	83 ef 04             	sub    $0x4,%edi
  800c2f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c32:	c1 e9 02             	shr    $0x2,%ecx
  800c35:	fd                   	std    
  800c36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c38:	eb 09                	jmp    800c43 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c3a:	83 ef 01             	sub    $0x1,%edi
  800c3d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c40:	fd                   	std    
  800c41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c43:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c44:	eb 20                	jmp    800c66 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c4c:	75 15                	jne    800c63 <memmove+0x6e>
  800c4e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c54:	75 0d                	jne    800c63 <memmove+0x6e>
  800c56:	f6 c1 03             	test   $0x3,%cl
  800c59:	75 08                	jne    800c63 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800c5b:	c1 e9 02             	shr    $0x2,%ecx
  800c5e:	fc                   	cld    
  800c5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c61:	eb 03                	jmp    800c66 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c63:	fc                   	cld    
  800c64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c66:	8b 34 24             	mov    (%esp),%esi
  800c69:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c6d:	89 ec                	mov    %ebp,%esp
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c77:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c85:	8b 45 08             	mov    0x8(%ebp),%eax
  800c88:	89 04 24             	mov    %eax,(%esp)
  800c8b:	e8 65 ff ff ff       	call   800bf5 <memmove>
}
  800c90:	c9                   	leave  
  800c91:	c3                   	ret    

00800c92 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	57                   	push   %edi
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
  800c98:	8b 75 08             	mov    0x8(%ebp),%esi
  800c9b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ca1:	85 c9                	test   %ecx,%ecx
  800ca3:	74 36                	je     800cdb <memcmp+0x49>
		if (*s1 != *s2)
  800ca5:	0f b6 06             	movzbl (%esi),%eax
  800ca8:	0f b6 1f             	movzbl (%edi),%ebx
  800cab:	38 d8                	cmp    %bl,%al
  800cad:	74 20                	je     800ccf <memcmp+0x3d>
  800caf:	eb 14                	jmp    800cc5 <memcmp+0x33>
  800cb1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800cb6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800cbb:	83 c2 01             	add    $0x1,%edx
  800cbe:	83 e9 01             	sub    $0x1,%ecx
  800cc1:	38 d8                	cmp    %bl,%al
  800cc3:	74 12                	je     800cd7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800cc5:	0f b6 c0             	movzbl %al,%eax
  800cc8:	0f b6 db             	movzbl %bl,%ebx
  800ccb:	29 d8                	sub    %ebx,%eax
  800ccd:	eb 11                	jmp    800ce0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ccf:	83 e9 01             	sub    $0x1,%ecx
  800cd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd7:	85 c9                	test   %ecx,%ecx
  800cd9:	75 d6                	jne    800cb1 <memcmp+0x1f>
  800cdb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ceb:	89 c2                	mov    %eax,%edx
  800ced:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cf0:	39 d0                	cmp    %edx,%eax
  800cf2:	73 15                	jae    800d09 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800cf8:	38 08                	cmp    %cl,(%eax)
  800cfa:	75 06                	jne    800d02 <memfind+0x1d>
  800cfc:	eb 0b                	jmp    800d09 <memfind+0x24>
  800cfe:	38 08                	cmp    %cl,(%eax)
  800d00:	74 07                	je     800d09 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d02:	83 c0 01             	add    $0x1,%eax
  800d05:	39 c2                	cmp    %eax,%edx
  800d07:	77 f5                	ja     800cfe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	83 ec 04             	sub    $0x4,%esp
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d1a:	0f b6 02             	movzbl (%edx),%eax
  800d1d:	3c 20                	cmp    $0x20,%al
  800d1f:	74 04                	je     800d25 <strtol+0x1a>
  800d21:	3c 09                	cmp    $0x9,%al
  800d23:	75 0e                	jne    800d33 <strtol+0x28>
		s++;
  800d25:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d28:	0f b6 02             	movzbl (%edx),%eax
  800d2b:	3c 20                	cmp    $0x20,%al
  800d2d:	74 f6                	je     800d25 <strtol+0x1a>
  800d2f:	3c 09                	cmp    $0x9,%al
  800d31:	74 f2                	je     800d25 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d33:	3c 2b                	cmp    $0x2b,%al
  800d35:	75 0c                	jne    800d43 <strtol+0x38>
		s++;
  800d37:	83 c2 01             	add    $0x1,%edx
  800d3a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d41:	eb 15                	jmp    800d58 <strtol+0x4d>
	else if (*s == '-')
  800d43:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d4a:	3c 2d                	cmp    $0x2d,%al
  800d4c:	75 0a                	jne    800d58 <strtol+0x4d>
		s++, neg = 1;
  800d4e:	83 c2 01             	add    $0x1,%edx
  800d51:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d58:	85 db                	test   %ebx,%ebx
  800d5a:	0f 94 c0             	sete   %al
  800d5d:	74 05                	je     800d64 <strtol+0x59>
  800d5f:	83 fb 10             	cmp    $0x10,%ebx
  800d62:	75 18                	jne    800d7c <strtol+0x71>
  800d64:	80 3a 30             	cmpb   $0x30,(%edx)
  800d67:	75 13                	jne    800d7c <strtol+0x71>
  800d69:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d6d:	8d 76 00             	lea    0x0(%esi),%esi
  800d70:	75 0a                	jne    800d7c <strtol+0x71>
		s += 2, base = 16;
  800d72:	83 c2 02             	add    $0x2,%edx
  800d75:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d7a:	eb 15                	jmp    800d91 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d7c:	84 c0                	test   %al,%al
  800d7e:	66 90                	xchg   %ax,%ax
  800d80:	74 0f                	je     800d91 <strtol+0x86>
  800d82:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d87:	80 3a 30             	cmpb   $0x30,(%edx)
  800d8a:	75 05                	jne    800d91 <strtol+0x86>
		s++, base = 8;
  800d8c:	83 c2 01             	add    $0x1,%edx
  800d8f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d91:	b8 00 00 00 00       	mov    $0x0,%eax
  800d96:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d98:	0f b6 0a             	movzbl (%edx),%ecx
  800d9b:	89 cf                	mov    %ecx,%edi
  800d9d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800da0:	80 fb 09             	cmp    $0x9,%bl
  800da3:	77 08                	ja     800dad <strtol+0xa2>
			dig = *s - '0';
  800da5:	0f be c9             	movsbl %cl,%ecx
  800da8:	83 e9 30             	sub    $0x30,%ecx
  800dab:	eb 1e                	jmp    800dcb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800dad:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800db0:	80 fb 19             	cmp    $0x19,%bl
  800db3:	77 08                	ja     800dbd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800db5:	0f be c9             	movsbl %cl,%ecx
  800db8:	83 e9 57             	sub    $0x57,%ecx
  800dbb:	eb 0e                	jmp    800dcb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800dbd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800dc0:	80 fb 19             	cmp    $0x19,%bl
  800dc3:	77 15                	ja     800dda <strtol+0xcf>
			dig = *s - 'A' + 10;
  800dc5:	0f be c9             	movsbl %cl,%ecx
  800dc8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800dcb:	39 f1                	cmp    %esi,%ecx
  800dcd:	7d 0b                	jge    800dda <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800dcf:	83 c2 01             	add    $0x1,%edx
  800dd2:	0f af c6             	imul   %esi,%eax
  800dd5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800dd8:	eb be                	jmp    800d98 <strtol+0x8d>
  800dda:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800ddc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800de0:	74 05                	je     800de7 <strtol+0xdc>
		*endptr = (char *) s;
  800de2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800de5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800de7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800deb:	74 04                	je     800df1 <strtol+0xe6>
  800ded:	89 c8                	mov    %ecx,%eax
  800def:	f7 d8                	neg    %eax
}
  800df1:	83 c4 04             	add    $0x4,%esp
  800df4:	5b                   	pop    %ebx
  800df5:	5e                   	pop    %esi
  800df6:	5f                   	pop    %edi
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    
  800df9:	00 00                	add    %al,(%eax)
  800dfb:	00 00                	add    %al,(%eax)
  800dfd:	00 00                	add    %al,(%eax)
	...

00800e00 <__udivdi3>:
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	83 ec 10             	sub    $0x10,%esp
  800e08:	8b 45 14             	mov    0x14(%ebp),%eax
  800e0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0e:	8b 75 10             	mov    0x10(%ebp),%esi
  800e11:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e14:	85 c0                	test   %eax,%eax
  800e16:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800e19:	75 35                	jne    800e50 <__udivdi3+0x50>
  800e1b:	39 fe                	cmp    %edi,%esi
  800e1d:	77 61                	ja     800e80 <__udivdi3+0x80>
  800e1f:	85 f6                	test   %esi,%esi
  800e21:	75 0b                	jne    800e2e <__udivdi3+0x2e>
  800e23:	b8 01 00 00 00       	mov    $0x1,%eax
  800e28:	31 d2                	xor    %edx,%edx
  800e2a:	f7 f6                	div    %esi
  800e2c:	89 c6                	mov    %eax,%esi
  800e2e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800e31:	31 d2                	xor    %edx,%edx
  800e33:	89 f8                	mov    %edi,%eax
  800e35:	f7 f6                	div    %esi
  800e37:	89 c7                	mov    %eax,%edi
  800e39:	89 c8                	mov    %ecx,%eax
  800e3b:	f7 f6                	div    %esi
  800e3d:	89 c1                	mov    %eax,%ecx
  800e3f:	89 fa                	mov    %edi,%edx
  800e41:	89 c8                	mov    %ecx,%eax
  800e43:	83 c4 10             	add    $0x10,%esp
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    
  800e4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e50:	39 f8                	cmp    %edi,%eax
  800e52:	77 1c                	ja     800e70 <__udivdi3+0x70>
  800e54:	0f bd d0             	bsr    %eax,%edx
  800e57:	83 f2 1f             	xor    $0x1f,%edx
  800e5a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800e5d:	75 39                	jne    800e98 <__udivdi3+0x98>
  800e5f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  800e62:	0f 86 a0 00 00 00    	jbe    800f08 <__udivdi3+0x108>
  800e68:	39 f8                	cmp    %edi,%eax
  800e6a:	0f 82 98 00 00 00    	jb     800f08 <__udivdi3+0x108>
  800e70:	31 ff                	xor    %edi,%edi
  800e72:	31 c9                	xor    %ecx,%ecx
  800e74:	89 c8                	mov    %ecx,%eax
  800e76:	89 fa                	mov    %edi,%edx
  800e78:	83 c4 10             	add    $0x10,%esp
  800e7b:	5e                   	pop    %esi
  800e7c:	5f                   	pop    %edi
  800e7d:	5d                   	pop    %ebp
  800e7e:	c3                   	ret    
  800e7f:	90                   	nop
  800e80:	89 d1                	mov    %edx,%ecx
  800e82:	89 fa                	mov    %edi,%edx
  800e84:	89 c8                	mov    %ecx,%eax
  800e86:	31 ff                	xor    %edi,%edi
  800e88:	f7 f6                	div    %esi
  800e8a:	89 c1                	mov    %eax,%ecx
  800e8c:	89 fa                	mov    %edi,%edx
  800e8e:	89 c8                	mov    %ecx,%eax
  800e90:	83 c4 10             	add    $0x10,%esp
  800e93:	5e                   	pop    %esi
  800e94:	5f                   	pop    %edi
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    
  800e97:	90                   	nop
  800e98:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800e9c:	89 f2                	mov    %esi,%edx
  800e9e:	d3 e0                	shl    %cl,%eax
  800ea0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ea3:	b8 20 00 00 00       	mov    $0x20,%eax
  800ea8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800eab:	89 c1                	mov    %eax,%ecx
  800ead:	d3 ea                	shr    %cl,%edx
  800eaf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800eb3:	0b 55 ec             	or     -0x14(%ebp),%edx
  800eb6:	d3 e6                	shl    %cl,%esi
  800eb8:	89 c1                	mov    %eax,%ecx
  800eba:	89 75 e8             	mov    %esi,-0x18(%ebp)
  800ebd:	89 fe                	mov    %edi,%esi
  800ebf:	d3 ee                	shr    %cl,%esi
  800ec1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800ec5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800ec8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ecb:	d3 e7                	shl    %cl,%edi
  800ecd:	89 c1                	mov    %eax,%ecx
  800ecf:	d3 ea                	shr    %cl,%edx
  800ed1:	09 d7                	or     %edx,%edi
  800ed3:	89 f2                	mov    %esi,%edx
  800ed5:	89 f8                	mov    %edi,%eax
  800ed7:	f7 75 ec             	divl   -0x14(%ebp)
  800eda:	89 d6                	mov    %edx,%esi
  800edc:	89 c7                	mov    %eax,%edi
  800ede:	f7 65 e8             	mull   -0x18(%ebp)
  800ee1:	39 d6                	cmp    %edx,%esi
  800ee3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800ee6:	72 30                	jb     800f18 <__udivdi3+0x118>
  800ee8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800eeb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800eef:	d3 e2                	shl    %cl,%edx
  800ef1:	39 c2                	cmp    %eax,%edx
  800ef3:	73 05                	jae    800efa <__udivdi3+0xfa>
  800ef5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  800ef8:	74 1e                	je     800f18 <__udivdi3+0x118>
  800efa:	89 f9                	mov    %edi,%ecx
  800efc:	31 ff                	xor    %edi,%edi
  800efe:	e9 71 ff ff ff       	jmp    800e74 <__udivdi3+0x74>
  800f03:	90                   	nop
  800f04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f08:	31 ff                	xor    %edi,%edi
  800f0a:	b9 01 00 00 00       	mov    $0x1,%ecx
  800f0f:	e9 60 ff ff ff       	jmp    800e74 <__udivdi3+0x74>
  800f14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f18:	8d 4f ff             	lea    -0x1(%edi),%ecx
  800f1b:	31 ff                	xor    %edi,%edi
  800f1d:	89 c8                	mov    %ecx,%eax
  800f1f:	89 fa                	mov    %edi,%edx
  800f21:	83 c4 10             	add    $0x10,%esp
  800f24:	5e                   	pop    %esi
  800f25:	5f                   	pop    %edi
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    
	...

00800f30 <__umoddi3>:
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	57                   	push   %edi
  800f34:	56                   	push   %esi
  800f35:	83 ec 20             	sub    $0x20,%esp
  800f38:	8b 55 14             	mov    0x14(%ebp),%edx
  800f3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f3e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800f41:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f44:	85 d2                	test   %edx,%edx
  800f46:	89 c8                	mov    %ecx,%eax
  800f48:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800f4b:	75 13                	jne    800f60 <__umoddi3+0x30>
  800f4d:	39 f7                	cmp    %esi,%edi
  800f4f:	76 3f                	jbe    800f90 <__umoddi3+0x60>
  800f51:	89 f2                	mov    %esi,%edx
  800f53:	f7 f7                	div    %edi
  800f55:	89 d0                	mov    %edx,%eax
  800f57:	31 d2                	xor    %edx,%edx
  800f59:	83 c4 20             	add    $0x20,%esp
  800f5c:	5e                   	pop    %esi
  800f5d:	5f                   	pop    %edi
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    
  800f60:	39 f2                	cmp    %esi,%edx
  800f62:	77 4c                	ja     800fb0 <__umoddi3+0x80>
  800f64:	0f bd ca             	bsr    %edx,%ecx
  800f67:	83 f1 1f             	xor    $0x1f,%ecx
  800f6a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800f6d:	75 51                	jne    800fc0 <__umoddi3+0x90>
  800f6f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  800f72:	0f 87 e0 00 00 00    	ja     801058 <__umoddi3+0x128>
  800f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f7b:	29 f8                	sub    %edi,%eax
  800f7d:	19 d6                	sbb    %edx,%esi
  800f7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f85:	89 f2                	mov    %esi,%edx
  800f87:	83 c4 20             	add    $0x20,%esp
  800f8a:	5e                   	pop    %esi
  800f8b:	5f                   	pop    %edi
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    
  800f8e:	66 90                	xchg   %ax,%ax
  800f90:	85 ff                	test   %edi,%edi
  800f92:	75 0b                	jne    800f9f <__umoddi3+0x6f>
  800f94:	b8 01 00 00 00       	mov    $0x1,%eax
  800f99:	31 d2                	xor    %edx,%edx
  800f9b:	f7 f7                	div    %edi
  800f9d:	89 c7                	mov    %eax,%edi
  800f9f:	89 f0                	mov    %esi,%eax
  800fa1:	31 d2                	xor    %edx,%edx
  800fa3:	f7 f7                	div    %edi
  800fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fa8:	f7 f7                	div    %edi
  800faa:	eb a9                	jmp    800f55 <__umoddi3+0x25>
  800fac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fb0:	89 c8                	mov    %ecx,%eax
  800fb2:	89 f2                	mov    %esi,%edx
  800fb4:	83 c4 20             	add    $0x20,%esp
  800fb7:	5e                   	pop    %esi
  800fb8:	5f                   	pop    %edi
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    
  800fbb:	90                   	nop
  800fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fc0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800fc4:	d3 e2                	shl    %cl,%edx
  800fc6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800fc9:	ba 20 00 00 00       	mov    $0x20,%edx
  800fce:	2b 55 f0             	sub    -0x10(%ebp),%edx
  800fd1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800fd4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800fd8:	89 fa                	mov    %edi,%edx
  800fda:	d3 ea                	shr    %cl,%edx
  800fdc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800fe0:	0b 55 f4             	or     -0xc(%ebp),%edx
  800fe3:	d3 e7                	shl    %cl,%edi
  800fe5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  800fe9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800fec:	89 f2                	mov    %esi,%edx
  800fee:	89 7d e8             	mov    %edi,-0x18(%ebp)
  800ff1:	89 c7                	mov    %eax,%edi
  800ff3:	d3 ea                	shr    %cl,%edx
  800ff5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  800ff9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800ffc:	89 c2                	mov    %eax,%edx
  800ffe:	d3 e6                	shl    %cl,%esi
  801000:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801004:	d3 ea                	shr    %cl,%edx
  801006:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80100a:	09 d6                	or     %edx,%esi
  80100c:	89 f0                	mov    %esi,%eax
  80100e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801011:	d3 e7                	shl    %cl,%edi
  801013:	89 f2                	mov    %esi,%edx
  801015:	f7 75 f4             	divl   -0xc(%ebp)
  801018:	89 d6                	mov    %edx,%esi
  80101a:	f7 65 e8             	mull   -0x18(%ebp)
  80101d:	39 d6                	cmp    %edx,%esi
  80101f:	72 2b                	jb     80104c <__umoddi3+0x11c>
  801021:	39 c7                	cmp    %eax,%edi
  801023:	72 23                	jb     801048 <__umoddi3+0x118>
  801025:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801029:	29 c7                	sub    %eax,%edi
  80102b:	19 d6                	sbb    %edx,%esi
  80102d:	89 f0                	mov    %esi,%eax
  80102f:	89 f2                	mov    %esi,%edx
  801031:	d3 ef                	shr    %cl,%edi
  801033:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801037:	d3 e0                	shl    %cl,%eax
  801039:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80103d:	09 f8                	or     %edi,%eax
  80103f:	d3 ea                	shr    %cl,%edx
  801041:	83 c4 20             	add    $0x20,%esp
  801044:	5e                   	pop    %esi
  801045:	5f                   	pop    %edi
  801046:	5d                   	pop    %ebp
  801047:	c3                   	ret    
  801048:	39 d6                	cmp    %edx,%esi
  80104a:	75 d9                	jne    801025 <__umoddi3+0xf5>
  80104c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80104f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801052:	eb d1                	jmp    801025 <__umoddi3+0xf5>
  801054:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801058:	39 f2                	cmp    %esi,%edx
  80105a:	0f 82 18 ff ff ff    	jb     800f78 <__umoddi3+0x48>
  801060:	e9 1d ff ff ff       	jmp    800f82 <__umoddi3+0x52>
