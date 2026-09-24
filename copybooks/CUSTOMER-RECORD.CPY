       01  CUSTOMER-RECORD.
           05  CUSTOMER-ID        PIC X(6).
           05  CUSTOMER-NAME      PIC X(20).
           05  CUSTOMER-BRANCH    PIC X(3).
           05  CUSTOMER-ACCT-TYPE  PIC X(2).
           05  CUSTOMER-STATUS    PIC X(1).
           05  CUSTOMER-BALANCE   PIC 9(10)V99.
           05  CUSTOMER-RESERVED  PIC X(6).

       01  CUSTOMER-REQUEST.
           05  REQUEST-OPERATION   PIC X(1).
           05  REQUEST-ID          PIC X(6).
           05  REQUEST-NAME        PIC X(20).
           05  REQUEST-BRANCH      PIC X(3).
           05  REQUEST-ACCT-TYPE   PIC X(2).
           05  REQUEST-STATUS      PIC X(1).
           05  REQUEST-BALANCE     PIC 9(10)V99.
           05  REQUEST-RESERVED    PIC X(5).
