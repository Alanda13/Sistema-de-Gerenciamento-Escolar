-- Pré-requisitos
INSERT INTO curso (nome, carga_horaria) VALUES ('Engenharia de Software', 3600); -- id_curso = 1
INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso) VALUES ('Disciplina X', 60, 1); -- id_disciplina = 1
INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso) VALUES ('Disciplina Y', 60, 1); -- id_disciplina = 2
INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso) VALUES ('Disciplina Z', 60, 1); -- id_disciplina = 3
INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso) VALUES ('Disciplina A', 60, 1); -- id_disciplina = 4
INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso) VALUES ('Disciplina B', 60, 1); -- id_disciplina = 5
INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso) VALUES ('Disciplina C', 60, 1); -- id_disciplina = 6
INSERT INTO periodo_letivo (ano, semestre, dt_inicio, dt_fim) VALUES (2025, 2, '2025-08-01', '2025-12-15'); -- id_periodo_letivo = 1

-- Turmas de teste (para id_periodo_letivo = 1)
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo) VALUES ('T1', 1, 20, 1, 1); -- id_turma = 1
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo) VALUES ('T2', 2, 20, 2, 1); -- id_turma = 2
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo) VALUES ('T3', 3, 20, 3, 1); -- id_turma = 3
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo) VALUES ('T4', 4, 20, 4, 1); -- id_turma = 4
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo) VALUES ('T5', 5, 20, 5, 1); -- id_turma = 5
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo) VALUES ('T6', 6, 20, 6, 1); -- id_turma = 6

-- Funções
INSERT INTO funcao (funcao) VALUES ('Professor'); -- id_funcao = 1
INSERT INTO funcao (funcao) VALUES ('Coordenador'); -- id_funcao = 2

-- Cenário 1: Professor com APENAS a função 'Professor' (limite de 5 turmas)
INSERT INTO professor (nome, cpf, telefone) VALUES ('Prof. Solo', '111.111.111-00', '111111111'); -- id_professor = 1
INSERT INTO func_prof (id_professor, id_funcao, dt_entrada) VALUES (1, 1, '2024-01-01');

-- Alocar Prof. Solo em 5 turmas (válido)
INSERT INTO professor_turma (id_professor, id_turma) VALUES (1, 1);
INSERT INTO professor_turma (id_professor, id_turma) VALUES (1, 2);
INSERT INTO professor_turma (id_professor, id_turma) VALUES (1, 3);
INSERT INTO professor_turma (id_professor, id_turma) VALUES (1, 4);
INSERT INTO professor_turma (id_professor, id_turma) VALUES (1, 5);
SELECT 'Professor Solo (5 turmas):', pt.* FROM professor_turma pt WHERE pt.id_professor = 1;

-- Teste 7.1.1: Inserção Inválida (Prof. Solo na 6ª turma)
-- A linha abaixo deve gerar um erro!
INSERT INTO professor_turma (id_professor, id_turma) VALUES (1, 6);

-- Cenário 2: Professor com 'Professor' E 'Coordenador' (limite de 3 turmas)
INSERT INTO professor (nome, cpf, telefone) VALUES ('Prof. Multi', '222.222.222-00', '222222222'); -- id_professor = 2
INSERT INTO func_prof (id_professor, id_funcao, dt_entrada) VALUES (2, 1, '2024-01-01'); -- Professor
INSERT INTO func_prof (id_professor, id_funcao, dt_entrada) VALUES (2, 2, '2024-03-01'); -- Coordenador

-- Alocar Prof. Multi em 3 turmas (válido)
INSERT INTO professor_turma (id_professor, id_turma) VALUES (2, 1); -- Reutilizando turmas para simplicidade
INSERT INTO professor_turma (id_professor, id_turma) VALUES (2, 2);
INSERT INTO professor_turma (id_professor, id_turma) VALUES (2, 3);
SELECT 'Professor Multi (3 turmas):', pt.* FROM professor_turma pt WHERE pt.id_professor = 2;

-- Teste 7.2.1: Inserção Inválida (Prof. Multi na 4ª turma)
-- A linha abaixo deve gerar um erro!
INSERT INTO professor_turma (id_professor, id_turma) VALUES (2, 4);

-- Cenário 3: Professor SEM a função 'Professor'
INSERT INTO professor (nome, cpf, telefone) VALUES ('Apenas Coordenador', '333.333.333-00', '333333333'); -- id_professor = 3
INSERT INTO func_prof (id_professor, id_funcao, dt_entrada) VALUES (3, 2, '2024-01-01'); -- Apenas Coordenador

-- Teste 7.3.1: Inserção Inválida (Apenas Coordenador tentando lecionar)
-- A linha abaixo deve gerar um erro!
INSERT INTO professor_turma (id_professor, id_turma) VALUES (3, 1);

-- Verificando logs (opcional)
SELECT * FROM registro_relatorios WHERE nome_tabela = 'professor_turma';