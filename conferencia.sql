-- Festival de Inovacao | Conferencia posterior a instalacao | MySQL 8.0
-- Executar com a conta administradora, depois dos dois scripts principais.
-- Apenas consultas: nao cria nem altera registros.
USE festival_inovacao_segunda_entrega;

-- Todas as sete tabelas devem apresentar pelo menos cinco registros.
SELECT 'pessoa' AS tabela, COUNT(*) AS total FROM pessoa
UNION ALL SELECT 'palestrante', COUNT(*) FROM palestrante
UNION ALL SELECT 'participante', COUNT(*) FROM participante
UNION ALL SELECT 'espaco', COUNT(*) FROM espaco
UNION ALL SELECT 'atividade', COUNT(*) FROM atividade
UNION ALL SELECT 'inscricoes_atividade', COUNT(*) FROM inscricoes_atividade
UNION ALL SELECT 'credencial', COUNT(*) FROM credencial;

-- Devem existir uma procedure e uma function no banco.
SELECT ROUTINE_NAME, ROUTINE_TYPE
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = DATABASE()
ORDER BY ROUTINE_TYPE, ROUTINE_NAME;

-- Deve existir o trigger BEFORE INSERT da tabela de inscricoes.
SELECT TRIGGER_NAME, ACTION_TIMING, EVENT_MANIPULATION, EVENT_OBJECT_TABLE
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = DATABASE();

-- A view deve apresentar seis atividades.
SELECT id_atividade, titulo, total_inscritos, total_checkins,
       fn_percentual_presenca(total_checkins, total_inscritos) AS percentual_presenca
FROM vw_resumo_atividades
ORDER BY id_atividade;

-- Resultados esperados: 75.00, 66.67 e 0.00.
SELECT fn_percentual_presenca(3, 4) AS tres_de_quatro,
       fn_percentual_presenca(2, 3) AS dois_de_tres,
       fn_percentual_presenca(0, 0) AS sem_inscritos;

-- Heranca: cinco palestrantes e seis participantes, com os dados da pessoa.
SELECT p.id_pessoa, p.nome, pal.area_especialidade
FROM pessoa AS p
INNER JOIN palestrante AS pal ON pal.id_pessoa = p.id_pessoa
ORDER BY p.id_pessoa;
SELECT p.id_pessoa, p.nome, par.tipo_ingresso
FROM pessoa AS p
INNER JOIN participante AS par ON par.id_pessoa = p.id_pessoa
ORDER BY p.id_pessoa;

-- Mostra as permissoes efetivas por meio da ROLE (conta administradora).
SHOW GRANTS FOR 'r_recepcao_festival'@'%';
SHOW GRANTS FOR 'recepcao_ana'@'localhost' USING 'r_recepcao_festival'@'%';
SHOW GRANTS FOR 'recepcao_bruno'@'localhost' USING 'r_recepcao_festival'@'%';

-- Em NOVAS conexoes individuais, entrar com cada usuario de recepcao e executar:
-- SELECT CURRENT_USER(), CURRENT_ROLE();
-- SELECT * FROM festival_inovacao_segunda_entrega.vw_resumo_atividades;
-- SELECT festival_inovacao_segunda_entrega.fn_percentual_presenca(3, 4);
-- CALL festival_inovacao_segunda_entrega.sp_registrar_checkin(8, 1);
