@'C:\hlocal\crear_tablas.sql';

SET SERVEROUTPUT ON SIZE 1000000;

CREATE OR REPLACE PROCEDURE pr_empleados_tlf
(p_teléfono TELÉFONOS.Teléfono%TYPE)
IS
    v_nombre EMPLEADOS.Nombre%TYPE;
    v_dni EMPLEADOS.Dni%TYPE;
BEGIN
    SELECT Nombre, Dni INTO v_nombre, v_dni
    FROM EMPLEADOS natural join TELÉFONOS
    WHERE TELÉFONOS.Teléfono=p_teléfono;
     
    DBMS_OUTPUT.put_line('El empleado con el teléfono ' || p_teléfono || ' es: ' || v_nombre || ', con DNI: ' || v_dni || '.');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.put_line('No se encontró el empleado con el teléfono ' || p_teléfono || '.');
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.put_line('Hay más de un empleado con el teléfono ' || p_teléfono || '.');
END;
/

CREATE OR REPLACE PROCEDURE pr_comprobar_poblaciones
IS
    CURSOR c_numProv IS
        SELECT C1.Población
        FROM "Códigos postales"  C1, "Códigos postales"  C2
        WHERE C1.Población=C2.Población and C1.Provincia<>C2.Provincia;
        
    v_nombre "Códigos postales".Población%TYPE;

BEGIN
    OPEN c_numProv;
    
    FETCH c_numProv INTO v_nombre;
    IF c_numProv%NOTFOUND THEN
        DBMS_OUTPUT.put_line('No hay dos o más provincias que compartan la misma población.');
    ELSE 
        DBMS_OUTPUT.put_line('A la población ' || v_nombre || ' no le corresponde siempre la misma provincia.');
    END IF;
    
    CLOSE c_numProv; 
END;
/


CREATE OR REPLACE PROCEDURE pr_empleados_CP
IS
    CURSOR c_emp IS
        SELECT DOMICILIOS."Código postal", EMPLEADOS.Nombre, DOMICILIOS.Calle, EMPLEADOS.Sueldo
        FROM EMPLEADOS INNER join DOMICILIOS
        on DOMICILIOS.DNI=EMPLEADOS.DNI
        ORDER BY DOMICILIOS."Código postal";
        
    CURSOR c_emp2 IS
        SELECT DOMICILIOS."Código postal", COUNT(EMPLEADOS.Dni), AVG(EMPLEADOS.Sueldo)
        FROM EMPLEADOS INNER join DOMICILIOS
        on DOMICILIOS.DNI=EMPLEADOS.DNI
        GROUP BY DOMICILIOS."Código postal"
        ORDER BY DOMICILIOS."Código postal";
        
    v_códigoP DOMICILIOS."Código postal"%TYPE;
    v_códigoP2 DOMICILIOS."Código postal"%TYPE;
    v_nombre EMPLEADOS.Nombre%TYPE;
    v_calle DOMICILIOS.Calle%TYPE;
    v_sueldo EMPLEADOS.Sueldo%TYPE;
    v_numEmp NUMBER(3);
    v_totEmp NUMBER(3) := 0;
    v_mediaSueldo EMPLEADOS.Sueldo%TYPE;
    
BEGIN
    OPEN c_emp;
    OPEN c_emp2;
    LOOP
        FETCH c_emp2 INTO v_códigoP, v_numEmp, v_mediaSueldo;
        EXIT WHEN c_emp2%NOTFOUND;
        DBMS_OUTPUT.put_line('Código postal: ' || v_códigoP);
        
        FOR i IN 0..v_numEmp-1
        LOOP
            FETCH c_emp INTO v_códigoP2, v_nombre, v_calle, v_sueldo;
                DBMS_OUTPUT.put_line('  ' || v_nombre || ', ' || v_calle || ', ' || v_sueldo);
        END LOOP;
        
        v_totEmp := v_totEmp + v_numEmp;
        DBMS_OUTPUT.put_line('      Nº empleados: ' || v_numEmp || ', Sueldo medio: ' || v_mediaSueldo);
    END LOOP;
    
    DBMS_OUTPUT.put_line('Total empleados: ' || v_totEmp);
    
    CLOSE c_emp;
    CLOSE c_emp2; 
END;
/


BEGIN
--vista1
    pr_empleados_tlf('666666666');
    pr_empleados_tlf('611111111');
    pr_empleados_tlf('913333333');
    DBMS_OUTPUT.put_line('');
    
--vista2
    pr_comprobar_poblaciones();
    INSERT INTO "Códigos postales" VALUES ('41008','Arganda','Sevilla');
    pr_comprobar_poblaciones();
    DELETE FROM "Códigos postales" WHERE 
    "Códigos postales"."Código postal" = '41008' and 
    "Códigos postales".Población = 'Arganda' and 
    "Códigos postales".Provincia = 'Sevilla';
    DBMS_OUTPUT.put_line('');
    
--vista3
    pr_empleados_CP();    
END;
/