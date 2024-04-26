

ORG 100H
.DATA 
ID   DW 1001H,1002H,1003H,1004H,1005H,1006H,1007H,1008H,1009H,1010H,1011H,1012H,1013H,1014H,1015H,1016H,1017H,1018H,1019H,1020H  

PASS DW 0H   ,1H   ,2H   ,3H   ,4H   ,5H   ,6H   ,7H   ,8H   ,9H   ,0H   ,1H   ,2H   ,3H   ,4H   ,5H   ,6H   ,7H   ,8H   ,9H

ID_INPUT DB 5,?,5 DUP ('') 
LINE     DB "---------------------------------------------------------------$"
FIRST    DB  "Security lock$"
LAST     DB  "***WELCOME***$" 
GET_ID   DB  "Enter Your ID$"
GET_PASS DB  "Enter Your Password$"
INVALID_ID1 DB "Invalid  ID,Your ID Must consist of 4 HEX Numbers$"
WRONG_ID1   DB "Wrong ID,Please try Again$"
WRONG_PASS DB "Wrong Pass,Please Try Again$"   
NUM_OF_LINE        DB  1H
ADDRES_OF_ID   DW  00H 
PASS_INPUT DB 2,?,2 DUP ('') 
WELCOME  DB  "Welcome$"
.CODE 
MAIN    PROC
       
START:  MOV  AH,9H
        MOV  DX,OFFSET FIRST  
        INT  21H                    ; OUTPUT "Security lock"
         
        
         
RETRY:  CALL NEW_LINE
        MOV  AH,9
        MOV  DX,OFFSET GET_ID 
        INT  21H                    ; OUTPUT "Enter Your ID"
         
        CALL NEW_LINE
        MOV  AH,0AH
        MOV  DX,OFFSET ID_INPUT 
        INT  21H                    ; GET INPUT OF ID 
        
        LEA  SI,ID_INPUT+1          ; SECOND BYTE CONTAINS NUMBER OF CHARS
        CMP  [SI],04H               ; CHECK IF ID CONSIST OF 4 HEX NUMBER  
        JZ   NEXT1
        
        CALL NEW_LINE
        
        MOV  AH,9
        MOV  DX,OFFSET INVALID_ID1
        INT  21H                    ; OUTPUT  "Invalid  ID,Your ID Must consist of 4 HEX Numbers"
        
        JMP  RETRY                  ; JUMP BACK TO GET ID AGAIN
NEXT1:  
        CALL NEW_LINE
        MOV  SI,OFFSET ID_INPUT+2   ; MAKE SI POINTS TO FIRST BYTE OF ID IN MEMORY
        
        CALL  SEARCH_ID
        
        CMP  CX,00H                 ; IF CX=0 THEN SEACRCH ENDED AND DIDNOT FIND ID 
        JNZ  FOUND                  ; CX > 0  THEN ID FOUND
        
        MOV  AH,9
        MOV  DX,OFFSET WRONG_ID1
        INT  21H                    ; OUTPUT"Wrong ID,Please try Again"
        
        JMP  RETRY                  ; JUMP BACK TO GET ID AGAIN
           
FOUND:  MOV  ADDRES_OF_ID,DI        ; STORE ADDRES OF ID FOUNDED FROM DI

        MOV  AH,9
        MOV  DX,OFFSET GET_PASS 
        INT  21H                    ; OUTPUT "Enter Your Password"
         
        CALL NEW_LINE
         
        MOV  AH,0AH
        MOV  DX,OFFSET PASS_INPUT 
        INT  21H                     ; GET INPUT OF PASSWORD
             
         
        MOV  SI,OFFSET PASS_INPUT+2  ; MAKE SI POINTS TO FIRST BYTE OF PASSWORD IN MEMORY
        CALL SEARCH_PASS             ; SEARCH FOR THE PASSWORD
        
        JZ   FOUND2                 
        
        CALL NEW_LINE
        
        MOV  AH,9
        MOV  DX,OFFSET WRONG_PASS 
        INT  21H                    ; OUTPUT"Wrong Pass,Please Try Again"
        
        CALL NEW_LINE
        
        JMP  FOUND                  ; JUMP BACK TO GET PASS AGAIN
        
FOUND2: CALL NEW_LINE

        MOV  AH,9
        MOV  DX,OFFSET LAST 
        INT  21H                    ; OUTPUT "***WELCOME***"
      
   
        CALL NEW_LINE
        
        MOV  AH,9
        MOV  DX,OFFSET LINE         ; OUTPUT "--------------------------------------------"
        INT  21H
        
        CALL NEW_LINE
        
  
        JMP  START                   
        
MAIN    ENDP

        
        
SEARCH_ID   PROC                    ; FUNC SEARCH FOR ID 
            MOV  CX,0004H
            CALL CONVERT_STR_TO_HEX ; CONVERT ID FROM STRING TO HEX 
            SUB  SI,4               ; MAKE SI POINT TO FIRST BYTE OF  ID 
            ;IF ID = 1534
            MOV  AH,[SI]            ; AX=0100
            MOV  AL,[SI+2]          ; AX=0103
            MOV  BH,[SI+1]          ; BX=0500
            MOV  BL,[SI+3]          ; BX=0504 
            SHL  AX,4               ; AX=1030
            OR   AX,BX              ; AX=1534
    
            MOV  CX,20              ; LOAD COUNTER BY 20(NUMBER OF IDS)
            LEA  DI,ID              ; LOAD OFFEST OF IDS IN DI
SEARCH:     CMP AX,[DI]             ; CHECK IF ID IN ARRAY OR NOT
            JZ  FINISH              ; ID FOUND ,JUMP TO FINISH
            INC DI 
            INC DI
            LOOP SEARCH
            
FINISH:            RET
SEARCH_ID ENDP

SEARCH_PASS PROC                     ; FUNC SEARCH FOR PASSWORD
             MOV  CX,0001H
             CALL CONVERT_STR_TO_HEX ; CONVERT PASSWORD FROM STRING TO HEX 
             MOV  BX,ADDRES_OF_ID    ; GET ADDRES THAT WAS INPUT BY THE USER
             ADD  BX,28H             ; ADD 28H (DIFFERENCE BETWEEN ID AND IT'S PASSWORD IN MEMORY) 
             SUB  SI,1               ; MAKE SI POINT TO THE FIRST BYTE OF PASSWORD ARRAY IN MEMORY 
             MOV  AH,[SI]            ; LOAD PASSWORD IN AH
             MOV  AL,0H              ; AX=0100
             SHR  AX,8               ; AX=0001
             CMP  AX,[BX]            ; CHECK IF PASSWORD IS RIGHT OR NOT
             RET
SEARCH_PASS ENDP




CONVERT_STR_TO_HEX PROC              ; FUNC TO CONVERT FROM STRING TO HEX 
L:       CMP [SI],39H
         JBE NUMBER
         JA  LETTER
    
NUMBER:  SUB [SI],30H
         JMP NEXT
         
         

LETTER:  CMP [SI],46H
         JBE CAPITAL
         JA  SMALL
         
CAPITAL: SUB [SI],37H
         JMP NEXT
         
SMALL:   SUB [SI],57H
         JMP NEXT
                  
NEXT:    INC SI
         DEC CX
         JNZ L
         RET
CONVERT_STR_TO_HEX ENDP



NEW_LINE   PROC                     ; FUNC TO MAKE NEW LINE 
        
        MOV AH,2 
        MOV DX,00H
        MOV BX,00H
        MOV DH, NUM_OF_LINE
        INT 10H 
        INC NUM_OF_LINE
        RET
        
NEW_LINE ENDP 











          