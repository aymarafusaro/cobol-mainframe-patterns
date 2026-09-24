       IDENTIFICATION DIVISION.
       PROGRAM-ID. CUSTOMER-ABM.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT CUSTOMER-FILE
               ASSIGN TO
               "lessons/01-abm/data/input/customer-master.dat"
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-CUSTOMER-STATUS.

           SELECT REQUEST-FILE
               ASSIGN TO
               "lessons/01-abm/data/input/customer-requests.dat"
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-REQUEST-STATUS.

           SELECT NEW-CUSTOMER-FILE
               ASSIGN TO
               "lessons/01-abm/data/output/customer-master-new.dat"
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-NEW-CUSTOMER-STATUS.

           SELECT REPORT-FILE
               ASSIGN TO
               "lessons/01-abm/data/output/abm-report.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-REPORT-STATUS.

       DATA DIVISION.
       FILE SECTION.

       FD  CUSTOMER-FILE.
       01  CUSTOMER-INPUT-RECORD.
           05  CUSTOMER-INPUT-DATA PIC X(50).

       FD  REQUEST-FILE.
       01  REQUEST-INPUT-RECORD.
           05  REQUEST-INPUT-DATA PIC X(50).

       FD  NEW-CUSTOMER-FILE.
       01  NEW-CUSTOMER-OUTPUT-RECORD.
           05  NEW-CUSTOMER-OUTPUT-DATA PIC X(50).

       FD  REPORT-FILE.
       01  REPORT-OUTPUT-RECORD PIC X(100).

       WORKING-STORAGE SECTION.

       COPY "copybooks/CUSTOMER-RECORD.CPY".

       01  WS-CUSTOMER-STATUS          PIC XX.
       01  WS-REQUEST-STATUS           PIC XX.
       01  WS-NEW-CUSTOMER-STATUS      PIC XX.
       01  WS-REPORT-STATUS            PIC XX.
       01  WS-END-CUSTOMER             PIC X     VALUE "N".
       01  WS-END-REQUEST              PIC X     VALUE "N".
       01  WS-CUSTOMER-FOUND           PIC X     VALUE "N".
       01  WS-CUSTOMER-COUNT           PIC 9(4)  VALUE 0.
       01  WS-REQUEST-COUNT            PIC 9(4)  VALUE 0.
       01  WS-ADD-COUNT                PIC 9(4)  VALUE 0.
       01  WS-MODIFY-COUNT             PIC 9(4)  VALUE 0.
       01  WS-DELETE-COUNT             PIC 9(4)  VALUE 0.
       01  WS-ERROR-COUNT              PIC 9(4)  VALUE 0.
       01  WS-REQUEST-RESULT           PIC X(100).
       01  WS-TABLE-INDEX              PIC 9(4).
       01  WS-FOUND-INDEX              PIC 9(4)  VALUE 0.
       01  WS-TABLE-FOUND              PIC X     VALUE "N".
       01  WS-CUSTOMER-TABLE.
           05  WS-CUSTOMER-ENTRY       OCCURS 100 TIMES.
               10  WS-TABLE-RECORD     PIC X(50).

       PROCEDURE DIVISION.

       MAIN-PROCESS.

           DISPLAY "========================================"
           DISPLAY "             ABM DE CLIENTES"
           DISPLAY "========================================"

           PERFORM OPEN-INPUT-FILES

           IF RETURN-CODE = 0
               PERFORM LOAD-CUSTOMERS
           END-IF

           IF RETURN-CODE = 0
               PERFORM PROCESS-REQUESTS
           END-IF

           IF RETURN-CODE = 0
               PERFORM WRITE-NEW-MASTER
           END-IF

           PERFORM CLOSE-INPUT-FILES

           DISPLAY "========================================"
           DISPLAY "CLIENTES CARGADOS:    " WS-CUSTOMER-COUNT
           DISPLAY "SOLICITUDES PROCESADAS: " WS-REQUEST-COUNT
           DISPLAY "ALTAS:                " WS-ADD-COUNT
           DISPLAY "MODIFICACIONES:       " WS-MODIFY-COUNT
           DISPLAY "BAJAS:                " WS-DELETE-COUNT
           DISPLAY "ERRORES:              " WS-ERROR-COUNT
           DISPLAY "RETURN-CODE:         " RETURN-CODE
           DISPLAY "========================================"

           STOP RUN.

       OPEN-INPUT-FILES.

           OPEN INPUT CUSTOMER-FILE

           IF WS-CUSTOMER-STATUS NOT = "00"
               DISPLAY "ERROR AL ABRIR ARCHIVO DE CLIENTES: "
                   WS-CUSTOMER-STATUS
               MOVE 8 TO RETURN-CODE
               GO TO OPEN-INPUT-END
           END-IF

           OPEN INPUT REQUEST-FILE

           IF WS-REQUEST-STATUS NOT = "00"
               DISPLAY "ERROR AL ABRIR ARCHIVO DE SOLICITUDES: "
                   WS-REQUEST-STATUS
               MOVE 8 TO RETURN-CODE
               GO TO OPEN-INPUT-END
           END-IF

           OPEN OUTPUT REPORT-FILE

           IF WS-REPORT-STATUS NOT = "00"
               DISPLAY "ERROR AL ABRIR ARCHIVO DE REPORTE: "
                   WS-REPORT-STATUS
               MOVE 8 TO RETURN-CODE
           END-IF.

       OPEN-INPUT-END.
           EXIT.

       LOAD-CUSTOMERS.

           MOVE "N" TO WS-END-CUSTOMER

           PERFORM UNTIL WS-END-CUSTOMER = "Y"

               READ CUSTOMER-FILE

                   AT END
                       MOVE "Y" TO WS-END-CUSTOMER

                   NOT AT END
                       ADD 1 TO WS-CUSTOMER-COUNT

                       MOVE CUSTOMER-INPUT-DATA
                           TO WS-TABLE-RECORD
                              (WS-CUSTOMER-COUNT)

               END-READ

           END-PERFORM.

       PROCESS-REQUESTS.

           MOVE "N" TO WS-END-REQUEST

           PERFORM UNTIL WS-END-REQUEST = "Y"

               READ REQUEST-FILE

                   AT END
                       MOVE "Y" TO WS-END-REQUEST

                   NOT AT END
                       ADD 1 TO WS-REQUEST-COUNT

                       MOVE REQUEST-INPUT-DATA
                           TO CUSTOMER-REQUEST

                       EVALUATE REQUEST-OPERATION

                           WHEN "A"
                               PERFORM PROCESS-ADD

                           WHEN "M"
                               PERFORM PROCESS-MODIFY

                           WHEN "D"
                               PERFORM PROCESS-DELETE

                           WHEN OTHER
                               STRING
                                   "INVALID OPERATION - "
                                   REQUEST-OPERATION
                                   DELIMITED BY SIZE
                                   INTO WS-REQUEST-RESULT
                               END-STRING

                               ADD 1 TO WS-ERROR-COUNT

                               PERFORM WRITE-RESULT

                       END-EVALUATE

               END-READ

           END-PERFORM.

       PROCESS-ADD.

           MOVE SPACES TO WS-REQUEST-RESULT

           PERFORM FIND-CUSTOMER

           IF WS-TABLE-FOUND = "Y"

               STRING
                   "ALTA       "
                   REQUEST-ID
                   " ERROR: CLIENTE YA EXISTE"
                   DELIMITED BY SIZE
                   INTO WS-REQUEST-RESULT
               END-STRING

               ADD 1 TO WS-ERROR-COUNT

           ELSE

               IF WS-CUSTOMER-COUNT < 100

                   ADD 1 TO WS-CUSTOMER-COUNT

                   MOVE REQUEST-ID          TO CUSTOMER-ID
                   MOVE REQUEST-NAME        TO CUSTOMER-NAME
                   MOVE REQUEST-BRANCH      TO CUSTOMER-BRANCH
                   MOVE REQUEST-ACCT-TYPE   TO CUSTOMER-ACCT-TYPE
                   MOVE REQUEST-STATUS      TO CUSTOMER-STATUS
                   MOVE REQUEST-BALANCE     TO CUSTOMER-BALANCE
                   MOVE REQUEST-RESERVED    TO CUSTOMER-RESERVED

                   MOVE CUSTOMER-RECORD     TO WS-TABLE-RECORD
                                            (WS-CUSTOMER-COUNT)

                   STRING
                       "ALTA       "
                       REQUEST-ID
                       " OK"
                       DELIMITED BY SIZE
                       INTO WS-REQUEST-RESULT
                   END-STRING

                   ADD 1 TO WS-ADD-COUNT

               ELSE

                   STRING
                       "ALTA       "
                       REQUEST-ID
                       " ERROR: TABLA COMPLETA"
                       DELIMITED BY SIZE
                       INTO WS-REQUEST-RESULT
                   END-STRING

                   ADD 1 TO WS-ERROR-COUNT

               END-IF

           END-IF

           PERFORM WRITE-RESULT.

       PROCESS-MODIFY.

           MOVE SPACES TO WS-REQUEST-RESULT

           PERFORM FIND-CUSTOMER

           IF WS-TABLE-FOUND = "Y"
               MOVE REQUEST-ID         TO CUSTOMER-ID
               MOVE REQUEST-NAME       TO CUSTOMER-NAME
               MOVE REQUEST-BRANCH     TO CUSTOMER-BRANCH
               MOVE REQUEST-ACCT-TYPE  TO CUSTOMER-ACCT-TYPE
               MOVE REQUEST-STATUS     TO CUSTOMER-STATUS
               MOVE REQUEST-BALANCE    TO CUSTOMER-BALANCE
               MOVE REQUEST-RESERVED   TO CUSTOMER-RESERVED

               MOVE CUSTOMER-RECORD    TO WS-TABLE-RECORD
                                       (WS-FOUND-INDEX)

               STRING
                   "MODIFICAR  "
                   REQUEST-ID
                   " OK"
                   DELIMITED BY SIZE
                   INTO WS-REQUEST-RESULT
               END-STRING

               ADD 1 TO WS-MODIFY-COUNT
           ELSE
               STRING
                   "MODIFICAR  "
                   REQUEST-ID
                   " ERROR: CLIENTE NO ENCONTRADO"
                   DELIMITED BY SIZE
                   INTO WS-REQUEST-RESULT
               END-STRING

               ADD 1 TO WS-ERROR-COUNT
           END-IF

           PERFORM WRITE-RESULT.

       PROCESS-DELETE.

           MOVE SPACES TO WS-REQUEST-RESULT
           
           PERFORM FIND-CUSTOMER

           IF WS-TABLE-FOUND = "Y"

               PERFORM DELETE-CUSTOMER

               STRING
                   "BAJA       "
                   REQUEST-ID
                   " OK"
                   DELIMITED BY SIZE
                   INTO WS-REQUEST-RESULT
               END-STRING

               ADD 1 TO WS-DELETE-COUNT

           ELSE

               STRING
                   "BAJA       "
                   REQUEST-ID
                   " ERROR: CLIENTE NO ENCONTRADO"
                   DELIMITED BY SIZE
                   INTO WS-REQUEST-RESULT
               END-STRING

               ADD 1 TO WS-ERROR-COUNT

           END-IF

           PERFORM WRITE-RESULT.

       FIND-CUSTOMER.

           MOVE "N" TO WS-TABLE-FOUND
           MOVE 0 TO WS-TABLE-INDEX
           MOVE 0 TO WS-FOUND-INDEX

           PERFORM VARYING WS-TABLE-INDEX FROM 1 BY 1
               UNTIL WS-TABLE-INDEX > WS-CUSTOMER-COUNT
                  OR WS-TABLE-FOUND = "Y"

               IF WS-TABLE-RECORD(WS-TABLE-INDEX)(1:6)
                   = REQUEST-ID

                   MOVE "Y" TO WS-TABLE-FOUND
                   MOVE WS-TABLE-INDEX TO WS-FOUND-INDEX

               END-IF

           END-PERFORM.

       DELETE-CUSTOMER.

           PERFORM VARYING WS-TABLE-INDEX
               FROM WS-FOUND-INDEX BY 1
               UNTIL WS-TABLE-INDEX >= WS-CUSTOMER-COUNT

               MOVE WS-TABLE-RECORD(WS-TABLE-INDEX + 1)
                   TO WS-TABLE-RECORD(WS-TABLE-INDEX)

           END-PERFORM

           MOVE SPACES
               TO WS-TABLE-RECORD(WS-CUSTOMER-COUNT)

           SUBTRACT 1 FROM WS-CUSTOMER-COUNT.

       WRITE-NEW-MASTER.

           OPEN OUTPUT NEW-CUSTOMER-FILE

           IF WS-NEW-CUSTOMER-STATUS NOT = "00"

               DISPLAY "ERROR AL ABRIR NUEVO ARCHIVO MAESTRO: "
                   WS-NEW-CUSTOMER-STATUS

               MOVE 8 TO RETURN-CODE

           ELSE

               PERFORM VARYING WS-TABLE-INDEX
                   FROM 1 BY 1
                   UNTIL WS-TABLE-INDEX > WS-CUSTOMER-COUNT

                   MOVE WS-TABLE-RECORD(WS-TABLE-INDEX)
                       TO NEW-CUSTOMER-OUTPUT-DATA

                   WRITE NEW-CUSTOMER-OUTPUT-RECORD

               END-PERFORM

               CLOSE NEW-CUSTOMER-FILE

           END-IF.

       WRITE-RESULT.

           DISPLAY WS-REQUEST-RESULT

           MOVE WS-REQUEST-RESULT
               TO REPORT-OUTPUT-RECORD

           WRITE REPORT-OUTPUT-RECORD.

       CLOSE-INPUT-FILES.

           CLOSE CUSTOMER-FILE
           CLOSE REQUEST-FILE
           CLOSE REPORT-FILE.

       END PROGRAM CUSTOMER-ABM.
