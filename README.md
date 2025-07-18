
# 📚 Sistema de Gerenciamento Escolar

Trabalho final da disciplina **Banco de Dados II** — Desenvolvimento de um sistema de gerenciamento escolar com foco em regras de negócio implementadas diretamente no banco de dados, utilizando PostgreSQL.

---

## 👥 Desenvolvedores

- **Alanda Amábily**
- **Iago José**

---

## 🎯 Objetivo do Sistema

O sistema tem como objetivo permitir:

- O gerenciamento de alunos, cursos, turmas e disciplinas;
- A matrícula de alunos em turmas;
- O registro e controle de avaliações e notas;
- A associação de professores a turmas e funções administrativas;
- A validação de regras de negócio complexas via **funções e triggers** no banco de dados.

Todo o funcionamento se dá **exclusivamente no nível do banco de dados**, **sem interface gráfica**.

---

## 🧱 Estrutura do Banco de Dados

O banco de dados é composto por **12 tabelas principais**, além de relacionamentos auxiliares:

- `curso`
- `disciplina`
- `pre_requisito` (relacionamento N:N entre disciplinas)
- `aluno`
- `turma`
- `periodo_letivo`
- `aluno_turma` (relacionamento aluno-turma)
- `professor`
- `funcao`
- `professor_funcao` (relacionamento professor-função com histórico)
- `professor_turma` (relacionamento professor-turma)
- `avaliacao`
- `result_avaliacao` (relacionamento aluno-avaliação)

---

## ⚙️ Regras de Negócio Implementadas

1. **Restrição por curso**  
   Um aluno só pode se matricular em turmas cujas disciplinas pertencem ao seu curso.

2. **Controle de vagas**  
   Uma turma só pode aceitar matrículas até o limite definido em `qtd_vagas`.

3. **Pré-requisitos de disciplina**  
   Um aluno só pode se matricular em uma disciplina se já tiver cursado/aprovado todas as disciplinas pré-requisito.

4. **Validação de carga horária da turma**  
   O horário de aula semanal multiplicado pelas semanas do período letivo deve cobrir a carga da disciplina.

5. **Avaliação só com matrícula**  
   Um aluno só pode receber nota em uma avaliação se estiver matriculado na turma correspondente.

6. **Prevenção de matrícula duplicada**  
   Um aluno não pode ser matriculado mais de uma vez na mesma turma.

7. **Validação de período letivo**  
   Matrículas em turmas só podem ocorrer dentro das datas válidas do período letivo.

---

## 🔧 Funcionalidades Técnicas

- Uso de **funções SQL parametrizadas**, com destaque para:
  - Função de cadastro
  - Função de alteração
  - Função de exclusão com tratamento de integridade referencial

- Uso de **triggers** para validar regras de negócio automaticamente durante `INSERT` e `UPDATE`.

- Todos os comandos são executados via **pgAdmin** e scripts SQL, **sem interface gráfica**.

---

## 🛠 Ferramentas e Tecnologias

- PostgreSQL
- pgAdmin
- SQL/PLpgSQL
- Modelo Entidade-Relacionamento (DER)
- Funções e Triggers



