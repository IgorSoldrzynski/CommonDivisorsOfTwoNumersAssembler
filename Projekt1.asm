; Napisać program, który pobiera dwie liczby z wejścia i oblicza
; ich wspólne dzielniki, a następnie dzielniki te wypisuje na ekranie,
; po jednym w linijce. Program powinien móc wielokrotnie powtarzać 
; operację z różnymi liczbami. Wykorzystać procedury i stos. 
; Przewidzieć sytuacje wyjątkowe.
section .text
org 100h

start:
	mov ah, 9 ; wypisanie początkowego tekstu
	mov dx, napisPoczatek
	int 21h
	
	xor dx, dx ; czyszczenie dx - będzie używany do liczenia

pobierz:
	mov ah, 1 ; Pobranie znaku
	int 21h

	cmp al, 'q' ; czy al='q'(koniec)
	je koniec ; zakończ

	cmp al, 32 ; czy al = 32 (spacja)
	je zapisz1 ; jeśli jest skocz do...

	cmp al, 13 ; czy al = 13 (czy wciśnieto enter)
	je zapisz2 ; jeśli jest skocz do...

	cmp al, 57 ; porównaj czy al < 57 (9)
	ja blad

	cmp al, 48 ; porównaj czy al > 48 (0)
	jb blad


	sub al, 48 ; odejmij od al 48 (odASCIIowanie)
	mov bl, al ; przeniesienie ostaniej cyfry do bl

	mov al, dl ; przeniesienie zapamiętanej liczby


	cmp dl, 25 ; sprawdzanie zakresu (1-255) wprowadzonej liczby
	ja blad
	je sprawdzbl

kontynuuj:
	mov dl, 10 ; mnożenie...
	mul dl ; ...zapamiętanej przez 10
	add al, bl ; dodanie ostatniej cyfry
	mov dl, al ; przeniesienie z powrotem do dl
	
	jmp pobierz

sprawdzbl:
	cmp bl, 5 ; sprawdzanie zakresu cd.
	ja blad
	jmp kontynuuj

zapisz1:
	push dx ; wysłanie naszej liczby na stos
	xor dx, dx ; czyszczenie dx
	jmp pobierz	

zapisz2:
	push dx ; wysłanie naszej liczby na stos
	xor dx, dx ; czyszczenie dx

	mov bp, sp ; sp do bp
	mov cl, 0 ; cl=0

	mov ah, 9 ; tekst "dzielniki..."
	mov dx, wspolne
	int 21h

sprawdz1:
	inc cl ; cl+1
	mov ax, [bp+2] ; pobranie ze stosu do ax

	cmp al, cl ; al=cl
	jb start ; od nowa

	div cl ; al/cl, całości=al, reszta=ah
	cmp ah, 0 ; czy reszta=0
	je sprawdz2
	
	jmp sprawdz1 ; nastepny cl

sprawdz2:
	mov ax, [bp] ; pobranie ze stosu do ax

	cmp al, cl ; al=al
	jb start ; od nowa 

	div cl ; al/cl, całości=al, reszta=ah
	cmp ah, 0 ; czy reszta=0
	je wypiszd ; wypisz liczbę, bo jest wspólnym dzielnikiem
	jmp sprawdz1

wypiszd:
	xor ax, ax ; czyszczenie rejestru ax
	mov al, cl ; al=znaleziony dzielnik

	call wypisz16bAX ; procedura wypisująca dzielnik
	call srednik ; procedura wypisująca średnik

	jmp sprawdz1 ; sprawdzaj kolejną liczbę czy jest dzielnikiem

blad:	
	mov ah, 9 ; informacja o błędzie
	mov dx, bledny
	int 21h
	xor dx, dx ; czyszczenie dx
	jmp start ; powrót do początku

koniec:
	mov ax, 4C00h ; koniec programu
	int 21h


;;;;;;;;; PROCEDURY:

srednik:
	mov ah, 2 ; wypisz średnik
	mov dl, 59 ; znak ;
	int 21h
ret	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; WYPISANIE 16bitowej wartości AX ;;;;;
wypisz16bAX:
	xor ch, ch ; czyść ch (bo w cl jest dzielnik)
w16bit1:
	xor dx, dx ; czyść dx
	mov bx, 10 ; bx=10
	div bx ; ax/10, ax=całości, dx=reszta
	push dx ; stos=dx,...
	inc ch ; ch+1
	cmp ax, 0 ; czy ax==0
	jne w16bit1 ; if(ax!=0)
w16bit2:
	xor dx, dx ; czyść dx
	pop dx ; pobierz ze stosu 
	mov ah, 2 ; wypisz znak
	add dl, 48 ; ASCII
	int 21h
	dec ch ; ch-1
	cmp ch, 0 ; czy ch==0
	jne w16bit2 ; if(ch!=0)
ret
;;;;KONIEC;;; WYPISANIE 16bitowej wartości AX ;;;;;
;;;;;;;;;;DZIAŁA! HAPPY!;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


section .data

napisPoczatek db "",10,13,10,13,"Podaj dwie liczby 1-255 rozdzielone spacja (np. '132 44').",10,13,"ENTER zatwierdza, q - koniec.",10,13,"$"
wspolne db "Wspolne dzielniki",58," $"
bledny db "",10,13,"BLAD! Od nowa. $"
