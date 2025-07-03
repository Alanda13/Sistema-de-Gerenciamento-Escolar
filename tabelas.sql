CREATE TABLE curso (
    id_curso SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    carga_horaria INTEGER NOT NULL
);

CREATE TABLE registro_relatorios (
    id_registro SERIAL PRIMARY KEY,
    nome_tabela VARCHAR(100) NOT NULL,
    tipo_operacao VARCHAR(10) NOT NULL,
    data_hora_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dados_antigos JSONB,
    dados_novos JSONB,
    usuario_bd VARCHAR(50) DEFAULT CURRENT_USER
);

CREATE TABLE disciplina (
    id_disciplina SERIAL PRIMARY KEY,
    nome_disciplina VARCHAR(100) NOT NULL,
    carga_horaria INTEGER NOT NULL,
    id_curso INTEGER NOT NULL REFERENCES curso(id_curso),
    id_pre_requisito INTEGER REFERENCES disciplina(id_disciplina)
);

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

CREATE TABLE periodo_letivo (
    id_periodo_letivo SERIAL PRIMARY KEY,
    ano INTEGER NOT NULL,
    semestre INTEGER NOT NULL CHECK (semestre IN (1, 2)),
    dt_inicio DATE NOT NULL,
    dt_fim DATE NOT NULL
);

CREATE TABLE turma (
    id_turma SERIAL PRIMARY KEY,
    sala VARCHAR(50),
    horario_aula INTEGER NOT NULL,
    qtd_vagas INTEGER NOT NULL,
    id_disciplina INTEGER NOT NULL REFERENCES disciplina(id_disciplina),
    id_periodo_letivo INTEGER NOT NULL REFERENCES periodo_letivo(id_periodo_letivo)
);


CREATE TABLE aluno_turma (
    id_aluno_turma SERIAL PRIMARY KEY,
    id_aluno INTEGER NOT NULL REFERENCES aluno(id_aluno),
    id_turma INTEGER NOT NULL REFERENCES turma(id_turma),
    UNIQUE (id_aluno, id_turma)
);

CREATE TABLE funcao (
    id_funcao SERIAL PRIMARY KEY,
    funcao VARCHAR(100) NOT NULL
);

CREATE TABLE professor (
    id_professor SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    telefone VARCHAR(20)
);

CREATE TABLE func_prof (
    id_professor INTEGER NOT NULL REFERENCES professor(id_professor),
    id_funcao INTEGER NOT NULL REFERENCES funcao(id_funcao),
    dt_entrada DATE NOT NULL,
    dt_saida DATE,
    PRIMARY KEY (id_professor, id_funcao)
);

CREATE TABLE professor_turma (
    id_prof_turma SERIAL PRIMARY KEY,
    id_professor INTEGER NOT NULL REFERENCES professor(id_professor),
    id_turma INTEGER NOT NULL REFERENCES turma(id_turma)
);

CREATE TABLE avaliacao (
    id_avaliacao SERIAL PRIMARY KEY,
    descricao TEXT NOT NULL,
    data DATE NOT NULL,
    id_prof_turma INTEGER NOT NULL REFERENCES professor_turma(id_prof_turma),
    id_periodo_letivo INTEGER NOT NULL REFERENCES periodo_letivo(id_periodo_letivo)
);

CREATE TABLE result_avaliacao (
    id_avaliacao INTEGER NOT NULL REFERENCES avaliacao(id_avaliacao),
    id_aluno_turma INTEGER NOT NULL REFERENCES aluno_turma(id_aluno_turma),
    nota_obtida NUMERIC(5,2),
    PRIMARY KEY (id_avaliacao, id_aluno_turma)
);

CREATE TABLE aula (
    id_aula SERIAL PRIMARY KEY,
    id_periodo_letivo INTEGER NOT NULL REFERENCES periodo_letivo(id_periodo_letivo),
    id_prof_turma INTEGER NOT NULL REFERENCES professor_turma(id_prof_turma),
    assunto VARCHAR(255),
    data DATE NOT NULL,
    qtd_aulas INTEGER NOT NULL CHECK (qtd_aulas > 0)
);

CREATE TABLE presenca (
    id_aula INTEGER NOT NULL REFERENCES aula(id_aula),
    id_aluno_turma INTEGER NOT NULL REFERENCES aluno_turma(id_aluno_turma),
    PRIMARY KEY (id_aula, id_aluno_turma)
);

CREATE TABLE result_aluno_periodo (
    id_result_aluno_periodo SERIAL PRIMARY KEY,
    id_aluno_turma INTEGER NOT NULL UNIQUE REFERENCES aluno_turma(id_aluno_turma),
    nota_media NUMERIC(5,2) DEFAULT 0.00,
    taxa_de_presenca NUMERIC(5,2) DEFAULT 0.00,
    resultado VARCHAR(20) CHECK (resultado IN ('Aprovado', 'Reprovado', 'Em Curso')) DEFAULT 'Em Curso'
);


----------------------------------\/RELATORIO\/----------------------------------
CREATE OR REPLACE FUNCTION registrar_operacao_relatorio()
RETURNS TRIGGER AS $$
DECLARE
    v_old_data JSONB;
    v_new_data JSONB;
BEGIN
    -- Converte OLD e NEW para JSONB, se existirem
    IF TG_OP = 'DELETE' THEN
        v_old_data := to_jsonb(OLD);
        v_new_data := NULL;
    ELSIF TG_OP = 'INSERT' THEN
        v_old_data := NULL;
        v_new_data := to_jsonb(NEW);
    ELSIF TG_OP = 'UPDATE' THEN
        v_old_data := to_jsonb(OLD);
        v_new_data := to_jsonb(NEW);
    END IF;

    INSERT INTO registro_relatorios (
        nome_tabela,
        tipo_operacao,
        data_hora_registro,
        dados_antigos,
        dados_novos,
        usuario_bd
    )
    VALUES (
        TG_TABLE_NAME,
        TG_OP,
        NOW(),
        v_old_data,
        v_new_data,
        CURRENT_USER
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para a tabela CURSO
CREATE TRIGGER trg_log_curso
AFTER INSERT OR UPDATE OR DELETE ON curso
FOR EACH ROW EXECUTE FUNCTION registrar_operacao_relatorio();

-- Trigger para a tabela DISCIPLINA
CREATE TRIGGER trg_log_disciplina
AFTER INSERT OR UPDATE OR DELETE ON disciplina
FOR EACH ROW EXECUTE FUNCTION registrar_operacao_relatorio();

-- Trigger para a tabela ALUNO
CREATE TRIGGER trg_log_aluno
AFTER INSERT OR UPDATE OR DELETE ON aluno
FOR EACH ROW EXECUTE FUNCTION registrar_operacao_relatorio();

-- Trigger para a tabela PERIODO_LETIVO
CREATE TRIGGER trg_log_periodo_letivo
AFTER INSERT OR UPDATE OR DELETE ON periodo_letivo
FOR EACH ROW EXECUTE FUNCTION registrar_operacao_relatorio();

-- Trigger para a tabela TURMA
CREATE TRIGGER trg_log_turma
AFTER INSERT OR UPDATE OR DELETE ON turma
FOR EACH ROW EXECUTE FUNCTION registrar_operacao_relatorio();

-- Trigger para a tabela ALUNO_TURMA
CREATE TRIGGER trg_log_aluno_turma
AFTER INSERT OR UPDATE OR DELETE ON aluno_turma
FOR EACH ROW EXECUTE FUNCTION registrar_operacao_relatorio();

-- Trigger para a tabela FUNCAO
CREATE TRIGGER trg_log_funcao
AFTER INSERT OR UPDATE OR DELETE ON funcao
FOR EACH ROW EXECUTE FUNCTION registrar_operacao_relatorio();

-- Trigger para a tabela PROFESSOR
CREATE TRIGGER trg_log_professor
AFTER INSERT OR UPDATE OR DELETE ON professor
FOR EACH ROW EXECUTE FUNCTION registrar_operacao_relatorio();

-- Trigger para a tabela FUNC_PROF
CREATE TRIGGER trg_log_func_prof
AFTER INSERT OR UPDATE OR DELETE ON func_prof
FOR EACH ROW EXECUTE FUNCTION registrar_operacao_relatorio();

-- Trigger para a tabela PROFESSOR_TURMA
CREATE TRIGGER trg_log_professor_turma
AFTER INSERT OR UPDATE OR DELETE ON professor_turma
FOR EACH ROW EXECUTE FUNCTION registrar_operacao_relatorio();

-- Trigger para a tabela AVALIACAO
CREATE TRIGGER trg_log_avaliacao
AFTER INSERT OR UPDATE OR DELETE ON avaliacao
FOR EACH ROW EXECUTE FUNCTION registrar_operacao_relatorio();

-- Trigger para a tabela RESULT_AVALIACAO
CREATE TRIGGER trg_log_result_avaliacao
AFTER INSERT OR UPDATE OR DELETE ON result_avaliacao
FOR EACH ROW EXECUTE FUNCTION registrar_operacao_relatorio();

-- Trigger para a tabela AULA
CREATE TRIGGER trg_log_aula
AFTER INSERT OR UPDATE OR DELETE ON aula
FOR EACH ROW EXECUTE FUNCTION registrar_operacao_relatorio();

-- Trigger para a tabela PRESENCA
CREATE TRIGGER trg_log_presenca
AFTER INSERT OR UPDATE OR DELETE ON presenca
FOR EACH ROW EXECUTE FUNCTION registrar_operacao_relatorio();

-- Trigger para a tabela RESULT_ALUNO_PERIODO
CREATE TRIGGER trg_log_result_aluno_periodo
AFTER INSERT OR UPDATE OR DELETE ON result_aluno_periodo
FOR EACH ROW EXECUTE FUNCTION registrar_operacao_relatorio();

----------------------------------/\ RELATORIO /\----------------------------------
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

-- Função para calcular e atualizar a média das notas de um aluno em uma turma/período
CREATE OR REPLACE FUNCTION calcular_e_atualizar_media_aluno()
RETURNS TRIGGER AS $$
DECLARE
    v_id_aluno_turma INTEGER;
    v_id_periodo_letivo INTEGER;
    v_media_calculada NUMERIC(5,2);
    v_total_avaliacoes INTEGER;
BEGIN
    -- Determina o id_aluno_turma e id_periodo_letivo relevantes para a operação
    IF TG_OP = 'DELETE' THEN
        v_id_aluno_turma := OLD.id_aluno_turma;
        -- Para DELETE, precisamos buscar o id_periodo_letivo da avaliação que foi deletada
        SELECT av.id_periodo_letivo INTO v_id_periodo_letivo
        FROM avaliacao av
        WHERE av.id_avaliacao = OLD.id_avaliacao;
    ELSE
        v_id_aluno_turma := NEW.id_aluno_turma;
        -- Para INSERT/UPDATE, buscamos o id_periodo_letivo da avaliação sendo inserida/atualizada
        SELECT av.id_periodo_letivo INTO v_id_periodo_letivo
        FROM avaliacao av
        WHERE av.id_avaliacao = NEW.id_avaliacao;
    END IF;

    -- Calcula a média das notas para o aluno_turma no período letivo
    SELECT COALESCE(AVG(ra.nota_obtida), 0.00), COUNT(ra.id_avaliacao)
    INTO v_media_calculada, v_total_avaliacoes
    FROM result_avaliacao ra
    JOIN avaliacao av ON ra.id_avaliacao = av.id_avaliacao
    WHERE ra.id_aluno_turma = v_id_aluno_turma
      AND av.id_periodo_letivo = v_id_periodo_letivo;

    -- Se não houver avaliações para o aluno_turma no período, a média é 0
    IF v_total_avaliacoes = 0 THEN
        v_media_calculada := 0.00;
    END IF;

    -- Atualiza ou insere o registro em result_aluno_periodo
    INSERT INTO result_aluno_periodo (id_aluno_turma, nota_media, taxa_de_presenca, resultado)
    VALUES (v_id_aluno_turma, v_media_calculada, 0.00, 'Em Curso')
    ON CONFLICT (id_aluno_turma) DO UPDATE SET
        nota_media = EXCLUDED.nota_media; -- Atualiza apenas a nota_media

    RETURN NULL; -- Triggers AFTER não retornam NEW/OLD
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calcular_media_aluno
AFTER INSERT OR UPDATE OR DELETE ON result_avaliacao
FOR EACH ROW
EXECUTE FUNCTION calcular_e_atualizar_media_aluno();
		
-- Função para calcular e atualizar a taxa de presença de um aluno em uma turma/período
CREATE OR REPLACE FUNCTION calcular_e_atualizar_taxa_presenca_aluno()
RETURNS TRIGGER AS $$
DECLARE
    v_id_aluno_turma INTEGER;
    v_id_periodo_letivo INTEGER;
    v_total_horas_presenca NUMERIC(10,2);
    v_total_horas_aulas_turma NUMERIC(10,2);
    v_taxa_presenca_calculada NUMERIC(5,2);
BEGIN
    -- Determina o id_aluno_turma e id_aula relevantes para a operação
    IF TG_OP = 'DELETE' THEN
        v_id_aluno_turma := OLD.id_aluno_turma;
        -- Para DELETE, precisamos buscar o id_periodo_letivo da aula que foi deletada da presença
        SELECT a.id_periodo_letivo INTO v_id_periodo_letivo
        FROM aula a
        WHERE a.id_aula = OLD.id_aula;
    ELSE
        v_id_aluno_turma := NEW.id_aluno_turma;
        -- Para INSERT, buscamos o id_periodo_letivo da aula que está sendo inserida na presença
        SELECT a.id_periodo_letivo INTO v_id_periodo_letivo
        FROM aula a
        WHERE a.id_aula = NEW.id_aula;
    END IF;

    -- Calcular o total de horas de presença do aluno na turma para o período letivo
    SELECT COALESCE(SUM(a.qtd_aulas), 0)
    INTO v_total_horas_presenca
    FROM presenca p
    JOIN aula a ON p.id_aula = a.id_aula
    WHERE p.id_aluno_turma = v_id_aluno_turma
      AND a.id_periodo_letivo = v_id_periodo_letivo;

    -- Calcular o total de horas de aulas ministradas para a turma do aluno no período letivo
    -- Primeiro, precisamos encontrar o id_turma associado ao id_aluno_turma
    -- E depois, somar todas as qtd_aulas para aquela turma e período.
    SELECT COALESCE(SUM(a.qtd_aulas), 0)
    INTO v_total_horas_aulas_turma
    FROM aula a
    JOIN professor_turma pt ON a.id_prof_turma = pt.id_prof_turma
    JOIN aluno_turma at ON pt.id_turma = at.id_turma
    WHERE at.id_aluno_turma = v_id_aluno_turma -- Filtra para a matrícula específica do aluno
      AND a.id_periodo_letivo = v_id_periodo_letivo;

    -- Calcular a taxa de presença
    IF v_total_horas_aulas_turma > 0 THEN
        v_taxa_presenca_calculada := (v_total_horas_presenca * 100.0) / v_total_horas_aulas_turma;
    ELSE
        v_taxa_presenca_calculada := 0.00; -- Se não houver aulas ministradas, a taxa é 0
    END IF;

    -- Atualiza ou insere o registro em result_aluno_periodo
    INSERT INTO result_aluno_periodo (id_aluno_turma, nota_media, taxa_de_presenca, resultado)
    VALUES (v_id_aluno_turma, 0.00, v_taxa_presenca_calculada, 'Em Curso')
    ON CONFLICT (id_aluno_turma) DO UPDATE SET
        taxa_de_presenca = EXCLUDED.taxa_de_presenca; -- Atualiza apenas a taxa_de_presenca

    RETURN NULL; -- Triggers AFTER não retornam NEW/OLD
END;
$$ LANGUAGE plpgsql;

-- Trigger que dispara a função após INSERT ou DELETE em presenca
CREATE TRIGGER trg_calcular_taxa_presenca_aluno
AFTER INSERT OR DELETE ON presenca
FOR EACH ROW
EXECUTE FUNCTION calcular_e_atualizar_taxa_presenca_aluno();
		
-- Função para finalizar o resultado dos alunos de uma turma específica
CREATE OR REPLACE FUNCTION finalizar_disciplina_alunos_da_turma(p_id_turma INTEGER)
RETURNS VOID AS $$
BEGIN
    -- Atualiza o campo 'resultado' na tabela result_aluno_periodo para os alunos
    -- da turma especificada, com base nas regras de nota_media e taxa_de_presenca.
    UPDATE result_aluno_periodo rap
    SET resultado = CASE
        WHEN rap.nota_media < 7.0 OR rap.taxa_de_presenca < 75.0 THEN 'Reprovado'
        ELSE 'Aprovado'
    END
    FROM aluno_turma at
    WHERE rap.id_aluno_turma = at.id_aluno_turma
      AND at.id_turma = p_id_turma
      AND rap.resultado = 'Em Curso'; -- Opcional: só atualiza quem ainda não foi finalizado

    RAISE NOTICE 'Resultados finais dos alunos da turma ID % que estavam "Em Curso" foram atualizados.', p_id_turma;

END;
$$ LANGUAGE plpgsql;
-----------------------------------/\ TRIGGERS E FUNÇÕES /\------------------------------------------
----------------------------------------\/ INSERTS \/------------------------------------------------
-- Curso
INSERT INTO curso (nome, carga_horaria) VALUES ('Engenharia de Software', 3600); -- id_curso = 1

-- Disciplina
INSERT INTO disciplina (nome_disciplina, carga_horaria, id_curso) VALUES ('Banco de Dados II', 80, 1); -- id_disciplina = 1

-- Período Letivo
INSERT INTO periodo_letivo (ano, semestre, dt_inicio, dt_fim) VALUES (2025, 2, '2025-08-01', '2025-12-15'); -- id_periodo_letivo = 1

-- Professor
INSERT INTO professor (nome, cpf, telefone) VALUES ('Dr. Smith', '123.456.789-00', '987654321'); -- id_professor = 1

-- Função
INSERT INTO funcao (funcao) VALUES ('Professor'); -- id_funcao = 1

-- Vínculo Professor-Função
INSERT INTO func_prof (id_professor, id_funcao, dt_entrada) VALUES (1, 1, '2025-01-01');

-- Turma (Disciplina 1, Período 1)
INSERT INTO turma (sala, horario_aula, qtd_vagas, id_disciplina, id_periodo_letivo)
VALUES ('Lab 201', 5, 20, 1, 1); -- id_turma = 1

-- Vínculo Professor-Turma
INSERT INTO professor_turma (id_professor, id_turma) VALUES (1, 1); -- id_prof_turma = 1

-- Aluno
INSERT INTO aluno (nome, cpf, email, data_nasc, telefone, id_curso, status)
VALUES ('Ana Maria', '000.000.000-00', 'ana@email.com', '2003-03-01', '999900000', 1, 'ativo'); -- id_aluno = 1

-- Matrícula do Aluno na Turma
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (1, 1); -- id_aluno_turma = 1

-- =================================================================================================
-- TESTES PARA A FUNÇÃO DE TAXA DE PRESENÇA (trg_calcular_taxa_presenca_aluno)
-- =================================================================================================

-- Inserir Aulas para a Turma (Total de Horas de Aula Esperadas)
-- Aula 1: 2 horas
INSERT INTO aula (id_periodo_letivo, id_prof_turma, assunto, data, qtd_aulas)
VALUES (1, 1, 'Introdução a SQL', '2025-08-05', 2); -- id_aula = 1

-- Aula 2: 3 horas
INSERT INTO aula (id_periodo_letivo, id_prof_turma, assunto, data, qtd_aulas)
VALUES (1, 1, 'Modelagem de Dados', '2025-08-12', 3); -- id_aula = 2

-- Verificar o total de horas de aula para a turma 1 no período 1 (esperado: 5 horas)
SELECT SUM(a.qtd_aulas) FROM aula a JOIN professor_turma pt ON a.id_prof_turma = pt.id_prof_turma WHERE pt.id_turma = 1 AND a.id_periodo_letivo = 1;

-- Inserir Presenças para o Aluno na Turma (Dispara o trigger de taxa de presença)
-- Presença na Aula 1 (2 horas)
INSERT INTO presenca (id_aula, id_aluno_turma) VALUES (1, 1); -- Taxa de presença deve ser (2 / 5) * 100 = 40.00%

-- Verificar result_aluno_periodo após a primeira presença
SELECT id_aluno_turma, nota_media, taxa_de_presenca, resultado
FROM result_aluno_periodo
WHERE id_aluno_turma = 1;

-- Presença na Aula 2 (3 horas)
INSERT INTO presenca (id_aula, id_aluno_turma) VALUES (2, 1); -- Taxa de presença deve ser (2+3 / 5) * 100 = 100.00%

-- Verificar result_aluno_periodo após a segunda presença
SELECT id_aluno_turma, nota_media, taxa_de_presenca, resultado
FROM result_aluno_periodo
WHERE id_aluno_turma = 1;

-- =================================================================================================
-- TESTES PARA A FUNÇÃO DE CÁLCULO DE MÉDIA (trg_calcular_media_aluno)
-- =================================================================================================

-- Inserir uma Avaliação para a Turma (necessário para result_avaliacao)
-- Avaliação de Banco de Dados II, lançada pelo Dr. Smith para a Turma 1 no Período 1
INSERT INTO avaliacao (descricao, data, id_prof_turma, id_periodo_letivo)
VALUES ('Prova 1 - SQL', '2025-09-01', 1, 1); -- id_avaliacao = 1

-- Inserir a primeira nota para o Aluno na Avaliação (Dispara o trigger de média)
INSERT INTO result_avaliacao (id_avaliacao, id_aluno_turma, nota_obtida)
VALUES (1, 1, 7.5); -- Média deve ser 7.50

-- Verificar result_aluno_periodo após a primeira nota
SELECT id_aluno_turma, nota_media, taxa_de_presenca, resultado
FROM result_aluno_periodo
WHERE id_aluno_turma = 1;

-- Inserir outra Avaliação
INSERT INTO avaliacao (descricao, data, id_prof_turma, id_periodo_letivo)
VALUES ('Trabalho Final', '2025-11-10', 1, 1); -- id_avaliacao = 2

-- Inserir a segunda nota para o Aluno (Dispara o trigger de média novamente)
INSERT INTO result_avaliacao (id_avaliacao, id_aluno_turma, nota_obtida)
VALUES (2, 1, 9.0); -- Média deve ser (7.5 + 9.0) / 2 = 8.25

-- Verificar result_aluno_periodo após a segunda nota
SELECT id_aluno_turma, nota_media, taxa_de_presenca, resultado
FROM result_aluno_periodo
WHERE id_aluno_turma = 1;

-- Testar DELETE de nota (Dispara o trigger de média)
DELETE FROM result_avaliacao WHERE id_avaliacao = 1 AND id_aluno_turma = 1; -- Média deve voltar para 9.00

-- Verificar result_aluno_periodo após o DELETE
SELECT id_aluno_turma, nota_media, taxa_de_presenca, resultado
FROM result_aluno_periodo
WHERE id_aluno_turma = 1;

-- Testar DELETE de presença (Dispara o trigger de taxa de presença)
DELETE FROM presenca WHERE id_aula = 1 AND id_aluno_turma = 1; -- Taxa de presença deve ser (3 / 5) * 100 = 60.00%

-- Verificar result_aluno_periodo após o DELETE de presença
SELECT id_aluno_turma, nota_media, taxa_de_presenca, resultado
FROM result_aluno_periodo
WHERE id_aluno_turma = 1;

-- =================================================================================================
-- FUNÇÃO ATUALIZADA: FINALIZAR DISCIPLINA DE ALUNOS DE UMA TURMA ESPECÍFICA
-- =================================================================================================

-- Função para finalizar o resultado dos alunos de uma turma específica
CREATE OR REPLACE FUNCTION finalizar_disciplina_alunos_da_turma(p_id_turma INTEGER)
RETURNS VOID AS $$
BEGIN
    -- Atualiza o campo 'resultado' na tabela result_aluno_periodo para os alunos
    -- da turma especificada, com base nas regras de nota_media e taxa_de_presenca.
    UPDATE result_aluno_periodo rap
    SET resultado = CASE
        WHEN rap.nota_media < 7.0 OR rap.taxa_de_presenca < 75.0 THEN 'Reprovado'
        ELSE 'Aprovado'
    END
    FROM aluno_turma at
    WHERE rap.id_aluno_turma = at.id_aluno_turma
      AND at.id_turma = p_id_turma
      AND rap.resultado = 'Em Curso'; -- Opcional: só atualiza quem ainda não foi finalizado

    RAISE NOTICE 'Resultados finais dos alunos da turma ID % que estavam "Em Curso" foram atualizados.', p_id_turma;

END;
$$ LANGUAGE plpgsql;

-- =================================================================================================
-- TESTES PARA A FUNÇÃO DE FINALIZAÇÃO DA DISCIPLINA (POR TURMA)
-- =================================================================================================

-- Cenário 1: Aluno com média e presença para aprovação (Ana Maria, id_aluno_turma = 1)
-- Média atual: 9.00, Taxa de Presença atual: 60.00% (reprovado por presença)
-- Vamos ajustar a presença para que ela seja aprovada na próxima etapa
DELETE FROM presenca WHERE id_aula = 2 AND id_aluno_turma = 1; -- Remove a aula 2 (3h)
-- Taxa de presença deve ser (0 / 5) * 100 = 0%
-- Inserir novamente a presença da Aula 2 para ter 100%
INSERT INTO presenca (id_aula, id_aluno_turma) VALUES (2, 1); -- Taxa de presença deve ser (2+3 / 5) * 100 = 100.00%
-- Verificar estado antes de finalizar
SELECT id_aluno_turma, nota_media, taxa_de_presenca, resultado FROM result_aluno_periodo WHERE id_aluno_turma = 1;

-- Cenário 2: Aluno com média baixa (reprovado por média)
-- Criar um novo aluno e matrícula para teste
INSERT INTO aluno (nome, cpf, email, data_nasc, telefone, id_curso, status)
VALUES ('Pedro Silva', '111.222.333-44', 'pedro@email.com', '2004-01-01', '999911111', 1, 'ativo'); -- id_aluno = 2
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (2, 1); -- id_aluno_turma = 2

-- Inserir notas para Pedro (média baixa)
INSERT INTO result_avaliacao (id_avaliacao, id_aluno_turma, nota_obtida) VALUES (1, 2, 5.0); -- Média 5.0
INSERT INTO result_avaliacao (id_avaliacao, id_aluno_turma, nota_obtida) VALUES (2, 2, 6.0); -- Média (5.0+6.0)/2 = 5.5

-- Inserir presenças para Pedro (taxa alta)
INSERT INTO presenca (id_aula, id_aluno_turma) VALUES (1, 2);
INSERT INTO presenca (id_aula, id_aluno_turma) VALUES (2, 2);

-- Verificar estado antes de finalizar
SELECT id_aluno_turma, nota_media, taxa_de_presenca, resultado FROM result_aluno_periodo WHERE id_aluno_turma = 2;

-- Cenário 3: Aluno com presença baixa (reprovado por presença)
-- Criar outro aluno e matrícula para teste
INSERT INTO aluno (nome, cpf, email, data_nasc, telefone, id_curso, status)
VALUES ('Mariana Souza', '555.666.777-88', 'mariana@email.com', '2003-05-10', '999922222', 1, 'ativo'); -- id_aluno = 3
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (3, 1); -- id_aluno_turma = 3

-- Inserir notas para Mariana (média alta)
INSERT INTO result_avaliacao (id_avaliacao, id_aluno_turma, nota_obtida) VALUES (1, 3, 8.0);
INSERT INTO result_avaliacao (id_avaliacao, id_aluno_turma, nota_obtida) VALUES (2, 3, 7.0); -- Média (8.0+7.0)/2 = 7.5

-- Inserir apenas uma presença para Mariana (taxa baixa)
INSERT INTO presenca (id_aula, id_aluno_turma) VALUES (1, 3); -- Apenas 2 horas de 5 totais = 40%

-- Verificar estado antes de finalizar
SELECT id_aluno_turma, nota_media, taxa_de_presenca, resultado FROM result_aluno_periodo WHERE id_aluno_turma = 3;

-- Chamar a função para finalizar a disciplina para TODOS os alunos da TURMA 1
SELECT finalizar_disciplina_alunos_da_turma(1);

-- Verificar os resultados finais de TODOS os alunos (deve refletir as mudanças para id_aluno_turma 1, 2 e 3)
SELECT id_aluno_turma, nota_media, taxa_de_presenca, resultado
FROM result_aluno_periodo
WHERE id_aluno_turma IN (1, 2, 3)
ORDER BY id_aluno_turma;

-- =================================================================================================
-- Cenário 4: Aluno APROVADO (Média >= 7.0 e Presença >= 75.0%)
-- =================================================================================================
-- Criar um novo aluno e matrícula para teste
INSERT INTO aluno (nome, cpf, email, data_nasc, telefone, id_curso, status)
VALUES ('Joao Santos', '123.123.123-12', 'joao@email.com', '2002-07-20', '999944444', 1, 'ativo'); -- id_aluno = 4
INSERT INTO aluno_turma (id_aluno, id_turma) VALUES (4, 1); -- id_aluno_turma = 4

-- Inserir notas para Joao (média alta)
INSERT INTO result_avaliacao (id_avaliacao, id_aluno_turma, nota_obtida) VALUES (1, 4, 8.5);
INSERT INTO result_avaliacao (id_avaliacao, id_aluno_turma, nota_obtida) VALUES (2, 4, 7.5); -- Média (8.5+7.5)/2 = 8.0

-- Inserir presenças para Joao (taxa alta)
-- Aula 1 (2h) e Aula 2 (3h) totalizam 5h de aula.
-- Para >= 75% de presença, precisa de 5 * 0.75 = 3.75 horas.
-- Vamos dar presença nas duas aulas para 100% (5h).
INSERT INTO presenca (id_aula, id_aluno_turma) VALUES (1, 4);
INSERT INTO presenca (id_aula, id_aluno_turma) VALUES (2, 4);

-- Verificar estado antes de finalizar
SELECT id_aluno_turma, nota_media, taxa_de_presenca, resultado FROM result_aluno_periodo WHERE id_aluno_turma = 4;

-- Chamar a função para finalizar a disciplina para a TURMA 1 (incluirá Joao)
SELECT finalizar_disciplina_alunos_da_turma(1);

-- Verificar o resultado final de Joao (Esperado: Aprovado)
SELECT id_aluno_turma, nota_media, taxa_de_presenca, resultado
FROM result_aluno_periodo;
SELECT * FROM registro_relatorios
----------------------------------------/\ INSERTS /\------------------------------------------------
-- -- Limpar dados de todas as tabelas (em ordem inversa de dependência)
-- DELETE FROM result_avaliacao;
-- DELETE FROM presenca;
-- DELETE FROM result_aluno_periodo;
-- DELETE FROM aula;
-- DELETE FROM avaliacao;
-- DELETE FROM professor_turma;
-- DELETE FROM func_prof;
-- DELETE FROM aluno_turma;
-- DELETE FROM turma;
-- DELETE FROM disciplina;
-- DELETE FROM aluno;
-- DELETE FROM professor;
-- DELETE FROM funcao;
-- DELETE FROM periodo_letivo;
-- DELETE FROM curso;
-- DELETE FROM REGISTRO_RELATORIOS;

-- -- Reiniciar contadores (SERIALS) de todas as tabelas
-- ALTER SEQUENCE curso_id_curso_seq RESTART WITH 1;
-- ALTER SEQUENCE disciplina_id_disciplina_seq RESTART WITH 1;
-- ALTER SEQUENCE aluno_id_aluno_seq RESTART WITH 1;
-- ALTER SEQUENCE periodo_letivo_id_periodo_letivo_seq RESTART WITH 1;
-- ALTER SEQUENCE turma_id_turma_seq RESTART WITH 1;
-- ALTER SEQUENCE aluno_turma_id_aluno_turma_seq RESTART WITH 1;
-- ALTER SEQUENCE funcao_id_funcao_seq RESTART WITH 1;
-- ALTER SEQUENCE professor_id_professor_seq RESTART WITH 1;
-- ALTER SEQUENCE professor_turma_id_prof_turma_seq RESTART WITH 1;
-- ALTER SEQUENCE avaliacao_id_avaliacao_seq RESTART WITH 1;
-- ALTER SEQUENCE aula_id_aula_seq RESTART WITH 1;
-- ALTER SEQUENCE result_aluno_periodo_id_result_aluno_periodo_seq RESTART WITH 1;
