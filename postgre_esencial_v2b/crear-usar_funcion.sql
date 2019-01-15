
CREATE OR REPLACE FUNCTION public.sumar(integer, integer)
	RETURNS integer
	LANGUAGE sql
AS $function$ 	
	select $1+$2;
 $function$
;


select postgre_esencial_v2b.public.sumar(2,4);