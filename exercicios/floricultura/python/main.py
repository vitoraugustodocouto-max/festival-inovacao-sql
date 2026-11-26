# main.py (já pronto: serve para testar as suas funções)
# Execute com: python main.py

from planta_dao import (
    atualizar_preco,
    buscar_por_especie,
    inserir_planta,
    listar_plantas,
    remover_planta,
    valor_total_estoque,
)


def mostrar(titulo, plantas):
    print(f"\n{titulo}")
    for id_, nome, especie, preco, estoque in plantas:
        print(f"  [{id_}] {nome} ({especie}) - R$ {preco} - estoque: {estoque}")


print("=== Floricultura (Python + MySQL) ===")

mostrar("1. Plantas cadastradas (esperado: 5):", listar_plantas())

novo_id = inserir_planta("Lavanda", "Lavanda", 15.00, 25)
print(f"\n2. Planta inserida com id (esperado: 6): {novo_id}")

mostrar("3. Plantas da espécie Rosa (esperado: 2):", buscar_por_especie("Rosa"))

print(f"\n4. Preço do Girassol atualizado? (esperado: True): {atualizar_preco(3, 7.50)}")
print(f"5. Samambaia removida? (esperado: True): {remover_planta(5)}")
print(f"6. Planta 99 removida? (esperado: False): {remover_planta(99)}")

print(f"\n7. Valor total do estoque (esperado: 1705.0): {valor_total_estoque()}")
mostrar("8. Lista final (esperado: 5 plantas):", listar_plantas())
