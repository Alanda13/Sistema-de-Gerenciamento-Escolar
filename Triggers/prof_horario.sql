-- Função que verifica conflito de horário
CREATE OR REPLACE FUNCTION evitar_conflito_horario_professor()
RETURNS TRIGGER AS $$
DECLARE
    novo_horario INTEGER;
BEGIN
    -- Obtem o horário da nova turma que está sendo atribuída ao professor
    SELECT horario_aula INTO novo_horario
    FROM turma
    WHERE id_turma = NEW.id_turma;

    -- Verifica se o professor já está vinculado a outra turma com o mesmo horário
    IF EXISTS (
        SELECT 1
        FROM professor_turma pt
        JOIN turma t ON pt.id_turma = t.id_turma
        WHERE pt.id_professor = NEW.id_professor
          AND t.horario_aula = novo_horario
          AND pt.id_turma <> NEW.id_turma
    ) THEN
        RAISE EXCEPTION 'Erro: Conflito de horário. O professor % já leciona em uma turma com o mesmo horário (% horas/semana).',
        NEW.id_professor, novo_horario;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_evitar_conflito_horario
BEFORE INSERT ON professor_turma
FOR EACH ROW
EXECUTE FUNCTION evitar_conflito_horario_professor();
