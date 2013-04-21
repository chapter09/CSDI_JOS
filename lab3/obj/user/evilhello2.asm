
obj/user/evilhello2:     file format elf32-i386


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
  80002c:	e8 13 01 00 00       	call   800144 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <evil>:
struct Segdesc *entry;
char va[PGSIZE];

// Call this function with ring0 privilege
void evil()
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
	// Kernel memory access
	*(char*)0xf010000a = 0;
  800037:	c6 05 0a 00 10 f0 00 	movb   $0x0,0xf010000a
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80003e:	ba f8 03 00 00       	mov    $0x3f8,%edx
  800043:	b8 49 00 00 00       	mov    $0x49,%eax
  800048:	ee                   	out    %al,(%dx)
  800049:	b8 4e 00 00 00       	mov    $0x4e,%eax
  80004e:	ee                   	out    %al,(%dx)
  80004f:	b8 20 00 00 00       	mov    $0x20,%eax
  800054:	ee                   	out    %al,(%dx)
  800055:	b8 52 00 00 00       	mov    $0x52,%eax
  80005a:	ee                   	out    %al,(%dx)
  80005b:	b8 49 00 00 00       	mov    $0x49,%eax
  800060:	ee                   	out    %al,(%dx)
  800061:	b8 4e 00 00 00       	mov    $0x4e,%eax
  800066:	ee                   	out    %al,(%dx)
  800067:	b8 47 00 00 00       	mov    $0x47,%eax
  80006c:	ee                   	out    %al,(%dx)
  80006d:	b8 30 00 00 00       	mov    $0x30,%eax
  800072:	ee                   	out    %al,(%dx)
  800073:	b8 21 00 00 00       	mov    $0x21,%eax
  800078:	ee                   	out    %al,(%dx)
  800079:	ee                   	out    %al,(%dx)
  80007a:	ee                   	out    %al,(%dx)
  80007b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800080:	ee                   	out    %al,(%dx)
	outb(0x3f8, '0');
	outb(0x3f8, '!');
	outb(0x3f8, '!');
	outb(0x3f8, '!');
	outb(0x3f8, '\n');
}
  800081:	5d                   	pop    %ebp
  800082:	c3                   	ret    

00800083 <evil_do>:

void evil_do(){
  800083:	55                   	push   %ebp
  800084:	89 e5                	mov    %esp,%ebp
	evil();
  800086:	e8 a9 ff ff ff       	call   800034 <evil>
	
	*entry = desc;
  80008b:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800091:	8b 0d 44 30 80 00    	mov    0x803044,%ecx
  800097:	a1 20 20 80 00       	mov    0x802020,%eax
  80009c:	89 10                	mov    %edx,(%eax)
  80009e:	89 48 04             	mov    %ecx,0x4(%eax)

	asm volatile("popl %ebp");
  8000a1:	5d                   	pop    %ebp

	asm volatile("lret");
  8000a2:	cb                   	lret   
}
  8000a3:	5d                   	pop    %ebp
  8000a4:	c3                   	ret    

008000a5 <ring0_call>:
{
	__asm __volatile("sgdt %0" :  "=m" (*gdtd));
}

// Invoke a given function pointer with ring0 privilege, then return to ring3
void ring0_call(void (*fun_ptr)(void)) {
  8000a5:	55                   	push   %ebp
  8000a6:	89 e5                	mov    %esp,%ebp
  8000a8:	83 ec 28             	sub    $0x28,%esp
	asm volatile("lret");
}
static void
sgdt(struct Pseudodesc* gdtd)
{
	__asm __volatile("sgdt %0" :  "=m" (*gdtd));
  8000ab:	0f 01 45 f2          	sgdtl  -0xe(%ebp)

    // Lab3 : Your Code Here
	struct Pseudodesc p;
	sgdt(&p);

	int ret = sys_map_kernel_page((void *)p.pd_base, (void *)va);
  8000af:	c7 44 24 04 40 20 80 	movl   $0x802040,0x4(%esp)
  8000b6:	00 
  8000b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 a5 01 00 00       	call   800267 <sys_map_kernel_page>
	uint32_t index = GD_UD >> 3;

	uint32_t base = PGNUM(va) << PTXSHIFT;
	uint32_t offset = PGOFF(p.pd_base);

	gdt = (struct Segdesc*)(base + offset);
  8000c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8000c5:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  8000cb:	b8 40 20 80 00       	mov    $0x802040,%eax
  8000d0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8000d5:	8d 04 02             	lea    (%edx,%eax,1),%eax
  8000d8:	a3 24 20 80 00       	mov    %eax,0x802024
	entry = gdt + index;
  8000dd:	83 c0 20             	add    $0x20,%eax
  8000e0:	a3 20 20 80 00       	mov    %eax,0x802020
	desc = *entry;
  8000e5:	8b 10                	mov    (%eax),%edx
  8000e7:	8b 48 04             	mov    0x4(%eax),%ecx
  8000ea:	89 15 40 30 80 00    	mov    %edx,0x803040
  8000f0:	89 0d 44 30 80 00    	mov    %ecx,0x803044
	SETCALLGATE(*((struct Gatedesc *)entry), GD_KT, evil_do, 3);
  8000f6:	b9 83 00 80 00       	mov    $0x800083,%ecx
  8000fb:	66 89 08             	mov    %cx,(%eax)
  8000fe:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  800104:	c6 40 04 00          	movb   $0x0,0x4(%eax)
  800108:	0f b6 50 05          	movzbl 0x5(%eax),%edx
  80010c:	83 e2 e0             	and    $0xffffffe0,%edx
  80010f:	83 ca 0c             	or     $0xc,%edx
  800112:	83 ca e0             	or     $0xffffffe0,%edx
  800115:	88 50 05             	mov    %dl,0x5(%eax)
  800118:	c1 e9 10             	shr    $0x10,%ecx
  80011b:	66 89 48 06          	mov    %cx,0x6(%eax)

	asm volatile("lcall $0x20, $0");
  80011f:	9a 00 00 00 00 20 00 	lcall  $0x20,$0x0
}
  800126:	c9                   	leave  
  800127:	c3                   	ret    

00800128 <umain>:

void
umain(int argc, char **argv)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	83 ec 18             	sub    $0x18,%esp
        // call the evil function in ring0
	ring0_call(&evil);
  80012e:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  800135:	e8 6b ff ff ff       	call   8000a5 <ring0_call>

	// call the evil function in ring3
	evil();
  80013a:	e8 f5 fe ff ff       	call   800034 <evil>
}
  80013f:	c9                   	leave  
  800140:	c3                   	ret    
  800141:	00 00                	add    %al,(%eax)
	...

00800144 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 18             	sub    $0x18,%esp
  80014a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80014d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800150:	8b 75 08             	mov    0x8(%ebp),%esi
  800153:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800156:	e8 cc 00 00 00       	call   800227 <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	6b c0 64             	imul   $0x64,%eax,%eax
  800163:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800168:	a3 48 30 80 00       	mov    %eax,0x803048

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80016d:	85 f6                	test   %esi,%esi
  80016f:	7e 07                	jle    800178 <libmain+0x34>
		binaryname = argv[0];
  800171:	8b 03                	mov    (%ebx),%eax
  800173:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800178:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80017c:	89 34 24             	mov    %esi,(%esp)
  80017f:	e8 a4 ff ff ff       	call   800128 <umain>

	// exit gracefully
	exit();
  800184:	e8 0b 00 00 00       	call   800194 <exit>
}
  800189:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80018c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80018f:	89 ec                	mov    %ebp,%esp
  800191:	5d                   	pop    %ebp
  800192:	c3                   	ret    
	...

00800194 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80019a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a1:	e8 03 01 00 00       	call   8002a9 <sys_env_destroy>
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 08             	sub    $0x8,%esp
  8001ae:	89 1c 24             	mov    %ebx,(%esp)
  8001b1:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8001ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c0:	89 c3                	mov    %eax,%ebx
  8001c2:	89 c7                	mov    %eax,%edi
  8001c4:	51                   	push   %ecx
  8001c5:	52                   	push   %edx
  8001c6:	53                   	push   %ebx
  8001c7:	54                   	push   %esp
  8001c8:	55                   	push   %ebp
  8001c9:	56                   	push   %esi
  8001ca:	57                   	push   %edi
  8001cb:	8d 35 d5 01 80 00    	lea    0x8001d5,%esi
  8001d1:	54                   	push   %esp
  8001d2:	5d                   	pop    %ebp
  8001d3:	0f 34                	sysenter 
  8001d5:	5f                   	pop    %edi
  8001d6:	5e                   	pop    %esi
  8001d7:	5d                   	pop    %ebp
  8001d8:	5c                   	pop    %esp
  8001d9:	5b                   	pop    %ebx
  8001da:	5a                   	pop    %edx
  8001db:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8001dc:	8b 1c 24             	mov    (%esp),%ebx
  8001df:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8001e3:	89 ec                	mov    %ebp,%esp
  8001e5:	5d                   	pop    %ebp
  8001e6:	c3                   	ret    

008001e7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	83 ec 08             	sub    $0x8,%esp
  8001ed:	89 1c 24             	mov    %ebx,(%esp)
  8001f0:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8001f9:	b8 01 00 00 00       	mov    $0x1,%eax
  8001fe:	89 d1                	mov    %edx,%ecx
  800200:	89 d3                	mov    %edx,%ebx
  800202:	89 d7                	mov    %edx,%edi
  800204:	51                   	push   %ecx
  800205:	52                   	push   %edx
  800206:	53                   	push   %ebx
  800207:	54                   	push   %esp
  800208:	55                   	push   %ebp
  800209:	56                   	push   %esi
  80020a:	57                   	push   %edi
  80020b:	8d 35 15 02 80 00    	lea    0x800215,%esi
  800211:	54                   	push   %esp
  800212:	5d                   	pop    %ebp
  800213:	0f 34                	sysenter 
  800215:	5f                   	pop    %edi
  800216:	5e                   	pop    %esi
  800217:	5d                   	pop    %ebp
  800218:	5c                   	pop    %esp
  800219:	5b                   	pop    %ebx
  80021a:	5a                   	pop    %edx
  80021b:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80021c:	8b 1c 24             	mov    (%esp),%ebx
  80021f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800223:	89 ec                	mov    %ebp,%esp
  800225:	5d                   	pop    %ebp
  800226:	c3                   	ret    

00800227 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	89 1c 24             	mov    %ebx,(%esp)
  800230:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800234:	ba 00 00 00 00       	mov    $0x0,%edx
  800239:	b8 02 00 00 00       	mov    $0x2,%eax
  80023e:	89 d1                	mov    %edx,%ecx
  800240:	89 d3                	mov    %edx,%ebx
  800242:	89 d7                	mov    %edx,%edi
  800244:	51                   	push   %ecx
  800245:	52                   	push   %edx
  800246:	53                   	push   %ebx
  800247:	54                   	push   %esp
  800248:	55                   	push   %ebp
  800249:	56                   	push   %esi
  80024a:	57                   	push   %edi
  80024b:	8d 35 55 02 80 00    	lea    0x800255,%esi
  800251:	54                   	push   %esp
  800252:	5d                   	pop    %ebp
  800253:	0f 34                	sysenter 
  800255:	5f                   	pop    %edi
  800256:	5e                   	pop    %esi
  800257:	5d                   	pop    %ebp
  800258:	5c                   	pop    %esp
  800259:	5b                   	pop    %ebx
  80025a:	5a                   	pop    %edx
  80025b:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80025c:	8b 1c 24             	mov    (%esp),%ebx
  80025f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800263:	89 ec                	mov    %ebp,%esp
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	83 ec 08             	sub    $0x8,%esp
  80026d:	89 1c 24             	mov    %ebx,(%esp)
  800270:	89 7c 24 04          	mov    %edi,0x4(%esp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800274:	bb 00 00 00 00       	mov    $0x0,%ebx
  800279:	b8 04 00 00 00       	mov    $0x4,%eax
  80027e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800281:	8b 55 08             	mov    0x8(%ebp),%edx
  800284:	89 df                	mov    %ebx,%edi
  800286:	51                   	push   %ecx
  800287:	52                   	push   %edx
  800288:	53                   	push   %ebx
  800289:	54                   	push   %esp
  80028a:	55                   	push   %ebp
  80028b:	56                   	push   %esi
  80028c:	57                   	push   %edi
  80028d:	8d 35 97 02 80 00    	lea    0x800297,%esi
  800293:	54                   	push   %esp
  800294:	5d                   	pop    %ebp
  800295:	0f 34                	sysenter 
  800297:	5f                   	pop    %edi
  800298:	5e                   	pop    %esi
  800299:	5d                   	pop    %ebp
  80029a:	5c                   	pop    %esp
  80029b:	5b                   	pop    %ebx
  80029c:	5a                   	pop    %edx
  80029d:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80029e:	8b 1c 24             	mov    (%esp),%ebx
  8002a1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002a5:	89 ec                	mov    %ebp,%esp
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	83 ec 28             	sub    $0x28,%esp
  8002af:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8002b2:	89 7d fc             	mov    %edi,-0x4(%ebp)

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8002b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ba:	b8 03 00 00 00       	mov    $0x3,%eax
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	89 cb                	mov    %ecx,%ebx
  8002c4:	89 cf                	mov    %ecx,%edi
  8002c6:	51                   	push   %ecx
  8002c7:	52                   	push   %edx
  8002c8:	53                   	push   %ebx
  8002c9:	54                   	push   %esp
  8002ca:	55                   	push   %ebp
  8002cb:	56                   	push   %esi
  8002cc:	57                   	push   %edi
  8002cd:	8d 35 d7 02 80 00    	lea    0x8002d7,%esi
  8002d3:	54                   	push   %esp
  8002d4:	5d                   	pop    %ebp
  8002d5:	0f 34                	sysenter 
  8002d7:	5f                   	pop    %edi
  8002d8:	5e                   	pop    %esi
  8002d9:	5d                   	pop    %ebp
  8002da:	5c                   	pop    %esp
  8002db:	5b                   	pop    %ebx
  8002dc:	5a                   	pop    %edx
  8002dd:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8002de:	85 c0                	test   %eax,%eax
  8002e0:	7e 28                	jle    80030a <sys_env_destroy+0x61>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002e6:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8002ed:	00 
  8002ee:	c7 44 24 08 72 11 80 	movl   $0x801172,0x8(%esp)
  8002f5:	00 
  8002f6:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  8002fd:	00 
  8002fe:	c7 04 24 8f 11 80 00 	movl   $0x80118f,(%esp)
  800305:	e8 0a 00 00 00       	call   800314 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80030a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80030d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800310:	89 ec                	mov    %ebp,%esp
  800312:	5d                   	pop    %ebp
  800313:	c3                   	ret    

00800314 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80031c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80031f:	a1 4c 30 80 00       	mov    0x80304c,%eax
  800324:	85 c0                	test   %eax,%eax
  800326:	74 10                	je     800338 <_panic+0x24>
		cprintf("%s: ", argv0);
  800328:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032c:	c7 04 24 9d 11 80 00 	movl   $0x80119d,(%esp)
  800333:	e8 ad 00 00 00       	call   8003e5 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800338:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80033e:	e8 e4 fe ff ff       	call   800227 <sys_getenvid>
  800343:	8b 55 0c             	mov    0xc(%ebp),%edx
  800346:	89 54 24 10          	mov    %edx,0x10(%esp)
  80034a:	8b 55 08             	mov    0x8(%ebp),%edx
  80034d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800351:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800355:	89 44 24 04          	mov    %eax,0x4(%esp)
  800359:	c7 04 24 a4 11 80 00 	movl   $0x8011a4,(%esp)
  800360:	e8 80 00 00 00       	call   8003e5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800365:	89 74 24 04          	mov    %esi,0x4(%esp)
  800369:	8b 45 10             	mov    0x10(%ebp),%eax
  80036c:	89 04 24             	mov    %eax,(%esp)
  80036f:	e8 10 00 00 00       	call   800384 <vcprintf>
	cprintf("\n");
  800374:	c7 04 24 a2 11 80 00 	movl   $0x8011a2,(%esp)
  80037b:	e8 65 00 00 00       	call   8003e5 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800380:	cc                   	int3   
  800381:	eb fd                	jmp    800380 <_panic+0x6c>
	...

00800384 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80038d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800394:	00 00 00 
	b.cnt = 0;
  800397:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80039e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003af:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b9:	c7 04 24 ff 03 80 00 	movl   $0x8003ff,(%esp)
  8003c0:	e8 d8 01 00 00       	call   80059d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003c5:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8003cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003cf:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d5:	89 04 24             	mov    %eax,(%esp)
  8003d8:	e8 cb fd ff ff       	call   8001a8 <sys_cputs>

	return b.cnt;
}
  8003dd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e3:	c9                   	leave  
  8003e4:	c3                   	ret    

008003e5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8003eb:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8003ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f5:	89 04 24             	mov    %eax,(%esp)
  8003f8:	e8 87 ff ff ff       	call   800384 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	53                   	push   %ebx
  800403:	83 ec 14             	sub    $0x14,%esp
  800406:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800409:	8b 03                	mov    (%ebx),%eax
  80040b:	8b 55 08             	mov    0x8(%ebp),%edx
  80040e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800412:	83 c0 01             	add    $0x1,%eax
  800415:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800417:	3d ff 00 00 00       	cmp    $0xff,%eax
  80041c:	75 19                	jne    800437 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80041e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800425:	00 
  800426:	8d 43 08             	lea    0x8(%ebx),%eax
  800429:	89 04 24             	mov    %eax,(%esp)
  80042c:	e8 77 fd ff ff       	call   8001a8 <sys_cputs>
		b->idx = 0;
  800431:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800437:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80043b:	83 c4 14             	add    $0x14,%esp
  80043e:	5b                   	pop    %ebx
  80043f:	5d                   	pop    %ebp
  800440:	c3                   	ret    
	...

00800450 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800450:	55                   	push   %ebp
  800451:	89 e5                	mov    %esp,%ebp
  800453:	57                   	push   %edi
  800454:	56                   	push   %esi
  800455:	53                   	push   %ebx
  800456:	83 ec 4c             	sub    $0x4c,%esp
  800459:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80045c:	89 d6                	mov    %edx,%esi
  80045e:	8b 45 08             	mov    0x8(%ebp),%eax
  800461:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800464:	8b 55 0c             	mov    0xc(%ebp),%edx
  800467:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80046a:	8b 45 10             	mov    0x10(%ebp),%eax
  80046d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800470:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800473:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800476:	b9 00 00 00 00       	mov    $0x0,%ecx
  80047b:	39 d1                	cmp    %edx,%ecx
  80047d:	72 15                	jb     800494 <printnum+0x44>
  80047f:	77 07                	ja     800488 <printnum+0x38>
  800481:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800484:	39 d0                	cmp    %edx,%eax
  800486:	76 0c                	jbe    800494 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800488:	83 eb 01             	sub    $0x1,%ebx
  80048b:	85 db                	test   %ebx,%ebx
  80048d:	8d 76 00             	lea    0x0(%esi),%esi
  800490:	7f 61                	jg     8004f3 <printnum+0xa3>
  800492:	eb 70                	jmp    800504 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800494:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800498:	83 eb 01             	sub    $0x1,%ebx
  80049b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80049f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004a3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8004a7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8004ab:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004ae:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8004b1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8004b4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004b8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004bf:	00 
  8004c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004c3:	89 04 24             	mov    %eax,(%esp)
  8004c6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004cd:	e8 2e 0a 00 00       	call   800f00 <__udivdi3>
  8004d2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004d5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8004d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8004dc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004e0:	89 04 24             	mov    %eax,(%esp)
  8004e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004e7:	89 f2                	mov    %esi,%edx
  8004e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004ec:	e8 5f ff ff ff       	call   800450 <printnum>
  8004f1:	eb 11                	jmp    800504 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004f7:	89 3c 24             	mov    %edi,(%esp)
  8004fa:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004fd:	83 eb 01             	sub    $0x1,%ebx
  800500:	85 db                	test   %ebx,%ebx
  800502:	7f ef                	jg     8004f3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800504:	89 74 24 04          	mov    %esi,0x4(%esp)
  800508:	8b 74 24 04          	mov    0x4(%esp),%esi
  80050c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80050f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800513:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80051a:	00 
  80051b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80051e:	89 14 24             	mov    %edx,(%esp)
  800521:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800524:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800528:	e8 03 0b 00 00       	call   801030 <__umoddi3>
  80052d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800531:	0f be 80 c7 11 80 00 	movsbl 0x8011c7(%eax),%eax
  800538:	89 04 24             	mov    %eax,(%esp)
  80053b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80053e:	83 c4 4c             	add    $0x4c,%esp
  800541:	5b                   	pop    %ebx
  800542:	5e                   	pop    %esi
  800543:	5f                   	pop    %edi
  800544:	5d                   	pop    %ebp
  800545:	c3                   	ret    

00800546 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800546:	55                   	push   %ebp
  800547:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800549:	83 fa 01             	cmp    $0x1,%edx
  80054c:	7e 0e                	jle    80055c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80054e:	8b 10                	mov    (%eax),%edx
  800550:	8d 4a 08             	lea    0x8(%edx),%ecx
  800553:	89 08                	mov    %ecx,(%eax)
  800555:	8b 02                	mov    (%edx),%eax
  800557:	8b 52 04             	mov    0x4(%edx),%edx
  80055a:	eb 22                	jmp    80057e <getuint+0x38>
	else if (lflag)
  80055c:	85 d2                	test   %edx,%edx
  80055e:	74 10                	je     800570 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800560:	8b 10                	mov    (%eax),%edx
  800562:	8d 4a 04             	lea    0x4(%edx),%ecx
  800565:	89 08                	mov    %ecx,(%eax)
  800567:	8b 02                	mov    (%edx),%eax
  800569:	ba 00 00 00 00       	mov    $0x0,%edx
  80056e:	eb 0e                	jmp    80057e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800570:	8b 10                	mov    (%eax),%edx
  800572:	8d 4a 04             	lea    0x4(%edx),%ecx
  800575:	89 08                	mov    %ecx,(%eax)
  800577:	8b 02                	mov    (%edx),%eax
  800579:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80057e:	5d                   	pop    %ebp
  80057f:	c3                   	ret    

00800580 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800580:	55                   	push   %ebp
  800581:	89 e5                	mov    %esp,%ebp
  800583:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800586:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80058a:	8b 10                	mov    (%eax),%edx
  80058c:	3b 50 04             	cmp    0x4(%eax),%edx
  80058f:	73 0a                	jae    80059b <sprintputch+0x1b>
		*b->buf++ = ch;
  800591:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800594:	88 0a                	mov    %cl,(%edx)
  800596:	83 c2 01             	add    $0x1,%edx
  800599:	89 10                	mov    %edx,(%eax)
}
  80059b:	5d                   	pop    %ebp
  80059c:	c3                   	ret    

0080059d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80059d:	55                   	push   %ebp
  80059e:	89 e5                	mov    %esp,%ebp
  8005a0:	57                   	push   %edi
  8005a1:	56                   	push   %esi
  8005a2:	53                   	push   %ebx
  8005a3:	83 ec 5c             	sub    $0x5c,%esp
  8005a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005a9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005af:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8005b6:	eb 16                	jmp    8005ce <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005b8:	85 c0                	test   %eax,%eax
  8005ba:	0f 84 4f 04 00 00    	je     800a0f <vprintfmt+0x472>
				return;
			putch(ch, putdat);
  8005c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005c4:	89 04 24             	mov    %eax,(%esp)
  8005c7:	ff d7                	call   *%edi
  8005c9:	eb 03                	jmp    8005ce <vprintfmt+0x31>
  8005cb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005ce:	0f b6 03             	movzbl (%ebx),%eax
  8005d1:	83 c3 01             	add    $0x1,%ebx
  8005d4:	83 f8 25             	cmp    $0x25,%eax
  8005d7:	75 df                	jne    8005b8 <vprintfmt+0x1b>
  8005d9:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  8005dd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005e4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005eb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8005f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f7:	eb 06                	jmp    8005ff <vprintfmt+0x62>
  8005f9:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  8005fd:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ff:	0f b6 13             	movzbl (%ebx),%edx
  800602:	0f b6 c2             	movzbl %dl,%eax
  800605:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800608:	8d 43 01             	lea    0x1(%ebx),%eax
  80060b:	83 ea 23             	sub    $0x23,%edx
  80060e:	80 fa 55             	cmp    $0x55,%dl
  800611:	0f 87 db 03 00 00    	ja     8009f2 <vprintfmt+0x455>
  800617:	0f b6 d2             	movzbl %dl,%edx
  80061a:	ff 24 95 d0 12 80 00 	jmp    *0x8012d0(,%edx,4)
  800621:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800625:	eb d6                	jmp    8005fd <vprintfmt+0x60>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800627:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80062a:	83 ea 30             	sub    $0x30,%edx
  80062d:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
  800630:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800633:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800636:	83 fb 09             	cmp    $0x9,%ebx
  800639:	77 4c                	ja     800687 <vprintfmt+0xea>
  80063b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80063e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800641:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800644:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800647:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  80064b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80064e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800651:	83 fb 09             	cmp    $0x9,%ebx
  800654:	76 eb                	jbe    800641 <vprintfmt+0xa4>
  800656:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800659:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80065c:	eb 29                	jmp    800687 <vprintfmt+0xea>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80065e:	8b 55 14             	mov    0x14(%ebp),%edx
  800661:	8d 5a 04             	lea    0x4(%edx),%ebx
  800664:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800667:	8b 12                	mov    (%edx),%edx
  800669:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
  80066c:	eb 19                	jmp    800687 <vprintfmt+0xea>

		case '.':
			if (width < 0)
  80066e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800671:	c1 fa 1f             	sar    $0x1f,%edx
  800674:	f7 d2                	not    %edx
  800676:	21 55 d4             	and    %edx,-0x2c(%ebp)
  800679:	eb 82                	jmp    8005fd <vprintfmt+0x60>
  80067b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800682:	e9 76 ff ff ff       	jmp    8005fd <vprintfmt+0x60>

		process_precision:
			if (width < 0)
  800687:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80068b:	0f 89 6c ff ff ff    	jns    8005fd <vprintfmt+0x60>
  800691:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800694:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800697:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80069a:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80069d:	e9 5b ff ff ff       	jmp    8005fd <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006a2:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8006a5:	e9 53 ff ff ff       	jmp    8005fd <vprintfmt+0x60>
  8006aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8d 50 04             	lea    0x4(%eax),%edx
  8006b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ba:	8b 00                	mov    (%eax),%eax
  8006bc:	89 04 24             	mov    %eax,(%esp)
  8006bf:	ff d7                	call   *%edi
  8006c1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
  8006c4:	e9 05 ff ff ff       	jmp    8005ce <vprintfmt+0x31>
  8006c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8d 50 04             	lea    0x4(%eax),%edx
  8006d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d5:	8b 00                	mov    (%eax),%eax
  8006d7:	89 c2                	mov    %eax,%edx
  8006d9:	c1 fa 1f             	sar    $0x1f,%edx
  8006dc:	31 d0                	xor    %edx,%eax
  8006de:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006e0:	83 f8 06             	cmp    $0x6,%eax
  8006e3:	7f 0b                	jg     8006f0 <vprintfmt+0x153>
  8006e5:	8b 14 85 28 14 80 00 	mov    0x801428(,%eax,4),%edx
  8006ec:	85 d2                	test   %edx,%edx
  8006ee:	75 20                	jne    800710 <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  8006f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f4:	c7 44 24 08 d8 11 80 	movl   $0x8011d8,0x8(%esp)
  8006fb:	00 
  8006fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800700:	89 3c 24             	mov    %edi,(%esp)
  800703:	e8 8f 03 00 00       	call   800a97 <printfmt>
  800708:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80070b:	e9 be fe ff ff       	jmp    8005ce <vprintfmt+0x31>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800710:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800714:	c7 44 24 08 e1 11 80 	movl   $0x8011e1,0x8(%esp)
  80071b:	00 
  80071c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800720:	89 3c 24             	mov    %edi,(%esp)
  800723:	e8 6f 03 00 00       	call   800a97 <printfmt>
  800728:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80072b:	e9 9e fe ff ff       	jmp    8005ce <vprintfmt+0x31>
  800730:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800733:	89 c3                	mov    %eax,%ebx
  800735:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800738:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80073b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80073e:	8b 45 14             	mov    0x14(%ebp),%eax
  800741:	8d 50 04             	lea    0x4(%eax),%edx
  800744:	89 55 14             	mov    %edx,0x14(%ebp)
  800747:	8b 00                	mov    (%eax),%eax
  800749:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80074c:	85 c0                	test   %eax,%eax
  80074e:	75 07                	jne    800757 <vprintfmt+0x1ba>
  800750:	c7 45 cc e4 11 80 00 	movl   $0x8011e4,-0x34(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800757:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80075b:	7e 06                	jle    800763 <vprintfmt+0x1c6>
  80075d:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800761:	75 13                	jne    800776 <vprintfmt+0x1d9>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800763:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800766:	0f be 02             	movsbl (%edx),%eax
  800769:	85 c0                	test   %eax,%eax
  80076b:	0f 85 9f 00 00 00    	jne    800810 <vprintfmt+0x273>
  800771:	e9 8f 00 00 00       	jmp    800805 <vprintfmt+0x268>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800776:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80077a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80077d:	89 0c 24             	mov    %ecx,(%esp)
  800780:	e8 56 03 00 00       	call   800adb <strnlen>
  800785:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800788:	29 c2                	sub    %eax,%edx
  80078a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80078d:	85 d2                	test   %edx,%edx
  80078f:	7e d2                	jle    800763 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800791:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800795:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800798:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  80079b:	89 d3                	mov    %edx,%ebx
  80079d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007a4:	89 04 24             	mov    %eax,(%esp)
  8007a7:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007a9:	83 eb 01             	sub    $0x1,%ebx
  8007ac:	85 db                	test   %ebx,%ebx
  8007ae:	7f ed                	jg     80079d <vprintfmt+0x200>
  8007b0:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8007b3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8007ba:	eb a7                	jmp    800763 <vprintfmt+0x1c6>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007bc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007c0:	74 1b                	je     8007dd <vprintfmt+0x240>
  8007c2:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007c5:	83 fa 5e             	cmp    $0x5e,%edx
  8007c8:	76 13                	jbe    8007dd <vprintfmt+0x240>
					putch('?', putdat);
  8007ca:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007d1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007d8:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007db:	eb 0d                	jmp    8007ea <vprintfmt+0x24d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8007dd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007e0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007e4:	89 04 24             	mov    %eax,(%esp)
  8007e7:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007ea:	83 ef 01             	sub    $0x1,%edi
  8007ed:	0f be 03             	movsbl (%ebx),%eax
  8007f0:	85 c0                	test   %eax,%eax
  8007f2:	74 05                	je     8007f9 <vprintfmt+0x25c>
  8007f4:	83 c3 01             	add    $0x1,%ebx
  8007f7:	eb 2e                	jmp    800827 <vprintfmt+0x28a>
  8007f9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007fc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8007ff:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800802:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800805:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800809:	7f 33                	jg     80083e <vprintfmt+0x2a1>
  80080b:	e9 bb fd ff ff       	jmp    8005cb <vprintfmt+0x2e>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800810:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800813:	83 c2 01             	add    $0x1,%edx
  800816:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800819:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80081c:	89 75 cc             	mov    %esi,-0x34(%ebp)
  80081f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800822:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800825:	89 d3                	mov    %edx,%ebx
  800827:	85 f6                	test   %esi,%esi
  800829:	78 91                	js     8007bc <vprintfmt+0x21f>
  80082b:	83 ee 01             	sub    $0x1,%esi
  80082e:	79 8c                	jns    8007bc <vprintfmt+0x21f>
  800830:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800833:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800836:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800839:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80083c:	eb c7                	jmp    800805 <vprintfmt+0x268>
  80083e:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800841:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800844:	89 74 24 04          	mov    %esi,0x4(%esp)
  800848:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80084f:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800851:	83 eb 01             	sub    $0x1,%ebx
  800854:	85 db                	test   %ebx,%ebx
  800856:	7f ec                	jg     800844 <vprintfmt+0x2a7>
  800858:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  80085b:	e9 6e fd ff ff       	jmp    8005ce <vprintfmt+0x31>
  800860:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800863:	83 f9 01             	cmp    $0x1,%ecx
  800866:	7e 16                	jle    80087e <vprintfmt+0x2e1>
		return va_arg(*ap, long long);
  800868:	8b 45 14             	mov    0x14(%ebp),%eax
  80086b:	8d 50 08             	lea    0x8(%eax),%edx
  80086e:	89 55 14             	mov    %edx,0x14(%ebp)
  800871:	8b 10                	mov    (%eax),%edx
  800873:	8b 48 04             	mov    0x4(%eax),%ecx
  800876:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800879:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80087c:	eb 32                	jmp    8008b0 <vprintfmt+0x313>
	else if (lflag)
  80087e:	85 c9                	test   %ecx,%ecx
  800880:	74 18                	je     80089a <vprintfmt+0x2fd>
		return va_arg(*ap, long);
  800882:	8b 45 14             	mov    0x14(%ebp),%eax
  800885:	8d 50 04             	lea    0x4(%eax),%edx
  800888:	89 55 14             	mov    %edx,0x14(%ebp)
  80088b:	8b 00                	mov    (%eax),%eax
  80088d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800890:	89 c1                	mov    %eax,%ecx
  800892:	c1 f9 1f             	sar    $0x1f,%ecx
  800895:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800898:	eb 16                	jmp    8008b0 <vprintfmt+0x313>
	else
		return va_arg(*ap, int);
  80089a:	8b 45 14             	mov    0x14(%ebp),%eax
  80089d:	8d 50 04             	lea    0x4(%eax),%edx
  8008a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a3:	8b 00                	mov    (%eax),%eax
  8008a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008a8:	89 c2                	mov    %eax,%edx
  8008aa:	c1 fa 1f             	sar    $0x1f,%edx
  8008ad:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008b6:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  8008bb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008bf:	0f 89 8a 00 00 00    	jns    80094f <vprintfmt+0x3b2>
				putch('-', putdat);
  8008c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008c9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008d0:	ff d7                	call   *%edi
				num = -(long long) num;
  8008d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008d5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008d8:	f7 d8                	neg    %eax
  8008da:	83 d2 00             	adc    $0x0,%edx
  8008dd:	f7 da                	neg    %edx
  8008df:	eb 6e                	jmp    80094f <vprintfmt+0x3b2>
  8008e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008e4:	89 ca                	mov    %ecx,%edx
  8008e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8008e9:	e8 58 fc ff ff       	call   800546 <getuint>
  8008ee:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  8008f3:	eb 5a                	jmp    80094f <vprintfmt+0x3b2>
  8008f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
			//break;
			num = getuint(&ap, lflag);
  8008f8:	89 ca                	mov    %ecx,%edx
  8008fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8008fd:	e8 44 fc ff ff       	call   800546 <getuint>
  800902:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800907:	eb 46                	jmp    80094f <vprintfmt+0x3b2>
  800909:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  80090c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800910:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800917:	ff d7                	call   *%edi
			putch('x', putdat);
  800919:	89 74 24 04          	mov    %esi,0x4(%esp)
  80091d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800924:	ff d7                	call   *%edi
			num = (unsigned long long)
  800926:	8b 45 14             	mov    0x14(%ebp),%eax
  800929:	8d 50 04             	lea    0x4(%eax),%edx
  80092c:	89 55 14             	mov    %edx,0x14(%ebp)
  80092f:	8b 00                	mov    (%eax),%eax
  800931:	ba 00 00 00 00       	mov    $0x0,%edx
  800936:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80093b:	eb 12                	jmp    80094f <vprintfmt+0x3b2>
  80093d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800940:	89 ca                	mov    %ecx,%edx
  800942:	8d 45 14             	lea    0x14(%ebp),%eax
  800945:	e8 fc fb ff ff       	call   800546 <getuint>
  80094a:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80094f:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800953:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800957:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80095a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80095e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800962:	89 04 24             	mov    %eax,(%esp)
  800965:	89 54 24 04          	mov    %edx,0x4(%esp)
  800969:	89 f2                	mov    %esi,%edx
  80096b:	89 f8                	mov    %edi,%eax
  80096d:	e8 de fa ff ff       	call   800450 <printnum>
  800972:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
  800975:	e9 54 fc ff ff       	jmp    8005ce <vprintfmt+0x31>
  80097a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			char* tmp = va_arg(ap, char*);
  80097d:	8b 45 14             	mov    0x14(%ebp),%eax
  800980:	8d 50 04             	lea    0x4(%eax),%edx
  800983:	89 55 14             	mov    %edx,0x14(%ebp)
  800986:	8b 00                	mov    (%eax),%eax
			if(tmp == NULL) {
  800988:	85 c0                	test   %eax,%eax
  80098a:	75 1f                	jne    8009ab <vprintfmt+0x40e>
  80098c:	bb 55 12 80 00       	mov    $0x801255,%ebx
  800991:	b0 0a                	mov    $0xa,%al
				for(; (ch = *null_error++) != '\0';) {	
					putch(ch, putdat);
  800993:	89 74 24 04          	mov    %esi,0x4(%esp)
  800997:	89 04 24             	mov    %eax,(%esp)
  80099a:	ff d7                	call   *%edi
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			char* tmp = va_arg(ap, char*);
			if(tmp == NULL) {
				for(; (ch = *null_error++) != '\0';) {	
  80099c:	0f be 03             	movsbl (%ebx),%eax
  80099f:	83 c3 01             	add    $0x1,%ebx
  8009a2:	85 c0                	test   %eax,%eax
  8009a4:	75 ed                	jne    800993 <vprintfmt+0x3f6>
  8009a6:	e9 20 fc ff ff       	jmp    8005cb <vprintfmt+0x2e>
					putch(ch, putdat);
				}
				break;
			}
			*tmp = *((signed char*) putdat);
  8009ab:	0f b6 16             	movzbl (%esi),%edx
  8009ae:	88 10                	mov    %dl,(%eax)
			if(*(signed char*) putdat < 0) {
  8009b0:	80 3e 00             	cmpb   $0x0,(%esi)
  8009b3:	0f 89 12 fc ff ff    	jns    8005cb <vprintfmt+0x2e>
  8009b9:	bb 8d 12 80 00       	mov    $0x80128d,%ebx
  8009be:	b8 0a 00 00 00       	mov    $0xa,%eax
				for(; (ch = *overflow_error++) != '\0';) {	
					putch(ch, putdat);
  8009c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009c7:	89 04 24             	mov    %eax,(%esp)
  8009ca:	ff d7                	call   *%edi
				}
				break;
			}
			*tmp = *((signed char*) putdat);
			if(*(signed char*) putdat < 0) {
				for(; (ch = *overflow_error++) != '\0';) {	
  8009cc:	0f be 03             	movsbl (%ebx),%eax
  8009cf:	83 c3 01             	add    $0x1,%ebx
  8009d2:	85 c0                	test   %eax,%eax
  8009d4:	75 ed                	jne    8009c3 <vprintfmt+0x426>
  8009d6:	e9 f0 fb ff ff       	jmp    8005cb <vprintfmt+0x2e>
  8009db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009e5:	89 14 24             	mov    %edx,(%esp)
  8009e8:	ff d7                	call   *%edi
  8009ea:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
  8009ed:	e9 dc fb ff ff       	jmp    8005ce <vprintfmt+0x31>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009f6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009fd:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009ff:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800a02:	80 38 25             	cmpb   $0x25,(%eax)
  800a05:	0f 84 c3 fb ff ff    	je     8005ce <vprintfmt+0x31>
  800a0b:	89 c3                	mov    %eax,%ebx
  800a0d:	eb f0                	jmp    8009ff <vprintfmt+0x462>
				/* do nothing */;
			break;
		}
	}
}
  800a0f:	83 c4 5c             	add    $0x5c,%esp
  800a12:	5b                   	pop    %ebx
  800a13:	5e                   	pop    %esi
  800a14:	5f                   	pop    %edi
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	83 ec 28             	sub    $0x28,%esp
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800a23:	85 c0                	test   %eax,%eax
  800a25:	74 04                	je     800a2b <vsnprintf+0x14>
  800a27:	85 d2                	test   %edx,%edx
  800a29:	7f 07                	jg     800a32 <vsnprintf+0x1b>
  800a2b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a30:	eb 3b                	jmp    800a6d <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a32:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a35:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800a39:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a3c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a43:	8b 45 14             	mov    0x14(%ebp),%eax
  800a46:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a4a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a4d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a51:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a54:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a58:	c7 04 24 80 05 80 00 	movl   $0x800580,(%esp)
  800a5f:	e8 39 fb ff ff       	call   80059d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a64:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a67:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a6d:	c9                   	leave  
  800a6e:	c3                   	ret    

00800a6f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800a75:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800a78:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a86:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	89 04 24             	mov    %eax,(%esp)
  800a90:	e8 82 ff ff ff       	call   800a17 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a95:	c9                   	leave  
  800a96:	c3                   	ret    

00800a97 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800a9d:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800aa0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aa4:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aae:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab5:	89 04 24             	mov    %eax,(%esp)
  800ab8:	e8 e0 fa ff ff       	call   80059d <vprintfmt>
	va_end(ap);
}
  800abd:	c9                   	leave  
  800abe:	c3                   	ret    
	...

00800ac0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ac6:	b8 00 00 00 00       	mov    $0x0,%eax
  800acb:	80 3a 00             	cmpb   $0x0,(%edx)
  800ace:	74 09                	je     800ad9 <strlen+0x19>
		n++;
  800ad0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ad3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ad7:	75 f7                	jne    800ad0 <strlen+0x10>
		n++;
	return n;
}
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	53                   	push   %ebx
  800adf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ae2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae5:	85 c9                	test   %ecx,%ecx
  800ae7:	74 19                	je     800b02 <strnlen+0x27>
  800ae9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800aec:	74 14                	je     800b02 <strnlen+0x27>
  800aee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800af3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800af6:	39 c8                	cmp    %ecx,%eax
  800af8:	74 0d                	je     800b07 <strnlen+0x2c>
  800afa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800afe:	75 f3                	jne    800af3 <strnlen+0x18>
  800b00:	eb 05                	jmp    800b07 <strnlen+0x2c>
  800b02:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b07:	5b                   	pop    %ebx
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	53                   	push   %ebx
  800b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b14:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b19:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b1d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b20:	83 c2 01             	add    $0x1,%edx
  800b23:	84 c9                	test   %cl,%cl
  800b25:	75 f2                	jne    800b19 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b27:	5b                   	pop    %ebx
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	53                   	push   %ebx
  800b2e:	83 ec 08             	sub    $0x8,%esp
  800b31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b34:	89 1c 24             	mov    %ebx,(%esp)
  800b37:	e8 84 ff ff ff       	call   800ac0 <strlen>
	strcpy(dst + len, src);
  800b3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b43:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800b46:	89 04 24             	mov    %eax,(%esp)
  800b49:	e8 bc ff ff ff       	call   800b0a <strcpy>
	return dst;
}
  800b4e:	89 d8                	mov    %ebx,%eax
  800b50:	83 c4 08             	add    $0x8,%esp
  800b53:	5b                   	pop    %ebx
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b61:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b64:	85 f6                	test   %esi,%esi
  800b66:	74 18                	je     800b80 <strncpy+0x2a>
  800b68:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800b6d:	0f b6 1a             	movzbl (%edx),%ebx
  800b70:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b73:	80 3a 01             	cmpb   $0x1,(%edx)
  800b76:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b79:	83 c1 01             	add    $0x1,%ecx
  800b7c:	39 ce                	cmp    %ecx,%esi
  800b7e:	77 ed                	ja     800b6d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	8b 75 08             	mov    0x8(%ebp),%esi
  800b8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b92:	89 f0                	mov    %esi,%eax
  800b94:	85 c9                	test   %ecx,%ecx
  800b96:	74 27                	je     800bbf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800b98:	83 e9 01             	sub    $0x1,%ecx
  800b9b:	74 1d                	je     800bba <strlcpy+0x36>
  800b9d:	0f b6 1a             	movzbl (%edx),%ebx
  800ba0:	84 db                	test   %bl,%bl
  800ba2:	74 16                	je     800bba <strlcpy+0x36>
			*dst++ = *src++;
  800ba4:	88 18                	mov    %bl,(%eax)
  800ba6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ba9:	83 e9 01             	sub    $0x1,%ecx
  800bac:	74 0e                	je     800bbc <strlcpy+0x38>
			*dst++ = *src++;
  800bae:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bb1:	0f b6 1a             	movzbl (%edx),%ebx
  800bb4:	84 db                	test   %bl,%bl
  800bb6:	75 ec                	jne    800ba4 <strlcpy+0x20>
  800bb8:	eb 02                	jmp    800bbc <strlcpy+0x38>
  800bba:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bbc:	c6 00 00             	movb   $0x0,(%eax)
  800bbf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bce:	0f b6 01             	movzbl (%ecx),%eax
  800bd1:	84 c0                	test   %al,%al
  800bd3:	74 15                	je     800bea <strcmp+0x25>
  800bd5:	3a 02                	cmp    (%edx),%al
  800bd7:	75 11                	jne    800bea <strcmp+0x25>
		p++, q++;
  800bd9:	83 c1 01             	add    $0x1,%ecx
  800bdc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bdf:	0f b6 01             	movzbl (%ecx),%eax
  800be2:	84 c0                	test   %al,%al
  800be4:	74 04                	je     800bea <strcmp+0x25>
  800be6:	3a 02                	cmp    (%edx),%al
  800be8:	74 ef                	je     800bd9 <strcmp+0x14>
  800bea:	0f b6 c0             	movzbl %al,%eax
  800bed:	0f b6 12             	movzbl (%edx),%edx
  800bf0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	53                   	push   %ebx
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800c01:	85 c0                	test   %eax,%eax
  800c03:	74 23                	je     800c28 <strncmp+0x34>
  800c05:	0f b6 1a             	movzbl (%edx),%ebx
  800c08:	84 db                	test   %bl,%bl
  800c0a:	74 25                	je     800c31 <strncmp+0x3d>
  800c0c:	3a 19                	cmp    (%ecx),%bl
  800c0e:	75 21                	jne    800c31 <strncmp+0x3d>
  800c10:	83 e8 01             	sub    $0x1,%eax
  800c13:	74 13                	je     800c28 <strncmp+0x34>
		n--, p++, q++;
  800c15:	83 c2 01             	add    $0x1,%edx
  800c18:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c1b:	0f b6 1a             	movzbl (%edx),%ebx
  800c1e:	84 db                	test   %bl,%bl
  800c20:	74 0f                	je     800c31 <strncmp+0x3d>
  800c22:	3a 19                	cmp    (%ecx),%bl
  800c24:	74 ea                	je     800c10 <strncmp+0x1c>
  800c26:	eb 09                	jmp    800c31 <strncmp+0x3d>
  800c28:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c2d:	5b                   	pop    %ebx
  800c2e:	5d                   	pop    %ebp
  800c2f:	90                   	nop
  800c30:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c31:	0f b6 02             	movzbl (%edx),%eax
  800c34:	0f b6 11             	movzbl (%ecx),%edx
  800c37:	29 d0                	sub    %edx,%eax
  800c39:	eb f2                	jmp    800c2d <strncmp+0x39>

00800c3b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c45:	0f b6 10             	movzbl (%eax),%edx
  800c48:	84 d2                	test   %dl,%dl
  800c4a:	74 18                	je     800c64 <strchr+0x29>
		if (*s == c)
  800c4c:	38 ca                	cmp    %cl,%dl
  800c4e:	75 0a                	jne    800c5a <strchr+0x1f>
  800c50:	eb 17                	jmp    800c69 <strchr+0x2e>
  800c52:	38 ca                	cmp    %cl,%dl
  800c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c58:	74 0f                	je     800c69 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c5a:	83 c0 01             	add    $0x1,%eax
  800c5d:	0f b6 10             	movzbl (%eax),%edx
  800c60:	84 d2                	test   %dl,%dl
  800c62:	75 ee                	jne    800c52 <strchr+0x17>
  800c64:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c75:	0f b6 10             	movzbl (%eax),%edx
  800c78:	84 d2                	test   %dl,%dl
  800c7a:	74 18                	je     800c94 <strfind+0x29>
		if (*s == c)
  800c7c:	38 ca                	cmp    %cl,%dl
  800c7e:	75 0a                	jne    800c8a <strfind+0x1f>
  800c80:	eb 12                	jmp    800c94 <strfind+0x29>
  800c82:	38 ca                	cmp    %cl,%dl
  800c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c88:	74 0a                	je     800c94 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c8a:	83 c0 01             	add    $0x1,%eax
  800c8d:	0f b6 10             	movzbl (%eax),%edx
  800c90:	84 d2                	test   %dl,%dl
  800c92:	75 ee                	jne    800c82 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	83 ec 0c             	sub    $0xc,%esp
  800c9c:	89 1c 24             	mov    %ebx,(%esp)
  800c9f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ca3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ca7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800caa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cb0:	85 c9                	test   %ecx,%ecx
  800cb2:	74 30                	je     800ce4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cb4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cba:	75 25                	jne    800ce1 <memset+0x4b>
  800cbc:	f6 c1 03             	test   $0x3,%cl
  800cbf:	75 20                	jne    800ce1 <memset+0x4b>
		c &= 0xFF;
  800cc1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cc4:	89 d3                	mov    %edx,%ebx
  800cc6:	c1 e3 08             	shl    $0x8,%ebx
  800cc9:	89 d6                	mov    %edx,%esi
  800ccb:	c1 e6 18             	shl    $0x18,%esi
  800cce:	89 d0                	mov    %edx,%eax
  800cd0:	c1 e0 10             	shl    $0x10,%eax
  800cd3:	09 f0                	or     %esi,%eax
  800cd5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800cd7:	09 d8                	or     %ebx,%eax
  800cd9:	c1 e9 02             	shr    $0x2,%ecx
  800cdc:	fc                   	cld    
  800cdd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cdf:	eb 03                	jmp    800ce4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ce1:	fc                   	cld    
  800ce2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ce4:	89 f8                	mov    %edi,%eax
  800ce6:	8b 1c 24             	mov    (%esp),%ebx
  800ce9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ced:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cf1:	89 ec                	mov    %ebp,%esp
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	83 ec 08             	sub    $0x8,%esp
  800cfb:	89 34 24             	mov    %esi,(%esp)
  800cfe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d02:	8b 45 08             	mov    0x8(%ebp),%eax
  800d05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800d08:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800d0b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800d0d:	39 c6                	cmp    %eax,%esi
  800d0f:	73 35                	jae    800d46 <memmove+0x51>
  800d11:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d14:	39 d0                	cmp    %edx,%eax
  800d16:	73 2e                	jae    800d46 <memmove+0x51>
		s += n;
		d += n;
  800d18:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d1a:	f6 c2 03             	test   $0x3,%dl
  800d1d:	75 1b                	jne    800d3a <memmove+0x45>
  800d1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d25:	75 13                	jne    800d3a <memmove+0x45>
  800d27:	f6 c1 03             	test   $0x3,%cl
  800d2a:	75 0e                	jne    800d3a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800d2c:	83 ef 04             	sub    $0x4,%edi
  800d2f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d32:	c1 e9 02             	shr    $0x2,%ecx
  800d35:	fd                   	std    
  800d36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d38:	eb 09                	jmp    800d43 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d3a:	83 ef 01             	sub    $0x1,%edi
  800d3d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d40:	fd                   	std    
  800d41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d43:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d44:	eb 20                	jmp    800d66 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d4c:	75 15                	jne    800d63 <memmove+0x6e>
  800d4e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d54:	75 0d                	jne    800d63 <memmove+0x6e>
  800d56:	f6 c1 03             	test   $0x3,%cl
  800d59:	75 08                	jne    800d63 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800d5b:	c1 e9 02             	shr    $0x2,%ecx
  800d5e:	fc                   	cld    
  800d5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d61:	eb 03                	jmp    800d66 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d63:	fc                   	cld    
  800d64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d66:	8b 34 24             	mov    (%esp),%esi
  800d69:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d6d:	89 ec                	mov    %ebp,%esp
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    

00800d71 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d77:	8b 45 10             	mov    0x10(%ebp),%eax
  800d7a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d85:	8b 45 08             	mov    0x8(%ebp),%eax
  800d88:	89 04 24             	mov    %eax,(%esp)
  800d8b:	e8 65 ff ff ff       	call   800cf5 <memmove>
}
  800d90:	c9                   	leave  
  800d91:	c3                   	ret    

00800d92 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	57                   	push   %edi
  800d96:	56                   	push   %esi
  800d97:	53                   	push   %ebx
  800d98:	8b 75 08             	mov    0x8(%ebp),%esi
  800d9b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800da1:	85 c9                	test   %ecx,%ecx
  800da3:	74 36                	je     800ddb <memcmp+0x49>
		if (*s1 != *s2)
  800da5:	0f b6 06             	movzbl (%esi),%eax
  800da8:	0f b6 1f             	movzbl (%edi),%ebx
  800dab:	38 d8                	cmp    %bl,%al
  800dad:	74 20                	je     800dcf <memcmp+0x3d>
  800daf:	eb 14                	jmp    800dc5 <memcmp+0x33>
  800db1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800db6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800dbb:	83 c2 01             	add    $0x1,%edx
  800dbe:	83 e9 01             	sub    $0x1,%ecx
  800dc1:	38 d8                	cmp    %bl,%al
  800dc3:	74 12                	je     800dd7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800dc5:	0f b6 c0             	movzbl %al,%eax
  800dc8:	0f b6 db             	movzbl %bl,%ebx
  800dcb:	29 d8                	sub    %ebx,%eax
  800dcd:	eb 11                	jmp    800de0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dcf:	83 e9 01             	sub    $0x1,%ecx
  800dd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd7:	85 c9                	test   %ecx,%ecx
  800dd9:	75 d6                	jne    800db1 <memcmp+0x1f>
  800ddb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800deb:	89 c2                	mov    %eax,%edx
  800ded:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800df0:	39 d0                	cmp    %edx,%eax
  800df2:	73 15                	jae    800e09 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800df4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800df8:	38 08                	cmp    %cl,(%eax)
  800dfa:	75 06                	jne    800e02 <memfind+0x1d>
  800dfc:	eb 0b                	jmp    800e09 <memfind+0x24>
  800dfe:	38 08                	cmp    %cl,(%eax)
  800e00:	74 07                	je     800e09 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e02:	83 c0 01             	add    $0x1,%eax
  800e05:	39 c2                	cmp    %eax,%edx
  800e07:	77 f5                	ja     800dfe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	57                   	push   %edi
  800e0f:	56                   	push   %esi
  800e10:	53                   	push   %ebx
  800e11:	83 ec 04             	sub    $0x4,%esp
  800e14:	8b 55 08             	mov    0x8(%ebp),%edx
  800e17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e1a:	0f b6 02             	movzbl (%edx),%eax
  800e1d:	3c 20                	cmp    $0x20,%al
  800e1f:	74 04                	je     800e25 <strtol+0x1a>
  800e21:	3c 09                	cmp    $0x9,%al
  800e23:	75 0e                	jne    800e33 <strtol+0x28>
		s++;
  800e25:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e28:	0f b6 02             	movzbl (%edx),%eax
  800e2b:	3c 20                	cmp    $0x20,%al
  800e2d:	74 f6                	je     800e25 <strtol+0x1a>
  800e2f:	3c 09                	cmp    $0x9,%al
  800e31:	74 f2                	je     800e25 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e33:	3c 2b                	cmp    $0x2b,%al
  800e35:	75 0c                	jne    800e43 <strtol+0x38>
		s++;
  800e37:	83 c2 01             	add    $0x1,%edx
  800e3a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e41:	eb 15                	jmp    800e58 <strtol+0x4d>
	else if (*s == '-')
  800e43:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e4a:	3c 2d                	cmp    $0x2d,%al
  800e4c:	75 0a                	jne    800e58 <strtol+0x4d>
		s++, neg = 1;
  800e4e:	83 c2 01             	add    $0x1,%edx
  800e51:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e58:	85 db                	test   %ebx,%ebx
  800e5a:	0f 94 c0             	sete   %al
  800e5d:	74 05                	je     800e64 <strtol+0x59>
  800e5f:	83 fb 10             	cmp    $0x10,%ebx
  800e62:	75 18                	jne    800e7c <strtol+0x71>
  800e64:	80 3a 30             	cmpb   $0x30,(%edx)
  800e67:	75 13                	jne    800e7c <strtol+0x71>
  800e69:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e6d:	8d 76 00             	lea    0x0(%esi),%esi
  800e70:	75 0a                	jne    800e7c <strtol+0x71>
		s += 2, base = 16;
  800e72:	83 c2 02             	add    $0x2,%edx
  800e75:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e7a:	eb 15                	jmp    800e91 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e7c:	84 c0                	test   %al,%al
  800e7e:	66 90                	xchg   %ax,%ax
  800e80:	74 0f                	je     800e91 <strtol+0x86>
  800e82:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800e87:	80 3a 30             	cmpb   $0x30,(%edx)
  800e8a:	75 05                	jne    800e91 <strtol+0x86>
		s++, base = 8;
  800e8c:	83 c2 01             	add    $0x1,%edx
  800e8f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e91:	b8 00 00 00 00       	mov    $0x0,%eax
  800e96:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e98:	0f b6 0a             	movzbl (%edx),%ecx
  800e9b:	89 cf                	mov    %ecx,%edi
  800e9d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ea0:	80 fb 09             	cmp    $0x9,%bl
  800ea3:	77 08                	ja     800ead <strtol+0xa2>
			dig = *s - '0';
  800ea5:	0f be c9             	movsbl %cl,%ecx
  800ea8:	83 e9 30             	sub    $0x30,%ecx
  800eab:	eb 1e                	jmp    800ecb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800ead:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800eb0:	80 fb 19             	cmp    $0x19,%bl
  800eb3:	77 08                	ja     800ebd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800eb5:	0f be c9             	movsbl %cl,%ecx
  800eb8:	83 e9 57             	sub    $0x57,%ecx
  800ebb:	eb 0e                	jmp    800ecb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800ebd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800ec0:	80 fb 19             	cmp    $0x19,%bl
  800ec3:	77 15                	ja     800eda <strtol+0xcf>
			dig = *s - 'A' + 10;
  800ec5:	0f be c9             	movsbl %cl,%ecx
  800ec8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ecb:	39 f1                	cmp    %esi,%ecx
  800ecd:	7d 0b                	jge    800eda <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800ecf:	83 c2 01             	add    $0x1,%edx
  800ed2:	0f af c6             	imul   %esi,%eax
  800ed5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ed8:	eb be                	jmp    800e98 <strtol+0x8d>
  800eda:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800edc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ee0:	74 05                	je     800ee7 <strtol+0xdc>
		*endptr = (char *) s;
  800ee2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ee5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ee7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800eeb:	74 04                	je     800ef1 <strtol+0xe6>
  800eed:	89 c8                	mov    %ecx,%eax
  800eef:	f7 d8                	neg    %eax
}
  800ef1:	83 c4 04             	add    $0x4,%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    
  800ef9:	00 00                	add    %al,(%eax)
  800efb:	00 00                	add    %al,(%eax)
  800efd:	00 00                	add    %al,(%eax)
	...

00800f00 <__udivdi3>:
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	57                   	push   %edi
  800f04:	56                   	push   %esi
  800f05:	83 ec 10             	sub    $0x10,%esp
  800f08:	8b 45 14             	mov    0x14(%ebp),%eax
  800f0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0e:	8b 75 10             	mov    0x10(%ebp),%esi
  800f11:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f14:	85 c0                	test   %eax,%eax
  800f16:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800f19:	75 35                	jne    800f50 <__udivdi3+0x50>
  800f1b:	39 fe                	cmp    %edi,%esi
  800f1d:	77 61                	ja     800f80 <__udivdi3+0x80>
  800f1f:	85 f6                	test   %esi,%esi
  800f21:	75 0b                	jne    800f2e <__udivdi3+0x2e>
  800f23:	b8 01 00 00 00       	mov    $0x1,%eax
  800f28:	31 d2                	xor    %edx,%edx
  800f2a:	f7 f6                	div    %esi
  800f2c:	89 c6                	mov    %eax,%esi
  800f2e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800f31:	31 d2                	xor    %edx,%edx
  800f33:	89 f8                	mov    %edi,%eax
  800f35:	f7 f6                	div    %esi
  800f37:	89 c7                	mov    %eax,%edi
  800f39:	89 c8                	mov    %ecx,%eax
  800f3b:	f7 f6                	div    %esi
  800f3d:	89 c1                	mov    %eax,%ecx
  800f3f:	89 fa                	mov    %edi,%edx
  800f41:	89 c8                	mov    %ecx,%eax
  800f43:	83 c4 10             	add    $0x10,%esp
  800f46:	5e                   	pop    %esi
  800f47:	5f                   	pop    %edi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    
  800f4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f50:	39 f8                	cmp    %edi,%eax
  800f52:	77 1c                	ja     800f70 <__udivdi3+0x70>
  800f54:	0f bd d0             	bsr    %eax,%edx
  800f57:	83 f2 1f             	xor    $0x1f,%edx
  800f5a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800f5d:	75 39                	jne    800f98 <__udivdi3+0x98>
  800f5f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  800f62:	0f 86 a0 00 00 00    	jbe    801008 <__udivdi3+0x108>
  800f68:	39 f8                	cmp    %edi,%eax
  800f6a:	0f 82 98 00 00 00    	jb     801008 <__udivdi3+0x108>
  800f70:	31 ff                	xor    %edi,%edi
  800f72:	31 c9                	xor    %ecx,%ecx
  800f74:	89 c8                	mov    %ecx,%eax
  800f76:	89 fa                	mov    %edi,%edx
  800f78:	83 c4 10             	add    $0x10,%esp
  800f7b:	5e                   	pop    %esi
  800f7c:	5f                   	pop    %edi
  800f7d:	5d                   	pop    %ebp
  800f7e:	c3                   	ret    
  800f7f:	90                   	nop
  800f80:	89 d1                	mov    %edx,%ecx
  800f82:	89 fa                	mov    %edi,%edx
  800f84:	89 c8                	mov    %ecx,%eax
  800f86:	31 ff                	xor    %edi,%edi
  800f88:	f7 f6                	div    %esi
  800f8a:	89 c1                	mov    %eax,%ecx
  800f8c:	89 fa                	mov    %edi,%edx
  800f8e:	89 c8                	mov    %ecx,%eax
  800f90:	83 c4 10             	add    $0x10,%esp
  800f93:	5e                   	pop    %esi
  800f94:	5f                   	pop    %edi
  800f95:	5d                   	pop    %ebp
  800f96:	c3                   	ret    
  800f97:	90                   	nop
  800f98:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800f9c:	89 f2                	mov    %esi,%edx
  800f9e:	d3 e0                	shl    %cl,%eax
  800fa0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fa3:	b8 20 00 00 00       	mov    $0x20,%eax
  800fa8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800fab:	89 c1                	mov    %eax,%ecx
  800fad:	d3 ea                	shr    %cl,%edx
  800faf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800fb3:	0b 55 ec             	or     -0x14(%ebp),%edx
  800fb6:	d3 e6                	shl    %cl,%esi
  800fb8:	89 c1                	mov    %eax,%ecx
  800fba:	89 75 e8             	mov    %esi,-0x18(%ebp)
  800fbd:	89 fe                	mov    %edi,%esi
  800fbf:	d3 ee                	shr    %cl,%esi
  800fc1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800fc5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800fc8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fcb:	d3 e7                	shl    %cl,%edi
  800fcd:	89 c1                	mov    %eax,%ecx
  800fcf:	d3 ea                	shr    %cl,%edx
  800fd1:	09 d7                	or     %edx,%edi
  800fd3:	89 f2                	mov    %esi,%edx
  800fd5:	89 f8                	mov    %edi,%eax
  800fd7:	f7 75 ec             	divl   -0x14(%ebp)
  800fda:	89 d6                	mov    %edx,%esi
  800fdc:	89 c7                	mov    %eax,%edi
  800fde:	f7 65 e8             	mull   -0x18(%ebp)
  800fe1:	39 d6                	cmp    %edx,%esi
  800fe3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800fe6:	72 30                	jb     801018 <__udivdi3+0x118>
  800fe8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800feb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800fef:	d3 e2                	shl    %cl,%edx
  800ff1:	39 c2                	cmp    %eax,%edx
  800ff3:	73 05                	jae    800ffa <__udivdi3+0xfa>
  800ff5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  800ff8:	74 1e                	je     801018 <__udivdi3+0x118>
  800ffa:	89 f9                	mov    %edi,%ecx
  800ffc:	31 ff                	xor    %edi,%edi
  800ffe:	e9 71 ff ff ff       	jmp    800f74 <__udivdi3+0x74>
  801003:	90                   	nop
  801004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801008:	31 ff                	xor    %edi,%edi
  80100a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80100f:	e9 60 ff ff ff       	jmp    800f74 <__udivdi3+0x74>
  801014:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801018:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80101b:	31 ff                	xor    %edi,%edi
  80101d:	89 c8                	mov    %ecx,%eax
  80101f:	89 fa                	mov    %edi,%edx
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	5e                   	pop    %esi
  801025:	5f                   	pop    %edi
  801026:	5d                   	pop    %ebp
  801027:	c3                   	ret    
	...

00801030 <__umoddi3>:
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	57                   	push   %edi
  801034:	56                   	push   %esi
  801035:	83 ec 20             	sub    $0x20,%esp
  801038:	8b 55 14             	mov    0x14(%ebp),%edx
  80103b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80103e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801041:	8b 75 0c             	mov    0xc(%ebp),%esi
  801044:	85 d2                	test   %edx,%edx
  801046:	89 c8                	mov    %ecx,%eax
  801048:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80104b:	75 13                	jne    801060 <__umoddi3+0x30>
  80104d:	39 f7                	cmp    %esi,%edi
  80104f:	76 3f                	jbe    801090 <__umoddi3+0x60>
  801051:	89 f2                	mov    %esi,%edx
  801053:	f7 f7                	div    %edi
  801055:	89 d0                	mov    %edx,%eax
  801057:	31 d2                	xor    %edx,%edx
  801059:	83 c4 20             	add    $0x20,%esp
  80105c:	5e                   	pop    %esi
  80105d:	5f                   	pop    %edi
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    
  801060:	39 f2                	cmp    %esi,%edx
  801062:	77 4c                	ja     8010b0 <__umoddi3+0x80>
  801064:	0f bd ca             	bsr    %edx,%ecx
  801067:	83 f1 1f             	xor    $0x1f,%ecx
  80106a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80106d:	75 51                	jne    8010c0 <__umoddi3+0x90>
  80106f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801072:	0f 87 e0 00 00 00    	ja     801158 <__umoddi3+0x128>
  801078:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80107b:	29 f8                	sub    %edi,%eax
  80107d:	19 d6                	sbb    %edx,%esi
  80107f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801082:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801085:	89 f2                	mov    %esi,%edx
  801087:	83 c4 20             	add    $0x20,%esp
  80108a:	5e                   	pop    %esi
  80108b:	5f                   	pop    %edi
  80108c:	5d                   	pop    %ebp
  80108d:	c3                   	ret    
  80108e:	66 90                	xchg   %ax,%ax
  801090:	85 ff                	test   %edi,%edi
  801092:	75 0b                	jne    80109f <__umoddi3+0x6f>
  801094:	b8 01 00 00 00       	mov    $0x1,%eax
  801099:	31 d2                	xor    %edx,%edx
  80109b:	f7 f7                	div    %edi
  80109d:	89 c7                	mov    %eax,%edi
  80109f:	89 f0                	mov    %esi,%eax
  8010a1:	31 d2                	xor    %edx,%edx
  8010a3:	f7 f7                	div    %edi
  8010a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a8:	f7 f7                	div    %edi
  8010aa:	eb a9                	jmp    801055 <__umoddi3+0x25>
  8010ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010b0:	89 c8                	mov    %ecx,%eax
  8010b2:	89 f2                	mov    %esi,%edx
  8010b4:	83 c4 20             	add    $0x20,%esp
  8010b7:	5e                   	pop    %esi
  8010b8:	5f                   	pop    %edi
  8010b9:	5d                   	pop    %ebp
  8010ba:	c3                   	ret    
  8010bb:	90                   	nop
  8010bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010c0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8010c4:	d3 e2                	shl    %cl,%edx
  8010c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8010c9:	ba 20 00 00 00       	mov    $0x20,%edx
  8010ce:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8010d1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010d4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8010d8:	89 fa                	mov    %edi,%edx
  8010da:	d3 ea                	shr    %cl,%edx
  8010dc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8010e0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8010e3:	d3 e7                	shl    %cl,%edi
  8010e5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8010e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8010ec:	89 f2                	mov    %esi,%edx
  8010ee:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8010f1:	89 c7                	mov    %eax,%edi
  8010f3:	d3 ea                	shr    %cl,%edx
  8010f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8010f9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8010fc:	89 c2                	mov    %eax,%edx
  8010fe:	d3 e6                	shl    %cl,%esi
  801100:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801104:	d3 ea                	shr    %cl,%edx
  801106:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80110a:	09 d6                	or     %edx,%esi
  80110c:	89 f0                	mov    %esi,%eax
  80110e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801111:	d3 e7                	shl    %cl,%edi
  801113:	89 f2                	mov    %esi,%edx
  801115:	f7 75 f4             	divl   -0xc(%ebp)
  801118:	89 d6                	mov    %edx,%esi
  80111a:	f7 65 e8             	mull   -0x18(%ebp)
  80111d:	39 d6                	cmp    %edx,%esi
  80111f:	72 2b                	jb     80114c <__umoddi3+0x11c>
  801121:	39 c7                	cmp    %eax,%edi
  801123:	72 23                	jb     801148 <__umoddi3+0x118>
  801125:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801129:	29 c7                	sub    %eax,%edi
  80112b:	19 d6                	sbb    %edx,%esi
  80112d:	89 f0                	mov    %esi,%eax
  80112f:	89 f2                	mov    %esi,%edx
  801131:	d3 ef                	shr    %cl,%edi
  801133:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801137:	d3 e0                	shl    %cl,%eax
  801139:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80113d:	09 f8                	or     %edi,%eax
  80113f:	d3 ea                	shr    %cl,%edx
  801141:	83 c4 20             	add    $0x20,%esp
  801144:	5e                   	pop    %esi
  801145:	5f                   	pop    %edi
  801146:	5d                   	pop    %ebp
  801147:	c3                   	ret    
  801148:	39 d6                	cmp    %edx,%esi
  80114a:	75 d9                	jne    801125 <__umoddi3+0xf5>
  80114c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80114f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801152:	eb d1                	jmp    801125 <__umoddi3+0xf5>
  801154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801158:	39 f2                	cmp    %esi,%edx
  80115a:	0f 82 18 ff ff ff    	jb     801078 <__umoddi3+0x48>
  801160:	e9 1d ff ff ff       	jmp    801082 <__umoddi3+0x52>
