-- Pré-requisitos
INSERT INTO curso (nome, carga_horaria) VALUES ('Engenharia de Software', 3600); -- id_curso = 1
INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso) VALUES ('Banco de Dados', 80, 1); -- id_disciplina = 1
INSERT INTO periodo_letivo (ano, semestre, dt_inicio, dt_fim) VALUES (2025, 2, '2025-08-01', '2025-12-15'); -- id_periodo_letivo = 1
-- Turma com 1 vaga
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo) VALUES ('Lab 301', 4, 1, 1, 1); -- id_turma = 1

-- Alunos de teste
INSERT INTO aluno (nome, cpf, email, data_nasc, telefone, id_curso, status) VALUES ('Aluno 1', '333.333.333-33', 'a1@email.com', '2001-01-01', '333333333', 1, 'ativo'); -- id_aluno = 1
INSERT INTO aluno (nome, cpf, email, data_nasc, telefone, id_curso, status) VALUES ('Aluno 2', '444.444.444-44', 'a2@email.com', '2002-02-02', '444444444', 1, 'ativo'); -- id_aluno = 2

-- Teste 6.1: Inserção Válida (ocupando a primeira e única vaga)
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (1, 1);
SELECT * FROM aluno_turma;

-- Teste 6.2: Inserção Inválida (turma cheia)
-- A linha abaixo deve gerar um erro!
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (2, 1);

-- Teste 6.3: Criar uma nova turma com mais vagas e testar update de turma
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo) VALUES ('Lab 302', 4, 5, 1, 1); -- id_turma = 2
-- Aluno 1 está na turma 1. Vamos tentar movê-lo para a turma 2.
UPDATE aluno_turma SET id_turma = 2 WHERE id_aluno = 1 AND id_turma = 1;
SELECT * FROM aluno_turma; -- Aluno 1 deve estar na turma 2

-- Teste 6.4: Tentar mover Aluno 1 de volta para a turma 1 (que agora está cheia se não for vazio)
-- Se a turma 1 ficou vazia ao mover o aluno, este teste será válido. Se não, gerará erro.
-- O trigger conta as vagas na *nova* turma. Se a turma 1 ainda tiver 0 vagas ocupadas após o update, é ok.
-- Caso contrário, se o trigger verificar OLD.id_turma para decrementar e NEW.id_turma para incrementar, a lógica seria mais complexa.
-- A lógica atual 'IF NEW.id_turma <> OLD.id_turma THEN IF (v_alunos_matriculados + 1) > v_qtd_vagas THEN' já é boa.
-- Considerando que Aluno 1 já saiu da Turma 1, a Turma 1 está vazia novamente, então um novo aluno pode entrar.

-- Inserindo outro aluno na Turma 1 (que está vazia)
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (2, 1);
SELECT * FROM aluno_turma;

-- Verificando logs (opcional)
SELECT * FROM registro_relatorios WHERE nome_tabela = 'aluno_turma';