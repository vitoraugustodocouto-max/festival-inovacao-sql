# Exercício — Floricultura (Python + MySQL)

Solução das seis questões de Banco de Dados, usando os arquivos fornecidos pelo monitor.

## Arquivos

- [Enunciado.md](Enunciado.md): enunciado original.
- [floricultura.sql](floricultura.sql): script original com a tabela e os cinco registros.
- [python/planta_dao.py](python/planta_dao.py): as seis funções resolvidas.
- [python/connection_dao.py](python/connection_dao.py): conexão original, configurável por variáveis de ambiente.
- [python/main.py](python/main.py): demonstração original do monitor.
- [saida_validacao.txt](saida_validacao.txt): saída obtida na execução real.

## Como executar

1. No MySQL Workbench, execute `floricultura.sql`. **O script original apaga e recria o banco `floricultura`**, portanto use um banco de exercício.
2. Abra um terminal na pasta `python/`.
3. Crie e ative um ambiente virtual:

```powershell
python -m venv venv
venv\Scripts\Activate.ps1
```

No Linux/macOS, a ativação é `source venv/bin/activate`. No Prompt de Comando do Windows, use `venv\Scripts\activate.bat`.

4. Instale a dependência:

```sh
python -m pip install -r requirements.txt
```

5. Configure a senha do seu MySQL, por exemplo no PowerShell:

```powershell
$env:DB_PASSWORD = "sua_senha_local"
python main.py
```

A conexão original usa, por padrão, `localhost`, porta `3306`, usuário `root`, senha de exemplo `root` e banco `floricultura`. É possível configurar `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD` e `DB_NAME`. Não publique sua senha real.

Para repetir a saída esperada do zero, execute novamente o script SQL antes do `main.py`.

## Resolução

| Questão | Função | Implementação e retorno |
| --- | --- | --- |
| 1 | `inserir_planta` | `INSERT` parametrizado, `commit()` e ID gerado. |
| 2 | `listar_plantas` | `SELECT` ordenado por ID, retornando tuplas. |
| 3 | `buscar_por_especie` | `SELECT` com igualdade de espécie e parâmetro `%s`. |
| 4 | `atualizar_preco` | `UPDATE` por ID, `commit()` e `cursor.rowcount > 0`. |
| 5 | `remover_planta` | `DELETE` por ID, `commit()` e `cursor.rowcount > 0`. |
| 6 | `valor_total_estoque` | `COALESCE(SUM(preco * estoque), 0)`, convertido para `float`. |

Todas as funções fecham cursor e conexão no `finally`, usando a função original `close_connection`. As operações de escrita executam `rollback()` se ocorrer erro SQL e propagam o erro. Uma falha de conexão também gera erro, em vez de parecer uma consulta vazia ou um total zero. Atualizar para o mesmo preço pode retornar `False`, pois nenhuma linha teve seu valor alterado.

## Resultado conferido

O `main.py` original foi executado com **MariaDB 11.8.9** e **mysql-connector-python 26.10.0**, em uma instância temporária, usando o SQL original. MariaDB foi usado na validação por ser compatível com o SQL deste exercício; não foi uma execução no MySQL Workbench.

- 5 plantas iniciais; Lavanda inserida com ID 6.
- 2 plantas da espécie Rosa.
- Girassol atualizado e Samambaia removida: `True`.
- Remoção da planta 99: `False`.
- Total do estoque: **1705.0**.
- 5 plantas na listagem final; alterações confirmadas em uma nova conexão.

O cálculo final é `12,50 × 30 + 45,00 × 8 + 7,50 × 50 + 11,00 × 20 + 15,00 × 25 = 1705,00`.

Os arquivos `Enunciado.md`, `floricultura.sql`, `python/main.py`, `python/connection_dao.py` e `python/requirements.txt` foram mantidos iguais aos anexos do monitor.
