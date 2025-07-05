-- Pré-requisitos
INSERT INTO curso (nome, carga_horaria) VALUES ('Engenharia de Software', 3600); -- id_curso = 1
INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso) VALUES ('Banco de Dados', 80, 1); -- id_disciplina = 1
INSERT INTO periodo_letivo (ano, semestre, dt_inicio, dt_fim) VALUES (2025, 2, '2025-08-01', '2025-12-15'); -- id_periodo_letivo = 1
INSERT INTO professor (nome, cpf, telefone) VALUES ('Dr. Smith', '123.456.789-00', '987654321'); -- id_professor = 1
INSERT INTO funcao (funcao) VALUES ('Professor'); -- id_funcao = 1
INSERT INTO func_prof (id_professor, id_funcao, dt_entrada) VALUES (1, 1, '2025-01-01');
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo) VALUES ('Lab 201', 5, 20, 1, 1); -- id_turma = 1
INSERT INTO professor_turma (id_professor, id_turma) VALUES (1, 1); -- id_prof_turma = 1

-- Teste 2.1: Inserção Válida da primeira avaliação
INSERT INTO avaliacao (descricao, data, id_prof_turma, id_periodo_letivo) VALUES ('Prova Final', '2025-12-01', 1, 1);
SELECT * FROM avaliacao;

-- Teste 2.2: Inserção Inválida (avaliação duplicada)
-- A linha abaixo deve gerar um erro!
INSERT INTO avaliacao (descricao, data, id_prof_turma, id_periodo_letivo) VALUES ('Prova Final', '2025-12-01', 1, 1);

-- Teste 2.3: Inserção Válida (mesmo professor, data diferente)
INSERT INTO avaliacao (descricao, data, id_prof_turma, id_periodo_letivo) VALUES ('Trabalho Prático', '2025-11-15', 1, 1);
SELECT * FROM avaliacao;

-- Verificando logs (opcional)
SELECT * FROM registro_relatorios WHERE nome_tabela = 'avaliacao';