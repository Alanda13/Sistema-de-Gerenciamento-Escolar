-- Pré-requisitos
INSERT INTO curso (nome, carga_horaria) VALUES ('Engenharia de Software', 3600); -- id_curso = 1
INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso) VALUES ('Engenharia de Requisitos', 80, 1); -- id_disciplina = 1
INSERT INTO periodo_letivo (ano, semestre, dt_inicio, dt_fim) VALUES (2025, 2, '2025-08-01', '2025-12-15'); -- id_periodo_letivo = 1
INSERT INTO professor (nome, cpf, telefone) VALUES ('Profa. Beta', '000.000.000-02', '444555666'); -- id_professor = 1
INSERT INTO funcao (funcao) VALUES ('Professor'); -- id_funcao = 1
INSERT INTO func_prof (id_professor, id_funcao, dt_entrada) VALUES (1, 1, '2025-01-01');
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo) VALUES ('Sala G', 5, 20, 1, 1); -- id_turma = 1
INSERT INTO professor_turma (id_professor, id_turma) VALUES (1, 1); -- id_prof_turma = 1

-- Aulas (para calcular presença)
INSERT INTO aula (id_periodo_letivo, id_prof_turma, assunto, data, qtd_aulas) VALUES (1, 1, 'Aula Final', '2025-12-01', 5); -- id_aula = 1 (5 horas)

-- Avaliações (para calcular média)
INSERT INTO avaliacao (descricao, data, id_prof_turma, id_periodo_letivo) VALUES ('Teste Final', '2025-12-10', 1, 1); -- id_avaliacao = 1

-- Aluno 1: Aprovado (Média >= 7.0 e Presença >= 75%)
INSERT INTO aluno (nome, cpf, email, data_nasc, telefone, id_curso, status) VALUES ('Aluno Aprovado', '222.222.222-22', 'aprovado@email.com', '2000-01-01', '222222222', 1, 'ativo'); -- id_aluno = 1
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (1, 1); -- id_aluno_turma = 1
INSERT INTO result_avaliacao (id_avaliacao, id_aluno_turma, nota_obtida) VALUES (1, 1, 8.5); -- Média 8.5
INSERT INTO presenca (id_aula, id_aluno_turma) VALUES (1, 1); -- 5 horas de 5 = 100%

-- Aluno 2: Reprovado por Média (Média < 7.0)
INSERT INTO aluno (nome, cpf, email, data_nasc, telefone, id_curso, status) VALUES ('Aluno Reprovado Media', '333.333.333-33', 'repmedia@email.com', '2000-01-01', '333333333', 1, 'ativo'); -- id_aluno = 2
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (2, 1); -- id_aluno_turma = 2
INSERT INTO result_avaliacao (id_avaliacao, id_aluno_turma, nota_obtida) VALUES (1, 2, 6.0); -- Média 6.0
INSERT INTO presenca (id_aula, id_aluno_turma) VALUES (1, 2); -- 5 horas de 5 = 100%

-- Aluno 3: Reprovado por Presença (Presença < 75%)
INSERT INTO aluno (nome, cpf, email, data_nasc, telefone, id_curso, status) VALUES ('Aluno Reprovado Presenca', '444.444.444-44', 'reppresenca@email.com', '2000-01-01', '444444444', 1, 'ativo'); -- id_aluno = 3
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (3, 1); -- id_aluno_turma = 3
INSERT INTO result_avaliacao (id_avaliacao, id_aluno_turma, nota_obtida) VALUES (1, 3, 7.5); -- Média 7.5
-- Nenhuma presença inserida, então a taxa será 0%

-- Verificar estado inicial (todos 'Em Curso')
SELECT id_aluno_turma, nota_media, taxa_de_presenca, resultado
FROM result_aluno_periodo
ORDER BY id_aluno_turma;

-- Chamar a função para finalizar os resultados da turma 1
SELECT finalizar_disciplina_alunos_da_turma(1);

-- Verificar resultados após a finalização
SELECT id_aluno_turma, nota_media, taxa_de_presenca, resultado
FROM result_aluno_periodo
ORDER BY id_aluno_turma;

-- Verificando logs (opcional)
SELECT * FROM registro_relatorios WHERE nome_tabela = 'result_aluno_periodo';