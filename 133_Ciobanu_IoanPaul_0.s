.data
m1: .space 4000
m2: .space 4000
m3: .space 4000
nrvecini: .space 400
n: .space 4
cerinta: .space 4
fs1: .asciz "%d "
fs2: .asciz "\n"
fs3: .asciz "%d%d%ld"
fs4: .asciz "%d"
index: .space 4
a: .space 4
vecin: .space 4
drum: .space 4   ;//pt cerinta 2
nod1: .space 4   ;//la fel
nod2: .space 4   ;//la fel

.text

matrix_mult:
push %ebp
mov %esp, %ebp
push %ebx
push %esi
push %edi
push %esp


mov 16(%ebp), %edi  ;//edi va contine adresa mres
pushl $0            ;//-20(%ebp) va contoriza liniile
xorl %edx, %edx ;//avem nevoie pt inmultiri
i:
    cmpl -20(%ebp), %eax
    je stop
    
    pushl $0  ;//-24(%ebp) va contoriza coloanele
    j:
        cmpl -24(%ebp), %eax
        je urmatoruli
        
        xorl %ebx, %ebx ;//ebx va contine valoarea ce trebuie pusa in mres[i][j]
        xorl %ecx, %ecx
        k:
            cmp %ecx, %eax
            je urmatorulj
            
            push %ebx ;// avem nevoie sa eliberam un registru

            mull -20(%ebp)  ;// eax <- linie*n
            add %ecx, %eax ;// eax <- linie*n + k
            movl 8(%ebp), %esi ;//esi ia m1
            movl (%esi, %eax, 4), %ebx ;//adaugam in ebx valoarea m1[i][k]

            movl 20(%ebp), %eax  ;//eax reprimeste n
            mull %ecx ;// eax <- n*k
            addl -24(%ebp), %eax ;// eax <- n*k + j
            movl 12(%ebp), %esi ;//esi ia m2
            movl (%esi, %eax, 4), %eax   ;//eax ia valoarea m2[k][j]
            mull %ebx   ;// eax <- m1[i][k]* m2[k][j]
            

            pop %ebx
            add %eax, %ebx  ;// ebx acumuleaza produsele, pentru a fi pus in mres[i][j]            
            mov 20(%ebp), %eax ;// restauram eax           
                
            inc %ecx
            jmp k

        urmatorulj:

        mull -20(%ebp)
        addl -24(%ebp), %eax
        movl %ebx, (%edi, %eax, 4)  ;//punem ebx in mres
        movl 20(%ebp), %eax
        
        incl -24(%ebp)
        jmp j


    urmatoruli:
    incl -20(%ebp)
    addl $4, %esp    ;//trebuie sa resetam contorul coloanelor
    jmp i

stop:

addl $4, %esp ;// scoatem contorul coloanelor

pop %esp
pop %edi
pop %esi
pop %ebx
pop %ebp
ret




.globl main
main:

pushl $cerinta
pushl $fs1
call scanf
popl %eax
popl %eax

lea n, %eax
pushl %eax
pushl $fs1
call scanf
popl %eax
popl %eax

lea nrvecini, %esi
xorl %ecx, %ecx
movl n, %eax
citireNrVecini:
    cmp %ecx, %eax
    je constrAdiac

    pushl %eax
    pushl %ecx
    
    pushl $a
    pushl $fs1
    call scanf
    popl %ebx
    popl %ebx

    popl %ecx
    popl %eax
    
    movl a, %ebx
    movl %ebx, (%esi, %ecx, 4)
    inc %ecx
    jmp citireNrVecini


constrAdiac:


;//prima oara vom umple matricea cu 0
;//movl $n, %eax
lea m1, %edi
xorl %ecx, %ecx   ;//ecx va contoriza liniile
xorl %ebx, %ebx   ;//vom avea nevoie de 0
umpleZeroLinii:
    cmp %eax, %ecx
    je cont1

    xorl %edx, %edx   ;//edx va contoriza coloanele
    umpleZeroCol:
        cmp %eax, %edx
        je iesirefor2
        
        pushl %eax  ;//salvam n
        pushl %edx  ;//salvam col
        movl $0, %edx
        mull %ecx  ;//eax <- linie*n
        popl %edx
        addl %edx, %eax  ;//eax <- linie*n + col
        movl %ebx, (%edi, %eax, 4)  ;// punem val 0 la pozitia eax
        popl %eax
        
        incl %edx
        jmp umpleZeroCol
    
    iesirefor2:
    incl %ecx
    jmp umpleZeroLinii


cont1:

;//movl $n, %eax
movl $0, index  ;// index va reprezenta nodul curent si va contoriza vectorul nrvecini
umpleMatrice:
    movl index, %ecx
    cmp %ecx, %eax
    je cont2
    
    movl (%esi, %ecx, 4), %ebx  ;// ebx primeste nr vecinilor nodului index
    xorl %ecx, %ecx
    parcurgereVecini:
        cmp %ecx, %ebx
        je urmatorulNod
        
        push %eax
        push %ecx
        
        pushl $vecin
        pushl $fs1
        call scanf
        popl %edx
        popl %edx

        popl %ecx
        popl %eax
    
        xorl %edx, %edx
        push %eax  ;//salvam eax (n)
        mull index ;//eax <- n*nod
        addl vecin, %eax  ;// eax <- n*nod + vecin
        movl $1, (%edi, %eax, 4)  ;// punem 1 la pozitia eax in matrice, adica matrice[nod][vecin] = 1
        pop %eax ;// eax reprimeste n
        
        inc %ecx
        jmp parcurgereVecini
    urmatorulNod:
    incl index
    jmp umpleMatrice


cont2:
movl $2, %ebx
cmpl cerinta, %ebx
je citire2


afisareMatrice:

;//movl $n, %eax
xorl %edx, %edx  ;//edx va contoriza liniile
linii:
    cmp %edx, %eax
    je etexit
    
    xorl %ecx, %ecx  ;//ecx va contoriza coloanele
    coloane:
        cmp %ecx, %eax
        je urmatoareaLinie
        
        push %eax
        push %ecx
        push %edx
        
        xorl %edx, %edx
        mull 0(%esp) ;// eax <- n*nod
        addl %ecx, %eax ;// eax <- n*nod + vecin

        pushl (%edi, %eax, 4)
        pushl $fs1
        call printf
        popl %eax
        popl %eax
    
        pushl $0
        call fflush
        pop %eax
        
        pop %edx
        pop %ecx
        pop %eax

        inc %ecx
        jmp coloane

    urmatoareaLinie:
    push %eax    
    push %edx    
    
    pushl $fs2
    call printf
    popl %ebx

    pop %edx
    pop %eax

    inc %edx
    jmp linii


citire2:
push %eax

pushl $nod2
pushl $nod1
pushl $drum
pushl $fs3
call scanf
addl $16, %esp

pop %eax
push %eax
mull %eax
xor %ecx, %ecx
movl $m1, %esi
movl $m2, %edi
copiere:
cmp %ecx, %eax
je cont3

movl (%esi, %ecx, 4), %ebx
movl %ebx, (%edi, %ecx, 4)

inc %ecx
jmp copiere

cont3:
pop %eax

movl drum, %edx
dec %edx
xorl %ecx, %ecx
movl $m2, %esi
movl $m3, %edi
ciclu:
    cmp %ecx, %edx
    je iesire

    push %eax
    push %ecx
    push %edx    

    pushl %eax
    pushl %edi
    pushl %esi
    pushl $m1
    call matrix_mult
    add $16, %esp

    pop %edx
    pop %ecx
    pop %eax 

    mov %esi, %ebx
    mov %edi, %esi
    mov %ebx, %edi    

    inc %ecx
    jmp ciclu

iesire:

mov %esi, %ebx
mov %edi, %esi
mov %ebx, %edi  ;//edi are ca referinta matricea dorita (m2 daca drum e impar, m3 daca drum e par)
;//jmp afisareMatrice
mull nod1
addl nod2, %eax

pushl (%edi, %eax, 4)
pushl $fs4
call printf
add $8, %esp

pushl $0
call fflush
addl $4, %esp

etexit:
movl $1, %eax
xorl %ebx, %ebx
int $0x80
