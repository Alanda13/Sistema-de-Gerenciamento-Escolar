CREATE OR REPLACE FUNCTION cadastrar(
    p_tabela TEXT,
    p_nomes_colunas TEXT[],
    p_valores_colunas TEXT[]
)
RETURNS TEXT AS $$
DECLARE
    v_colunas_str TEXT;
    v_valores_str TEXT;
    v_sql TEXT;
    v_retorno_id INTEGER;
    v_pk_coluna TEXT;
BEGIN
    -- Validação: número de colunas e valores
    IF array_length(p_nomes_colunas, 1) IS DISTINCT FROM array_length(p_valores_colunas, 1) THEN
        RETURN 'Erro: O número de nomes de colunas e valores não corresponde.';
    END IF;

    -- Constrói a string de colunas usando STRING_AGG e quote_ident
    -- É mais conciso do que o loop, mas faz a mesma coisa:
    -- pega cada nome de coluna do array, coloca aspas nele e junta com ', '
    SELECT string_agg(quote_ident(col), ', ')
    INTO v_colunas_str
    FROM unnest(p_nomes_colunas) AS col;

    -- Constrói a string de valores usando STRING_AGG e quote_literal
    -- Pega cada valor do array, coloca aspas de literal e junta com ', '
    SELECT string_agg(quote_literal(val), ', ')
    INTO v_valores_str
    FROM unnest(p_valores_colunas) AS val;

    -- Constrói a query SQL completa
    v_sql := 'INSERT INTO ' || quote_ident(p_tabela) || ' (' || v_colunas_str || ') VALUES (' || v_valores_str || ')';

    -- Tenta obter o nome da coluna PK para o RETURNING
    -- (Essa parte não muda, é para que a função retorne o ID do novo registro)
    SELECT a.attname
    INTO v_pk_coluna
    FROM pg_index i
    JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey)
    WHERE i.indrelid = p_tabela::regclass AND i.indisprimary;

    -- Executa a query
    IF v_pk_coluna IS NOT NULL THEN
        v_sql := v_sql || ' RETURNING ' || quote_ident(v_pk_coluna);
        EXECUTE v_sql INTO v_retorno_id;
        RETURN 'Registro inserido com sucesso na tabela ' || p_tabela || '. ID: ' || v_retorno_id;
    ELSE
        EXECUTE v_sql;
        RETURN 'Registro inserido com sucesso na tabela ' || p_tabela || '.';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Erro ao inserir registro na tabela ' || p_tabela || ': ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

----------------TESTES FUNÇÃO CADASTRAR
SELECT cadastrar(
    'aluno',
    ARRAY['nome', 'cpf', 'email', 'data_nasc', 'telefone', 'id_curso', 'status'],
    ARRAY['Roberto Carlos', '444.555.666-77', 'roberto.c@example.com', '1998-11-11', '88998765432', '1', 'ativo']
);
SELECT cadastrar(
    'aluno',
    ARRAY['nome', 'cpf', 'email', 'data_nasc', 'telefone', 'id_curso', 'status'],
    ARRAY['Lionel Messi', '101.010.666-99', 'leo.c@example.com', '1998-11-11', '89998765432', '1', 'ativo']
);

select * from aluno;