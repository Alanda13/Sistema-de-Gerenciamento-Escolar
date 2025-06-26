CREATE OR REPLACE FUNCTION validar_matricula_aluno_turma()
RETURNS TRIGGER AS $$
DECLARE
	id_curso_aluno INTEGER;
	id_curso_turma INTEGER;
BEGIN
	-- Descobrindo o curso da turma que está tentando ser usada na matricula
	SELECT id_curso INTO id_curso_turma from turma t 
	join disciplina d on t.id_disciplina = d.id_disciplina
	where id_turma = NEW.id_turma;
	-- Descobrindo o curso do aluno que está tentando realizar a matricula
	SELECT id_curso INTO id_curso_aluno from aluno where id_aluno = NEW.id_aluno;
	
	IF id_curso_aluno <> id_curso_turma THEN
	RAISE EXCEPTION 'A turma que o aluno está tentando se matricular não é do mesmo curso dele. Id do curso do aluno: %, ID do curso da turma: %', id_curso_aluno, id_curso_turma;
	END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_matricula_aluno_turma
BEFORE INSERT ON aluno_turma
FOR EACH ROW
EXECUTE FUNCTION validar_matricula_aluno_turma();
