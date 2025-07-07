-- Função de Trigger para Validar Idade Mínima do Aluno
-- Esta função é chamada ANTES de um novo aluno ser inserido na tabela 'aluno'.
-- Verifica se o aluno tem pelo menos 16 anos na data atual (data de matrícula).
CREATE OR REPLACE FUNCTION validar_idade_minima_aluno()
RETURNS TRIGGER AS $$
DECLARE
    v_idade_minima INTEGER := 16;
    v_idade_calculada INTEGER;
BEGIN
    -- Calcula a idade do aluno na data atual
    v_idade_calculada := EXTRACT(YEAR FROM AGE(CURRENT_DATE, NEW.data_nasc));

    IF v_idade_calculada < v_idade_minima THEN
        RAISE EXCEPTION 'Erro de Cadastro de Aluno: O aluno deve ter no mínimo % anos para se matricular. Idade atual: %', v_idade_minima, v_idade_calculada;
    END IF;

    RETURN NEW; -- Permite a inserção
END;
$$ LANGUAGE plpgsql;

-- Trigger para chamar a função de validação antes de cada INSERT na tabela aluno
CREATE OR REPLACE TRIGGER trg_validar_idade_minima_aluno
BEFORE INSERT ON aluno
FOR EACH ROW
EXECUTE FUNCTION validar_idade_minima_aluno();
