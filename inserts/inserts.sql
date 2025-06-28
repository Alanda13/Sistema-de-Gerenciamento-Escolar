---curso
INSERT INTO curso (id_curso, nome, carga_horaria) VALUES
(1, 'Análise e Desenvolvimento de Sistemas', 2000),
(2, 'Engenharia de Software', 3000)
(3, 'Engenharia da Computação', 3800);

-----disciplina
INSERT INTO disciplina (id_disciplina, nome_disciplina, carga_horaria, id_curso, id_aluno, id_pre_requisito) VALUES
(1, 'Algoritmos', 80, 1),
(2, 'Estrutura de Dados', 80, 1, 1),
(3, 'Banco de Dados', 80, 1, 1);

-----periodo letivo
INSERT INTO periodo_letivo (id_periodo_letivo, semestre, ano, dt_inicio, dt_fim) VALUES
(1, 1, 2025, '2025-01-15', '2025-06-30'),
(2, 2, 2025, '2025-08-01', '2025-12-20');

----turma
INSERT INTO turma (id_turma, sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo) VALUES
(1, 'Lab 01', 4, 30, 1, 1),
(2, 'Lab 02', 4, 25, 2, 1),
(3, 'Lab 03', 6, 20, 3, 1);

----aluno
INSERT INTO aluno (id_aluno, nome, cpf, email, data_nasc, telefone, id_curso, status) VALUES
(2, 'João Silva', '111.111.111-11', 'joao@ifpi.edu.br', '2000-05-10', '88991234567', 1, 'ativo'),
(3, 'Maria Souza', '222.222.222-22', 'maria@ifpi.edu.br', '2001-08-15', '88991234567', 1, 'ativo'),
(4, 'Carlos Silva', '333.333.333-33', 'carlos@ifpi.edu.br', '1999-02-25', '869777777', 2, 'inativo');


--aluno turma
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES
(2, 2),
(3, 2);

---- professor 
INSERT INTO professor (id_professor, nome, cpf, telefone) VALUES
(1, 'Carlos Lima', '12312312312', '8899001122'),
(2, 'Ana Beatriz', '32132132132', '8899112233');




---- funcao
INSERT INTO funcao (id_funcao, funcao) VALUES
(1, 'Professor'),
(2, 'Orientador');

---- funcao_prof
INSERT INTO func_prof (id_professor, id_funcao, dt_entrada, dt_saida) VALUES
(1, 1, '2023-01-01', NULL),
(2, 2, '2024-05-01', NULL);

--- prof_turma
INSERT INTO professor_turma (id_prof_turma, id_professor, id_turma) VALUES
(1, 1, 1);

---avaliacao

INSERT INTO avaliacao (id_avaliacao, id_prof_turma, descricao, data) VALUES
(1, 1, 'Prova 1', '2025-03-10'),
(2, 1, 'Prova 2', '2025-04-20'),
(3, 1, 'Trabalho', '2025-04-15');

---result_avaliacao
INSERT INTO result_avaliacao (id_avaliacao, id_aluno, nota_obtida) VALUES
(1, 2, 8.5),
(1, 3, 7.0);

