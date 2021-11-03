CREATE TABLE pedidos (
    código CHAR(6) PRIMARY KEY,
    fecha CHAR(10) NOT NULL,
    importe NUMBER(6,2),
    cliente CHAR(20),
    notas CHAR(1024)
);

CREATE TABLE contiene (
    pedido CHAR(6),
    plato CHAR(10),
    precio NUMBER(6,2),
    unidades NUMBER(2,0),
    PRIMARY KEY (pedido, plato)
);

CREATE TABLE auditoría (
    operación CHAR(6),
    tabla CHAR(50),
    fecha CHAR(10),
    hora CHAR(8)
);


CREATE OR REPLACE TRIGGER trigger_pedidos
    AFTER INSERT OR UPDATE OR DELETE ON pedidos
    BEGIN
        IF DELETING THEN
            INSERT INTO auditoría values ('DELETE', 'pedidos', to_char(sysdate,'dd/mm/yyyy'), to_char(sysdate,'hh:mi:ss'));
        ELSIF INSERTING THEN
            INSERT INTO auditoría values ('INSERT', 'pedidos', to_char(sysdate,'dd/mm/yyyy'), to_char(sysdate,'hh:mi:ss'));
        ELSIF UPDATING THEN
            INSERT INTO auditoría values ('UPDATE', 'pedidos', to_char(sysdate,'dd/mm/yyyy'), to_char(sysdate,'hh:mi:ss'));
        END IF;
    END;
/

CREATE OR REPLACE TRIGGER trigger_contiene
    AFTER INSERT OR UPDATE OR DELETE ON contiene
    FOR EACH ROW
    BEGIN
        IF DELETING THEN
            UPDATE pedidos
            SET importe = importe - (:OLD.precio);
        ELSIF INSERTING THEN
            UPDATE pedidos
            SET importe = importe + (:NEW.precio)*(:NEW.unidades);
        ELSIF UPDATING THEN
            UPDATE pedidos
            SET importe = importe - (:OLD.precio)+(:NEW.precio);
        END IF;
    END;
/

SET TIMING ON;
CREATE INDEX index_pedidos ON pedidos (cliente);
BEGIN
    FOR i IN 1..300000
        LOOP
            INSERT INTO pedidos VALUES (i, to_char('06/01/2015'), 10.0, 'C' || i, ' ');
        END LOOP;
    SELECT * FROM pedidos WHERE cliente = 'C300000';
END;
DROP INDEX index_pedidos;
SELECT * FROM pedidos WHERE cliente = 'C300000';
/

/*
SET TIMING ON;
CREATE INDEX index_codigo ON pedidos (código);
BEGIN
    SELECT * FROM pedidos WHERE código = 'C300000';
END;
DROP INDEX index_codigo;
SELECT * FROM pedidos WHERE código = 'C300000';
/
*/

SET TIMING ON;
SELECT * FROM pedidos WHERE código = '300000';
ALTER TABLE pedidos DROP PRIMARY KEY;
SELECT * FROM pedidos WHERE código = '300000';
/

/*
CREATE INDEX index_pedidos ON pedidos (código);
BEGIN
    SELECT * FROM pedidos WHERE código = '300000';
END;
DROP INDEX index_pedidos;
SELECT * FROM pedidos WHERE código = '300000';
*/

SET TIMING ON;
CREATE VIEW vista AS
	SELECT * FROM pedidos WHERE código = '300000';
CREATE MATERIALIZED VIEW vistaM AS
	SELECT * FROM pedidos WHERE código = '300000';

CREATE INDEX index_vista ON vista (clientes);
CREATE INDEX index_vista_M ON vistaM (clientes);
/

BEGIN
	INSERT INTO pedidos VALUES('123456','20/11/2019',10.0,'Alex','10');
	INSERT INTO pedidos VALUES('111111','20/11/2019',10.0,'David','11');
	INSERT INTO contiene VALUES('123456','carne',10,1);
	UPDATE pedidos SET importe = importe + 1;
	DELETE FROM pedidos WHERE clientes = 'Alex';
END;
/

