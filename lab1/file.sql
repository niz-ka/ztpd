-- Tworzenie typów obiektowych

CREATE TYPE samochod AS OBJECT (
        marka          VARCHAR(20),
        model          VARCHAR(20),
        kilometry      NUMBER,
        data_produkcji DATE,
        cena           NUMBER(10, 2)
);

desc samochod;

CREATE TABLE samochody OF samochod;

INSERT INTO samochody VALUES (
    NEW samochod ( 'FIAT', 'BRAVA', 60000, DATE '1999-11-30', 25000 )
);

INSERT INTO samochody VALUES (
    NEW samochod ( 'FORD', 'MONDEO', 80000, DATE '1997-05-10', 45000 )
);

INSERT INTO samochody VALUES (
    NEW samochod ( 'MAZDA', '323', 12000, DATE '2000-09-22', 52000 )
);

SELECT
    *
FROM
    samochody;

CREATE TABLE wlasciciele (
    imie     VARCHAR2(100),
    nazwisko VARCHAR2(100),
    auto     samochod
);

INSERT INTO wlasciciele VALUES (
    'JAN',
    'KOWALSKI',
        NEW samochod ( 'FIAT', 'SEICENTO', 30000, DATE '0010-12-02', 19500 )
);

INSERT INTO wlasciciele VALUES (
    'ADAM',
    'NOWAK',
        NEW samochod ( 'OPEL', 'ASTRA', 34000, DATE '0009-06-01', 33700 )
);

SELECT
    *
FROM
    wlasciciele;

ALTER TYPE SAMOCHOD REPLACE AS OBJECT (
    MARKA VARCHAR(20),
    MODEL VARCHAR(20),
    KILOMETRY NUMBER,
    DATA_PRODUKCJI DATE,
    CENA NUMBER(10,2),
    MEMBER FUNCTION wartosc RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY SAMOCHOD AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
       RETURN cena * power(0.9, EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM DATA_PRODUKCJI));
    END wartosc;
END;

SELECT s.marka, s.cena, s.wartosc() FROM SAMOCHODY s;

ALTER TYPE SAMOCHOD ADD MAP MEMBER FUNCTION odwzoruj
RETURN NUMBER CASCADE INCLUDING TABLE DATA;

CREATE OR REPLACE TYPE BODY SAMOCHOD AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
       RETURN cena * power(0.9, EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM DATA_PRODUKCJI));
    END wartosc;
    
    MAP MEMBER FUNCTION odwzoruj RETURN NUMBER IS
    BEGIN
        RETURN kilometry + 10000 * (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM DATA_PRODUKCJI));
    END odwzoruj;
END;

SELECT * FROM SAMOCHODY s ORDER BY VALUE(s);

CREATE TYPE WLASCICIEL AS OBJECT (
    IMIE VARCHAR(50),
    NAZWISKO VARCHAR(50)
);

DELETE FROM SAMOCHODY;
DROP TABLE SAMOCHODY;
DROP TABLE WLASCICIELE;
DROP TYPE SAMOCHOD;

CREATE TYPE SAMOCHOD AS OBJECT (
    MARKA VARCHAR(20),
    MODEL VARCHAR(20),
    KILOMETRY NUMBER,
    DATA_PRODUKCJI DATE,
    CENA NUMBER(10,2),
    WLASCICIEL_COL REF WLASCICIEL
);
CREATE TABLE SAMOCHODY OF SAMOCHOD;
CREATE TABLE WLASCICIELE OF WLASCICIEL;

INSERT INTO WLASCICIELE VALUES (
    NEW WLASCICIEL('Jan', 'Nowak')
);

INSERT INTO SAMOCHODY VALUES (
    NEW SAMOCHOD('FIAT', 'BRAVA', 60000, DATE '1999-11-30', 25000, (select ref(w) from wlasciciele w where nazwisko = 'Nowak'))
);

SELECT * FROM SAMOCHODY;

-- Kolekcje

-- ZAD 7
DECLARE
 TYPE t_ksiazki IS VARRAY(3) OF VARCHAR2(20);
 ksiazki t_ksiazki := t_ksiazki();
BEGIN
    -- rozszerz
    ksiazki.extend(3);
    
    -- wstaw
    ksiazki(1) := 'Rok 1984';
    ksiazki(2) := 'Potop';
    ksiazki(3) := 'Romeo i Julia';
    
    -- usu?
    ksiazki.trim(1);
    
    FOR i IN ksiazki.first()..ksiazki.last() LOOP
        dbms_output.put_line(ksiazki(i));
    END LOOP;
END;

-- ZAD 9 
DECLARE
 TYPE t_miesiace IS TABLE OF VARCHAR2(20);
 miesiace
t_miesiace := t_miesiace();

BEGIN
    -- rozszerz
    miesiace.extend(12);
    
    -- wstaw
    miesiace(1) := 'stycze?';
    miesiace(2) := 'luty';
    miesiace(3) := 'marzec';
    miesiace(4) := 'kwiece?';
    miesiace(5) := 'maj';
    miesiace(6) := 'czerwiec';
    miesiace(7) := 'lipiec';
    miesiace(8) := 'sierpie?';
    miesiace(9) := 'wrzesie?';
    miesiace(10) := 'pa?dziernik';
    miesiace(11) := 'listopad';
    miesiace(12) := 'grudzie?';
    
    -- usu?
    miesiace.DELETE(4, 8);
    
    -- wyswietl
    FOR i IN miesiace.first()..miesiace.last() LOOP
        IF miesiace.EXISTS(i) THEN
            dbms_output.put_line(miesiace(i));
        END IF;
    END LOOP;

END;

-- ZAD 11
CREATE TYPE koszyk_produktow AS
    TABLE OF VARCHAR2(20);

CREATE TYPE zakup AS OBJECT (
        numer  NUMBER,
        koszyk koszyk_produktow
);

CREATE TABLE zakupy OF zakup
NESTED TABLE koszyk STORE AS tab_koszyk;

INSERT INTO zakupy VALUES ( zakup(1,
                                  koszyk_produktow('Marchew', 'Mleko', 'Jab?ka')) );

INSERT INTO zakupy VALUES ( zakup(2,
                                  koszyk_produktow('Banany', 'Kasza', 'Mleko')) );

INSERT INTO zakupy VALUES ( zakup(3,
                                  koszyk_produktow('Bu?ki', 'Chleb', 'Ry?')) );

SELECT
    *
FROM
    zakupy;

BEGIN
    FOR r IN (
        SELECT
            numer,
            koszyk
        FROM
            zakupy
        ORDER BY
            numer
    ) LOOP
        IF 'Mleko' MEMBER OF r.koszyk THEN
            DELETE FROM zakupy
            WHERE
                numer = r.numer;

        END IF;
    END LOOP;
END;

SELECT
    *
FROM
    zakupy;

-- Polimorfizm, dziedziczenie, perspektywy obiektowe

-- ZAD 22
CREATE TABLE PISARZE (
 ID_PISARZA NUMBER PRIMARY KEY,
 NAZWISKO VARCHAR2(20),
 DATA_UR DATE );

CREATE TYPE PISARZ AS OBJECT (
 ID_PISARZA NUMBER,
 NAZWISKO VARCHAR2(20),
 DATA_UR DATE,
 MEMBER FUNCTION ILE_KSIAZEK RETURN NUMBER
 );
 
CREATE OR REPLACE VIEW PISARZE_V OF PISARZ
WITH OBJECT IDENTIFIER (ID_PISARZA)
AS SELECT ID_PISARZA, NAZWISKO, DATA_UR
FROM PISARZE;

 CREATE TABLE KSIAZKI (
 ID_KSIAZKI NUMBER PRIMARY KEY,
 ID_PISARZA NUMBER NOT NULL REFERENCES PISARZE,
 TYTUL VARCHAR2(50),
 DATA_WYDANIE DATE );

CREATE TYPE KSIAZKA AS OBJECT (
 ID_KSIAZKI NUMBER,
 AUTOR REF PISARZ,
 TYTUL VARCHAR2(50),
 DATA_WYDANIE DATE,
 MEMBER FUNCTION ILE_LAT RETURN NUMBER
 ); 
 
 CREATE OR REPLACE VIEW KSIAZKI_V OF KSIAZKA
WITH OBJECT IDENTIFIER (ID_KSIAZKI)
AS SELECT ID_KSIAZKI, MAKE_REF(PISARZE_V,ID_PISARZA) AS AUTOR, TYTUL, DATA_WYDANIE
FROM
ksiazki;

CREATE OR REPLACE TYPE BODY pisarz AS
    MEMBER FUNCTION ile_ksiazek RETURN NUMBER IS
        ret_value NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO ret_value
        FROM
            ksiazki_v k
        WHERE
            k.autor.id_pisarza = id_pisarza;

        RETURN ret_value;
    END ile_ksiazek;

END;

CREATE OR REPLACE TYPE BODY ksiazka AS
    MEMBER FUNCTION ile_lat RETURN NUMBER IS
    BEGIN
        RETURN extract(YEAR FROM current_date) - extract(YEAR FROM data_wydanie);
    END ile_lat;

END;

INSERT INTO pisarze VALUES (
    10,
    'SIENKIEWICZ',
    DATE '1880-01-01'
);

INSERT INTO pisarze VALUES (
    20,
    'PRUS',
    DATE '1890-04-12'
);

INSERT INTO pisarze VALUES (
    30,
    'ZEROMSKI',
    DATE '1899-09-11'
);

INSERT INTO ksiazki (
    id_ksiazki,
    id_pisarza,
    tytul,
    data_wydanie
) VALUES (
    10,
    10,
    'OGNIEM I MIECZEM',
    DATE '1990-01-05'
);

INSERT INTO ksiazki (
    id_ksiazki,
    id_pisarza,
    tytul,
    data_wydanie
) VALUES (
    20,
    10,
    'POTOP',
    DATE '1975-12-09'
);

INSERT INTO ksiazki (
    id_ksiazki,
    id_pisarza,
    tytul,
    data_wydanie
) VALUES (
    30,
    10,
    'PAN WOLODYJOWSKI',
    DATE '1987-02-15'
);

INSERT INTO ksiazki (
    id_ksiazki,
    id_pisarza,
    tytul,
    data_wydanie
) VALUES (
    40,
    20,
    'FARAON',
    DATE '1948-01-21'
);

INSERT INTO ksiazki (
    id_ksiazki,
    id_pisarza,
    tytul,
    data_wydanie
) VALUES (
    50,
    20,
    'LALKA',
    DATE '1994-08-01'
);

INSERT INTO ksiazki (
    id_ksiazki,
    id_pisarza,
    tytul,
    data_wydanie
) VALUES (
    60,
    30,
    'PRZEDWIOSNIE',
    DATE '1938-02-02'
);

SELECT
    k.tytul,
    k.autor.nazwisko,
    k.ile_lat() AS wiek
FROM
    ksiazki_v k;

SELECT
    p.nazwisko,
    p.ile_ksiazek() AS liczba_ksiazek
FROM
    pisarze_v p;

-- ZAD 23
CREATE TYPE auto AS OBJECT (
        marka          VARCHAR2(20),
        model          VARCHAR2(20),
        kilometry      NUMBER,
        data_produkcji DATE,
        cena           NUMBER(10, 2),
        MEMBER FUNCTION wartosc RETURN NUMBER
) NOT FINAL;

CREATE OR REPLACE TYPE BODY auto AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
        wiek    NUMBER;
        wartosc NUMBER;
    BEGIN
        wiek := round(months_between(sysdate, data_produkcji) / 12);
        wartosc := cena - ( wiek * 1000 );
        IF ( wartosc < 0 ) THEN
            wartosc := 0;
        END IF;
        RETURN wartosc;
    END wartosc;

END;

CREATE TABLE auta OF auto;

INSERT INTO auta VALUES ( auto('FIAT', 'BRAVA', 60000, DATE '1999-11-30', 25000) );

INSERT INTO auta VALUES ( auto('FORD', 'MONDEO', 80000, DATE '1997-05-10', 45000) );

INSERT INTO auta VALUES ( auto('MAZDA', '323', 12000, DATE '2000-09-22', 52000) );

CREATE TYPE auto_osobowe UNDER auto (
        liczba_miejsc NUMBER,
        klimatyzacja  CHAR(1),
        OVERRIDING MEMBER FUNCTION wartosc RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY auto_osobowe AS OVERRIDING
    MEMBER FUNCTION wartosc RETURN NUMBER IS
        wiek    NUMBER;
        wartosc NUMBER;
    BEGIN
        wiek := round(months_between(sysdate, data_produkcji) / 12);
        wartosc := cena - ( wiek * 1000 );
        IF ( wartosc < 0 ) THEN
            wartosc := 0;
        END IF;
        IF klimatyzacja = 'Y' THEN
            wartosc := wartosc + 0.5 * wartosc;
        END IF;

        RETURN wartosc;
    END wartosc;

END;

CREATE TABLE auta_osobowe OF auto_osobowe;

CREATE TYPE auto_ciezarowe UNDER auto (
        ladownosc NUMBER,
        OVERRIDING MEMBER FUNCTION wartosc RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY auto_ciezarowe AS OVERRIDING
    MEMBER FUNCTION wartosc RETURN NUMBER IS
        wiek    NUMBER;
        wartosc NUMBER;
    BEGIN
        wiek := round(months_between(sysdate, data_produkcji) / 12);
        wartosc := cena - ( wiek * 1000 );
        IF ( wartosc < 0 ) THEN
            wartosc := 0;
        END IF;
        IF ladownosc > 10 THEN
            wartosc := 2 * wartosc;
        END IF;
        RETURN wartosc;
    END wartosc;

END;

CREATE TABLE auta_ciezarowe OF auto_ciezarowe;

INSERT INTO auta VALUES ( auto_osobowe('FIAT_O', 'BRAVA_O', 60000, DATE '1999-11-30', 25000,
                                       4, 'Y') );

INSERT INTO auta VALUES ( auto_osobowe('FORD_O', 'MONDEO_O', 80000, DATE '1997-05-10', 45000,
                                       4, 'N') );

INSERT INTO auta VALUES ( auto_ciezarowe('FIAT_C', 'BRAVA_C', 60000, DATE '1999-11-30', 25000,
                                         8) );

INSERT INTO auta VALUES ( auto_ciezarowe('FORD_C', 'MONDEO_C', 80000, DATE '1997-05-10', 45000,
                                         12) );

SELECT
    a.marka,
    a.wartosc() AS wartosc
FROM
    auta a;
