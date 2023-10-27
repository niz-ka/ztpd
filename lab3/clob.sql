-- Duze obiekty tekstowe

-- Zad 1
CREATE TABLE DOKUMENTY(
    ID NUMBER(12) PRIMARY KEY,
    DOKUMENT CLOB
);

-- Zad 2
DECLARE
        TEXT_STRING CLOB;   
BEGIN
    FOR I IN 1..10000
    LOOP
        TEXT_STRING := CONCAT(TEXT_STRING, 'Oto tekst. ');    
    END LOOP;
    
    INSERT INTO DOKUMENTY VALUES (1, TEXT_STRING);
END;

-- Zad 3
SELECT ID, DOKUMENT FROM DOKUMENTY;
SELECT ID, UPPER(DOKUMENT) AS DOKUMENT FROM DOKUMENTY;
SELECT ID, LENGTH(DOKUMENT) AS DLUGOSC FROM DOKUMENTY;
SELECT ID, DBMS_LOB.GETLENGTH(DOKUMENT) AS DLUGOSC FROM DOKUMENTY;
SELECT ID, SUBSTR(DOKUMENT, 5, 1000) AS FRAGMENT FROM DOKUMENTY;
SELECT ID, DBMS_LOB.SUBSTR(DOKUMENT, 1000, 5) AS FRAGMENT FROM DOKUMENTY;

-- Zad 4
INSERT INTO DOKUMENTY VALUES (2, EMPTY_CLOB());

-- Zad 5
INSERT INTO DOKUMENTY VALUES (3, NULL);
COMMIT;

-- Zad 6
SELECT ID, DOKUMENT FROM DOKUMENTY;
SELECT ID, UPPER(DOKUMENT) AS DOKUMENT FROM DOKUMENTY;
SELECT ID, LENGTH(DOKUMENT) AS DLUGOSC FROM DOKUMENTY;
SELECT ID, DBMS_LOB.GETLENGTH(DOKUMENT) AS DLUGOSC FROM DOKUMENTY;
SELECT ID, SUBSTR(DOKUMENT, 5, 1000) AS FRAGMENT FROM DOKUMENTY;
SELECT ID, DBMS_LOB.SUBSTR(DOKUMENT, 1000, 5) AS FRAGMENT FROM DOKUMENTY;

-- Zad 7
DECLARE
    TEXT_CLOB CLOB;
    FILE_BFILE BFILE := BFILENAME('TPD_DIR', 'dokument.txt');
    doffset integer := 1;
    soffset integer := 1;
    langctx integer := 0;
    warn integer := null;
BEGIN
    SELECT DOKUMENT INTO TEXT_CLOB FROM DOKUMENTY WHERE ID = 2 FOR UPDATE;
    
    DBMS_LOB.FILEOPEN(FILE_BFILE, DBMS_LOB.FILE_READONLY);
    DBMS_LOB.LOADCLOBFROMFILE(TEXT_CLOB, FILE_BFILE, DBMS_LOB.LOBMAXSIZE, doffset, soffset, 0, langctx, warn); 
    DBMS_LOB.FILECLOSE(FILE_BFILE);
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Status operacji: '||warn);
END;

-- Zad 8
UPDATE DOKUMENTY SET DOKUMENT = TO_CLOB(BFILENAME('TPD_DIR', 'dokument.txt'), 0) WHERE ID = 3;

-- Zad 9
SELECT ID, DOKUMENT FROM DOKUMENTY;

-- Zad 10
SELECT ID, DBMS_LOB.GETLENGTH(DOKUMENT) AS DLUGOSC FROM DOKUMENTY;

-- Zad 11
DROP TABLE DOKUMENTY;

-- Zad 12
CREATE OR REPLACE PROCEDURE CLOB_CENSOR(LONG_TEXT IN OUT CLOB, PHRASE VARCHAR2) AS
    OCCURRENCE_POSITION INTEGER := 1;
    PHRASE_LENGTH INTEGER := LENGTH(PHRASE);
    DOTS VARCHAR2(255) := '';
BEGIN
    FOR I IN 1..PHRASE_LENGTH
    LOOP
        DOTS := CONCAT(DOTS, '.');
    END LOOP;
    
    LOOP
        OCCURRENCE_POSITION := DBMS_LOB.INSTR(LONG_TEXT, PHRASE, OCCURRENCE_POSITION, 1);
        EXIT WHEN OCCURRENCE_POSITION IS NULL OR OCCURRENCE_POSITION = 0;
        DBMS_LOB.WRITE(LONG_TEXT, PHRASE_LENGTH, OCCURRENCE_POSITION, DOTS);
    END LOOP;
END;

-- Zad 13
CREATE TABLE BIOGRAPHIES AS SELECT * FROM ZTPD.BIOGRAPHIES; -- Not exists :(

-- Zad 14
DECLARE
    EXAMPLE_TEXT CLOB := 'In 1967 Jiří Šebánek, together with Miloň Čepelka, Ladislav Smoljak and Zdeněk Svěrák, founded the Jára Cimrman Theatre. The first play, written by Svěrák and attributed to Cimrman/Svěrák, was called Akt ("The Nude"), and premiered in October 1967. Jiří Šebánek later left the theatre and in 1980 founded Salon Cimrman. People from the Jára Cimrman Theatre and Salon Cimrman call themselves "cimrmanologists", and pretend to be enthusiastic scholars who explore and analyse Cimrman''s life and work. The plays all follow a similar format; the first half is a seminar in the style of a communist-era public meeting, with the actors taking turns to come onstage and present their "findings", then a comic dramatisation of the topics discussed in the seminar follows in the second half. Salon Cimrman focuses just on lectures supplemented by brief sketches or songs. In total 16 Cimrman plays have been produced.';
    PHRASE VARCHAR2(255) := 'Cimrman';
BEGIN
    CLOB_CENSOR(EXAMPLE_TEXT, PHRASE);
    INSERT INTO DOKUMENTY VALUES(4, EXAMPLE_TEXT);
END;
SELECT ID, DOKUMENT FROM DOKUMENTY WHERE ID = 4;

-- ZAD 15
DROP TABLE BIOGRAPHIES;
