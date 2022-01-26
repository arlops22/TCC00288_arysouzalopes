DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

CREATE TABLE Atividade(
    id INT,
    nome VARCHAR);

CREATE TABLE Artista(
    id INT,
    nome VARCHAR,
    rua VARCHAR,
    cidade VARCHAR,
    estado VARCHAR,
    cep VARCHAR,
    atividade INT);

CREATE TABLE Arena(
    id INT,
    nome VARCHAR,
    cidade VARCHAR,
    capacidade INT
);

CREATE TABLE Concerto(
    id INT,
    artista INT,
    arena INT,
    inicio TIMESTAMP,
    fim TIMESTAMP,
    preço INT
);


INSERT INTO Atividade values (1, 'Atividade1');
INSERT INTO Atividade values (2, 'Atividade2');
INSERT INTO Atividade values (3, 'Atividade3');
INSERT INTO Artista values (1, 'Artista1', 'Rua1', 'Cidade1', 'Estado1', 'Cep1', 1);
INSERT INTO Artista values (2, 'Artista2', 'Rua2', 'Cidade2', 'Estado2', 'Cep2', 2);
INSERT INTO Artista values (3, 'Artista3', 'Rua3', 'Cidade3', 'Estado3', 'Cep3', 2);
INSERT INTO Arena values (1, 'Arena1', 'Cidade1', 1000);
INSERT INTO Arena values (2, 'Arena2', 'Cidade2', 1500);
INSERT INTO Arena values (3, 'Arena3', 'Cidade3', 2000);

CREATE OR REPLACE FUNCTION verificarUnicidade() RETURNS TRIGGER AS $$
declare
begin
    
    IF EXISTS (SELECT * FROM Concerto
                WHERE concerto.id != new.id AND
                (concerto.arena = new.arena OR concerto.artista = new.artista) AND
                (concerto.inicio BETWEEN new.inicio AND new.fim or concerto.fim BETWEEN new.inicio and new.fim)) THEN
        raise exception 'Os horários informados são incompatíveis';
    END IF;

    return NEW;
end;
$$ language plpgsql;

CREATE TRIGGER verificarUnicidade
AFTER INSERT OR UPDATE ON Concerto FOR EACH ROW
EXECUTE PROCEDURE verificarUnicidade();

CREATE OR REPLACE FUNCTION funcaoAux() RETURNS TRIGGER AS $$
DECLARE
BEGIN
    CREATE temp TABLE atividadeAux(id int) ON COMMIT DROP;
    return null;
END;
$$ language plpgsql;

CREATE TRIGGER triggerAux
BEFORE UPDATE OR DELETE ON Artista FOR EACH STATEMENT
EXECUTE PROCEDURE funcaoAux();

CREATE OR REPLACE FUNCTION registroArtista() RETURNS TRIGGER AS $$
DECLARE
BEGIN
    INSERT INTO atividadeAux VALUES(old.atividade);
    return null;
END;
$$ language plpgsql;

CREATE TRIGGER registroArtista
AFTER UPDATE OR DELETE ON Artista FOR EACH ROW
EXECUTE PROCEDURE registroArtista();

CREATE OR REPLACE FUNCTION verificarAtividade() RETURNS TRIGGER AS $$
DECLARE
    atvd record;
    cont int;
BEGIN   
    FOR atvd IN SELECT DISTINCT * FROM atividadeAux LOOP
        SELECT COUNT(*) FROM Artista WHERE atividade = atvd.id INTO cont;
        IF cont = 0 THEN
            raise exception 'A atividade está sem artista';
        END IF;
    END LOOP;

    RETURN NULL;
END;
$$ language plpgsql;

CREATE TRIGGER verificarAtividade
AFTER UPDATE OR DELETE ON Artista FOR EACH STATEMENT
EXECUTE PROCEDURE verificarAtividade();

DELETE FROM Artista WHERE id = 1;

INSERT INTO Concerto VALUES (1, 1, 1, '2021-09-08 21:00:00', '2021-09-08 21:00:30', 300);
INSERT INTO Concerto VALUES (2, 1, 2, '2021-09-08 21:00:00', '2021-09-08 21:00:20', 200);
INSERT INTO Concerto VALUES (3, 1, 3, '2021-09-08 21:00:00', '2021-09-08 21:00:40', 200);

INSERT INTO Concerto VALUES (1, 1, 1, '2021-09-08 21:00:00', '2021-09-08 21:00:10', 300);
INSERT INTO Concerto VALUES (2, 2, 1, '2021-09-08 21:00:00', '2021-09-08 21:00:05', 400);
INSERT INTO Concerto VALUES (3, 3, 1, '2021-09-08 21:00:00', '2021-09-08 21:00:30', 300);

INSERT INTO Concerto VALUES (1, 1, 1, '2021-09-08 21:00:00', '2022-09-08 21:00:40', 200);
INSERT INTO Concerto VALUES (2, 2, 1, '2022-09-08 21:00:00', '2021-09-08 21:00:20', 350);
INSERT INTO Concerto VALUES (3, 3, 1, '2021-09-08 21:00:00', '2021-09-08 21:00:30', 400);
