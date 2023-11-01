
/*Crie um banco de dados para armazenar alunos e cursos de uma universidade;
- Cada curso pode pertencer a somente uma área;*/

	create database bd;

	create table alunos (
    id int auto_increment primary key,
    nome_aluno varchar(50) not null,
    data_nasc date,
    curso_id int,
    foreign key (curso_id) references cursos(id)
    );
    
    create table cursos (
    id int auto_increment primary key,
    nome_curso varchar (50) not null,
    area_id int,
    foreign key (area_id) references areas(id_area)
    );
    
    create table areas(
    id_area int auto_increment primary key,
    nome_area varchar(50) not null
	);
    
/*Utilize Stored Procedures para automatizar a inserção e seleção dos cursos;*/

  -- Criando Stored Procedure para inserir Cursos:
    delimiter $$
    
    create procedure InsercaoCursos(
    in nomeCurso varchar(50),
    in area_id int
    )
    begin
		insert into cursos(nome_curso, area_id)
        values (nomeCurso, area_id);
    end$$
    
    delimiter ;
    
    call InsercaoCursos('Ingles', 1);
    
    -- verificar as inserções.
    select * from cursos;
    
 -- Criando Store Procedure para Selecionar Cursos:
 delimiter $$
 
	create procedure SelecaoCursosArea(
	in areaID int
	)
	begin 
		select cursos.id as CursoID, nome_curso as NomeCurso
		from cursos
		where area_id = areaID;
	end$$
    delimiter ;
 
	call SelecaoCursosArea(1);
    
/*O aluno possui um e-mail que deve ter seu endereço gerado automaticamente no seguinte formato: nome.sobrenome@dominio.com*/

	-- adicionar uma coluna chamada sobrenome_aluno.
	alter table alunos 
    add column sobrenome_aluno varchar(50) not null;
    
    -- adicionando uma coluna chamada email.
    alter table alunos
    add column email varchar(100) not null;
    
	delimiter $$
    create function GerarEmailAluno(
    nome_aluno varchar(50),
    sobrenome_aluno varchar(50)
    )
    returns varchar(100)
    begin
		set @email = concat(nome_aluno, '.', sobrenome_aluno, '@gmail.com');
        return @email;
    end $$
    delimiter ;
    
    select GerarEmailAluno('Jonas', 'Alves');
    
/*Crie uma rotina que recebe os dados de um novo curso e o insere no banco de dados;*/

	delimiter $$
    create procedure InserçaoNovoCurso(
		in nomeCurso varchar(50),
        in areaID int,
        in nomeArea varchar(50)
    )
    begin
		insert into cursos (nome_curso, area_id)
        values (nomeCurso, areaID);
    end$$
    delimiter ;
   
    call InsercaoNovoCurso('Fisica',2);
    
    select * from cursos;
    
/*Crie uma função que recebe o nome de um curso e sua área, em seguida retorna o id do curso;*/

	delimiter $$
    create function IdCurso(
		nomeCurso varchar(50),
        nomeArea varchar(50)
    )
    returns int
    begin 
		declare cursoId int;
		select cursos.id into cursoId
        from cursos
        where nome_curso = nomeCurso and area_id = 
        (select id_area from areas where nome_area = nomeArea);
        return cursoId;
    end$$
	delimiter ;
    
	drop function IdCurso;
    
    select IdCurso('Ingles','Educacao');
    
    select * from cursos;
 
/*Crie uma procedure que recebe os dados do aluno e de um curso e faz sua matrícula;*/
	
    delimiter $$
    create procedure matricularAlunoCurso(
		in nome_aluno varchar (50),
        in data_nascimento date,
        in nome_curso varchar (50),
        in nome_area varchar (50)
    )
    begin 
		insert into alunos (nome_aluno, data_nasc)
        values (nome_aluno, data_nascimento)
        on duplicate key update id = id;
        
        insert into matriculas (aluno.id, curso_id, data_matricula)
        select a.id_aluno, c.id_curso, curdate()
        from alunos a
        join cursos c on c.nome_curso = nome_curso
        join areas ar on ar.nome_area = nome_area
        where a.nome = nome_aluno
        and a.data.nasc = data_nascimento
        and c.area_id = ar.id_area
        on duplicate key update aluno_id = aluno_id;
    end$$
    delimiter ;
        
	select matricularAlunoCurso('Jonas','2023-01-01','Ingles','Educacao');
    
/*Caso o aluno já esteja matriculado em um curso, essa matrícula não pode ser realizada;*/    
	delimiter $$
	create procedure MatricularAlunoEmCurso(
		in nome_aluno varchar (50),
		in data_nascimento date,
		in nome_curso varchar(50),
		in nome_area varchar(50)
	)
	begin
		insert into Alunos (nome, data_nascimento)
		values (nome_aluno, data_nascimento)
		on duplicate key update id_aluno = LAST_INSERT_ID(id_aluno);

		insert ignore into Matriculas (aluno_id, curso_id, data_matricula)
		select A.id_aluno, C.id_curso, CURDATE()
		from Alunos A
		join Cursos C on C.nome_curso = nome_curso
		join Areas Ar on Ar.nome_area = nome_area
		where A.nome = nome_aluno
		and A.data_nascimento = data_nascimento
		and C.area_id = Ar.id_area;
	end$$
	
	delimiter ;
    
/*Crie o modelo lógico do exercício.*/



