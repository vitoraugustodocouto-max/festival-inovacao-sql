# Exercício — Integração com MySQL (Floricultura)

Você vai integrar uma aplicação ao banco de uma **floricultura**, que guarda as plantas à venda. Faça em **Python**, em **Java** ou nos dois (se fizer nos dois, compare as soluções).

## Preparação

1. Abra o MySQL Workbench e execute o script [`floricultura.sql`](floricultura.sql). Ele cria o banco `floricultura` com a tabela `planta` e 5 registros.
2. Confira a senha do seu MySQL em `connection_dao.py` (Python) ou em `ConnectionDAO.java` (Java).
3. **Python:** crie o ambiente virtual e instale o conector, como na aula.
   ```bash
   python -m venv venv
   venv\Scripts\activate
   pip install mysql-connector-python
   ```
   Depois abra a pasta `python/` e complete o arquivo `planta_dao.py`.
4. **Java:** abra a pasta `java/` como projeto Maven no IntelliJ (ela já tem o `pom.xml` com o driver) e complete a classe `PlantaDAO.java`.

## O que fazer

Complete as **6 funções** do DAO, no ponto indicado por `TODO`. Os arquivos de conexão e o `Main`/`main.py` já estão prontos.

| Questão | O que a função deve fazer |
|---:|---|
| 1 | Inserir uma planta (nome, espécie, preço, estoque). Em Python devolve o id gerado; em Java devolve `true`/`false`. |
| 2 | Listar todas as plantas, ordenadas pelo id. |
| 3 | Buscar as plantas de uma espécie. |
| 4 | Atualizar o preço de uma planta pelo id. Devolve se alguma linha foi alterada. |
| 5 | Remover uma planta pelo id. Devolve se alguma linha foi removida. |
| 6 *(desafio)* | Devolver o valor total do estoque: a soma de `preco * estoque` de todas as plantas. |

## Regras

- Use **sempre parâmetros** (`%s` no Python, `?` no Java). Não monte o SQL juntando texto.
- Feche o cursor/conexão (Python) ou os recursos (Java) no `finally`.
- No Python, lembre-se do `commit()` nas operações que alteram dados.

## Como conferir

Rode o `main.py` (ou o `Main.java`). Cada linha da saída traz o valor **esperado** ao lado. Com tudo certo, o resultado deve ser:

```
1. Plantas cadastradas (esperado: 5):          -> 5 plantas listadas
2. Planta inserida                             -> id 6 (Python) ou true (Java)
3. Plantas da espécie Rosa (esperado: 2):      -> Rosa Vermelha e Rosa Amarela
4. Preço do Girassol atualizado?               -> True
5. Samambaia removida?                         -> True
6. Planta 99 removida?                         -> False
7. Valor total do estoque                      -> 1705.0
8. Lista final                                 -> 5 plantas (Samambaia saiu, Lavanda entrou)
```

> Para rodar de novo do zero, execute o `floricultura.sql` outra vez: o script apaga e recria o banco.
