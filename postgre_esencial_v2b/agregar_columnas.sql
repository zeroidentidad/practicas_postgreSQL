ALTER TABLE public.profesores
    ADD COLUMN "ClaseA" text;

ALTER TABLE public.profesores
    ADD COLUMN "ClaseB" text COLLATE pg_catalog."es-MX-x-icu";
