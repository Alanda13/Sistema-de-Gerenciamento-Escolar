CREATE OR REPLACE FUNCTION evitar_avaliacao_duplicada()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM avaliacao
        WHERE id_prof_turma = NEW.id_prof_turma
          AND data = NEW.data
          AND descricao = NEW.descricao
          AND id_periodo_letivo = NEW.id_periodo_letivo -- Adicionando o periodo letivo tbm
    ) THEN
        RAISE EXCEPTION 'Erro: Já existe uma avaliação com a mesma descrição, data, professor_turma e período letivo.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4. Recriar a trigger associada à tabela avaliacao
CREATE TRIGGER trigger_evitar_avaliacao_duplicada
BEFORE INSERT ON avaliacao
FOR EACH ROW
EXECUTE FUNCTION evitar_avaliacao_duplicada();