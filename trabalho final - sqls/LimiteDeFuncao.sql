-- Pré-requisitos
INSERT INTO professor (nome, cpf, telefone) VALUES ('Prof. Funções', '444.444.444-44', '444444444'); -- id_professor = 1
INSERT INTO funcao (funcao) VALUES ('Professor'); -- id_funcao = 1
INSERT INTO funcao (funcao) VALUES ('Coordenador'); -- id_funcao = 2
INSERT INTO funcao (funcao) VALUES ('Pesquisador'); -- id_funcao = 3
INSERT INTO funcao (funcao) VALUES ('Diretor'); -- id_funcao = 4

-- Quantidades de funcoes do professor 1
SELECT COUNT(fp.id_professor) AS qtd_funcoes_prof
	FROM func_prof fp
	WHERE fp.id_professor = 1;
	
-- Teste 8.1: Inserção Válida (primeira função)
INSERT INTO func_prof (id_professor, id_funcao, dt_entrada) VALUES (1, 1, '2024-01-01');
SELECT * FROM func_prof;

-- Teste 8.2: Inserção Válida (segunda função)
INSERT INTO func_prof (id_professor, id_funcao, dt_entrada) VALUES (1, 2, '2024-02-01');
SELECT * FROM func_prof;

-- Teste 8.3: Inserção Inválida (terceira função - excedendo o limite)
-- A linha abaixo deve gerar um erro!
INSERT INTO func_prof (id_professor, id_funcao, dt_entrada) VALUES (1, 4, '2024-03-01');

-- Verificando logs (opcional)
SELECT * FROM registro_relatorios WHERE nome_tabela = 'func_prof';