-- Reiniciar contadores (SERIALS) de todas as tabelas e limpar dados para garantir um estado limpo
-- Execute esta seção se você deseja zerar o banco de dados antes de popular.
DELETE FROM result_avaliacao;
DELETE FROM presenca;
DELETE FROM result_aluno_periodo;
DELETE FROM aula;
DELETE FROM avaliacao;
DELETE FROM professor_turma;
DELETE FROM func_prof;
DELETE FROM aluno_turma;
DELETE FROM turma;
DELETE FROM disciplina;
DELETE FROM aluno;
DELETE FROM professor;
DELETE FROM funcao;
DELETE FROM periodo_letivo;
DELETE FROM curso;
DELETE FROM registro_relatorios;

ALTER SEQUENCE curso_id_curso_seq RESTART WITH 1;
ALTER SEQUENCE disciplina_id_disciplina_seq RESTART WITH 1;
ALTER SEQUENCE aluno_id_aluno_seq RESTART WITH 1;
ALTER SEQUENCE periodo_letivo_id_periodo_letivo_seq RESTART WITH 1;
ALTER SEQUENCE turma_id_turma_seq RESTART WITH 1;
ALTER SEQUENCE aluno_turma_id_aluno_turma_seq RESTART WITH 1;
ALTER SEQUENCE funcao_id_funcao_seq RESTART WITH 1;
ALTER SEQUENCE professor_id_professor_seq RESTART WITH 1;
ALTER SEQUENCE professor_turma_id_prof_turma_seq RESTART WITH 1;
ALTER SEQUENCE avaliacao_id_avaliacao_seq RESTART WITH 1;
ALTER SEQUENCE aula_id_aula_seq RESTART WITH 1;
ALTER SEQUENCE result_aluno_periodo_id_result_aluno_periodo_seq RESTART WITH 1;
ALTER SEQUENCE registro_relatorios_id_registro_seq RESTART WITH 1;

-- 1. Tabela: CURSO
INSERT INTO curso (nome, carga_horaria) VALUES
('Engenharia de Software', 3600),   -- id_curso = 1
('Ciência da Computação', 3200),    -- id_curso = 2
('Análise e Desenvolvimento de Sistemas', 2800), -- id_curso = 3
('Sistemas de Informação', 3000),   -- id_curso = 4
('Redes de Computadores', 2500),    -- id_curso = 5
('Engenharia Elétrica', 4000);      -- id_curso = 6

-- 2. Tabela: PERIODO_LETIVO
INSERT INTO periodo_letivo (ano, semestre, dt_inicio, dt_fim) VALUES
(2024, 1, '2024-02-01', '2024-06-30'), -- id_periodo_letivo = 1
(2024, 2, '2024-08-01', '2024-12-15'), -- id_periodo_letivo = 2
(2025, 1, '2025-02-01', '2025-06-30'), -- id_periodo_letivo = 3
(2025, 2, '2025-08-01', '2025-12-15'), -- id_periodo_letivo = 4
(2026, 1, '2026-02-01', '2026-06-30'), -- id_periodo_letivo = 5
(2026, 2, '2026-08-01', '2026-12-15'); -- id_periodo_letivo = 6

-- 3. Tabela: DISCIPLINA (com alguns pré-requisitos)
INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso, id_pre_requisito) VALUES
('Programação Orientada a Objetos', 80, 1, NULL),    -- id_disciplina = 1 (Eng. Software)
('Estruturas de Dados', 80, 2, NULL),               -- id_disciplina = 2 (Ciência Comp.)
('Banco de Dados I', 80, 3, NULL),                  -- id_disciplina = 3 (ADS)
('Redes de Computadores Fundamentos', 60, 5, NULL), -- id_disciplina = 4 (Redes)
('Cálculo I', 120, 6, NULL),                        -- id_disciplina = 5 (Eng. Elétrica)
('Engenharia de Software I', 80, 1, NULL),          -- id_disciplina = 6 (Eng. Software)
('Algoritmos Avançados', 80, 2, 2),                 -- id_disciplina = 7 (Ciência Comp. - Prereq: Estruturas de Dados)
('Banco de Dados II', 80, 3, 3);                    -- id_disciplina = 8 (ADS - Prereq: Banco de Dados I)


-- 4. Tabela: ALUNO
INSERT INTO aluno (nome, cpf, email, data_nasc, telefone, id_curso, status) VALUES
('Maria Silva', '111.111.111-11', 'maria.silva@email.com', '2002-01-15', '998877665', 1, 'ativo'), -- id_aluno = 1 (Eng. Software)
('João Santos', '222.222.222-22', 'joao.santos@email.com', '2001-05-20', '987654321', 2, 'ativo'),  -- id_aluno = 2 (Ciência Comp.)
('Ana Paula', '333.333.333-33', 'ana.paula@email.com', '2003-03-10', '991122334', 3, 'ativo'),   -- id_aluno = 3 (ADS)
('Carlos Souza', '444.444.444-44', 'carlos.souza@email.com', '2000-11-25', '988776655', 4, 'ativo'), -- id_aluno = 4 (Sistemas Info.)
('Fernanda Lima', '555.555.555-55', 'fernanda.lima@email.com', '2004-07-07', '999887766', 5, 'ativo'), -- id_aluno = 5 (Redes)
('Pedro Costa', '666.666.666-66', 'pedro.costa@email.com', '2002-09-01', '987765544', 6, 'ativo'),  -- id_aluno = 6 (Eng. Elétrica)
('Julia Alves', '777.777.777-77', 'julia.alves@email.com', '2003-04-18', '991133557', 1, 'ativo'),  -- id_aluno = 7 (Eng. Software)
('Lucas Mendes', '888.888.888-88', 'lucas.mendes@email.com', '2001-10-05', '982244668', 2, 'ativo'); -- id_aluno = 8 (Ciência Comp.)

-- 5. Tabela: FUNCAO
INSERT INTO funcao (funcao) VALUES
('Professor'),      -- id_funcao = 1
('Coordenador'),    -- id_funcao = 2
('Diretor'),        -- id_funcao = 3
('Secretário(a)'),  -- id_funcao = 4
('Bibliotecário(a)'),-- id_funcao = 5
('Pesquisador');    -- id_funcao = 6

-- 6. Tabela: PROFESSOR
INSERT INTO professor (nome, cpf, telefone) VALUES
('Dr. Alberto Lima', '010.010.010-10', '999900001'), -- id_professor = 1
('Profa. Beatriz Mello', '020.020.020-20', '999900002'), -- id_professor = 2
('Dr. Claudio Neves', '030.030.030-30', '999900003'), -- id_professor = 3
('Profa. Denise Oliveira', '040.040.040-40', '999900004'), -- id_professor = 4
('Eng. Eduardo Pereira', '050.050.050-50', '999900005'), -- id_professor = 5
('Dra. Fabiana Queiroz', '060.060.060-60', '999900006'); -- id_professor = 6

-- 7. Tabela: FUNC_PROF (Vínculo Professor-Função)
INSERT INTO func_prof (id_professor, id_funcao, dt_entrada) VALUES
(1, 1, '2020-01-01'), -- Dr. Alberto: Professor
(2, 1, '2019-08-15'), -- Profa. Beatriz: Professor
(3, 1, '2021-03-10'), -- Dr. Claudio: Professor
(4, 1, '2018-02-20'), -- Profa. Denise: Professor
(5, 1, '2022-06-01'), -- Eng. Eduardo: Professor
(6, 1, '2020-09-01'), -- Dra. Fabiana: Professor
(1, 2, '2023-01-01'), -- Dr. Alberto: Coordenador (limite de 2 funções)
(3, 6, '2023-05-01'); -- Dr. Claudio: Pesquisador (limite de 2 funções)

-- 8. Tabela: TURMA (Cada turma está associada a uma disciplina e um período letivo)
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo) VALUES
('A101', 4, 30, 1, 3), -- id_turma = 1 (POO - 2025/1)
('B203', 5, 25, 2, 3), -- id_turma = 2 (Estruturas de Dados - 2025/1)
('C305', 3, 35, 3, 3), -- id_turma = 3 (BD I - 2025/1)
('D401', 4, 20, 4, 3), -- id_turma = 4 (Redes Fundamentos - 2025/1)
('E502', 6, 40, 5, 3), -- id_turma = 5 (Cálculo I - 2025/1)
('A102', 4, 30, 6, 3), -- id_turma = 6 (Eng. Software I - 2025/1)
('B204', 5, 25, 7, 4), -- id_turma = 7 (Algoritmos Avançados - 2025/2)
('C306', 3, 35, 8, 4); -- id_turma = 8 (BD II - 2025/2)

-- 9. Tabela: PROFESSOR_TURMA (Associação entre Professor e Turma)
INSERT INTO professor_turma (id_professor, id_turma) VALUES
(1, 1), -- Dr. Alberto (Professor, Coordenador) -> POO
(2, 2), -- Profa. Beatriz (Professor) -> Estruturas de Dados
(3, 3), -- Dr. Claudio (Professor, Pesquisador) -> BD I
(4, 4), -- Profa. Denise (Professor) -> Redes Fundamentos
(5, 5), -- Eng. Eduardo (Professor) -> Cálculo I
(6, 6), -- Dra. Fabiana (Professor) -> Eng. Software I
(2, 5), -- Profa. Beatriz -> Algoritmos Avançados (dentro do limite)
(3, 4); -- Dr. Claudio -> BD II (dentro do limite)

-- 10. Tabela: ALUNO_TURMA (Matrícula de Alunos em Turmas)
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES
(1, 1), -- Maria (Eng. Software) -> POO (id_aluno_turma = 1)
(7, 1), -- Julia (Eng. Software) -> POO (id_aluno_turma = 2)
(2, 2), -- João (Ciência Comp.) -> Estruturas de Dados (id_aluno_turma = 3)
(8, 2), -- Lucas (Ciência Comp.) -> Estruturas de Dados (id_aluno_turma = 4)
(3, 3), -- Ana (ADS) -> BD I (id_aluno_turma = 5)
(6, 5), -- Pedro (Eng. Elétrica) -> Eng. Software I (id_aluno_turma = 6)
(1, 6), -- Maria (Eng. Software) -> Algoritmos Av. (id_aluno_turma = 7)
(3, 8); -- Ana (ADS) -> BD II (id_aluno_turma = 8)

-- 11. Tabela: AVALIACAO (Avaliações para as turmas)
INSERT INTO avaliacao (descricao, data, id_prof_turma, id_periodo_letivo) VALUES
('Prova POO - A1', '2025-04-10', 1, 3), -- id_avaliacao = 1 (Turma 1 - POO)
('Trabalho ED - T1', '2025-05-01', 2, 3), -- id_avaliacao = 2 (Turma 2 - Estruturas de Dados)
('Exame BD I - E1', '2025-06-15', 3, 3), -- id_avaliacao = 3 (Turma 3 - BD I)
('Atividade Redes', '2025-04-20', 4, 3), -- id_avaliacao = 4 (Turma 4 - Redes)
('Prova Cálculo I', '2025-06-01', 5, 3), -- id_avaliacao = 5 (Turma 5 - Cálculo I)
('Projeto ES I', '2025-05-25', 6, 3), -- id_avaliacao = 6 (Turma 6 - Eng. Software I)
('Teste Alg. Av.', '2025-10-05', 7, 4), -- id_avaliacao = 7 (Turma 7 - Algoritmos Av.)
('Prova BD II', '2025-11-10', 8, 4); -- id_avaliacao = 8 (Turma 8 - BD II)
select * from avaliacao
-- 12. Tabela: RESULT_AVALIACAO (Notas dos Alunos nas Avaliações)
INSERT INTO result_avaliacao (id_avaliacao, id_aluno_turma, nota_obtida) VALUES
(1, 1, 8.5),  -- Maria em POO, Prova A1
(1, 2, 7.0),  -- Julia em POO, Prova A1
(2, 3, 6.8),  -- João em ED, Trabalho T1
(2, 4, 9.2),  -- Lucas em ED, Trabalho T1
(3, 5, 5.0),  -- Ana em BD I, Exame E1 (reprovado por nota)
(4, 6, 7.7),  -- Carlos em Redes, Atividade Redes
(5, 7, 8.0),  -- Fernanda em Cálculo I, Prova
(6, 8, 6.5);  -- Pedro em ES I, Projeto (reprovado por nota)

select * from result_avaliacao
select * from aluno_turma

-- 13. Tabela: AULA (Sessões de Aula)
INSERT INTO aula (id_periodo_letivo, id_prof_turma, assunto, data, qtd_aulas) VALUES
(3, 1, 'Introdução POO', '2025-02-05', 2),  -- id_aula = 1 (Turma 1 - POO)
(3, 1, 'Herança POO', '2025-02-12', 2),    -- id_aula = 2 (Turma 1 - POO)
(3, 2, 'Arrays em ED', '2025-02-06', 3),   -- id_aula = 3 (Turma 2 - Estruturas de Dados)
(3, 3, 'Modelagem Relacional', '2025-02-07', 2), -- id_aula = 4 (Turma 3 - BD I)
(3, 4, 'Topologias de Rede', '2025-02-10', 2), -- id_aula = 5 (Turma 4 - Redes)
(3, 5, 'Limites e Derivadas', '2025-02-11', 3),-- id_aula = 6 (Turma 5 - Cálculo I)
(3, 6, 'Ciclo de Vida do Software', '2025-02-13', 2), -- id_aula = 7 (Turma 6 - ES I)
(4, 7, 'Grafos', '2025-08-05', 3),           -- id_aula = 8 (Turma 7 - Algoritmos Av.)
(4, 8, 'Normalização BD', '2025-08-06', 2);   -- id_aula = 9 (Turma 8 - BD II)

-- 14. Tabela: PRESENCA (Presença dos Alunos nas Aulas)
INSERT INTO presenca (id_aula, id_aluno_turma) VALUES
(1, 1), -- Maria presente na Aula 1 (POO)
(2, 1), -- Maria presente na Aula 2 (POO) - 100% de presença
(1, 2), -- Julia presente na Aula 1 (POO)
-- Julia ausente na Aula 2 (POO) - 50% de presença
(3, 3), -- João presente na Aula 3 (ED) - 100%
(3, 4), -- Lucas presente na Aula 3 (ED) - 100%
(4, 5), -- Ana presente na Aula 4 (BD I) - 100%
(5, 6), -- Carlos presente na Aula 5 (Redes) - 100%
(6, 7), -- Fernanda presente na Aula 6 (Cálculo I) - 100%
(7, 8); -- Pedro presente na Aula 7 (ES I) - 100%

-- 15. Tabela: RESULT_ALUNO_PERIODO (Resultados consolidados - Populdada por triggers)
-- Esta tabela será populada e atualizada automaticamente pelos triggers
-- trg_calcular_media_aluno e trg_calcular_taxa_presenca_aluno.
-- Podemos consultar para ver o estado atual:
SELECT
    al.nome AS aluno_nome,
    d.nome_disciplina AS disciplina_nome,
    pl.ano || '/' || pl.semestre AS periodo,
    rap.nota_media,
    rap.taxa_de_presenca,
    rap.resultado
FROM result_aluno_periodo rap
JOIN aluno_turma at ON rap.id_aluno_turma = at.id_aluno_turma
JOIN aluno al ON at.id_aluno = al.id_aluno
JOIN turma t ON at.id_turma = t.id_turma
JOIN disciplina d ON t.id_disciplina = d.id_disciplina
JOIN periodo_letivo pl ON t.id_periodo_letivo = pl.id_periodo_letivo
ORDER BY aluno_nome, periodo, disciplina_nome;

-- Agora, vamos "finalizar" algumas disciplinas para ver o resultado mudar
-- (Aprovado/Reprovado) usando a função `finalizar_disciplina_alunos_da_turma`.
-- Ex: Turma 1 (POO)
SELECT finalizar_disciplina_alunos_da_turma(1);
-- Ex: Turma 3 (BD I) - Ana reprovou por nota (5.0)
SELECT finalizar_disciplina_alunos_da_turma(3);
-- Ex: Turma 6 (ES I) - Pedro reprovou por nota (6.5)
SELECT finalizar_disciplina_alunos_da_turma(6);

-- Consultar novamente os resultados finais
SELECT
    al.nome AS aluno_nome,
    d.nome_disciplina AS disciplina_nome,
    pl.ano || '/' || pl.semestre AS periodo,
    rap.nota_media,
    rap.taxa_de_presenca,
    rap.resultado
FROM result_aluno_periodo rap
JOIN aluno_turma at ON rap.id_aluno_turma = at.id_aluno_turma
JOIN aluno al ON at.id_aluno = al.id_aluno
JOIN turma t ON at.id_turma = t.id_turma
JOIN disciplina d ON t.id_disciplina = d.id_disciplina
JOIN periodo_letivo pl ON t.id_periodo_letivo = pl.id_periodo_letivo
ORDER BY aluno_nome, periodo, disciplina_nome;

-- 16. Tabela: REGISTRO_RELATORIOS (Populada automaticamente pelos triggers)
-- Você pode consultar esta tabela para ver todas as operações de INSERT/UPDATE/DELETE que ocorreram
-- durante a população do banco de dados, pois os triggers de log estavam ativos.
SELECT * FROM registro_relatorios ORDER BY data_hora_registro DESC;
