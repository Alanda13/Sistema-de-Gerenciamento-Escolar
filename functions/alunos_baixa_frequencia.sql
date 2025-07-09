CREATE OR REPLACE FUNCTION relatorio_alunos_baixa_frequencia(
    p_id_disciplina INTEGER DEFAULT NULL,
    p_id_periodo_letivo INTEGER DEFAULT NULL,
    p_limite_frequencia NUMERIC(5,2) DEFAULT 75.00 -- Limite padrão de 75%
) RETURNS TABLE (
    nome_aluno VARCHAR(100),
    nome_disciplina VARCHAR(100),
    ano_periodo INTEGER,
    semestre_periodo INTEGER,
    taxa_presenca NUMERIC(5,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.nome AS nome_aluno,
        dis.nome_disciplina,
        pl.ano AS ano_periodo,
        pl.semestre AS semestre_periodo,
        COALESCE(
            (COUNT(p.id_aula) * 100.0) / NULLIF(SUM(au.qtd_aulas), 0),
            0.00
        ) AS taxa_presenca
    FROM
        aluno_turma at_main
    JOIN
        aluno a ON at_main.id_aluno = a.id_aluno
    JOIN
        turma t ON at_main.id_turma = t.id_turma
    JOIN
        disciplina dis ON t.id_disciplina = dis.id_disciplina
    JOIN
        periodo_letivo pl ON t.id_periodo_letivo = pl.id_periodo_letivo
    LEFT JOIN
        professor_turma pt ON t.id_turma = pt.id_turma
    LEFT JOIN
        aula au ON pt.id_prof_turma = au.id_prof_turma AND pl.id_periodo_letivo = au.id_periodo_letivo
    LEFT JOIN
        presenca p ON au.id_aula = p.id_aula AND at_main.id_aluno_turma = p.id_aluno_turma
    WHERE
        (p_id_disciplina IS NULL OR dis.id_disciplina = p_id_disciplina)
        AND (p_id_periodo_letivo IS NULL OR pl.id_periodo_letivo = p_id_periodo_letivo)
    GROUP BY
        at_main.id_aluno_turma, a.nome, dis.nome_disciplina, pl.ano, pl.semestre
    HAVING
        COALESCE(
            (COUNT(p.id_aula) * 100.0) / NULLIF(SUM(au.qtd_aulas), 0),
            0.00
        ) < p_limite_frequencia
    ORDER BY
        nome_aluno, nome_disciplina;
END;
$$ LANGUAGE plpgsql;



-----------------------
-- Inserir Períodos Letivos
SELECT cadastrar('periodo_letivo', ARRAY['ano', 'semestre', 'dt_inicio', 'dt_fim'], ARRAY['2024', '1', '2024-02-01', '2024-06-30']); -- ID 1
SELECT cadastrar('periodo_letivo', ARRAY['ano', 'semestre', 'dt_inicio', 'dt_fim'], ARRAY['2024', '2', '2024-08-01', '2024-12-15']); -- ID 2

-- Inserir Disciplinas (assumindo id_curso 1 para Eng. Software)
SELECT cadastrar('disciplina', ARRAY['nome_disciplina', 'carga_horaria', 'id_curso', 'id_pre_requisito'], ARRAY['Banco de Dados II', '80', '1', 'NULL']); -- ID 1
SELECT cadastrar('disciplina', ARRAY['nome_disciplina', 'carga_horaria', 'id_curso', 'id_pre_requisito'], ARRAY['Estrutura de Dados', '60', '1', 'NULL']); -- ID 2
SELECT cadastrar('disciplina', ARRAY['nome_disciplina', 'carga_horaria', 'id_curso', 'id_pre_requisito'], ARRAY['Cálculo I', '90', '2', 'NULL']); -- ID 3

-- Inserir Funções
SELECT cadastrar('funcao', ARRAY['funcao'], ARRAY['Professor']); -- ID 1
SELECT cadastrar('funcao', ARRAY['funcao'], ARRAY['Coordenador']); -- ID 2

-- Inserir Professores
SELECT cadastrar('professor', ARRAY['nome', 'cpf', 'telefone'], ARRAY['Prof. Silva', '000.000.000-00', '99000-0000']); -- ID 1
SELECT cadastrar('professor', ARRAY['nome', 'cpf', 'telefone'], ARRAY['Prof. Oliveira', '101.101.101-10', '99101-1010']); -- ID 2

-- Atribuir Funções aos Professores
SELECT cadastrar('func_prof', ARRAY['id_professor', 'id_funcao', 'dt_entrada', 'dt_saida'], ARRAY['1', '1', '2023-01-01', 'NULL']); -- Prof. Silva é Professor
SELECT cadastrar('func_prof', ARRAY['id_professor', 'id_funcao', 'dt_entrada', 'dt_saida'], ARRAY['2', '1', '2023-01-01', 'NULL']); -- Prof. Oliveira é Professor
SELECT cadastrar('func_prof', ARRAY['id_professor', 'id_funcao', 'dt_entrada', 'dt_saida'], ARRAY['2', '2', '2023-01-01', 'NULL']); -- Prof. Oliveira também é Coordenador

-- Inserir Turmas
-- Turma de Banco de Dados II (ID 1, Disc ID 1, Período ID 1)
SELECT cadastrar('turma', ARRAY['sala', 'horario_aula', 'qtd_vagas', 'id_disciplina', 'id_periodo_letivo'], ARRAY['Sala A1', '14', '20', '1', '1']); -- ID 1
-- Turma de Estrutura de Dados (ID 2, Disc ID 2, Período ID 1)
SELECT cadastrar('turma', ARRAY['sala', 'horario_aula', 'qtd_vagas', 'id_disciplina', 'id_periodo_letivo'], ARRAY['Sala B2', '16', '15', '2', '1']); -- ID 2
-- Turma de Cálculo I (ID 3, Disc ID 3, Período ID 2)
SELECT cadastrar('turma', ARRAY['sala', 'horario_aula', 'qtd_vagas', 'id_disciplina', 'id_periodo_letivo'], ARRAY['Sala C3', '10', '25', '3', '2']); -- ID 3

-- Atribuir Professores às Turmas (professor_turma)
SELECT cadastrar('professor_turma', ARRAY['id_professor', 'id_turma'], ARRAY['1', '1']); -- Prof. Silva na Turma 1 (BD II)
SELECT cadastrar('professor_turma', ARRAY['id_professor', 'id_turma'], ARRAY['1', '2']); -- Prof. Silva na Turma 2 (Estrutura de Dados)
SELECT cadastrar('professor_turma', ARRAY['id_professor', 'id_turma'], ARRAY['2', '3']); -- Prof. Oliveira na Turma 3 (Cálculo I)

-- Matricular Alunos em Turmas (aluno_turma)
-- Aluno 1 (Ana Paula) na Turma 1 (BD II)
SELECT cadastrar('aluno_turma', ARRAY['id_aluno', 'id_turma'], ARRAY['1', '1']); -- ID 1
-- Aluno 2 (Bruno Costa) na Turma 1 (BD II)
SELECT cadastrar('aluno_turma', ARRAY['id_aluno', 'id_turma'], ARRAY['2', '1']); -- ID 2
-- Aluno 4 (Daniela Lima) na Turma 3 (Cálculo I)
SELECT cadastrar('aluno_turma', ARRAY['id_aluno', 'id_turma'], ARRAY['4', '3']); -- ID 3

-- Inserir Aulas (para calcular frequência)
-- Aulas para Turma 1 (BD II) - 5 aulas no total
SELECT cadastrar('aula', ARRAY['id_periodo_letivo', 'id_prof_turma', 'assunto', 'data', 'qtd_aulas'], ARRAY['1', '1', 'Introdução a BD', '2024-02-05', '1']); -- ID 1
SELECT cadastrar('aula', ARRAY['id_periodo_letivo', 'id_prof_turma', 'assunto', 'data', 'qtd_aulas'], ARRAY['1', '1', 'Modelagem ER', '2024-02-12', '1']); -- ID 2
SELECT cadastrar('aula', ARRAY['id_periodo_letivo', 'id_prof_turma', 'assunto', 'data', 'qtd_aulas'], ARRAY['1', '1', 'Normalização', '2024-02-19', '1']); -- ID 3
SELECT cadastrar('aula', ARRAY['id_periodo_letivo', 'id_prof_turma', 'assunto', 'data', 'qtd_aulas'], ARRAY['1', '1', 'SQL Básico', '2024-02-26', '1']); -- ID 4
SELECT cadastrar('aula', ARRAY['id_periodo_letivo', 'id_prof_turma', 'assunto', 'data', 'qtd_aulas'], ARRAY['1', '1', 'SQL Avançado', '2024-03-04', '1']); -- ID 5

-- Aulas para Turma 3 (Cálculo I) - 4 aulas no total
SELECT cadastrar('aula', ARRAY['id_periodo_letivo', 'id_prof_turma', 'assunto', 'data', 'qtd_aulas'], ARRAY['2', '3', 'Limites', '2024-08-05', '1']); -- ID 6
SELECT cadastrar('aula', ARRAY['id_periodo_letivo', 'id_prof_turma', 'assunto', 'data', 'qtd_aulas'], ARRAY['2', '3', 'Derivadas', '2024-08-12', '1']); -- ID 7
SELECT cadastrar('aula', ARRAY['id_periodo_letivo', 'id_prof_turma', 'assunto', 'data', 'qtd_aulas'], ARRAY['2', '3', 'Integrais', '2024-08-19', '1']); -- ID 8
SELECT cadastrar('aula', ARRAY['id_periodo_letivo', 'id_prof_turma', 'assunto', 'data', 'qtd_aulas'], ARRAY['2', '3', 'Aplicações', '2024-08-26', '1']); -- ID 9


-- Inserir Presenças (para simular baixa frequência)
-- Aluno 1 (Ana Paula) na Turma 1 (BD II) - Frequência alta (4 de 5 aulas)
SELECT cadastrar('presenca', ARRAY['id_aula', 'id_aluno_turma'], ARRAY['1', '1']);
SELECT cadastrar('presenca', ARRAY['id_aula', 'id_aluno_turma'], ARRAY['2', '1']);
SELECT cadastrar('presenca', ARRAY['id_aula', 'id_aluno_turma'], ARRAY['3', '1']);
SELECT cadastrar('presenca', ARRAY['id_aula', 'id_aluno_turma'], ARRAY['4', '1']);

-- Aluno 2 (Bruno Costa) na Turma 1 (BD II) - Frequência baixa (2 de 5 aulas = 40%)
SELECT cadastrar('presenca', ARRAY['id_aula', 'id_aluno_turma'], ARRAY['1', '2']);
SELECT cadastrar('presenca', ARRAY['id_aula', 'id_aluno_turma'], ARRAY['2', '2']);

-- Aluno 4 (Daniela Lima) na Turma 3 (Cálculo I) - Frequência alta (3 de 4 aulas)
SELECT cadastrar('presenca', ARRAY['id_aula', 'id_aluno_turma'], ARRAY['6', '3']);
SELECT cadastrar('presenca', ARRAY['id_aula', 'id_aluno_turma'], ARRAY['7', '3']);
SELECT cadastrar('presenca', ARRAY['id_aula', 'id_aluno_turma'], ARRAY['8', '3']);

-- Aluno 5 (Eduardo Santos) na Turma 3 (Cálculo I) - Frequência baixa (1 de 4 aulas = 25%)
SELECT cadastrar('presenca', ARRAY['id_aula', 'id_aluno_turma'], ARRAY['6', '4']);

-- Testar a função relatorio_alunos_baixa_frequencia:
SELECT * FROM relatorio_alunos_baixa_frequencia(); -- Limite padrão 75%
SELECT * FROM relatorio_alunos_baixa_frequencia(p_limite_frequencia := 50.00); -- Alunos com frequência abaixo de 50%
SELECT * FROM relatorio_alunos_baixa_frequencia(p_id_disciplina := 1); -- Alunos de BD II com baixa frequência
SELECT * FROM relatorio_alunos_baixa_frequencia(p_id_periodo_letivo := 1); -- Alunos do Período 1 com baixa frequência

-------falta ajeitar!!!!