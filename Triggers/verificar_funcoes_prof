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
