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