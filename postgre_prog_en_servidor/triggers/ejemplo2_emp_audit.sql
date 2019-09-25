DROP TABLE Employee;

CREATE TABLE Employee (
    empname           text NOT NULL,
    salary            integer
);

CREATE TABLE Employee_audit(
    operation         char(1)   NOT NULL,
    stamp             timestamp NOT NULL,
    userid            text      NOT NULL,
    empname           text      NOT NULL,
    salary integer
);

CREATE OR REPLACE FUNCTION process_emp_audit() RETURNS TRIGGER AS $emp_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO Employee_audit SELECT 'D', now(), user, OLD.*;
            RETURN OLD;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO Employee_audit SELECT 'U', now(), user, NEW.*;
            RETURN NEW;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO Employee_audit SELECT 'I', now(), user, NEW.*;
            RETURN NEW;
        END IF;
        RETURN NULL; -- result is ignored since this is an AFTER trigger
    END;
$emp_audit$ LANGUAGE plpgsql;

CREATE TRIGGER emp_audit
AFTER INSERT OR UPDATE OR DELETE ON Employee
    FOR EACH ROW EXECUTE PROCEDURE process_emp_audit();

-- Consultar datos
SELECT *
FROM Employee;
-- Consultar datos
SELECT *
FROM Employee_audit;

-- Insertar valores
INSERT INTO Employee (empname, salary)
VALUES('Pinal',500);
INSERT INTO Employee (empname, salary)
VALUES('Troy',1500);
INSERT INTO Employee (empname, salary)
VALUES('Beth',2500);

-- Consultar datos
SELECT *
FROM Employee;
-- Consultar datos
SELECT *
FROM Employee_audit;

UPDATE Employee
SET salary = 200
WHERE empname = 'Troy';

-- Consultar datos
SELECT *
FROM Employee;
-- Consultar datos
SELECT *
FROM Employee_audit;

DELETE 
FROM Employee
WHERE empname = 'Pinal';

-- Consultar datos
SELECT *
FROM Employee;
-- Consultar datos
SELECT *
FROM Employee_audit;


-- Limpiar
DROP TABLE emp;
DROP TABLE emp_audit;
DROP FUNCTION process_emp_audit();