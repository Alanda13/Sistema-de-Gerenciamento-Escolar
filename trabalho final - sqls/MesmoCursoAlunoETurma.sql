-- Pré-requisitos
INSERT INTO curso (nome, carga_horaria) VALUES ('Engenharia de Software', 3600); -- id_curso = 1
INSERT INTO curso (nome, carga_horaria) VALUES ('Design Gráfico', 2400); -- id_curso = 2

INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso) VALUES ('BD para Eng', 80, 1); -- id_disciplina = 1 (Curso Eng.)
INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso) VALUES ('Photoshop Avançado', 60, 2); -- id_disciplina = 2 (Curso Design)

INSERT INTO periodo_letivo (ano, semestre, dt_inicio, dt_fim) VALUES (2025, 2, '2025-08-01', '2025-12-15'); -- id_periodo_letivo = 1

INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo) VALUES ('Lab Eng', 5, 20, 1, 1); -- id_turma = 1 (Turma de Eng.)
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo) VALUES ('Lab Design', 5, 20, 2, 1); -- id_turma = 2 (Turma de Design)

INSERT INTO aluno (nome, cpf, email, data_nasc, telefone, id_curso, status) VALUES ('Aluno Eng', '555.555.555-55', 'alunoeng@email.com', '2000-01-01', '555555555', 1, 'ativo'); -- id_aluno = 1 (Aluno de Eng.)
INSERT INTO aluno (nome, cpf, email, data_nasc, telefone, id_curso, status) VALUES ('Aluno Design', '666.666.666-66', 'alunodesign@email.com', '2000-01-01', '666666666', 2, 'ativo'); -- id_aluno = 2 (Aluno de Design)

-- Teste 9.1: Matrícula Válida (Aluno Eng. na Turma Eng.)
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (1, 1);
SELECT * FROM aluno_turma;

-- Teste 9.2: Matrícula Inválida (Aluno Eng. na Turma Design)
-- A linha abaixo deve gerar um erro!
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (1, 2);

-- Teste 9.3: Matrícula Válida (Aluno Design na Turma Design)
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (2, 2);
SELECT * FROM aluno_turma;

-- Verificando logs (opcional)
SELECT * FROM registro_relatorios WHERE nome_tabela = 'aluno_turma';