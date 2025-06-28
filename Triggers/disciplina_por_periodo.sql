CREATE OR REPLACE FUNCTION limitar_disciplinas_por_periodo()
RETURNS TRIGGER AS $$
DECLARE
    qtd_matriculas INTEGER;
    id_periodo INT;
BEGIN
    -- Obter o período letivo da turma onde o aluno deseja se matricular
    SELECT t.id_periodo_letivo INTO id_periodo
    FROM turma t
    WHERE t.id_turma = NEW.id_turma;

    -- Contar quantas turmas o aluno já está matriculado nesse período
    SELECT COUNT(*) INTO qtd_matriculas
    FROM aluno_turma at
    JOIN turma t ON at.id_turma = t.id_turma
    WHERE at.id_aluno = NEW.id_aluno
      AND t.id_periodo_letivo = id_periodo;

    -- Verificar se já atingiu o limite de 7
    IF qtd_matriculas >= 7 THEN
        RAISE EXCEPTION 'Erro: O aluno já está matriculado no limite de 7 disciplinas neste período.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
