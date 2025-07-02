CREATE OR REPLACE FUNCTION alterar(
    p_nome_tabela TEXT,
    p_nomes_colunas_set TEXT[], -- Nomes das colunas para alterar. Ex: ARRAY['nome', 'carga_horaria']
    p_novos_valores TEXT[],     -- Novos valores correspondentes. Ex: ARRAY['Novo Nome', '200']
    p_nome_coluna_id TEXT,      -- Nome da coluna que identifica o registro. Ex: 'id_curso'
    p_valor_id TEXT             -- Valor da coluna de identificação. Ex: '1'
)
RETURNS TEXT AS $$
DECLARE
    v_set_clause TEXT := '';
    v_sql TEXT;
    v_count INTEGER;
    i INTEGER;
BEGIN
    -- 1. Verifica se a tabela existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = p_nome_tabela) THEN
        RETURN 'Erro: A tabela "' || p_nome_tabela || '" não existe.';
    END IF;

    -- 2. Verifica se o número de colunas e valores corresponde
    IF array_length(p_nomes_colunas_set, 1) IS NULL OR array_length(p_novos_valores, 1) IS NULL OR array_length(p_nomes_colunas_set, 1) <> array_length(p_novos_valores, 1) THEN
        RETURN 'Erro: O número de nomes de colunas para SET não corresponde ao número de novos valores.';
    END IF;

    -- 3. Constrói a parte SET do UPDATE
    FOR i IN 1..array_length(p_nomes_colunas_set, 1)
    LOOP
        IF i > 1 THEN
            v_set_clause := v_set_clause || ', ';
        END IF;

        v_set_clause := v_set_clause || quote_ident(p_nomes_colunas_set[i]) || ' = ';

        -- Trata 'NULL' como valor nulo SQL
        IF p_novos_valores[i] = 'NULL' THEN
            v_set_clause := v_set_clause || 'NULL';
        ELSE
            v_set_clause := v_set_clause || quote_literal(p_novos_valores[i]);
        END IF;
    END LOOP;

    IF v_set_clause = '' THEN
        RETURN 'Erro: Nenhum dado válido fornecido para alteração.';
    END IF;

    -- 4. Constrói a query de UPDATE
    v_sql := 'UPDATE ' || quote_ident(p_nome_tabela) || ' SET ' || v_set_clause ||
             ' WHERE ' || quote_ident(p_nome_coluna_id) || ' = ' || quote_literal(p_valor_id) || ';';

    -- 5. Executa a query
    BEGIN
        EXECUTE v_sql;
        GET DIAGNOSTICS v_count = ROW_COUNT;
        IF v_count = 0 THEN
            RETURN 'Nenhum registro encontrado na tabela ' || p_nome_tabela || ' com ' || p_nome_coluna_id || ' = ' || p_valor_id || '.';
        ELSE
            RETURN v_count || ' registro(s) alterado(s) com sucesso na tabela ' || p_nome_tabela || '.';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'Erro ao alterar dados na tabela ' || p_nome_tabela || ': ' || SQLERRM || '. SQL: ' || v_sql;
    END;
END;
$$ LANGUAGE plpgsql;