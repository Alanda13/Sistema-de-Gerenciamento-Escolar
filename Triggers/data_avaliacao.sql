-- Função de Trigger para Validar Data de Avaliação
-- Esta função é chamada ANTES de uma avaliação ser inserida ou atualizada.
-- Verifica se a data da avaliação está dentro do período letivo associado.
CREATE OR REPLACE FUNCTION validar_data_avaliacao()
RETURNS TRIGGER AS $$
DECLARE
    v_dt_inicio_periodo DATE;
    v_dt_fim_periodo DATE;
BEGIN
    SELECT dt_inicio, dt_fim
    INTO v_dt_inicio_periodo, v_dt_fim_periodo
    FROM periodo_letivo
    WHERE id_periodo_letivo = NEW.id_periodo_letivo;

    IF NEW.data < v_dt_inicio_periodo OR NEW.data > v_dt_fim_periodo THEN
        RAISE EXCEPTION 'Erro de Avaliação: A data da avaliação (%) deve estar dentro do período letivo (de % a %).', NEW.data, v_dt_inicio_periodo, v_dt_fim_periodo;
    END IF;

    RETURN NEW; -- Permite a operação
END;
$$ LANGUAGE plpgsql;

-- Trigger para chamar a função de validação antes de cada INSERT ou UPDATE na tabela avaliacao
CREATE OR REPLACE TRIGGER trg_validar_data_avaliacao
BEFORE INSERT OR UPDATE ON avaliacao
FOR EACH ROW
EXECUTE FUNCTION validar_data_avaliacao();
