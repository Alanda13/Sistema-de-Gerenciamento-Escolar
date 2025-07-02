-- Tabela CURSO (inalterada)
CREATE TABLE curso (
    id_curso SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    carga_horaria INTEGER NOT NULL
);

-- Tabela DISCIPLINA (inalterada, exceto pelo trigger de auto-requisito)
CREATE TABLE disciplina (
    id_disciplina SERIAL PRIMARY KEY,
    nome_disciplina VARCHAR(100) NOT NULL,
    carga_horaria INTEGER NOT NULL,
    id_curso INTEGER NOT NULL REFERENCES curso(id_curso),
    id_pre_requisito INTEGER REFERENCES disciplina(id_disciplina)
);

-- Tabela ALUNO (inalterada)
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

-- Tabela PERIODO_LETIVO (inalterada)
CREATE TABLE periodo_letivo (
    id_periodo_letivo SERIAL PRIMARY KEY,
    ano INTEGER NOT NULL,
    semestre INTEGER NOT NULL CHECK (semestre IN (1, 2)),
    dt_inicio DATE NOT NULL,
    dt_fim DATE NOT NULL
);

-- Tabela TURMA (inalterada)
CREATE TABLE turma (
    id_turma SERIAL PRIMARY KEY,
    sala VARCHAR(50),
    horario_aula INTEGER NOT NULL, -- horas por semana
    qtd_vagas INTEGER NOT NULL,
    id_disciplina INTEGER NOT NULL REFERENCES disciplina(id_disciplina),
    id_periodo_letivo INTEGER NOT NULL REFERENCES periodo_letivo(id_periodo_letivo)
);

-- Tabela ALUNO_TURMA (MODIFICADA: Adiciona id_aluno_turma como PK, e PK antiga vira UNIQUE)
-- Representa a matrícula de um aluno em uma turma específica.
CREATE TABLE aluno_turma (
    id_aluno_turma SERIAL PRIMARY KEY, -- Novo ID para identificar a matrícula única
    id_aluno INTEGER NOT NULL REFERENCES aluno(id_aluno),
    id_turma INTEGER NOT NULL REFERENCES turma(id_turma),
    UNIQUE (id_aluno, id_turma) -- Garante que um aluno não se matricule duas vezes na mesma turma
);

-- Tabela FUNCAO (inalterada)
CREATE TABLE funcao (
    id_funcao SERIAL PRIMARY KEY,
    funcao VARCHAR(100) NOT NULL
);

-- Tabela PROFESSOR (inalterada)
CREATE TABLE professor (
    id_professor SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    telefone VARCHAR(20)
);

-- Tabela FUNC_PROF (inalterada)
CREATE TABLE func_prof (
    id_professor INTEGER NOT NULL REFERENCES professor(id_professor),
    id_funcao INTEGER NOT NULL REFERENCES funcao(id_funcao),
    dt_entrada DATE NOT NULL,
    dt_saida DATE,
    PRIMARY KEY (id_professor, id_funcao)
);

-- Tabela PROFESSOR_TURMA (inalterada)
CREATE TABLE professor_turma (
    id_prof_turma SERIAL PRIMARY KEY,
    id_professor INTEGER NOT NULL REFERENCES professor(id_professor),
    id_turma INTEGER NOT NULL REFERENCES turma(id_turma)
);

-- Tabela AVALIACAO (MODIFICADA: Adiciona id_periodo_letivo)
-- Representa uma avaliação lançada por um professor para uma turma em um período.
CREATE TABLE avaliacao (
    id_avaliacao SERIAL PRIMARY KEY,
    descricao TEXT NOT NULL,
    data DATE NOT NULL,
    id_prof_turma INTEGER NOT NULL REFERENCES professor_turma(id_prof_turma),
    id_periodo_letivo INTEGER NOT NULL REFERENCES periodo_letivo(id_periodo_letivo) -- Novo campo
);

-- Tabela RESULT_AVALIACAO (MODIFICADA: id_aluno_turma substitui id_aluno)
-- Armazena a nota obtida por um aluno em uma avaliação específica.
CREATE TABLE result_avaliacao (
    id_avaliacao INTEGER NOT NULL REFERENCES avaliacao(id_avaliacao),
    id_aluno_turma INTEGER NOT NULL REFERENCES aluno_turma(id_aluno_turma), -- Referencia a matrícula específica
    nota_obtida NUMERIC(5,2),
    PRIMARY KEY (id_avaliacao, id_aluno_turma)
);

-- NOVA TABELA: AULA
-- Registra cada sessão de aula para uma turma específica com um professor em um período.
CREATE TABLE aula (
    id_aula SERIAL PRIMARY KEY,
    id_periodo_letivo INTEGER NOT NULL REFERENCES periodo_letivo(id_periodo_letivo),
    id_prof_turma INTEGER NOT NULL REFERENCES professor_turma(id_prof_turma), -- Professor que lecionou essa aula
    assunto VARCHAR(255),
    data DATE NOT NULL,
    qtd_aulas INTEGER NOT NULL CHECK (qtd_aulas > 0) -- Horas desta sessão de aula (ex: 1 para 1h de aula)
);

-- NOVA TABELA: PRESENCA
-- Relaciona um aluno em uma turma (id_aluno_turma) a uma aula específica (id_aula).
CREATE TABLE presenca (
    id_aula INTEGER NOT NULL REFERENCES aula(id_aula),
    id_aluno_turma INTEGER NOT NULL REFERENCES aluno_turma(id_aluno_turma),
    PRIMARY KEY (id_aula, id_aluno_turma) -- Garante uma única presença por aluno_turma por aula
);

-- NOVA TABELA: RESULT_ALUNO_PERIODO
-- Armazena os resultados consolidados de um aluno para uma matrícula em uma turma/período.
CREATE TABLE result_aluno_periodo (
    id_result_aluno_periodo SERIAL PRIMARY KEY,
    id_aluno_turma INTEGER NOT NULL UNIQUE REFERENCES aluno_turma(id_aluno_turma), -- Um resultado por matrícula
    nota_media NUMERIC(5,2) DEFAULT 0.00, -- Média das notas do aluno naquela turma/período
    taxa_de_presenca NUMERIC(5,2) DEFAULT 0.00, -- Percentual de presença do aluno naquela turma/período
    resultado VARCHAR(20) CHECK (resultado IN ('Aprovado', 'Reprovado', 'Em Curso')) DEFAULT 'Em Curso' -- Status final
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
	-- PEGANDO A QUANTIDADE DE FUNÇÕES QUE ESSE PROFESSOR TERÁ APÓS A OPERAÇÃO
	SELECT COUNT(fp.id_professor) INTO qtd_funcoes_prof
	FROM func_prof fp
	WHERE fp.id_professor = NEW.id_professor;
	
	
	IF (qtd_funcoes_prof > 2) THEN
		RAISE EXCEPTION 'Esse professor atingiu o limite de funções (Máximo: 2). Funções atuais: %', qtd_funcoes_prof;
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
