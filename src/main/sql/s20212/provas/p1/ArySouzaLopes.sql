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


insert into venda values(202001,1,1,10,100.0);
insert into venda values(202001,1,2,10,200.0);
insert into venda values(202001,1,3,10,300.0);
insert into venda values(202002,1,1,10,200.0);
insert into venda values(202002,1,2,10,300.0);
insert into venda values(202002,1,3,10,500.0);
insert into venda values(202003,1,1,10,900.0);
insert into venda values(202003,1,2,10,200.0);
insert into venda values(202003,1,3,10,500.0);
insert into venda values(202004,1,1,10,200.0);
insert into venda values(202004,1,2,10,150.0);
insert into venda values(202004,1,3,10,500.0);
insert into venda values(202005,1,1,10,500.0);
insert into venda values(202005,1,2,10,300.0);
insert into venda values(202005,1,3,10,700.0);
insert into venda values(202006,1,1,10,200.0);
insert into venda values(202006,1,2,10,200.0);
insert into venda values(202006,1,3,10,200.0);



-----------------------------------------
--
-- Acrescente seu código a partir daqui
-----------------------------------------
