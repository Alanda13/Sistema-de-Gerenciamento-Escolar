-- Função que valida o pré-requisito
CREATE OR REPLACE FUNCTION evitar_autopre_requisito()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id_pre_requisito IS NOT NULL AND NEW.id_disciplina = NEW.id_pre_requisito THEN
        RAISE EXCEPTION 'Erro: A disciplina não pode ser pré-requisito de si mesma. ID: %', NEW.id_disciplina;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_evitar_autopre_requisito
BEFORE INSERT OR UPDATE ON disciplina
FOR EACH ROW
EXECUTE FUNCTION evitar_autopre_requisito();