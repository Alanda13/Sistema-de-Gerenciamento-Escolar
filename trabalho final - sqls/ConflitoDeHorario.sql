-- Pré-requisitos
INSERT INTO curso (nome, carga_horaria) VALUES ('Engenharia de Software', 3600); -- id_curso = 1
INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso) VALUES ('Banco de Dados', 80, 1); -- id_disciplina = 1
INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso) VALUES ('Redes de Computadores', 80, 1); -- id_disciplina = 2
INSERT INTO periodo_letivo (ano, semestre, dt_inicio, dt_fim) VALUES (2025, 2, '2025-08-01', '2025-12-15'); -- id_periodo_letivo = 1
INSERT INTO professor (nome, cpf, telefone) VALUES ('Profa. Carla', '222.222.222-22', '222222222'); -- id_professor = 1
INSERT INTO funcao (funcao) VALUES ('Professor'); -- id_funcao = 1
INSERT INTO func_prof (id_professor, id_funcao, dt_entrada) VALUES (1, 1, '2025-01-01');

-- Turma 1 (Banco de Dados, 5 horas)
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo) VALUES ('Sala A', 5, 20, 1, 1); -- id_turma = 1
-- Turma 2 (Redes, 5 horas - CONFLITO)
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo) VALUES ('Sala B', 5, 20, 2, 1); -- id_turma = 2
-- Turma 3 (Matemática, 3 horas - SEM CONFLITO)
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo) VALUES ('Sala C', 3, 20, 2, 1); -- id_turma = 3

-- Teste 5.1: Inserção Válida (professor na primeira turma)
INSERT INTO professor_turma (id_professor, id_turma) VALUES (1, 1);
SELECT * FROM professor_turma;

-- Teste 5.2: Inserção Inválida (professor na turma com horário conflitante)
-- A linha abaixo deve gerar um erro!
INSERT INTO professor_turma (id_professor, id_turma) VALUES (1, 2);

-- Teste 5.3: Inserção Válida (professor na turma com horário diferente)
INSERT INTO professor_turma (id_professor, id_turma) VALUES (1, 3);
SELECT * FROM professor_turma;

-- Verificando logs (opcional)
SELECT * FROM registro_relatorios WHERE nome_tabela = 'professor_turma';