CREATE OR REPLACE FUNCTION cadastrar(
    p_nome_tabela TEXT,
    p_nomes_colunas TEXT[],
    p_valores TEXT[]
)
RETURNS TEXT AS $$
DECLARE
    v_colunas_str TEXT;
    v_valores_str TEXT;
    v_sql TEXT;
    v_id_gerado INTEGER;
    v_pk_coluna TEXT;
BEGIN
    -- 1. Verifica se a tabela existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = p_nome_tabela) THEN
        RETURN 'Erro: A tabela "' || p_nome_tabela || '" não existe.';
    END IF;

    -- 2. Verifica se o número de colunas e valores corresponde
    IF array_length(p_nomes_colunas, 1) IS NULL OR array_length(p_valores, 1) IS NULL OR array_length(p_nomes_colunas, 1) <> array_length(p_valores, 1) THEN
        RETURN 'Erro: O número de nomes de colunas não corresponde ao número de valores fornecidos.';
    END IF;

    -- 3. Constrói a string de colunas (escapando com quote_ident para segurança)
    v_colunas_str := array_to_string(p_nomes_colunas, ', ', quote_ident_array_elements => TRUE);

    -- 4. Constrói a string de valores (escapando com quote_literal para segurança)
    -- Trata 'NULL' como valor nulo SQL
    SELECT string_agg(
        CASE
            WHEN val = 'NULL' THEN 'NULL'
            ELSE quote_literal(val)
        END, ', '
    ) INTO v_valores_str
    FROM unnest(p_valores) AS val;

    -- 5. Encontra o nome da coluna PRIMARY KEY para o RETURNING
    SELECT a.attname INTO v_pk_coluna
    FROM pg_index i
    JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey)
    WHERE i.indrelid = p_nome_tabela::regclass AND i.indisprimary;

    -- 6. Constrói a query de INSERT
    v_sql := 'INSERT INTO ' || quote_ident(p_nome_tabela) || ' (' || v_colunas_str || ') VALUES (' || v_valores_str || ')';

    -- Adiciona RETURNING se uma PK foi encontrada
    IF v_pk_coluna IS NOT NULL THEN
        v_sql := v_sql || ' RETURNING ' || quote_ident(v_pk_coluna);
    END IF;
    v_sql := v_sql || ';';

    -- 7. Executa a query
    BEGIN
        IF v_pk_coluna IS NOT NULL THEN
            EXECUTE v_sql INTO v_id_gerado;
            RETURN 'Dados cadastrados com sucesso na tabela ' || p_nome_tabela || '. ID gerado: ' || v_id_gerado;
        ELSE
            EXECUTE v_sql;
            RETURN 'Dados cadastrados com sucesso na tabela ' || p_nome_tabela || '.';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'Erro ao cadastrar dados na tabela ' || p_nome_tabela || ': ' || SQLERRM || '. SQL: ' || v_sql;
    END;
END;
$$ LANGUAGE plpgsql;