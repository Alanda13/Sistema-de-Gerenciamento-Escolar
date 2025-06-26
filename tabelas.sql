-- Tabela CURSO
CREATE TABLE curso (
    id_curso SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    carga_horaria INTEGER NOT NULL
);

-- Tabela DISCIPLINA com autorreferência (1 pré-requisito opcional)
CREATE TABLE disciplina (
    id_disciplina SERIAL PRIMARY KEY,
    nome_disciplina VARCHAR(100) NOT NULL,
    carga_horaria INTEGER NOT NULL,
    id_curso INTEGER NOT NULL REFERENCES curso(id_curso),
    id_pre_requisito INTEGER REFERENCES disciplina(id_disciplina)
);

-- Tabela ALUNO com status 'ativo' ou 'inativo'
CREATE TABLE aluno (
    id_aluno SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    email VARCHAR(100),
    data_nasc DATE,
    telefone VARCHAR(20),
    id_curso INTEGER NOT NULL REFERENCES curso(id_curso),
    status VARCHAR(10) CHECK (status IN ('ativo', 'inativo')) DEFAULT 'ativo'
);

-- Tabela PERIODO_LETIVO
CREATE TABLE periodo_letivo (
    id_periodo_letivo SERIAL PRIMARY KEY,
    ano INTEGER NOT NULL,
    semestre INTEGER NOT NULL CHECK (semestre IN (1, 2)),
    dt_inicio DATE NOT NULL,
    dt_fim DATE NOT NULL
);

-- Tabela TURMA
CREATE TABLE turma (
    id_turma SERIAL PRIMARY KEY,
    sala VARCHAR(50),
    horario_aula INTEGER NOT NULL, -- horas por semana
    qtd_vagas INTEGER NOT NULL,
    id_disciplina INTEGER NOT NULL REFERENCES disciplina(id_disciplina),
    id_periodo_letivo INTEGER NOT NULL REFERENCES periodo_letivo(id_periodo_letivo)
);

-- Tabela ALUNO_TURMA (sem o campo media)
CREATE TABLE aluno_turma (
    id_aluno INTEGER NOT NULL REFERENCES aluno(id_aluno),
    id_turma INTEGER NOT NULL REFERENCES turma(id_turma),
    PRIMARY KEY (id_aluno, id_turma)
);

-- Tabela FUNCAO
CREATE TABLE funcao (
    id_funcao SERIAL PRIMARY KEY,
    funcao VARCHAR(100) NOT NULL
);

-- Tabela PROFESSOR
CREATE TABLE professor (
    id_professor SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    telefone VARCHAR(20)
);

-- Tabela FUNC_PROF (vínculo professor x função)
CREATE TABLE func_prof (
    id_professor INTEGER NOT NULL REFERENCES professor(id_professor),
    id_funcao INTEGER NOT NULL REFERENCES funcao(id_funcao),
    dt_entrada DATE NOT NULL,
    dt_saida DATE,
    PRIMARY KEY (id_professor, id_funcao)
);

-- Tabela PROFESSOR_TURMA (associação professor <-> turma)
CREATE TABLE professor_turma (
    id_prof_turma SERIAL PRIMARY KEY,
    id_professor INTEGER NOT NULL REFERENCES professor(id_professor),
    id_turma INTEGER NOT NULL REFERENCES turma(id_turma)
);

-- Tabela AVALIACAO (lançada por professor_turma)
CREATE TABLE avaliacao (
    id_avaliacao SERIAL PRIMARY KEY,
    descricao TEXT NOT NULL,
    data DATE NOT NULL,
    id_prof_turma INTEGER NOT NULL REFERENCES professor_turma(id_prof_turma)
);

-- Tabela RESULT_AVALIACAO (nota por avaliação por aluno)
CREATE TABLE result_avaliacao (
    id_avaliacao INTEGER NOT NULL REFERENCES avaliacao(id_avaliacao),
    id_aluno INTEGER NOT NULL REFERENCES aluno(id_aluno),
    nota_obtida NUMERIC(5,2),
    PRIMARY KEY (id_avaliacao, id_aluno)
);

----------------------------------\/ TRIGGERS E FUNÇÕES \/---------------------------------------------
-- Função que valida o pré-requisito
CREATE OR REPLACE FUNCTION evitar_autopre_requisito()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id_pre_requisito IS NOT NULL AND NEW.id_disciplina = NEW.id_pre_requisito THEN
        RAISE EXCEPTION 'Erro: A disciplina não pode ser pré-requisito de si mesma. ID: %', NEW.id_disciplina;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_evitar_autopre_requisito
BEFORE INSERT OR UPDATE ON disciplina
FOR EACH ROW
EXECUTE FUNCTION evitar_autopre_requisito();

-- Função que verifica se a avaliação já existe
CREATE OR REPLACE FUNCTION evitar_avaliacao_duplicada()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM avaliacao
        WHERE id_prof_turma = NEW.id_prof_turma
          AND data = NEW.data
          AND descricao = NEW.descricao
    ) THEN
        RAISE EXCEPTION 'Erro: Já existe uma avaliação com a mesma descrição, data e professor_turma.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger associada à tabela avaliacao
CREATE TRIGGER trigger_evitar_avaliacao_duplicada
BEFORE INSERT ON avaliacao
FOR EACH ROW
EXECUTE FUNCTION evitar_avaliacao_duplicada();

-- Função que verifica o intervalo da nota
CREATE OR REPLACE FUNCTION verificar_nota_valida()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.nota_obtida < 0 OR NEW.nota_obtida > 10 THEN
        RAISE EXCEPTION 'Erro: A nota (%) está fora do intervalo permitido (0 a 10).', NEW.nota_obtida;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_nota
BEFORE INSERT OR UPDATE ON result_avaliacao
FOR EACH ROW
EXECUTE FUNCTION verificar_nota_valida();

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
BEFORE INSERT OR UPDATE ON aluno_turma
FOR EACH ROW
EXECUTE FUNCTION verificar_matricula_duplicada();

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

-- Function para limitar os profs
CREATE OR REPLACE FUNCTION verificar_turmas_prof()
RETURNS TRIGGER AS $$
DECLARE 
    qtd_turmas_prof INTEGER;
    total_funcoes INTEGER;
    possui_funcao_professor BOOLEAN;
BEGIN
    SELECT COUNT(*) INTO qtd_turmas_prof
    FROM professor_turma pt
    WHERE pt.id_professor = NEW.id_professor;

    SELECT COUNT(*) INTO total_funcoes
    FROM func_prof fp
    WHERE fp.id_professor = NEW.id_professor;

    SELECT EXISTS (
        SELECT 1
        FROM func_prof fp_inner
        JOIN funcao f_inner ON fp_inner.id_funcao = f_inner.id_funcao
        WHERE fp_inner.id_professor = NEW.id_professor
        AND LOWER(f_inner.funcao) = 'professor'
    ) INTO possui_funcao_professor;

    -- Aplicar a lógica condicional baseada nas funções do professor e limites:

    IF NOT possui_funcao_professor THEN
        -- Se o professor NÃO possui a função 'Professor', ele não pode ser matriculado em NENHUMA turma.
        RAISE EXCEPTION 'Este professor não possui a função "Professor" e, portanto, não pode ser matriculado em nenhuma turma.';

    ELSIF possui_funcao_professor AND total_funcoes > 1 THEN
        -- Professor tem a função 'Professor' E possui MAIS DE UMA função no total (ex: Professor e Coordenador)
        IF qtd_turmas_prof >= 3 THEN
            RAISE EXCEPTION 'Esse professor possui a função "Professor" e outras funções, atingiu o limite de turmas (máximo de 3). Turmas atuais: %', qtd_turmas_prof;
        END IF;

    ELSIF possui_funcao_professor AND total_funcoes = 1 THEN
        -- Professor tem APENAS a função 'Professor'
        IF qtd_turmas_prof >= 5 THEN
            RAISE EXCEPTION 'Esse professor possui apenas a função "Professor", atingiu o limite de turmas (máximo de 5). Turmas atuais: %', qtd_turmas_prof;
        END IF;

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_verificar_turmas_prof
BEFORE INSERT OR UPDATE ON professor_turma
FOR EACH ROW
EXECUTE FUNCTION verificar_turmas_prof();

CREATE OR REPLACE FUNCTION verificar_funcoes_prof()
RETURNS TRIGGER AS $$
DECLARE
	qtd_funcoes_prof INTEGER;
BEGIN
	-- PEGANDO A QUANTIDADE DE FUNÇÕES QUE ESSE PROFESSOR TEM
	SELECT COUNT(p.id_professor) INTO qtd_funcoes_prof from professor p 
	join func_prof fp ON p.id_professor = fp.id_professor
	where p.id_professor = NEW.id_professor
	group by p.id_professor;
	
	IF (qtd_funcoes_prof = 2) THEN
		RAISE EXCEPTION 'Esse professor atingiu o limite de funções (Maximo 2).';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_verificar_funcoes_prof
BEFORE INSERT OR UPDATE ON func_prof
FOR EACH ROW
EXECUTE FUNCTION verificar_funcoes_prof();

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

SELECT * FROM ALUNO_TURMA AT 
JOIN TURMA T ON AT.id_turma = T.id_turma 
JOIN periodo_letivo PL on T.id_periodo_letivo = PL.id_periodo_letivo

CREATE OR REPLACE FUNCTION limitar_qtd_turmas_aluno()
RETURNS TRIGGER AS $$
DECLARE
    qtd_turmas_do_aluno INTEGER;
    id_periodo_letivo_da_nova_turma INTEGER;
BEGIN
    -- Descobrir o ID do período letivo da turma que está sendo usada para a nova matrícula
    SELECT T.id_periodo_letivo
    INTO id_periodo_letivo_da_nova_turma
    FROM TURMA T
    WHERE T.id_turma = NEW.id_turma;
	
    -- Descobrir a quantidade de turmas que o aluno já está matriculado nesse MESMO período letivo 
    SELECT COUNT(al.id_turma) INTO qtd_turmas_do_aluno
    FROM aluno_turma al
    JOIN turma t ON al.id_turma = t.id_turma
    WHERE al.id_aluno = NEW.id_aluno
      AND t.id_periodo_letivo = id_periodo_letivo_da_nova_turma
      AND al.id_turma <> NEW.id_turma;

    IF (qtd_turmas_do_aluno + 1) > 7 THEN
        RAISE EXCEPTION 'O aluno já está matriculado em % turmas neste período letivo. O limite máximo é de 7 turmas por período.', qtd_turmas_do_aluno;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_limitar_qtd_turmas_aluno
BEFORE INSERT OR UPDATE ON aluno_turma
FOR EACH ROW
EXECUTE FUNCTION limitar_qtd_turmas_aluno();
		
		
-----------------------------------/\ TRIGGERS E FUNÇÕES /\------------------------------------------

----------------------------------------\/ INSERTS \/------------------------------------------------
-- Curso
INSERT INTO curso (nome, carga_horaria) VALUES ('Engenharia de Software', 3600);
INSERT INTO curso (nome, carga_horaria) VALUES ('Analise e desenvolvimento de sistemas', 3600);

-- Disciplina
INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso) VALUES ('Banco de Dados I', 60, 2); -- Use o ID do curso obtido acima

-- Período Letivo
INSERT INTO periodo_letivo (ano, semestre, dt_inicio, dt_fim) VALUES (2025, 1, '2025-02-01', '2025-06-30');

-- Turmas
-- Turma 1: Poucas vagas para testar rapidamente a lotação
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo)
VALUES ('Sala A101', 8, 2, 1, 1);

-- Turma 2: Mais vagas para testar inserts múltiplos
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo)
VALUES ('Sala B205', 10, 5, 1, 1);

-- Turma 3: Teste de CURSO DO ALUNO = CURSO DA TURMA
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo)
VALUES ('Sala B303', 10, 5, 2, 1);

-- Turmas até a 9: Para testar maximo de turmas
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo)
VALUES ('SALA B101', 10, 5, 1, 1)

INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo)
VALUES ('SALA B102', 10, 5, 1, 1)

INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo)
VALUES ('SALA B103', 10, 5, 1, 1)

INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo)
VALUES ('SALA B104', 10, 5, 1, 1)

INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo)
VALUES ('SALA B105', 10, 5, 1, 1)

INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo)
VALUES ('SALA B106', 10, 5, 1, 1)

-- Alunos
INSERT INTO aluno (nome, cpf, email, data_nasc, telefone, id_curso, status) VALUES
('Alice Silva', '111.111.111-11', 'alice@email.com', '2000-01-15', '999911111', 1, 'ativo'),
('Bruno Costa', '222.222.222-22', 'bruno@email.com', '1999-05-20', '999922222', 1, 'ativo'),
('Carla Dias', '333.333.333-33', 'carla@email.com', '2001-11-10', '999933333', 1, 'ativo'),
('Daniel Luz', '444.444.444-44', 'daniel@email.com', '2002-03-25', '999944444', 1, 'ativo');

-- Testar INSERT bem-sucedido (Turma 1 tem 2 vagas)
-- Matriculando Alice na Turma 1
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (1, 1);
-- Matriculando Bruno na Turma 1
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (2, 1);
-- Tentando matricular Daniel na turma 3, que é de um curso diferente do dele
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (4, 3)
-- Matricular alice em mais uma turma pra testar
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (1, 2)
-- Matricular alice em um monte de outras turmas pra impedir ela de passar de 7 turmas
INSERT INTO aluno_turma (id_aluno, id_turma) 
VALUES 
(1, 3),
(1, 4),
(1, 5),
(1, 6),
(1, 7),
(1, 8);
-- Funcao
INSERT INTO FUNCAO VALUES (1, 'PROFESSOR');
INSERT INTO FUNCAO VALUES (2, 'COORDENADOR');
INSERT INTO FUNCAO VALUES (3, 'DIRETOR');

-- Professor
INSERT INTO PROFESSOR VALUES (1, 'CAMARADA', '120.129.482-34', '4002-8922');
INSERT INTO PROFESSOR VALUES (2, 'CAMARADA2', '485.421.578-23', '190');
INSERT INTO PROFESSOR VALUES (3, 'CAMARADA3', '578.462.147-89', '191');

-- FUNC_PROF
INSERT INTO FUNC_PROF VALUES (1, 1, '2025-06-25', '2025-06-26');
INSERT INTO FUNC_PROF VALUES (1, 2, '2025-06-25', '2025-06-26');
INSERT INTO FUNC_PROF VALUES (2, 1, '2025-06-25', '2025-06-26');
INSERT INTO FUNC_PROF VALUES (3, 2, '2025-06-25', '2025-06-26');
INSERT INTO FUNC_PROF VALUES (1, 3, '2025-06-25', '2025-06-26');


-- PROFESSOR_TURMA
INSERT INTO PROFESSOR_TURMA VALUES (1, 1, 1);
INSERT INTO PROFESSOR_TURMA VALUES (2, 2, 1);
INSERT INTO PROFESSOR_TURMA VALUES (3, 1, 2);

----------------------------------------/\ INSERTS /\------------------------------------------------
-- -- Limpar dados
-- DELETE FROM func_prof;
-- DELETE FROM professor_turma;
-- DELETE FROM aluno_turma;
-- DELETE FROM result_avaliacao;
-- DELETE FROM funcao;
-- DELETE FROM professor;
-- DELETE FROM aluno;
-- DELETE FROM avaliacao;
-- DELETE FROM turma;
-- DELETE FROM disciplina;
-- DELETE FROM curso;
-- DELETE FROM periodo_letivo;

-- -- Reiniciar SERIALS:
-- ALTER SEQUENCE curso_id_curso_seq RESTART WITH 1;
-- ALTER SEQUENCE disciplina_id_disciplina_seq RESTART WITH 1;
-- ALTER SEQUENCE aluno_id_aluno_seq RESTART WITH 1;
-- ALTER SEQUENCE periodo_letivo_id_periodo_letivo_seq RESTART WITH 1;
-- ALTER SEQUENCE turma_id_turma_seq RESTART WITH 1;
-- ALTER SEQUENCE funcao_id_funcao_seq RESTART WITH 1;
-- ALTER SEQUENCE professor_id_professor_seq RESTART WITH 1;
-- ALTER SEQUENCE professor_turma_id_prof_turma_seq RESTART WITH 1;
-- ALTER SEQUENCE avaliacao_id_avaliacao_seq RESTART WITH 1;
