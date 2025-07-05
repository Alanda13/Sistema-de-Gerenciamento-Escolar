-- Pré-requisitos
INSERT INTO curso (nome, carga_horaria) VALUES ('Engenharia de Software', 3600); -- id_curso = 1
INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso) VALUES ('Banco de Dados', 80, 1); -- id_disciplina = 1
INSERT INTO periodo_letivo (ano, semestre, dt_inicio, dt_fim) VALUES (2025, 2, '2025-08-01', '2025-12-15'); -- id_periodo_letivo = 1
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo) VALUES ('Lab 201', 5, 20, 1, 1); -- id_turma = 1
INSERT INTO aluno (nome, cpf, email, data_nasc, telefone, id_curso, status) VALUES ('Aluno Teste', '111.111.111-11', 'teste@email.com', '2000-01-01', '111111111', 1, 'ativo'); -- id_aluno = 1

-- Teste 4.1: Inserção Válida
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (1, 1);
SELECT * FROM aluno_turma;

-- Teste 4.2: Inserção Inválida (matrícula duplicada)
-- A linha abaixo deve gerar um erro!
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (1, 1);

-- Verificando logs (opcional)
SELECT * FROM registro_relatorios WHERE nome_tabela = 'aluno_turma';