-- Oracle Text - cwiczenia

-- Zad 1
CREATE TABLE CYTATY AS SELECT * FROM ZTPD.CYTATY;

-- Zad 2
SELECT AUTOR, TEKST FROM CYTATY WHERE UPPER(TEKST) LIKE '%OPTYMISTA%' AND UPPER(TEKST) LIKE '%PESYMISTA%';

-- Zad 3
create index CYTATY_IDX on CYTATY(TEKST)
indextype is CTXSYS.CONTEXT;

-- Zad 4
SELECT AUTOR, TEKST FROM CYTATY WHERE CONTAINS(TEKST, 'OPTYMISTA and PESYMISTA') > 0;

-- Zad 5
SELECT AUTOR, TEKST FROM CYTATY WHERE CONTAINS(TEKST, 'PESYMISTA not OPTYMISTA') > 0;

-- Zad 6
SELECT AUTOR, TEKST FROM CYTATY WHERE CONTAINS(TEKST, 'near((OPTYMISTA, PESYMISTA), 3)') > 0;

-- Zad 7
SELECT AUTOR, TEKST FROM CYTATY WHERE CONTAINS(TEKST, 'near((OPTYMISTA, PESYMISTA), 10)') > 0;

-- Zad 8
SELECT AUTOR, TEKST FROM CYTATY WHERE CONTAINS(TEKST, '?yci%') > 0;

-- Zad 9
SELECT AUTOR, TEKST, CONTAINS(TEKST, '?yci%') SCORE FROM CYTATY WHERE CONTAINS(TEKST, '?yci%') > 0;

-- Zad 10
SELECT * FROM (
    SELECT AUTOR, TEKST, CONTAINS(TEKST, '?yci%') SCORE FROM CYTATY WHERE CONTAINS(TEKST, '?yci%') > 0 ORDER BY SCORE DESC
) WHERE ROWNUM <= 1;

-- Zad 11
SELECT AUTOR, TEKST FROM CYTATY WHERE CONTAINS(TEKST, 'fuzzy(PROBELM)') > 0;

-- Zad 12
INSERT INTO CYTATY(ID, AUTOR, TEKST) VALUES(
    39, 'Bertrand Russell','To smutne, ?e g?upcy s? tacy pewni siebie, a ludzie rozs?dni tacy pe?ni w?tpliwo?ci.'
);

-- Zad 13
SELECT AUTOR, TEKST FROM CYTATY WHERE CONTAINS(TEKST, 'g?upcy') > 0;

-- Zad 14
SELECT * FROM DR$CYTATY_IDX$I WHERE TOKEN_TEXT = 'G?UPCY';

-- Zad 15
DROP INDEX CYTATY_IDX;

create index CYTATY_IDX on CYTATY(TEKST)
indextype is CTXSYS.CONTEXT;

-- Zad 16
SELECT AUTOR, TEKST FROM CYTATY WHERE CONTAINS(TEKST, 'g?upcy') > 0;

-- Zad 17
DROP INDEX CYTATY_IDX;
DROP TABLE CYTATY;

-- #################### Zaawansowane indeksowanie i wyszukiwanie

-- Zad 1
CREATE TABLE QUOTES AS SELECT * FROM ZTPD.QUOTES;

-- Zad 2
create index QUOTES_IDX on QUOTES(TEXT)
indextype is CTXSYS.CONTEXT;

-- Zad 3
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'work') > 0;
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '$work') > 0;
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'working') > 0;
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '$working') > 0;

-- Zad 4
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'it') > 0;

-- Zad 5
SELECT * FROM CTX_STOPLISTS;

-- Zad 6
SELECT * FROM CTX_STOPWORDS;

-- Zad 7
DROP INDEX QUOTES_IDX;

create index QUOTES_IDX on QUOTES(TEXT)
indextype is CTXSYS.CONTEXT
parameters ('STOPLIST CTXSYS.EMPTY_STOPLIST');

-- Zad 8
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'it') > 0;

-- Zad 9
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'FOOL and HUMANS') > 0;

-- Zad 10
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'FOOL and COMPUTER') > 0;

-- Zad 11
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '(FOOL and HUMANS) within sentence') > 0;

-- Zad 12
DROP INDEX QUOTES_IDX;

-- Zad 13
begin
 ctx_ddl.create_section_group('nullgroup', 'NULL_SECTION_GROUP');
 ctx_ddl.add_special_section('nullgroup', 'SENTENCE');
 ctx_ddl.add_special_section('nullgroup', 'PARAGRAPH');
end;

-- Zad 14
create index QUOTES_IDX on QUOTES(TEXT)
indextype is CTXSYS.CONTEXT
parameters ('section group nullgroup');

-- Zad 15
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '(FOOL and HUMANS) within sentence') > 0;
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, '(FOOL and COMPUTER) within sentence') > 0;

-- Zad 16
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'humans') > 0;

-- Zad 17
DROP INDEX QUOTES_IDX;

begin
 ctx_ddl.create_preference('lex_z_m','BASIC_LEXER');
 ctx_ddl.set_attribute('lex_z_m',
 'printjoins', '_-');
 ctx_ddl.set_attribute ('lex_z_m',
 'index_text', 'YES');
end;

create index QUOTES_IDX on QUOTES(TEXT)
indextype is CTXSYS.CONTEXT
parameters ( 'LEXER lex_z_m' );

-- Zad 18
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'humans') > 0;

-- Zad 19
SELECT * FROM QUOTES WHERE CONTAINS(TEXT, 'non\-humans') > 0;

-- Zad 20
DROP INDEX QUOTES_IDX;
DROP TABLE QUOTES;
