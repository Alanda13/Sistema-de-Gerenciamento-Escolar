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

SELECT cadastrar('aluno', ARRAY['nome', 'cpf', 'email', 'data_nasc', 'telefone', 'id_curso', 'status'],
ARRAY['Eduardo bezerra', '599.355.555-55', 'edi.s@email.com', '2900-11-30', '994455-5555', '3', 'ativo']);
SELECT cadastrar('aluno', ARRAY['nome', 'cpf', 'email', 'data_nasc', 'telefone', 'id_curso', 'status'], 
ARRAY['Ana Paula', '131.111.111-11', 'ana.paula@email.com', '2000-01-15', '99111-1111', '1', 'ativo']); -- ID 1
SELECT cadastrar('aluno', ARRAY['nome', 'cpf', 'email', 'data_nasc', 'telefone', 'id_curso', 'status'], 
ARRAY['Bruno Costa', '222.666.222-22', 'bruno.c@email.com', '2001-03-20', '99222-2222', '2', 'ativo']); -- ID 2
SELECT cadastrar('aluno', ARRAY['nome', 'cpf', 'email', 'data_nasc', 'telefone', 'id_curso', 'status'],
ARRAY['Carla Dias', '333.303.333-33', 'carla.d@email.com', '1999-07-10', '99333-3333', '1', 'inativo']); -- ID 1

SELECT cadastrar('aluno', ARRAY['nome', 'cpf', 'email', 'data_nasc', 'telefone', 'id_curso', 'status'],
ARRAY['Daniela Lima', '444.444.494-44', 'dani.l@email.com', '2002-05-05', '99444-4444', '2', 'ativo']); -- ID 4
SELECT cadastrar('aluno', ARRAY['nome', 'cpf', 'email', 'data_nasc', 'telefone', 'id_curso', 'status'],
ARRAY['Eduardo Santos', '555.355.555-55', 'edu.s@email.com', '2000-11-30', '99555-5555', '2', 'ativo']); -- ID 5

SELECT * FROM alunos_ativos_por_curso(1);

-----------------funcionando
