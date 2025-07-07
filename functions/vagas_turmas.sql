CREATE OR REPLACE FUNCTION turmas_com_vagas(
    p_id_disciplina INTEGER DEFAULT NULL,
    p_id_periodo_letivo INTEGER DEFAULT NULL
) RETURNS TABLE (
    nome_disciplina VARCHAR(100),
    ano_periodo INTEGER,
    semestre_periodo INTEGER,
    sala_turma VARCHAR(50),
    horario_turma INTEGER,
    qtd_vagas_total INTEGER,
    vagas_ocupadas BIGINT,
    vagas_disponiveis BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        dis.nome_disciplina,
        pl.ano,
        pl.semestre,
        t.sala,
        t.horario_aula,
        t.qtd_vagas,
        COUNT(at.id_aluno) AS vagas_ocupadas,
        (t.qtd_vagas - COUNT(at.id_aluno)) AS vagas_disponiveis
    FROM
        turma t
    JOIN
        disciplina dis ON t.id_disciplina = dis.id_disciplina
    JOIN
        periodo_letivo pl ON t.id_periodo_letivo = pl.id_periodo_letivo
    LEFT JOIN -- LEFT JOIN para incluir turmas que ainda não têm alunos
        aluno_turma at ON t.id_turma = at.id_turma
    WHERE
        (p_id_disciplina IS NULL OR t.id_disciplina = p_id_disciplina)
        AND (p_id_periodo_letivo IS NULL OR t.id_periodo_letivo = p_id_periodo_letivo)
    GROUP BY
        dis.nome_disciplina, pl.ano, pl.semestre, t.sala, t.horario_aula, t.qtd_vagas
    HAVING
        (t.qtd_vagas - COUNT(at.id_aluno)) > 0 -- Filtra apenas turmas com vagas disponíveis
    ORDER BY
        dis.nome_disciplina, pl.ano, pl.semestre, t.sala;
END;
$$ LANGUAGE plpgsql;