format PE console

entry start

include 'win32a.inc'

section '.data' data readable writable

        ru db 'Russian',0   ; Для русской локали

        string db '%d', 0 ;Для считывания числа
        strLen db 'Введите длину массива А: ',13,10,0
        strElA db 'Введите элементы masA: ',13,10,0
        strMasA db 'Mассив А: ',13,10,0
        strMasB db 'Mассив B: ',13,10,0
        strNet db 'Нет нечетных элементов в массиве',13,10,0

        N dd ? ;размер массива A
        Ni dd 0 ;счетчик нечетных элементов
        masA dd ?
        masB dd ?
        i dd 0  ; счетчик
        k dd ? ; вводимый элемент мас

        ;Разделители
        sm dd ' ',0
        probel db ' %d ', 0
        hashteg db 13,10,'#####################################',13,10,0

        NULL = 0

section '.code' code readable executable

        start:
                cinvoke setlocale,0,ru ;Устанавливаем русскую локаль

                call readMasA ; Читаем размер массива А, а затем переменные
                push hashteg
                call [printf]
                push strMasA     ; Выводим А на экран
                call [printf]
                call printMasA

                push hashteg
                call [printf]
                call makeMasB  ; Создание masB
                push strMasB
                call [printf]
                call prinMasB  ; Вывод masB

                call [getch]
                push NULL
                call [ExitProcess]



        proc readMasA
                invoke printf, strLen  ;Выводим сообщение
                invoke scanf, string, N ;считываем кол-во элементов
                invoke GetProcessHeap
                mov [masA], eax
                mov ecx, 4
                imul ecx, [N]   ;Динамически выделаем память под введенный размер
                invoke HeapAlloc, [masA],0,ecx
                mov [masA], eax
                push strElA
                call [printf]
                add esp, 16
                            ;Заполняем наш массив
                mov [i], 0
                lp1:
                        invoke scanf, string, k
                        add esp, 8 ;удаление из стека pushей чтобы процедура работала
                        mov edx, [masA] ;массив кладем в регистр,
                        ;чтобы обратится к его ячейке
                        mov ebx, [k] ; кладем введенное значение в регистр

                        inc [i]   ;i++
                        mov eax, [i]  ; кладем счетчик в регистр

                        mov [edx+eax*4], ebx ;кладем в массА значение
                        cmp eax, [N]   ; сравнение для выхода из цикла
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
                 call [printf]     ;Проходимся циклом по ячейкам массива А и вызываем printf
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
             mov edx,0;обнуляем регистр с остатком
             do:
                   mov edi, [masA]   ;помещаем данные в регистры
                   mov ecx, [masB]
                   inc[i]
                   mov ebp, [i]
                   mov eax, [edi+ebp*4] ;обращаемся к элементу массива
                   div esi
                   cmp edx, 1     ;если ост ==1 то нечетн ->masB
                   je equals ; если верно идем в метку equals


                      cmp ebp, [N]
                      je  finish
                      jmp do

                equals:
                        inc [Ni] ; Счетчик неч элементов

                        mov edi,[masB]
                        mov ecx, [Ni]
                        mul esi ;Возвращаем начальное занчение eax до деления (eax*2+1)
                        inc eax
                        mov ebp,eax
                        mov [edi+ecx*4] ,ebp
                        mov ebp, [i] ;Помещаем значения в регистр для сравнения
                        ;(и выхода из метки)
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
                 call [printf]     ;Проходимся циклом по ячейкам массива B
                 ;и вызываем printf
                 push sm
                 call [printf]
                 add esp, 12

                 mov eax, [k]
                 cmp eax,[Ni];Сравниваем с кол-вом нечетных элементов
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
                                     ;импортированные библиотеки и функции
        import msvcrt,\
               setlocale,'setlocale',\
               printf,'printf',\
               scanf,'scanf',\
               system,'system',\
               getch, '_getch'