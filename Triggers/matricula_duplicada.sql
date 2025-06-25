CREATE OR REPLACE FUNCTION verificar_matricula_duplicada()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se já existe uma matrícula para o mesmo aluno na mesma turma
    IF EXISTS (
        SELECT 1 FROM aluno_turma
        WHERE id_aluno = NEW.id_aluno
          AND id_turma = NEW.id_turma
    ) THEN
        RAISE EXCEPTION 'Erro: O aluno % já está matriculado na turma %.', NEW.id_aluno, NEW.id_turma;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER impedir_matricula_duplicada
BEFORE INSERT ON aluno_turma
FOR EACH ROW
EXECUTE FUNCTION verificar_matricula_duplicada();