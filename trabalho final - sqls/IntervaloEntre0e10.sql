-- Pré-requisitos (assumindo que já existem do teste anterior ou recriando)
INSERT INTO curso (nome, carga_horaria) VALUES ('Engenharia de Software', 3600); -- id_curso = 1
INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso) VALUES ('Banco de Dados', 80, 1); -- id_disciplina = 1
INSERT INTO periodo_letivo (ano, semestre, dt_inicio, dt_fim) VALUES (2025, 2, '2025-08-01', '2025-12-15'); -- id_periodo_letivo = 1
INSERT INTO professor (nome, cpf, telefone) VALUES ('Dr. Smith', '123.456.789-00', '987654321'); -- id_professor = 1
INSERT INTO funcao (funcao) VALUES ('Professor'); -- id_funcao = 1
INSERT INTO func_prof (id_professor, id_funcao, dt_entrada) VALUES (1, 1, '2025-01-01');
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo) VALUES ('Lab 201', 5, 20, 1, 1); -- id_turma = 1
INSERT INTO professor_turma (id_professor, id_turma) VALUES (1, 1); -- id_prof_turma = 1
INSERT INTO aluno (nome, cpf, email, data_nasc, telefone, id_curso, status) VALUES ('Ana Maria', '000.000.000-00', 'ana@email.com', '2003-03-01', '999900000', 1, 'ativo'); -- id_aluno = 1
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (1, 1); -- id_aluno_turma = 1
INSERT INTO avaliacao (descricao, data, id_prof_turma, id_periodo_letivo) VALUES ('Prova 1', '2025-10-10', 1, 1); -- id_avaliacao = 1

-- Teste 3.1: Inserção Válida (nota entre 0 e 10)
INSERT INTO result_avaliacao (id_avaliacao, id_aluno_turma, nota_obtida) VALUES (1, 1, 7.5);
SELECT * FROM result_avaliacao;

-- Teste 3.2: Inserção Inválida (nota abaixo de 0)
-- A linha abaixo deve gerar um erro!
INSERT INTO result_avaliacao (id_avaliacao, id_aluno_turma, nota_obtida) VALUES (1, 1, -1.0);

-- Teste 3.3: Inserção Inválida (nota acima de 10)
-- A linha abaixo deve gerar um erro!
INSERT INTO result_avaliacao (id_avaliacao, id_aluno_turma, nota_obtida) VALUES (1, 1, 10.1);

-- Teste 3.4: Update Válido
UPDATE result_avaliacao SET nota_obtida = 8.0 WHERE id_avaliacao = 1 AND id_aluno_turma = 1;
SELECT * FROM result_avaliacao;

-- Teste 3.5: Update Inválido (nota abaixo de 0)
-- A linha abaixo deve gerar um erro!
UPDATE result_avaliacao SET nota_obtida = -0.5 WHERE id_avaliacao = 1 AND id_aluno_turma = 1;

-- Verificando logs (opcional)
SELECT * FROM registro_relatorios WHERE nome_tabela = 'result_avaliacao';