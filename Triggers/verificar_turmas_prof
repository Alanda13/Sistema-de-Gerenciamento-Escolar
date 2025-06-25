CREATE OR REPLACE FUNCTION verificar_turmas_prof()
RETURNS TRIGGER AS $$
DECLARE 
    qtd_turmas_prof INTEGER;
    total_funcoes INTEGER;
    possui_funcao_professor BOOLEAN;
BEGIN
    -- 1. Contar as turmas atuais do professor (para a qual a inserção/atualização está ocorrendo)
    SELECT COUNT(*) INTO qtd_turmas_prof
    FROM professor_turma pt
    WHERE pt.id_professor = NEW.id_professor;

    -- 2. Contar o número TOTAL de funções que o professor possui
    SELECT COUNT(*) INTO total_funcoes
    FROM func_prof fp
    WHERE fp.id_professor = NEW.id_professor;

    -- 3. Verificar se o professor possui a função 'Professor' (pelo menos uma vez)
    SELECT EXISTS (
        SELECT 1
        FROM func_prof fp_inner
        JOIN funcao f_inner ON fp_inner.id_funcao = f_inner.id_funcao
        WHERE fp_inner.id_professor = NEW.id_professor
        AND LOWER(f_inner.funcao) = 'professor' -- Considera 'Professor', 'professor', etc.
    ) INTO possui_funcao_professor;

    -- 4. Aplicar a lógica condicional baseada nas funções do professor e limites:

    IF NOT possui_funcao_professor THEN
        -- REGRA NOVA: Se o professor NÃO possui a função 'Professor' (independentemente de outras funções ou total de funções),
        -- ele não pode ser matriculado em NENHUMA turma.
        -- Como este trigger é BEFORE INSERT/UPDATE, se ele não tem essa função, simplesmente bloqueamos.
        RAISE EXCEPTION 'Este professor não possui a função "Professor" e, portanto, não pode ser matriculado em nenhuma turma.';

    ELSIF possui_funcao_professor AND total_funcoes > 1 THEN
        -- Cenário: Professor tem a função 'Professor' E possui MAIS DE UMA função no total (ex: Professor e Coordenador)
        -- Limite: 3 turmas
        IF qtd_turmas_prof >= 3 THEN
            RAISE EXCEPTION 'Esse professor possui a função "Professor" e outras funções, atingiu o limite de turmas (máximo de 3). Turmas atuais: %', qtd_turmas_prof;
        END IF;

    ELSIF possui_funcao_professor AND total_funcoes = 1 THEN
        -- Cenário: Professor tem APENAS a função 'Professor'
        -- Limite: 5 turmas
        IF qtd_turmas_prof >= 5 THEN
            RAISE EXCEPTION 'Esse professor possui apenas a função "Professor", atingiu o limite de turmas (máximo de 5). Turmas atuais: %', qtd_turmas_prof;
        END IF;

    END IF;

    RETURN NEW; -- Permite a operação se nenhuma exceção for levantada
END;
$$ LANGUAGE plpgsql;

-- Para aplicar esta função ao seu banco de dados, certifique-se de que o trigger esteja associado:
-- (Se você já criou o trigger, não precisa executá-lo novamente, a não ser que queira ter certeza)
-- DROP TRIGGER IF EXISTS trg_verificar_turmas_prof ON professor_turma; -- Opcional: para recriar do zero
CREATE TRIGGER trg_verificar_turmas_prof
BEFORE INSERT OR UPDATE ON professor_turma
FOR EACH ROW
EXECUTE FUNCTION verificar_turmas_prof();
