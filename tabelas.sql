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
