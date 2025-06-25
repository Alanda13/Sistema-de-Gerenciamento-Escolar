-- Função que verifica o intervalo da nota
CREATE OR REPLACE FUNCTION verificar_nota_valida()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.nota_obtida < 0 OR NEW.nota_obtida > 10 THEN
        RAISE EXCEPTION 'Erro: A nota (%) está fora do intervalo permitido (0 a 10).', NEW.nota_obtida;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_nota
BEFORE INSERT OR UPDATE ON result_avaliacao
FOR EACH ROW
EXECUTE FUNCTION verificar_nota_valida();
