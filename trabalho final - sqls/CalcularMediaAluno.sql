-- Pré-requisitos
INSERT INTO curso (nome, carga_horaria) VALUES ('Engenharia de Software', 3600); -- id_curso = 1
INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso) VALUES ('Algoritmos', 80, 1); -- id_disciplina = 1
INSERT INTO periodo_letivo (ano, semestre, dt_inicio, dt_fim) VALUES (2025, 2, '2025-08-01', '2025-12-15'); -- id_periodo_letivo = 1
INSERT INTO professor (nome, cpf, telefone) VALUES ('Prof. Guto', '888.888.888-88', '888888888'); -- id_professor = 1
INSERT INTO funcao (funcao) VALUES ('Professor'); -- id_funcao = 1
INSERT INTO func_prof (id_professor, id_funcao, dt_entrada) VALUES (1, 1, '2025-01-01');
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo) VALUES ('Lab 401', 5, 20, 1, 1); -- id_turma = 1
INSERT INTO professor_turma (id_professor, id_turma) VALUES (1, 1); -- id_prof_turma = 1
INSERT INTO aluno (nome, cpf, email, data_nasc, telefone, id_curso, status) VALUES ('Aluno Nota', '999.999.999-99', 'alunonota@email.com', '2000-01-01', '999999999', 1, 'ativo'); -- id_aluno = 1
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (1, 1); -- id_aluno_turma = 1
INSERT INTO avaliacao (descricao, data, id_prof_turma, id_periodo_letivo) VALUES ('Prova P1', '2025-09-10', 1, 1); -- id_avaliacao = 1
INSERT INTO avaliacao (descricao, data, id_prof_turma, id_periodo_letivo) VALUES ('Prova P2', '2025-11-20', 1, 1); -- id_avaliacao = 2

-- Teste 11.1: Inserir primeira nota (média = 8.00)
INSERT INTO result_avaliacao (id_avaliacao, id_aluno_turma, nota_obtida) VALUES (1, 1, 8.0);
SELECT 'Após 1ª nota:', * FROM result_aluno_periodo WHERE id_aluno_turma = 1;

-- Teste 11.2: Inserir segunda nota (média = (8.0 + 6.0) / 2 = 7.00)
INSERT INTO result_avaliacao (id_avaliacao, id_aluno_turma, nota_obtida) VALUES (2, 1, 6.0);
SELECT 'Após 2ª nota:', * FROM result_aluno_periodo WHERE id_aluno_turma = 1;

-- Teste 11.3: Atualizar nota (média = (9.0 + 6.0) / 2 = 7.50)
UPDATE result_avaliacao SET nota_obtida = 9.0 WHERE id_avaliacao = 1 AND id_aluno_turma = 1;
SELECT 'Após update:', * FROM result_aluno_periodo WHERE id_aluno_turma = 1;

-- Teste 11.4: Deletar uma nota (média = 6.00)
DELETE FROM result_avaliacao WHERE id_avaliacao = 1 AND id_aluno_turma = 1;
SELECT 'Após delete:', * FROM result_aluno_periodo WHERE id_aluno_turma = 1;

-- Teste 11.5: Deletar a última nota (média = 0.00)
DELETE FROM result_avaliacao WHERE id_avaliacao = 2 AND id_aluno_turma = 1;
SELECT 'Após último delete:', * FROM result_aluno_periodo WHERE id_aluno_turma = 1;

-- Verificando logs (opcional)
SELECT * FROM registro_relatorios WHERE nome_tabela IN ('result_avaliacao', 'result_aluno_periodo');