CREATE TRIGGER trigger_evitar_conflito_horario
BEFORE INSERT OR UPDATE ON professor_turma
FOR EACH ROW
EXECUTE FUNCTION evitar_conflito_horario_professor();

CREATE OR REPLACE FUNCTION verificar_vagas_turma()
RETURNS TRIGGER AS $$
DECLARE
    v_qtd_vagas INTEGER;
    v_alunos_matriculados INTEGER;
BEGIN
    -- Obter a quantidade de vagas da turma
    SELECT qtd_vagas INTO v_qtd_vagas
    FROM turma
    WHERE id_turma = NEW.id_turma;

    -- Contar o número atual de alunos matriculados na turma
    SELECT COUNT(*) INTO v_alunos_matriculados
    FROM aluno_turma
    WHERE id_turma = NEW.id_turma;

    -- Se for um INSERT, apenas verifica a contagem atual mais o novo aluno
    IF TG_OP = 'INSERT' THEN
        IF (v_alunos_matriculados + 1) > v_qtd_vagas THEN
            RAISE EXCEPTION 'Não há vagas disponíveis nesta turma. Vagas totais: %, Alunos já matriculados: %', v_qtd_vagas, v_alunos_matriculados;
        END IF;
    -- Se for um UPDATE, verifica se o id_turma foi alterado
    ELSIF TG_OP = 'UPDATE' THEN
		-- Se o aluno que está sendo cadastrado tiver o id_turma diferente, 
		-- mas o mesmo id_aluno, quer dizer que está sendo movido para a nova turma, 
		-- então faz o calculo denovo.
        IF NEW.id_turma <> OLD.id_turma THEN
            IF (v_alunos_matriculados + 1) > v_qtd_vagas THEN
                RAISE EXCEPTION 'Não há vagas disponíveis na nova turma. Vagas totais: %, Alunos já matriculados: %', v_qtd_vagas, v_alunos_matriculados;
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_verificar_vagas_aluno_turma
BEFORE INSERT OR UPDATE ON aluno_turma
FOR EACH ROW
EXECUTE FUNCTION verificar_vagas_turma();
