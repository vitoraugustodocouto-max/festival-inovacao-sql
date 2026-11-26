# planta_dao.py — solução das seis questões
# SQL parametrizado; cursor e conexão fechados no finally.

from mysql.connector import Error

from connection_dao import close_connection, get_connection


# Questão 1
def inserir_planta(nome, especie, preco, estoque):
    """Insere uma planta e devolve o ID gerado."""
    connection = None
    cursor = None
    try:
        connection = get_connection()
        if connection is None:
            raise Error("Não foi possível conectar ao banco floricultura.")
        cursor = connection.cursor()
        cursor.execute(
            "INSERT INTO planta (nome, especie, preco, estoque) VALUES (%s, %s, %s, %s)",
            (nome, especie, preco, estoque)
        )
        connection.commit()
        return cursor.lastrowid
    except Error:
        if connection is not None:
            connection.rollback()
        raise
    finally:
        close_connection(connection, cursor)


# Questão 2
def listar_plantas():
    """Lista todas as plantas como tuplas, em ordem de ID."""
    connection = None
    cursor = None
    try:
        connection = get_connection()
        if connection is None:
            raise Error("Não foi possível conectar ao banco floricultura.")
        cursor = connection.cursor()
        cursor.execute(
            "SELECT id, nome, especie, preco, estoque FROM planta ORDER BY id"
        )
        return cursor.fetchall()
    finally:
        close_connection(connection, cursor)


# Questão 3
def buscar_por_especie(especie):
    """Busca plantas cuja espécie seja igual ao parâmetro."""
    connection = None
    cursor = None
    try:
        connection = get_connection()
        if connection is None:
            raise Error("Não foi possível conectar ao banco floricultura.")
        cursor = connection.cursor()
        cursor.execute(
            "SELECT id, nome, especie, preco, estoque FROM planta WHERE especie = %s ORDER BY id",
            (especie,)
        )
        return cursor.fetchall()
    finally:
        close_connection(connection, cursor)


# Questão 4
def atualizar_preco(id_planta, novo_preco):
    """Devolve True quando alguma linha tem o preço alterado."""
    connection = None
    cursor = None
    try:
        connection = get_connection()
        if connection is None:
            raise Error("Não foi possível conectar ao banco floricultura.")
        cursor = connection.cursor()
        cursor.execute(
            "UPDATE planta SET preco = %s WHERE id = %s",
            (novo_preco, id_planta)
        )
        connection.commit()
        return cursor.rowcount > 0
    except Error:
        if connection is not None:
            connection.rollback()
        raise
    finally:
        close_connection(connection, cursor)


# Questão 5
def remover_planta(id_planta):
    """Devolve True quando alguma planta é removida."""
    connection = None
    cursor = None
    try:
        connection = get_connection()
        if connection is None:
            raise Error("Não foi possível conectar ao banco floricultura.")
        cursor = connection.cursor()
        cursor.execute(
            "DELETE FROM planta WHERE id = %s",
            (id_planta,)
        )
        connection.commit()
        return cursor.rowcount > 0
    except Error:
        if connection is not None:
            connection.rollback()
        raise
    finally:
        close_connection(connection, cursor)


# Questão 6
def valor_total_estoque():
    """Calcula a soma de preço × estoque como float; estoque vazio retorna 0.0."""
    connection = None
    cursor = None
    try:
        connection = get_connection()
        if connection is None:
            raise Error("Não foi possível conectar ao banco floricultura.")
        cursor = connection.cursor()
        cursor.execute(
            "SELECT COALESCE(SUM(preco * estoque), 0) FROM planta"
        )
        return float(cursor.fetchone()[0])
    finally:
        close_connection(connection, cursor)
