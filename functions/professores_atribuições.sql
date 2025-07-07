CREATE OR REPLACE FUNCTION professores_atribuicoes(
    p_id_professor INTEGER DEFAULT NULL,
    p_id_periodo_letivo INTEGER DEFAULT NULL
) RETURNS TABLE (
    nome_professor VARCHAR(100),
    cpf_professor VARCHAR(14),
    nome_disciplina VARCHAR(100),
    sala_turma VARCHAR(50),
    horario_turma INTEGER,
    ano_periodo INTEGER,
    semestre_periodo INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        prof.nome AS nome_professor,
        prof.cpf AS cpf_professor,
        dis.nome_disciplina,
        t.sala,
        t.horario_aula,
        pl.ano,
        pl.semestre
    FROM
        professor prof
    JOIN
        professor_turma pt ON prof.id_professor = pt.id_professor
    JOIN
        turma t ON pt.id_turma = t.id_turma
    JOIN
        disciplina dis ON t.id_disciplina = dis.id_disciplina
    JOIN
        periodo_letivo pl ON t.id_periodo_letivo = pl.id_periodo_letivo
    WHERE
        (p_id_professor IS NULL OR prof.id_professor = p_id_professor)
        AND (p_id_periodo_letivo IS NULL OR pl.id_periodo_letivo = p_id_periodo_letivo)
    ORDER BY
        prof.nome, pl.ano, pl.semestre, dis.nome_disciplina;
END;
$$ LANGUAGE plpgsql;