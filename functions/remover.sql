CREATE OR REPLACE FUNCTION remover(
    p_nome_tabela TEXT,
    p_nome_coluna_id TEXT, -- Ex: 'id_aluno'
    p_valor_id TEXT       -- Ex: '1' (valor como texto)
)
RETURNS TEXT AS $$
DECLARE
    v_sql TEXT;
    v_count INTEGER;
BEGIN
    -- 1. Verifica se a tabela existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = p_nome_tabela) THEN
        RETURN 'Erro: A tabela "' || p_nome_tabela || '" não existe.';
    END IF;

    -- 2. Caso especial para ALUNO: Inativa em vez de remover
    IF p_nome_tabela = 'aluno' AND p_nome_coluna_id = 'id_aluno' THEN -- Assume que id_aluno é a PK
        v_sql := 'UPDATE aluno SET status = ''inativo'' WHERE ' || quote_ident(p_nome_coluna_id) || ' = ' || quote_literal(p_valor_id) || ';';
        EXECUTE v_sql;
        GET DIAGNOSTICS v_count = ROW_COUNT;
        IF v_count = 0 THEN
            RETURN 'Nenhum aluno encontrado com ID ' || p_valor_id || ' para inativar.';
        ELSE
            RETURN v_count || ' aluno(s) inativado(s) com sucesso.';
        END IF;
    ELSE
        -- 3. Para outras tabelas, tenta remover
        BEGIN
            v_sql := 'DELETE FROM ' || quote_ident(p_nome_tabela) || ' WHERE ' || quote_ident(p_nome_coluna_id) || ' = ' || quote_literal(p_valor_id) || ';';
            EXECUTE v_sql;
            GET DIAGNOSTICS v_count = ROW_COUNT;
            IF v_count = 0 THEN
                RETURN 'Nenhum registro encontrado na tabela ' || p_nome_tabela || ' com ' || p_nome_coluna_id || ' = ' || p_valor_id || '.';
            ELSE
                RETURN v_count || ' registro(s) removido(s) com sucesso da tabela ' || p_nome_tabela || '.';
            END IF;
        EXCEPTION
            WHEN foreign_key_violation THEN
                RETURN 'Erro: Não foi possível remover o(s) registro(s) da tabela ' || p_nome_tabela || ' (ID: ' || p_valor_id || ') devido a registros dependentes. Remova primeiro os registros relacionados.';
            WHEN OTHERS THEN
                RETURN 'Erro ao remover dados da tabela ' || p_nome_tabela || ': ' || SQLERRM || '. SQL: ' || v_sql;
        END;
    END IF;
END;
$$ LANGUAGE plpgsql;


--- testando a função remover
SELECT remover('disciplina', 'id_disciplina', '1');   --tenta remover banco de dados 3 
SELECT remover('disciplina', 'id_disciplina', '4');  --- remove metodologia cientifica