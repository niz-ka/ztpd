-- Duze obiekty binarne

-- Zad 1
CREATE TABLE MOVIES AS SELECT * FROM ZTPD.MOVIES;

-- Zad 2
SELECT * FROM MOVIES;
DESCRIBE MOVIES;

-- Zad 3
SELECT ID, TITLE FROM MOVIES WHERE COVER IS NULL;

-- Zad 4
SELECT ID, TITLE, LENGTH(COVER) AS FILESIZE FROM MOVIES WHERE COVER IS NOT NULL;

-- Zad 5
SELECT ID, TITLE, LENGTH(COVER) AS FILESIZE FROM MOVIES WHERE COVER IS NULL;

-- Zad 6
SELECT * FROM ALL_DIRECTORIES;

-- Zad 7
UPDATE MOVIES SET COVER = EMPTY_BLOB(), MIME_TYPE = 'image/jpeg' WHERE ID = 66;
COMMIT;

-- Zad 8
SELECT ID, TITLE, LENGTH(COVER) AS FILESIZE FROM MOVIES WHERE ID IN (65, 66);

-- Zad 9
DECLARE
    COVER_BLOB BLOB;
    FILE_BFILE BFILE := BFILENAME('TPD_DIR', 'escape.jpg');
BEGIN
    SELECT COVER INTO COVER_BLOB FROM MOVIES WHERE ID = 66 FOR UPDATE;
    
    DBMS_LOB.FILEOPEN(FILE_BFILE, DBMS_LOB.FILE_READONLY);
    DBMS_LOB.LOADFROMFILE(COVER_BLOB, FILE_BFILE, DBMS_LOB.GETLENGTH(FILE_BFILE));
    DBMS_LOB.FILECLOSE(FILE_BFILE);
    
    COMMIT;
END;
SELECT ID, TITLE, LENGTH(COVER) FROM MOVIES WHERE ID = 66;

-- Zad 10
CREATE TABLE TEMP_COVERS(
    MOVIE_ID NUMBER(12),
    IMAGE BFILE,
    MIME_TYPE VARCHAR2(50)
);

-- Zad 11
INSERT INTO TEMP_COVERS VALUES(65, BFILENAME('TPD_DIR', 'eagles.jpg'), 'image/jpeg');

-- Zad 12
SELECT MOVIE_ID, DBMS_LOB.GETLENGTH(image) FROM TEMP_COVERS;

-- Zad 13
DECLARE
    COVER_BLOB BLOB;
    FILE_BFILE BFILE;
    MIME_TYPE VARCHAR2(50);
BEGIN
    SELECT IMAGE, MIME_TYPE INTO FILE_BFILE, MIME_TYPE FROM TEMP_COVERS WHERE MOVIE_ID = 65;
    
    DBMS_LOB.CREATETEMPORARY(COVER_BLOB, TRUE);
    DBMS_LOB.FILEOPEN(FILE_BFILE, DBMS_LOB.FILE_READONLY);
   
    DBMS_LOB.LOADFROMFILE(COVER_BLOB, FILE_BFILE, DBMS_LOB.GETLENGTH(FILE_BFILE));
    UPDATE MOVIES SET COVER = COVER_BLOB, MIME_TYPE = MIME_TYPE WHERE ID = 65;
    
    DBMS_LOB.FILECLOSE(FILE_BFILE);
    DBMS_LOB.FREETEMPORARY(COVER_BLOB);
    
    COMMIT;
END;

-- Zad 14
SELECT ID, LENGTH(COVER) AS FILESIZE FROM MOVIES WHERE ID IN (65,66);

-- Zad 15
DROP TABLE MOVIES;
