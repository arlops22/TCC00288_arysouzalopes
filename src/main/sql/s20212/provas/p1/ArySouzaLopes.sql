DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

create table cidade(
numero int not null primary key,
nome varchar not null
);

create table bairro(
numero int not null primary key,
nome varchar not null,
cidade int not null,
foreign key (cidade) references cidade(numero)
);

create table pesquisa(
numero int not null,
descricao varchar not null,
primary key (numero)
);

create table pergunta(
pesquisa int not null,
numero int not null,
descricao varchar not null,
primary key (pesquisa,numero),
foreign key (pesquisa) references pesquisa(numero)
);

create table resposta(
pesquisa int not null,
pergunta int not null,
numero int not null,
descricao varchar not null,
primary key (pesquisa,pergunta,numero),
foreign key (pesquisa,pergunta) references pergunta(pesquisa,numero)
);

create table entrevista(
numero int not null primary key,
data_hora timestamp not null,
bairro int not null,
foreign key (bairro) references bairro(numero)
);

create table escolha(
entrevista int not null,
pesquisa int not null,
pergunta int not null,
resposta int not null,
primary key (entrevista,pesquisa,pergunta),
foreign key (entrevista) references entrevista(numero),
foreign key (pesquisa,pergunta,resposta) references resposta(pesquisa,pergunta,numero)
);

insert into cidade values (1,'Rio de Janeiro');
insert into cidade values (2,'Niterói');
insert into cidade values (3,'São Paulo');

insert into bairro values (1,'Tijuca',1);
insert into bairro values (2,'Centro',1);
insert into bairro values (3,'Lagoa',1);
insert into bairro values (4,'Icaraí',2);
insert into bairro values (5,'São Domingos',2);
insert into bairro values (6,'Santa Rosa',2);
insert into bairro values (7,'Moema',3);
insert into bairro values (8,'Jardim Paulista',3);
insert into bairro values (9,'Higienópolis',3);

insert into pesquisa values (1,'Pesquisa 1');

insert into pergunta values (1,1,'Pergunta 1');
insert into pergunta values (1,2,'Pergunta 2');
insert into pergunta values (1,3,'Pergunta 3');
insert into pergunta values (1,4,'Pergunta 4');

insert into resposta values (1,1,1,'Resposta 1 da pergunta 1');
insert into resposta values (1,1,2,'Resposta 2 da pergunta 1');
insert into resposta values (1,1,3,'Resposta 3 da pergunta 1');
insert into resposta values (1,1,4,'Resposta 4 da pergunta 1');
insert into resposta values (1,1,5,'Resposta 5 da pergunta 1');

insert into resposta values (1,2,1,'Resposta 1 da pergunta 2');
insert into resposta values (1,2,2,'Resposta 2 da pergunta 2');
insert into resposta values (1,2,3,'Resposta 3 da pergunta 2');
insert into resposta values (1,2,4,'Resposta 4 da pergunta 2');
insert into resposta values (1,2,5,'Resposta 5 da pergunta 2');
insert into resposta values (1,2,6,'Resposta 5 da pergunta 2');

insert into resposta values (1,3,1,'Resposta 1 da pergunta 3');
insert into resposta values (1,3,2,'Resposta 2 da pergunta 3');
insert into resposta values (1,3,3,'Resposta 3 da pergunta 3');

insert into resposta values (1,4,1,'Resposta 1 da pergunta 4');
insert into resposta values (1,4,2,'Resposta 2 da pergunta 4');

insert into entrevista values (1,'2020-03-01'::timestamp,1);
insert into escolha values (1,1,1,2);
insert into escolha values (1,1,2,2);
insert into escolha values (1,1,3,1);

insert into entrevista values (2,'2020-03-01'::timestamp,1);
insert into escolha values (2,1,1,3);
insert into escolha values (2,1,2,1);
insert into escolha values (2,1,3,2);

insert into entrevista values (3,'2020-03-01'::timestamp,1);
insert into escolha values (3,1,1,4);
insert into escolha values (3,1,2,1);
insert into escolha values (3,1,3,1);

insert into entrevista values (4,'2020-03-01'::timestamp,1);
insert into escolha values (4,1,1,2);
insert into escolha values (4,1,2,1);
insert into escolha values (4,1,3,1);

insert into entrevista values (5,'2020-03-01'::timestamp,1);
insert into escolha values (5,1,1,2);
insert into escolha values (5,1,2,1);
insert into escolha values (5,1,3,1);

CREATE OR REPLACE function resultado(p_pesquisa INT, p_bairros VARCHAR[], p_cidades VARCHAR[])
    RETURNS TABLE (pergunta INT, histograma FLOAT[]) AS $$
    DECLARE
        escolhaRegistro RECORD;
        idBairros int[];
    BEGIN
        
        IF p_bairros IS NULL AND p_cidades IS NULL THEN
            SELECT array_agg(bairro.numero) FROM bairro INTO idBairros;
        END IF; 

        IF p_bairros IS NULL AND p_cidades IS NOT NULL THEN
            SELECT array_agg(bairro.numero) FROM bairro
            INNER JOIN cidade ON bairro.cidade = cidade.numero
            WHERE cidade.nome = ANY(p_cidades) INTO idBairros;
        END IF;

        IF p_bairros IS NOT NULL AND p_cidades IS NULL THEN
            SELECT array_agg(bairro.numero) FROM bairro
            WHERE bairro.nome = ANY(p_bairros) INTO idBairros;
        END IF;

        IF p_bairros IS NOT NULL AND p_cidades IS NOT NULL THEN
            SELECT array_agg(bairro.numero) FROM bairro
            INNER JOIN cidade ON bairro.cidade = cidade.numero
            WHERE bairro.nome = ANY(p_bairros) AND cidade.nome = ANY(p_cidades) INTO idBairros;
        END IF;

        CREATE TEMPORARY TABLE aux AS
            (SELECT resposta.pergunta, numero AS resposta, 0 AS frequencia
                FROM resposta
                WHERE pesquisa = p_pesquisa);
        
        CREATE TEMPORARY TABLE temp_table2 AS (SELECT pergunta.numero, 1 AS frequencia2
            FROM pergunta 
                WHERE pesquisa = p_pesquisa);

        FOR escolhaRegistro IN SELECT  escolha.pergunta, escolha.resposta, COUNT(escolha.resposta) AS frequencia FROM escolha
            WHERE entrevista IN (
                SELECT numero FROM entrevista
                    WHERE bairro IN(
                        SELECT numero FROM bairro
                            WHERE numero = ANY (idBairros)
                        )
            ) GROUP BY escolha.pergunta, escolha.resposta LOOP
            
            UPDATE aux SET frequencia = escolhaRegistro.frequencia 
            WHERE escolhaRegistro.pergunta = aux.pergunta AND escolhaRegistro.resposta = aux.resposta;
        
        END LOOP;      

        FOR escolhaRegistro IN SELECT escolha.pergunta, COUNT(escolha.pergunta) AS frequencia2 FROM escolha
            WHERE entrevista IN (
                SELECT numero FROM entrevista
                    WHERE bairro IN(
                        SELECT numero FROM bairro
                        WHERE numero = ANY (idBairros)
                    )
            ) GROUP BY escolha.pergunta LOOP
            
            UPDATE temp_table2 SET frequencia2 = escolhaRegistro.frequencia2
            WHERE escolhaRegistro.pergunta = temp_table2.numero;

        END LOOP;       
            
        FOR escolhaRegistro IN SELECT * FROM temp_table2 ORDER BY 1 LOOP 
            SELECT ARRAY_AGG(ARRAY[resposta, a])
                FROM (SELECT resposta, aux.frequencia::float / escolhaRegistro.frequencia2::float AS a FROM aux WHERE aux.pergunta = escolhaRegistro.numero ORDER BY resposta ) AS t
                    INTO histograma;
                        pergunta := escolhaRegistro.numero;
            RETURN NEXT;
        END LOOP;        

        RETURN;
    END;
$$ LANGUAGE plpgsql;

SELECT * FROM resultado(1, ARRAY['Tijuca'], ARRAY['Rio de Janeiro', 'São Paulo']);