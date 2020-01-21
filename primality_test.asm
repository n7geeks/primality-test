;------- Description -------
        ;_________________________________________________________________________
        ;|                                                                        |
        ;| Le but de ce programme est d'ecrire une fonction en assembleur capable | 
        ;| de determiner si un entier non signe est un nombre premier ou pas.     |
        ;|                                                                        |
        ;| On donnera un seul parametre d'entree de type entier non signe qui     |
        ;| representera le nombre a tester.                                       |
        ;|                                                                        |
        ;| La valeur de retour doit etre "Premier / Pas Premier"                  |
        ;|                                                                        |
        ;|________________________________________________________________________|



.model small
.stack 200H            ; taille de la pile 200


; ------ Declaration des chaines de caracteres + les variables -----

.data

 	entete1		DB	9,9,   ' ____________________________________',13,'$'
	entete2		DB	10,9,9,'|                                    |',13,'$'
	entete3	    db	10,9,9,'|       # TEST DE PRIMALITE #        |',13,'$'
	entete4		db	10,9,9,'|                                    |',13,'$'
	entete5		db	10,9,9,'| Mohamed BOUKHLIF & Mounir BOULWAFA |',13,'$'
	entete6		db	10,9,9,'|         II_BDCC 1 - ENSETM         |',13,'$'
	entete7		db	10,9,9,'|____________________________________|',13,'$'
	
	                                             
    msg1                DB 10,13,'> Entrez un nombre : $'
    msg_premier         DB 10,13,'> Ce nombre est Premier $'
    msg_pas_premier     DB 10,13,"> Ce nombre n'est pas Premier $"
    msg_erreur          DB 10,13,'> Entrez un nombre valide ! :$'
    msg_recommencer            DB 10,13,'> Voulez-vous recommencer (o/n)? $'  
    divisible           DB 10,13,'> Il est divisible par : $'
    nouv_ligne          DB 10,13,' $'                             ; nouvelle ligne
    
    Nbr dw ?              ;variable pour le nombre enter par le user
    Demi_Nbr dw ?
 
 

	
	


.code   
         
    
    
.startup

JMP Clean_screen

debut:  
	  print entete1           ;Affichage des entetes
	  print entete2
	  print entete3
	  print entete4
	  print entete5
	  print entete6
	  print entete7


    print nouv_ligne
    print msg1
    
    call readnumtoAX       ;Appeler la fonction pour la lecture du nombre Nbr 
    cmp ax, 0              ;test si Nbr = 0
    je PasPremier_0_1               ;si oui jump to afficher Pas Premier
    
    cmp ax, 1              ;test si Nbr = 1
    je PasPremier_0_1               ;si oui jump to afficher Pas Premier
            
    mov cx,2               ;initialiser CX par 2 pour demarrer la division 
    mov Nbr,ax             ;fixer le nombre entrer par le user dans la variable Nbr
    mov dx,0
    div cx                 ;Diviser AX par CX, le quotient sera dans AX et le reste dans DX
    mov Demi_Nbr,ax        ;Demi_Nbr = Nbr/2, pour l'utiliser dans le test de division




; ------ Boucle de test (division seccesive) ------
;Division seccesive du nombre pour savoir s'il est premier ou pas

TEST:
    cmp cx,Demi_Nbr        ;Comparer CX avec Nbr/2
    ja Premier               ;si CX > Nbr/2  ,donc ----> Premier    
    cmp dx,00              ;comparer le reste DX avec 0
    je PasPremier               ;si egaux       ,donc ----> Pas Premier
    inc cx
    mov dx,0               ;initialiser les reste DX a 0
    mov ax,Nbr             ;initialiser le AX avec le nombre initial pour refaire les division 
    div cx                 ;refaire le test (les division)
    jmp TEST
 
 

; ----- affichage du msg: Premier ------
Premier:                  
    print nouv_ligne
    print msg_premier
    print nouv_ligne
    jmp exit
 
 
; ------ affichage du msg: Pas Premier -----
PasPremier:                  
    print nouv_ligne
    print msg_pas_premier
    print nouv_ligne
 
    print divisible        ;afficher le premier diviseur CX 
    mov dx, cx
    add dx, 30h            ;ajouter 30 pour avoir la valeur DECIMAL depuis le HEXADECIMAL
    mov ah, 02h
    int 21h
    jmp exit

 
; ------ affichage du msg: Pas Premier pour le 0 & 1 -----
PasPremier_0_1:
    print nouv_ligne
    print msg_pas_premier  
    print nouv_ligne
 


; ------ affichage du msg de recommencer ----- 

exit:  
    print nouv_ligne        
    print nouv_ligne
    print msg_recommencer   ;affichage du msg "recommencer ou pas ?"

    
    MOV AH,01H
    INT 21H

    cmp al, 6fh             ;6Fh = code ASCI de o               
    je Clean_screen         ;si le choix = o (oui) ,donc effacer l'ecran et recommancer
                            
    cmp al, 4fh             ;4Fh = code ASCI de O            
    je Clean_screen         ;si le choix = o (oui) ,donc effacer l'ecran et recommancer
    

; ------ Sortir du programme ---------------
.exit                        



; ------- effacer l'ecran ----------
;pour effacer l'ecran si on choisi de recommencer le programme
Clean_screen:                     
    mov ax,02
    mov bx,03
    int 10h
    jmp debut               ;jump vers debut du programme

  
  
  
  





; ------- marco qui affiche un message --------

    print MACRO msg                                  
    PUSH AX
    PUSH DX                                          
    MOV AH,09H
    MOV DX,offset msg
    INT 21H
    POP DX
    POP AX
    ENDM  
    
    
    
    

; -------- Fonction Enregistre le nombre dans AX ---------

readnumtoAX PROC NEAR
                             ;inserer BX & CX dans la pile
    PUSH BX
    PUSH CX                  
    MOV CX,10                ;initialisation de BX & CX
    MOV BX,00
 
back:
    MOV AH,01H               ;lecture du nombre enter par le user
    INT 21H 
    cmp Al, 13
    je skip                  ;si on valide avec ENTRER, AX=le nombre puis sortir de la fonction
    
    CMP AL,'0'               ;si le valeur enter n'est pas un chiffre
    JB erreur_saisie         ;donc afficher un message d'erreur
    
    CMP AL,'9'         
    JA erreur_saisie
    
    SUB AL,'0'
    PUSH AX
    MOV AX,BX
    MUL CX
    MOV BX,AX
    POP AX
    MOV AH,00
    ADD BX,AX
    JMP back                 ;lecture du chiffre suivant
 
erreur_saisie:               ;
    print msg_erreur
    MOV AX,0
    MOV CX,10
    MOV BX,00
    jmp back  
 
skip:     
    MOV AX,BX 
    POP CX
    POP BX
    RET
    
readnumtoAX ENDP


    INT 21H
END   