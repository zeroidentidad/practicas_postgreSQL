create table usuarios(
nombre varchar(20),
clave varchar(15),
primary key (nombre)
);


CREATE TABLE public.grados
(
    idgrado integer,
    grado text,
    PRIMARY KEY (idgrado)
)
WITH (OIDS = FALSE);

ALTER TABLE public.grados
    OWNER to postgres;

create table calificacion(
idcalificacion integer,
idmateria integer,
primerparcial integer,
segundoparcial integer,
tercerparcial integer,
promediofinal integer,	
primary key(idcalificacion)
)