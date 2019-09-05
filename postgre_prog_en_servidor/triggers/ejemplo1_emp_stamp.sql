
-- primero:

create function emp_stamp() returns trigger as $emp_stamp$
begin
	-- revisar empname y salary fueron ingresados
	if new.empname is null then
		raise exception 'Columna de nombre de empleado no puede ser null';
	end if;
	if new.salary is null then
		raise exception '% no puede tener salario null', new.empname;
	end if;

	-- funciona cuando se pago con eso
	if new.salary < 0 then
		raise exception '% no puede tener un salario negativo', new.empname;
	end if;

	return new;
end;
$emp_stamp$ language plpgsql;

-- luego enlazar a tabla de interes: crear trigger de tipo before

create trigger emp_stamp before insert or update on public.employee
for each row execute procedure emp_stamp();

-- TEST:

select * from employee;

insert into employee(empname, salary) values ('Jesus', 110000);

-- entonces: 

insert into employee (salary) values (10000); -- ERROR: Columna de nombre de empleado no puede ser null Where: PL/pgSQL function emp_stamp() line 5 at RAISE

insert into employee (empname) values ('Steve'); -- ERROR: Steve no puede tener salario null Where: PL/pgSQL function emp_stamp() line 8 at RAISE

insert into employee (empname, salary) values ('Steve', -1000); -- ERROR: Steve no puede tener un salario negativo Where: PL/pgSQL function emp_stamp() line 13 at RAISE

insert into employee (empname, salary) values ('Steve', 10500); -- ok