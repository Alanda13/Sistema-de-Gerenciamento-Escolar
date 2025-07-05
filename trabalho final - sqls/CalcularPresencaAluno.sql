-- Pré-requisitos
INSERT INTO curso (nome, carga_horaria) VALUES ('Engenharia de Software', 3600); -- id_curso = 1
INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso) VALUES ('Matemática', 80, 1); -- id_disciplina = 1
INSERT INTO periodo_letivo (ano, semestre, dt_inicio, dt_fim) VALUES (2025, 2, '2025-08-01', '2025-12-15'); -- id_periodo_letivo = 1
INSERT INTO professor (nome, cpf, telefone) VALUES ('Prof. Alfa', '000.000.000-01', '111222333'); -- id_professor = 1
INSERT INTO funcao (funcao) VALUES ('Professor'); -- id_funcao = 1
INSERT INTO func_prof (id_professor, id_funcao, dt_entrada) VALUES (1, 1, '2025-01-01');
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo) VALUES ('Sala F', 5, 20, 1, 1); -- id_turma = 1
INSERT INTO professor_turma (id_professor, id_turma) VALUES (1, 1); -- id_prof_turma = 1
INSERT INTO aluno (nome, cpf, email, data_nasc, telefone, id_curso, status) VALUES ('Aluno Presenca', '111.111.111-10', 'presenca@email.com', '2000-01-01', '101010101', 1, 'ativo'); -- id_aluno = 1
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (1, 1); -- id_aluno_turma = 1

-- Aulas para a turma:
INSERT INTO aula (id_periodo_letivo, id_prof_turma, assunto, data, qtd_aulas) VALUES (1, 1, 'Aula 1', '2025-08-01', 2); -- id_aula = 1
INSERT INTO aula (id_periodo_letivo, id_prof_turma, assunto, data, qtd_aulas) VALUES (1, 1, 'Aula 2', '2025-08-08', 3); -- id_aula = 2
-- Total de horas de aula para a turma no período: 2 + 3 = 5 horas

-- Teste 12.1: Inserir primeira presença (2 horas de 5 = 40%)
INSERT INTO presenca (id_aula, id_aluno_turma) VALUES (1, 1);
SELECT 'Após 1ª presença (40%):', * FROM result_aluno_periodo WHERE id_aluno_turma = 1;

-- Teste 12.2: Inserir segunda presença (2+3 = 5 horas de 5 = 100%)
INSERT INTO presenca (id_aula, id_aluno_turma) VALUES (2, 1);
SELECT 'Após 2ª presença (100%):', * FROM result_aluno_periodo WHERE id_aluno_turma = 1;

-- Teste 12.3: Deletar uma presença (3 horas de 5 = 60%)
DELETE FROM presenca WHERE id_aula = 1 AND id_aluno_turma = 1;
SELECT 'Após delete de 1ª presença (60%):', * FROM result_aluno_periodo WHERE id_aluno_turma = 1;

-- Teste 12.4: Deletar a última presença (0 horas de 5 = 0%)
DELETE FROM presenca WHERE id_aula = 2 AND id_aluno_turma = 1;
SELECT 'Após delete de 2ª presença (0%):', * FROM result_aluno_periodo WHERE id_aluno_turma = 1;

-- Verificando logs (opcional)
SELECT * FROM registro_relatorios WHERE nome_tabela IN ('presenca', 'aula', 'result_aluno_periodo');