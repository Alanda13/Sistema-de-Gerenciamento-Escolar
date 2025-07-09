CREATE ROLE administrador;
CREATE ROLE coordenador;
CREATE ROLE professor;

ALTER ROLE administrador SUPERUSER CREATEDB CREATEROLE;

---criação de usuarios e distribuição de papeis
CREATE USER usuario_admin WITH PASSWORD 'admin123' LOGIN;
CREATE USER usuario_coordenador WITH PASSWORD 'coord123' LOGIN;
CREATE USER usuario_professor WITH PASSWORD 'prof123' LOGIN;

GRANT administrador TO usuario_admin;
GRANT coordenador TO usuario_coordenador;
GRANT professor TO usuario_professor;

--privilegios
---professor
-- Permissões para cadastrar e alterar provas, notas (usando INSERT/UPDATE)
GRANT SELECT, INSERT, UPDATE ON avaliacao TO professor;
GRANT SELECT, INSERT, UPDATE ON result_avaliacao TO professor;
GRANT SELECT, INSERT, UPDATE ON presenca TO professor;
GRANT SELECT, INSERT, UPDATE ON aula TO professor;

-- Permissões para visualizar informações relacionadas a turmas, alunos, disciplinas
GRANT SELECT ON aluno TO professor;
GRANT SELECT ON turma TO professor;
GRANT SELECT ON disciplina TO professor;
GRANT SELECT ON periodo_letivo TO professor;
GRANT SELECT ON professor_turma TO professor;
GRANT SELECT ON aluno_turma TO professor;
GRANT SELECT ON result_aluno_periodo TO professor;

-- Permissão para usar as funções de cadastrar e alterar
-- As funções 'cadastrar' e 'alterar' devem ter sido adaptadas para aceitar o usuário logado como parâmetro
-- e verificar as permissões internas. O professor executará a função, e a função verificará se ele pode
-- cadastrar/alterar o objeto específico.
GRANT EXECUTE ON FUNCTION cadastrar(TEXT, TEXT[], TEXT[]) TO professor;
GRANT EXECUTE ON FUNCTION alterar(VARCHAR, VARCHAR, VARCHAR, TEXT[], TEXT[]) TO professor;

-- Alterar informações próprias (o professor precisaria de permissão UPDATE na tabela 'professor'
-- e possivelmente filtros de RLS para garantir que só ele possa alterar seus próprios dados).
GRANT UPDATE ON professor TO professor;

--coordenador
-- Permissões de atualização e exclusão em tabelas de gerenciamento
GRANT SELECT, UPDATE, DELETE ON curso TO coordenador;
GRANT SELECT, UPDATE, DELETE ON disciplina TO coordenador;
GRANT SELECT, UPDATE, DELETE ON turma TO coordenador;
GRANT SELECT, UPDATE, DELETE ON professor TO coordenador;
GRANT SELECT, UPDATE, DELETE ON periodo_letivo TO coordenador;
GRANT SELECT, UPDATE, DELETE ON aluno_turma TO coordenador;
GRANT SELECT, UPDATE, DELETE ON func_prof TO coordenador;
GRANT SELECT, UPDATE, DELETE ON professor_turma TO coordenador;

-- Permissões de visualização em outras tabelas (ex: alunos, notas para acompanhamento)
GRANT SELECT ON aluno TO coordenador;
GRANT SELECT ON avaliacao TO coordenador;
GRANT SELECT ON result_avaliacao TO coordenador;
GRANT SELECT ON presenca TO coordenador;
GRANT SELECT ON aula TO coordenador;
GRANT SELECT ON result_aluno_periodo TO coordenador;
GRANT SELECT ON registro_relatorios TO coordenador;

-- Permissão para usar as funções de alteração e remoção
GRANT EXECUTE ON FUNCTION alterar(VARCHAR, VARCHAR, VARCHAR, TEXT[], TEXT[]) TO coordenador;
GRANT EXECUTE ON FUNCTION remover(TEXT, TEXT, TEXT) TO coordenador;

ALTER ROLE administrador SUPERUSER CREATEDB CREATEROLE;



