-- Pré-requisitos
INSERT INTO curso (nome, carga_horaria) VALUES ('Engenharia de Software', 3600); -- id_curso = 1
INSERT INTO periodo_letivo (ano, semestre, dt_inicio, dt_fim) VALUES (2025, 2, '2025-08-01', '2025-12-15'); -- id_periodo_letivo = 1

-- Criar 8 disciplinas e turmas para o mesmo período
DO $$
DECLARE
    i INTEGER;
BEGIN
    FOR i IN 1..8 LOOP
        INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso) VALUES ('Disciplina ' || i, 60, 1);
        INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo) VALUES ('Sala ' || i, i, 10, i, 1);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

INSERT INTO aluno (nome, cpf, email, data_nasc, telefone, id_curso, status) VALUES ('Aluno Multiturmas', '777.777.777-77', 'alunomult@email.com', '2000-01-01', '777777777', 1, 'ativo'); -- id_aluno = 1

-- Teste 10.1: Matricular em 7 turmas (válido)
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (1, 1);
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (1, 2);
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (1, 3);
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (1, 4);
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (1, 5);
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (1, 6);
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (1, 7);
SELECT 'Aluno Multiturmas (7 turmas):', * FROM aluno_turma;

-- Teste 10.2: Matricular na 8ª turma (inválido - excedendo o limite)
-- A linha abaixo deve gerar um erro!
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (1, 8);

-- Verificando logs (opcional)
SELECT * FROM registro_relatorios WHERE nome_tabela = 'aluno_turma';