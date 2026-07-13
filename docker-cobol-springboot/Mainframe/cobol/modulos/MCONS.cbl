        IDENTIFICATION DIVISION. 
        PROGRAM-ID. MCONS.
        AUTHOR. JUAN-BARBERO.
        ENVIRONMENT DIVISION. 
        DATA DIVISION. 

        WORKING-STORAGE SECTION.

       01  SQLDA-ID pic 9(4) comp-5.
       01  SQLDSIZE pic 9(4) comp-5.
       01  SQL-STMT-ID pic 9(4) comp-5.
       01  SQLVAR-INDEX pic 9(4) comp-5.
       01  SQL-DATA-TYPE pic 9(4) comp-5.
       01  SQL-HOST-VAR-LENGTH pic 9(9) comp-5.
       01  SQL-S-HOST-VAR-LENGTH pic 9(9) comp-5.
       01  SQL-S-LITERAL pic X(258).
       01  SQL-LITERAL1 pic X(130).
       01  SQL-LITERAL2 pic X(130).
       01  SQL-LITERAL3 pic X(130).
       01  SQL-LITERAL4 pic X(130).
       01  SQL-LITERAL5 pic X(130).
       01  SQL-LITERAL6 pic X(130).
       01  SQL-LITERAL7 pic X(130).
       01  SQL-LITERAL8 pic X(130).
       01  SQL-LITERAL9 pic X(130).
       01  SQL-LITERAL10 pic X(130).
       01  SQL-IS-LITERAL pic 9(4) comp-5 value 1.
       01  SQL-IS-INPUT-HVAR pic 9(4) comp-5 value 2.
       01  SQL-CALL-TYPE pic 9(4) comp-5.
       01  SQL-SECTIONUMBER pic 9(4) comp-5.
       01  SQL-INPUT-SQLDA-ID pic 9(4) comp-5.
       01  SQL-OUTPUT-SQLDA-ID pic 9(4) comp-5.
       01  SQL-VERSION-NUMBER pic 9(4) comp-5.
       01  SQL-ARRAY-SIZE pic 9(4) comp-5.
       01  SQL-IS-STRUCT  pic 9(4) comp-5.
       01  SQL-IS-IND-STRUCT pic 9(4) comp-5.
       01  SQL-STRUCT-SIZE pic 9(4) comp-5.
       01  SQLA-PROGRAM-ID.
           05 SQL-PART1 pic 9(4) COMP-5 value 172.
           05 SQL-PART2 pic X(6) value "AEAVAI".
           05 SQL-PART3 pic X(24) value "XAKsMNHq01111 2         ".
           05 SQL-PART4 pic 9(4) COMP-5 value 8.
           05 SQL-PART5 pic X(8) value "DB2INST1".
           05 SQL-PART6 pic X(120) value LOW-VALUES.
           05 SQL-PART7 pic 9(4) COMP-5 value 8.
           05 SQL-PART8 pic X(8) value "MCONS   ".
           05 SQL-PART9 pic X(120) value LOW-VALUES.
                                
        
      *EXEC SQL BEGIN DECLARE SECTION END-EXEC.
        01  WS-ID-CLIENTE           PIC S9(9)         COMP-5.
        01  WS-SALDO-EFECTIVO       PIC S9(10)V99     COMP-3.
        01  WS-SALDO-EMBARGADO      PIC S9(10)V99     COMP-3.
        01  WS-IBAN                 PIC X(24)         VALUE SPACES.
        
      *EXEC SQL END DECLARE SECTION END-EXEC
                                              

        
      *EXEC SQL INCLUDE SQLCA END-EXEC
      * SQL Communication Area - SQLCA
       COPY 'sqlca.cbl'.

                                        
        01  SQL-ERROR               PIC X(9)          VALUE SPACES.

        01  ST-CURSOR-EOF           PIC X             VALUE 'N'.
           88 CURSOR-EOF                              VALUE 'S'.
           88 CURSOR-OK                               VALUE 'N'.
        LINKAGE SECTION.
        01  TRAMA-ENTRADA.
            05 FILLER                PIC X(4).
            05 TE-ID-CLIENTE         PIC 9(9).

        01  TRAMA-SALIDA.
            05 TS-CD-RETORNO         PIC 9(2).       
            05 TS-NUM-CUENTAS        PIC 9(2).        
            05 TS-LISTA-CUENTAS      OCCURS 10 TIMES
                                     INDEXED BY IX-CTA.
               10 TS-IBAN            PIC X(24).        
               10 TS-SALDO-EFECTIVO  PIC +9(10).99.   
               10 TS-SALDO-EMBARGADO PIC +9(10).99.    

        PROCEDURE DIVISION USING TRAMA-ENTRADA 
                                 TRAMA-SALIDA.
        
        0000-MAIN.

           INITIALIZE TRAMA-SALIDA.
           
           
      *EXEC SQL CONNECT TO TESTDB END-EXEC
           CALL "sqlgstrt" USING
              BY CONTENT SQLA-PROGRAM-ID
              BY VALUE 0
              BY REFERENCE SQLCA
           CALL "sqlgmf" USING
              BY VALUE 0

           MOVE 1 TO SQL-STMT-ID 
           MOVE 1 TO SQLDSIZE 
           MOVE 2 TO SQLDA-ID 

           CALL "sqlgaloc" USING
               BY VALUE SQLDA-ID 
                        SQLDSIZE
                        SQL-STMT-ID
                        0

           MOVE "TESTDB"
            TO SQL-LITERAL1
           MOVE 6 TO SQL-HOST-VAR-LENGTH
           MOVE 452 TO SQL-DATA-TYPE
           MOVE 0 TO SQLVAR-INDEX
           MOVE 2 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE SQL-LITERAL1
            BY VALUE 0
                     0

           MOVE 0 TO SQL-OUTPUT-SQLDA-ID 
           MOVE 2 TO SQL-INPUT-SQLDA-ID 
           MOVE 4 TO SQL-SECTIONUMBER 
           MOVE 29 TO SQL-CALL-TYPE 

           CALL "sqlgcall" USING
            BY VALUE SQL-CALL-TYPE 
                     SQL-SECTIONUMBER
                     SQL-INPUT-SQLDA-ID
                     SQL-OUTPUT-SQLDA-ID
                     0

           CALL "sqlgstop" USING
            BY VALUE 0
                                              .
           
           IF SQLCODE NOT = 0
               MOVE 99 TO TS-CD-RETORNO
               DISPLAY "[DB2 ERROR] CONEXION FALLIDA: " SQLCODE
               GOBACK
           END-IF.

                 PERFORM 1000-PROCESAR-CURSOR.
           
           GOBACK.
        
       1000-PROCESAR-CURSOR.
           MOVE TE-ID-CLIENTE TO WS-ID-CLIENTE.
           
           
      *EXEC SQL DECLARE C_CUENTAS CURSOR FOR
      *              SELECT S.EFECTIVO_DISPONIBLE,
      *                     S.EFECTIVO_EMBARGADO,
      *                     CU.IBAN
      *              FROM CLIENTE C
      *              INNER JOIN CUENTA CU ON C.ID_CLIENTE = CU.ID_CLIENTE
      *              INNER JOIN SALDO  S  ON CU.ID_SALDO  = S.ID_SALDO
      *              WHERE C.ID_CLIENTE = :WS-ID-CLIENTE
      *     END-EXEC
                    

           
      *EXEC SQL OPEN C_CUENTAS END-EXEC
           CALL "sqlgstrt" USING
              BY CONTENT SQLA-PROGRAM-ID
              BY VALUE 0
              BY REFERENCE SQLCA
           CALL "sqlgmf" USING
              BY VALUE 0

           MOVE 2 TO SQL-STMT-ID 
           MOVE 1 TO SQLDSIZE 
           MOVE 2 TO SQLDA-ID 

           CALL "sqlgaloc" USING
               BY VALUE SQLDA-ID 
                        SQLDSIZE
                        SQL-STMT-ID
                        0

           MOVE 4 TO SQL-HOST-VAR-LENGTH
           MOVE 496 TO SQL-DATA-TYPE
           MOVE 0 TO SQLVAR-INDEX
           MOVE 2 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-ID-CLIENTE
            BY VALUE 0
                     0

           MOVE 0 TO SQL-OUTPUT-SQLDA-ID 
           MOVE 2 TO SQL-INPUT-SQLDA-ID 
           MOVE 1 TO SQL-SECTIONUMBER 
           MOVE 26 TO SQL-CALL-TYPE 

           CALL "sqlgcall" USING
            BY VALUE SQL-CALL-TYPE 
                     SQL-SECTIONUMBER
                     SQL-INPUT-SQLDA-ID
                     SQL-OUTPUT-SQLDA-ID
                     0

           CALL "sqlgstop" USING
            BY VALUE 0
                                           .
           
           EVALUATE SQLCODE
               WHEN 0
                   SET IX-CTA TO 1
                   PERFORM 2000-LECTURA-CURSOR
                   
                   PERFORM 3000-BUCLE-FETCH 
                      UNTIL CURSOR-EOF OR IX-CTA > 10
                      
                   
      *EXEC SQL CLOSE C_CUENTAS END-EXEC
           CALL "sqlgstrt" USING
              BY CONTENT SQLA-PROGRAM-ID
              BY VALUE 0
              BY REFERENCE SQLCA
           CALL "sqlgmf" USING
              BY VALUE 0

           MOVE 0 TO SQL-OUTPUT-SQLDA-ID 
           MOVE 0 TO SQL-INPUT-SQLDA-ID 
           MOVE 1 TO SQL-SECTIONUMBER 
           MOVE 20 TO SQL-CALL-TYPE 

           CALL "sqlgcall" USING
            BY VALUE SQL-CALL-TYPE 
                     SQL-SECTIONUMBER
                     SQL-INPUT-SQLDA-ID
                     SQL-OUTPUT-SQLDA-ID
                     0

           CALL "sqlgstop" USING
            BY VALUE 0
                                                    
                   
                   IF TS-NUM-CUENTAS > 0
                       MOVE 00 TO TS-CD-RETORNO
                   ELSE
                       MOVE 01 TO TS-CD-RETORNO
                       MOVE TE-ID-CLIENTE  
                         TO TS-IBAN(IX-CTA)
                   END-IF
                   
               WHEN OTHER
                   DISPLAY "[DB2 ERROR] ERROR AL ABRIR CURSOR: " SQLCODE
                   MOVE 99 TO TS-CD-RETORNO
           END-EVALUATE.

       2000-LECTURA-CURSOR.
           
      *EXEC SQL FETCH C_CUENTAS INTO :WS-SALDO-EFECTIVO, 
      *                               :WS-SALDO-EMBARGADO, 
      *                               :WS-IBAN
      *     END-EXEC
           CALL "sqlgstrt" USING
              BY CONTENT SQLA-PROGRAM-ID
              BY VALUE 0
              BY REFERENCE SQLCA
           CALL "sqlgmf" USING
              BY VALUE 0

           MOVE 3 TO SQL-STMT-ID 
           MOVE 3 TO SQLDSIZE 
           MOVE 3 TO SQLDA-ID 

           CALL "sqlgaloc" USING
               BY VALUE SQLDA-ID 
                        SQLDSIZE
                        SQL-STMT-ID
                        0

           MOVE 524 TO SQL-HOST-VAR-LENGTH
           MOVE 484 TO SQL-DATA-TYPE
           MOVE 0 TO SQLVAR-INDEX
           MOVE 3 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-SALDO-EFECTIVO
            BY VALUE 0
                     0

           MOVE 524 TO SQL-HOST-VAR-LENGTH
           MOVE 484 TO SQL-DATA-TYPE
           MOVE 1 TO SQLVAR-INDEX
           MOVE 3 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-SALDO-EMBARGADO
            BY VALUE 0
                     0

           MOVE 24 TO SQL-HOST-VAR-LENGTH
           MOVE 452 TO SQL-DATA-TYPE
           MOVE 2 TO SQLVAR-INDEX
           MOVE 3 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE WS-IBAN
            BY VALUE 0
                     0

           MOVE 3 TO SQL-OUTPUT-SQLDA-ID 
           MOVE 0 TO SQL-INPUT-SQLDA-ID 
           MOVE 1 TO SQL-SECTIONUMBER 
           MOVE 25 TO SQL-CALL-TYPE 

           CALL "sqlgcall" USING
            BY VALUE SQL-CALL-TYPE 
                     SQL-SECTIONUMBER
                     SQL-INPUT-SQLDA-ID
                     SQL-OUTPUT-SQLDA-ID
                     0

           CALL "sqlgstop" USING
            BY VALUE 0
                   .
           
      
           EVALUATE SQLCODE
               WHEN 0
                   SET CURSOR-OK TO TRUE
               WHEN 100
                   SET CURSOR-EOF TO TRUE
               WHEN OTHER
                   DISPLAY "[DB2 ERROR] FETCH FALLIDO: " SQLCODE
                   SET CURSOR-EOF TO TRUE
                   MOVE 99 TO TS-CD-RETORNO
           END-EVALUATE.

       3000-BUCLE-FETCH.
      
           MOVE WS-SALDO-EFECTIVO  TO TS-SALDO-EFECTIVO(IX-CTA).
           MOVE WS-SALDO-EMBARGADO TO TS-SALDO-EMBARGADO(IX-CTA).
           MOVE WS-IBAN            TO TS-IBAN(IX-CTA).
           
           ADD 1 TO TS-NUM-CUENTAS.
           SET IX-CTA UP BY 1.

           PERFORM 2000-LECTURA-CURSOR.

