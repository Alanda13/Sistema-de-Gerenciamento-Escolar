CREATE OR REPLACE FUNCTION alterar(
    p_tabela VARCHAR, -- Alterado de TEXT para VARCHAR
    p_coluna_id VARCHAR, -- Alterado de TEXT para VARCHAR
    p_valor_id VARCHAR, -- Alterado de TEXT para VARCHAR
    p_colunas_a_atualizar TEXT[],
    p_novos_valores TEXT[]
)
RETURNS TEXT AS $$
DECLARE
    v_set_str TEXT := '';
    v_sql TEXT;
    v_count INTEGER;
BEGIN
    -- Validação: número de colunas e valores
    IF array_length(p_colunas_a_atualizar, 1) IS DISTINCT FROM array_length(p_novos_valores, 1) THEN
        RETURN 'Erro: O número de colunas a serem atualizadas e novos valores não corresponde.';
    END IF;

    -- Constrói a string SET 'coluna' = 'valor'
    FOR i IN 1 .. array_length(p_colunas_a_atualizar, 1) LOOP
        v_set_str := v_set_str || quote_ident(p_colunas_a_atualizar[i]) || ' = ' || quote_literal(p_novos_valores[i]);
        IF i < array_length(p_colunas_a_atualizar, 1) THEN
            v_set_str := v_set_str || ', ';
        END IF;
    END LOOP;

    -- Constrói a query SQL completa
    v_sql := 'UPDATE ' || quote_ident(p_tabela) || ' SET ' || v_set_str ||
             ' WHERE ' || quote_ident(p_coluna_id) || ' = ' || quote_literal(p_valor_id);

    EXECUTE v_sql;
    GET DIAGNOSTICS v_count = ROW_COUNT; -- Retorna o número de linhas afetadas

    IF v_count = 0 THEN
        RETURN 'Nenhum registro encontrado na tabela ' || p_tabela || ' com ' || p_coluna_id || ' = ' || p_valor_id || ' para atualizar.';
    ELSE
        RETURN v_count || ' registro(s) atualizado(s) com sucesso na tabela ' || p_tabela || '.';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Erro ao atualizar registro na tabela ' || p_tabela || ': ' || SQLERRM || '. SQL: ' || v_sql;
END;
$$ LANGUAGE plpgsql;

------testanto função de alterar
-- Teste 1: Alterar o E-mail de um Aluno
SELECT alterar(
    'aluno',                        -- Tabela
    'id_aluno', '1',                -- Condição WHERE: id_aluno = 1
    ARRAY['email'],                 -- Colunas a serem atualizadas
    ARRAY['alice.silva.novo@ifpi.edu.br'] -- Novos valores correspondentes
);

select * from aluno;