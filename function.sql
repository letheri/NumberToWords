CREATE OR REPLACE FUNCTION public.number_to_words_turkish(num integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
    digits CONSTANT TEXT[] := ARRAY['bir', 'iki', 'üç', 'dört', 'beş', 'altı', 'yedi', 'sekiz', 'dokuz'];
    tens CONSTANT TEXT[] := ARRAY['on', 'yirmi', 'otuz', 'kırk', 'elli', 'altmış', 'yetmiş', 'seksen', 'doksan'];
    thousands CONSTANT TEXT[] := ARRAY['bin', 'milyon', 'milyar', 'trilyon', 'katrilyon'];
    result TEXT := '';
    sub_result TEXT := '';
    num_str TEXT := num::TEXT; -- 1234
    num_len INTEGER := length(num_str); -- 4
    part INTEGER := ceil(LENGTH(num_str)::FLOAT/3); -- 2
    birlik VARCHAR(1) := '';
   	onluk VARCHAR(1) := '';
  	yuzluk VARCHAR(1) := '';
BEGIN
    IF num = 0 or num is null THEN
        RETURN 'sıfır';
    END IF;
   	IF num < 0 THEN
        result := 'eksi';
        RETURN result;
    END IF;

    FOR i IN 1..part LOOP
	   	birlik := substring(num_str, num_len-(i-1)*3, 1);
	   	onluk := substring(num_str, num_len-(i-1)*3 -1, 1);
	   	yuzluk := substring(num_str, num_len-(i-1)*3 -2, 1);

	    IF i > 1 THEN
	    	sub_result := ' ' || thousands[i-1];
	    END IF;
        IF birlik NOT IN ('0', '') THEN
            sub_result := digits[birlik::int] || sub_result ;
        END IF;

        IF onluk NOT IN ('0', '') THEN
            sub_result := tens[onluk::int] || ' ' || sub_result;
        END IF;

       IF yuzluk NOT IN ('0', '') THEN
       		IF yuzluk = '1' THEN
       			sub_result := 'yüz ' || sub_result;
       		else
            	sub_result := digits[yuzluk::int] || ' yüz ' || sub_result;
            END IF;
        END IF;
		result :=  sub_result || ' ' || result  ;
		sub_result := '';
    END LOOP;

    RETURN result;
END;
$function$ ;


CREATE OR REPLACE FUNCTION public.money_to_words(money numeric)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
    result TEXT := '';
    money_int int := trunc(round(money,2));
    money_decimal int := (round(money,2)*100)%100;
BEGIN
    IF money = 0 OR money IS NULL THEN
        RETURN 'sıfır';
    END IF;
    RESULT := trim(number_to_words_turkish(money_int)) || ' türk lirası';
	IF money_decimal != 0 AND money_decimal IS NOT NULL THEN
        RESULT := result || ', '|| trim(number_to_words_turkish(money_decimal)) || ' kr.' ;
    END IF;

    RETURN result;
END;
$function$;