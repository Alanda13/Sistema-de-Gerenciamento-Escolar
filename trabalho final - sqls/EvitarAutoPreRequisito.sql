-- Limpeza para o teste específico
DELETE FROM disciplina;
DELETE FROM curso;
ALTER SEQUENCE disciplina_id_disciplina_seq RESTART WITH 1;
ALTER SEQUENCE curso_id_curso_seq RESTART WITH 1;

-- Pre-requisito: Inserir um curso
INSERT INTO curso (nome, carga_horaria) VALUES ('Engenharia de Software', 3600); -- id_curso = 1

-- Teste 1.1: Inserção Válida (sem pré-requisito)
INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso) VALUES ('Programação I', 80, 1);
SELECT * FROM disciplina; -- Deve mostrar 'Programação I' (id_disciplina = 1)

-- Teste 1.2: Inserção Inválida (disciplina como pré-requisito de si mesma)
-- A linha abaixo deve gerar um erro!
-- Descomente para testar o erro
-- INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso, id_pre_requisito) VALUES ('Programação II', 80, 1, 2);
-- UPDATE disciplina SET id_pre_requisito = id_disciplina WHERE id_disciplina = 1; -- Outra forma de testar

-- Correção: Inserção válida com pré-requisito (supondo id_disciplina = 1 já existe)
INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso, id_pre_requisito) VALUES ('Estrutura de Dados', 80, 1, 1);
SELECT * FROM disciplina; -- Deve mostrar 'Estrutura de Dados' com pré-requisito 1

-- Verificando logs (opcional)
SELECT * FROM registro_relatorios WHERE nome_tabela = 'disciplina';