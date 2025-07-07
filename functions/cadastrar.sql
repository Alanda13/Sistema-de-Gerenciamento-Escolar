CREATE OR REPLACE FUNCTION cadastrar_dados_generico(
    p_nome_tabela TEXT,
    p_nomes_colunas TEXT[],
    p_valores TEXT[]
) RETURNS TEXT AS $$
DECLARE
    v_colunas_str TEXT;
    v_valores_str TEXT;
    v_query TEXT;
    i INTEGER;
BEGIN
    -- Constrói a string de nomes de colunas (ex: "nome, carga_horaria")
    v_colunas_str := '';
    FOR i IN 1..array_length(p_nomes_colunas, 1) LOOP
        IF i > 1 THEN
            v_colunas_str := v_colunas_str || ', ';
        END IF;
        v_colunas_str := v_colunas_str || quote_ident(p_nomes_colunas[i]);
    END LOOP;

    -- Constrói a string de valores (ex: 'Valor1', 'Valor2')
    v_valores_str := '';
    FOR i IN 1..array_length(p_valores, 1) LOOP
        IF i > 1 THEN
            v_valores_str := v_valores_str || ', ';
        END IF;
        -- Usa quote_literal para garantir que valores de texto sejam tratados corretamente
        v_valores_str := v_valores_str || quote_literal(p_valores[i]);
    END LOOP;

    -- Monta a query de INSERT usando format para segurança e EXECUTE para execução dinâmica
    v_query := format('INSERT INTO %I (%s) VALUES (%s)',
                      p_nome_tabela, v_colunas_str, v_valores_str);

    -- Executa a query
    EXECUTE v_query;

    RETURN 'Dados cadastrados com sucesso na tabela ' || p_nome_tabela || '.';
EXCEPTION
    WHEN unique_violation THEN
        RETURN 'Erro: Violação de chave única ao cadastrar dados na tabela ' || p_nome_tabela || '.';
    WHEN foreign_key_violation THEN
        RETURN 'Erro: Violação de chave estrangeira ao cadastrar dados na tabela ' || p_nome_tabela || '. Verifique os IDs referenciados.';
    WHEN OTHERS THEN
        RETURN 'Erro ao cadastrar dados na tabela ' || p_nome_tabela || ': ' || SQLERRM;
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
--criando disciplina metodologia cientifica
SELECT cadastrar(
    'disciplina',
    ARRAY['nome_disciplina', 'carga_horaria', 'id_curso'],
    ARRAY['Metodologia Científica', '60', '1'] -- '1' é o id_curso
);   


select * from aluno;