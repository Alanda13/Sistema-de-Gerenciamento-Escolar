CREATE OR REPLACE FUNCTION verificar_carga_horaria_curso(
    p_id_curso INTEGER
) RETURNS TEXT AS $$
DECLARE
    v_carga_horaria_curso INTEGER;
    v_soma_carga_horaria_disciplinas INTEGER;
BEGIN
    SELECT carga_horaria INTO v_carga_horaria_curso FROM curso WHERE id_curso = p_id_curso;

    IF v_carga_horaria_curso IS NULL THEN
        RETURN 'Erro: Curso com ID ' || p_id_curso || ' não encontrado.';
    END IF;

    SELECT COALESCE(SUM(carga_horaria), 0)
    INTO v_soma_carga_horaria_disciplinas
    FROM disciplina
    WHERE id_curso = p_id_curso;

    IF v_soma_carga_horaria_disciplinas < v_carga_horaria_curso THEN
        RETURN 'Alerta: A soma das cargas horárias das disciplinas do curso (ID ' || p_id_curso || ') é ' || v_soma_carga_horaria_disciplinas ||
               ', que é INFERIOR à carga horária total do curso (' || v_carga_horaria_curso || ').';
    ELSE
        RETURN 'Sucesso: A soma das cargas horárias das disciplinas do curso (ID ' || p_id_curso || ') é ' || v_soma_carga_horaria_disciplinas ||
               ', que é IGUAL ou SUPERIOR à carga horaria total do curso (' || v_carga_horaria_curso || ').';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Erro ao verificar carga horária do curso: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;