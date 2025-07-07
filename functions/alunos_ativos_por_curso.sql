CREATE OR REPLACE FUNCTION alunos_ativos_por_curso(
    p_id_curso INTEGER DEFAULT NULL
) RETURNS TABLE (
    nome_curso VARCHAR(100),
    total_alunos_ativos BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.nome AS nome_curso,
        COUNT(a.id_aluno) AS total_alunos_ativos
    FROM
        curso c
    JOIN
        aluno a ON c.id_curso = a.id_curso
    WHERE
        a.status = 'ativo'
        AND (p_id_curso IS NULL OR c.id_curso = p_id_curso)
    GROUP BY
        c.nome
    ORDER BY
        c.nome;
END;
$$ LANGUAGE plpgsql;
