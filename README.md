# Festival de Inovação — 2ª entrega de Banco de Dados

Projeto da disciplina de Banco de Dados (C07). O banco registra pessoas, palestrantes, participantes, espaços, atividades, inscrições, credenciais e check-ins de um festival. A carga usa dados fictícios.

## Modelo e execução

O arquivo [segundaEntrega.drawio](segundaEntrega.drawio) reúne os modelos conceitual e relacional. O [script principal](segundaEntrega.sql) implementa o modelo relacional no MySQL com sete tabelas InnoDB, chaves primárias, chaves estrangeiras e restrições de unicidade.

Use MySQL 8.0 ou superior e uma conta administradora em uma instância de aula ou teste. Execute cada script inteiro, nesta ordem:

1. [segundaEntrega.sql](segundaEntrega.sql) cria o banco `festival_inovacao_segunda_entrega`, instala os objetos, carrega os dados e executa as demonstrações.
2. [usuarios_roles.sql](usuarios_roles.sql) cria os usuários locais de demonstração e configura suas permissões. Execute os dois primeiros scripts uma vez, em uma instalação nova para o projeto.
3. [conferencia.sql](conferencia.sql) consulta os totais, objetos e permissões.
4. [validacao/testes_funcionais.sql](validacao/testes_funcionais.sql) verifica a carga original, os relacionamentos, as consultas, as rotinas e a role. Execute o arquivo inteiro na mesma conexão com `ONLY_FULL_GROUP_BY` ativo. O resumo final informa quantos testes foram aprovados e reprovados.

### Carga esperada após as demonstrações

| Tabela | Registros |
| --- | ---: |
| `pessoa` | 11 |
| `palestrante` | 5 |
| `participante` | 6 |
| `espaco` | 5 |
| `atividade` | 6 |
| `inscricoes_atividade` | 16 |
| `credencial` | 5 |

## Manipulação de dados (DML)

A seção 3 usa `INSERT` para carregar dados de exemplo e permitir a reprodução das consultas. A seção 6 demonstra três operações do festival:

| Comando | Motivo |
| --- | --- |
| `INSERT` | Cadastrar a inscrição de Luiza na atividade 1. |
| `UPDATE` | Corrigir o telefone de Felipe no cadastro existente. |
| `DELETE` | Cancelar somente a inscrição de Luiza na atividade 1, preservando seu cadastro. |

Cada operação é seguida de uma consulta que mostra o efeito da alteração.

## Usuários e role

Os usuários locais `recepcao_ana` e `recepcao_bruno` recebem `r_recepcao_festival` como role padrão. Isso centraliza as permissões da recepção: consultar o banco, atualizar a coluna `status_checkin` de `inscricoes_atividade` e executar a procedure e a function do projeto. As senhas do script são para demonstração local.

## Consultas com JOIN

| Consulta | Relacionamento | Finalidade |
| --- | --- | --- |
| Q1 | 1:1, participante e credencial | Lista participantes e seus códigos. O `LEFT JOIN` inclui quem ainda não recebeu credencial. A chave estrangeira com `UNIQUE` limita cada participante a uma credencial. |
| Q2 | 1:N, espaço e atividade | Agrupa a programação por espaço e conta as atividades, incluindo espaços vazios. |
| Q3 | N:M, participante e atividade | Usa a tabela associativa `inscricoes_atividade` para encontrar participantes com três ou mais inscrições, somar a duração das atividades e contar check-ins. |
| Q4 | 1:1, 1:N e N:M | Reúne presenças confirmadas, credenciais, atividades, espaços e palestrantes em uma consulta. |

## Objetos SQL e seus propósitos

| Objeto | Por que foi criado |
| --- | --- |
| Procedure `sp_registrar_checkin` | Centraliza a marcação de presença. Atualiza uma inscrição existente e informa quando a inscrição não foi encontrada. |
| View `vw_resumo_atividades` | Permite reutilizar um relatório por atividade com espaço, palestrante e totais de inscritos e check-ins. Inclui atividades sem inscrições. |
| Trigger `trg_inscricao_data` | Preenche a data com `NOW()` antes de inserir uma inscrição quando a data não é informada. Preserva a data fornecida pelo comando. |
| Function `fn_percentual_presenca` | Padroniza o cálculo do percentual de presença com duas casas decimais e retorna zero quando não há inscritos. |

## Implementações extras

- **Especialização de pessoa.** Participante e palestrante reutilizam a chave de `pessoa` como chave primária e estrangeira. Uma pessoa pode exercer os dois papéis.
- **Pré-requisito entre atividades.** A chave estrangeira na própria tabela `atividade` permite vincular uma atividade a outra. A consulta Q5 mostra esses vínculos com um autojoin.
- **Participantes sem inscrição.** A consulta Q6 usa `LEFT JOIN` e verifica se não há linha correspondente para identificar participantes que ainda não se inscreveram.
- **Integridade e conferência.** A chave composta de `inscricoes_atividade` impede inscrição duplicada na mesma atividade. As chaves estrangeiras preservam os vínculos do modelo, com `CASCADE` para registros dependentes e `SET NULL` para vínculos opcionais de atividade. Os testes funcionais usam `ROLLBACK` nas alterações temporárias dos dados.
