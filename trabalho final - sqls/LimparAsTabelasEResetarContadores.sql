-- Limpar dados de todas as tabelas (em ordem inversa de dependência)
DELETE FROM result_avaliacao;
DELETE FROM presenca;
DELETE FROM result_aluno_periodo;
DELETE FROM aula;
DELETE FROM avaliacao;
DELETE FROM professor_turma;
DELETE FROM func_prof;
DELETE FROM aluno_turma;
DELETE FROM turma;
DELETE FROM disciplina;
DELETE FROM aluno;
DELETE FROM professor;
DELETE FROM funcao;
DELETE FROM periodo_letivo;
DELETE FROM curso;
DELETE FROM registro_relatorios; -- Nova tabela de logs

-- Reiniciar contadores (SERIALS) de todas as tabelas
ALTER SEQUENCE curso_id_curso_seq RESTART WITH 1;
ALTER SEQUENCE disciplina_id_disciplina_seq RESTART WITH 1;
ALTER SEQUENCE aluno_id_aluno_seq RESTART WITH 1;
ALTER SEQUENCE periodo_letivo_id_periodo_letivo_seq RESTART WITH 1;
ALTER SEQUENCE turma_id_turma_seq RESTART WITH 1;
ALTER SEQUENCE aluno_turma_id_aluno_turma_seq RESTART WITH 1;
ALTER SEQUENCE funcao_id_funcao_seq RESTART WITH 1;
ALTER SEQUENCE professor_id_professor_seq RESTART WITH 1;
ALTER SEQUENCE professor_turma_id_prof_turma_seq RESTART WITH 1;
ALTER SEQUENCE avaliacao_id_avaliacao_seq RESTART WITH 1;
ALTER SEQUENCE aula_id_aula_seq RESTART WITH 1;
ALTER SEQUENCE result_aluno_periodo_id_result_aluno_periodo_seq RESTART WITH 1;
ALTER SEQUENCE registro_relatorios_id_registro_seq RESTART WITH 1; -- Reset da nova tabela