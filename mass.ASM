format PE console

entry start

include 'win32a.inc'

section '.data' data readable writable

        ru db 'Russian',0   ; ��� ������� ������

        string db '%d', 0 ;��� ���������� �����
        strLen db '������� ����� ������� �: ',13,10,0
        strElA db '������� �������� masA: ',13,10,0
        strMasA db 'M����� �: ',13,10,0
        strMasB db 'M����� B: ',13,10,0
        strNet db '��� �������� ��������� � �������',13,10,0

        N dd ? ;������ ������� A
        Ni dd 0 ;������� �������� ���������
        masA dd ?
        masB dd ?
        i dd 0  ; �������
        k dd ? ; �������� ������� ���

        ;�����������
        sm dd ' ',0
        probel db ' %d ', 0
        hashteg db 13,10,'#####################################',13,10,0

        NULL = 0

section '.code' code readable executable

        start:
                cinvoke setlocale,0,ru ;������������� ������� ������

                call readMasA ; ������ ������ ������� �, � ����� ����������
                push hashteg
                call [printf]
                push strMasA     ; ������� � �� �����
                call [printf]
                call printMasA

                push hashteg
                call [printf]
                call makeMasB  ; �������� masB
                push strMasB
                call [printf]
                call prinMasB  ; ����� masB

                call [getch]
                push NULL
                call [ExitProcess]



        proc readMasA
                invoke printf, strLen  ;������� ���������
                invoke scanf, string, N ;��������� ���-�� ���������
                invoke GetProcessHeap
                mov [masA], eax
                mov ecx, 4
                imul ecx, [N]   ;����������� �������� ������ ��� ��������� ������
                invoke HeapAlloc, [masA],0,ecx
                mov [masA], eax
                push strElA
                call [printf]
                add esp, 16
                            ;��������� ��� ������
                mov [i], 0
                lp1:
                        invoke scanf, string, k
                        add esp, 8 ;�������� �� ����� push�� ����� ��������� ��������
                        mov edx, [masA] ;������ ������ � �������,
                        ;����� ��������� � ��� ������
                        mov ebx, [k] ; ������ ��������� �������� � �������

                        inc [i]   ;i++
                        mov eax, [i]  ; ������ ������� � �������

                        mov [edx+eax*4], ebx ;������ � ����� ��������
                        cmp eax, [N]   ; ��������� ��� ������ �� �����
                        jne lp1

             ret

        endp

        proc printMasA
        mov [k],0
            forprint1:
                 mov edx, [masA]
                 inc [k]
                 mov eax, [k]
                 mov ecx,  [edx+eax*4]
                 push ecx
                 push probel
                 call [printf]     ;���������� ������ �� ������� ������� � � �������� printf
                 push sm
                 call [printf]
                 add esp, 12

                 mov eax, [k]
                 cmp eax,[N]
                 jne forprint1

                ret
        endp

        proc makeMasB
             invoke GetProcessHeap
             mov [masB], eax
             mov ecx, 4
             imul ecx, [N]
             invoke HeapAlloc, [masB],0,ecx
             mov [masB], eax
             mov [i],0
             mov esi,2
             mov edx,0;�������� ������� � ��������
             do:
                   mov edi, [masA]   ;�������� ������ � ��������
                   mov ecx, [masB]
                   inc[i]
                   mov ebp, [i]
                   mov eax, [edi+ebp*4] ;���������� � �������� �������
                   div esi
                   cmp edx, 1     ;���� ��� ==1 �� ������ ->masB
                   je equals ; ���� ����� ���� � ����� equals


                      cmp ebp, [N]
                      je  finish
                      jmp do

                equals:
                        inc [Ni] ; ������� ��� ���������

                        mov edi,[masB]
                        mov ecx, [Ni]
                        mul esi ;���������� ��������� �������� eax �� ������� (eax*2+1)
                        inc eax
                        mov ebp,eax
                        mov [edi+ecx*4] ,ebp
                        mov ebp, [i] ;�������� �������� � ������� ��� ���������
                        ;(� ������ �� �����)
                        cmp ebp,[N]
                        je finish
                        jmp do

                finish:
                        ret

             ret
        endp

        proc  prinMasB
            mov [k],0
            cmp [Ni],0
            je fl
            jne flu

            fl:
                 push strNet
                 call [printf]
            ret

            flu:
                 mov edx, [masB]
                 inc [k]
                 mov eax, [k]
                 mov ecx,  [edx+eax*4]
                 push ecx
                 push probel
                 call [printf]     ;���������� ������ �� ������� ������� B
                 ;� �������� printf
                 push sm
                 call [printf]
                 add esp, 12

                 mov eax, [k]
                 cmp eax,[Ni];���������� � ���-��� �������� ���������
                 jne flu

             ret
        endp

section '.idata' import data readable

       library kernel,'kernel32.dll',\
                msvcrt,'msvcrt.dll'
 
        import kernel,\
               ExitProcess,'ExitProcess',\
                HeapAlloc, 'HeapAlloc',\
               GetProcessHeap, 'GetProcessHeap'
                                     ;��������������� ���������� � �������
        import msvcrt,\
               setlocale,'setlocale',\
               printf,'printf',\
               scanf,'scanf',\
               system,'system',\
               getch, '_getch'