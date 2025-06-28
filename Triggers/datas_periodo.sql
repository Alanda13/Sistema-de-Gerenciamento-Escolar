-- Função que verifica se a data de início é menor ou igual à data de fim
CREATE OR REPLACE FUNCTION verificar_datas_periodo_letivo()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se a data de início é posterior à data de fim
    IF NEW.dt_inicio > NEW.dt_fim THEN
        RAISE EXCEPTION 'Erro: A data de início (%) não pode ser posterior à data de fim (%) para o período letivo.', 
                        NEW.dt_inicio, NEW.dt_fim;
    END IF;

    RETURN NEW; 
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_verificar_datas_periodo_letivo
BEFORE INSERT OR UPDATE ON periodo_letivo
FOR EACH ROW
EXECUTE FUNCTION verificar_datas_periodo_letivo();