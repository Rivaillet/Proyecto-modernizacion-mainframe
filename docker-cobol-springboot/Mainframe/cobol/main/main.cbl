       IDENTIFICATION DIVISION.
       PROGRAM-ID. MAIN.
       AUTHOR. JUAN-BARBERO-SERRANO.
       ENVIRONMENT DIVISION. 
       DATA DIVISION. 
       WORKING-STORAGE SECTION. 
       01 TRAMA-ENTRADA.      
           05 TE-ACCION       PIC X(4)       VALUE SPACES.
           05 FILLER          PIC X(196)      VALUE SPACES.

       01 TRAMA-SALIDA        PIC X(524)     VALUE SPACES.

       PROCEDURE DIVISION.
       0000-MAIN.

           ACCEPT TRAMA-ENTRADA.

           EVALUATE TE-ACCION  
               WHEN 'LOGI'
                    CALL 'MLOGIN'      USING TRAMA-ENTRADA 
                                             TRAMA-SALIDA
      *        WHEN 'TRNF'
      *              CALL 'OTRO-MODULO' USING TRAMA-ENTRADA
      **                                       TRAMA-SALIDA 
      *         WHEN 'RETI'
      *              CALL 'OTRO-MODULO' USING TRAMA-ENTRADA
      *                                       TRAMA-SALIDA 
      *         WHEN 'INGR'
      *              CALL 'OTRO-MODULO' USING TRAMA-ENTRADA
      *                                       TRAMA-SALIDA 
               WHEN 'CONS'
                    CALL 'MCONS' USING TRAMA-ENTRADA
                                             TRAMA-SALIDA 
               WHEN OTHER 
                    MOVE 'ERROR : ACCIÓN INVÁLIDA '
                      TO TRAMA-SALIDA 
           END-EVALUATE.

           DISPLAY TRAMA-SALIDA.

           STOP RUN.

