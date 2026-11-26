-- Festival de Inovacao | Testes funcionais | MySQL 8.0+
-- Executar DEPOIS dos scripts principais, com conta administradora.
-- Os totais esperados pressupõem a carga original, sem outras alteracoes.
-- Cria uma tabela TEMPORARY e uma procedure auxiliar removidas ao final.
-- Os testes de dados utilizam ROLLBACK. Os erros esperados sao tratados.
-- A procedure auxiliar qa_erro nao deve existir antes da execucao.
-- Execute o arquivo inteiro na mesma conexao.
USE festival_inovacao_segunda_entrega;

CREATE TEMPORARY TABLE qa_resultados (teste VARCHAR(200), aprovado BOOLEAN) ENGINE=MEMORY;
DELIMITER $$
CREATE PROCEDURE qa_erro(IN p_nome VARCHAR(200), IN p_sql TEXT, IN p_esperado INT)
BEGIN
  DECLARE v_erro INT DEFAULT 0;
  BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
      GET DIAGNOSTICS CONDITION 1 v_erro = MYSQL_ERRNO;
    SET @qa_sql = p_sql;
    PREPARE qa_stmt FROM @qa_sql;
    EXECUTE qa_stmt;
    DEALLOCATE PREPARE qa_stmt;
  END;
  INSERT INTO qa_resultados VALUES(p_nome, v_erro = p_esperado);
END$$
DELIMITER ;
INSERT INTO qa_resultados VALUES ('Sete tabelas do modelo', ((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_type='BASE TABLE')=7));
INSERT INTO qa_resultados VALUES ('SQL mode com ONLY_FULL_GROUP_BY', (FIND_IN_SET('ONLY_FULL_GROUP_BY',@@sql_mode)>0));
INSERT INTO qa_resultados VALUES ('Quantidade final em pessoa', ((SELECT COUNT(*) FROM pessoa)=11));
INSERT INTO qa_resultados VALUES ('Quantidade final em palestrante', ((SELECT COUNT(*) FROM palestrante)=5));
INSERT INTO qa_resultados VALUES ('Quantidade final em participante', ((SELECT COUNT(*) FROM participante)=6));
INSERT INTO qa_resultados VALUES ('Quantidade final em espaco', ((SELECT COUNT(*) FROM espaco)=5));
INSERT INTO qa_resultados VALUES ('Quantidade final em atividade', ((SELECT COUNT(*) FROM atividade)=6));
INSERT INTO qa_resultados VALUES ('Quantidade final em inscricoes_atividade', ((SELECT COUNT(*) FROM inscricoes_atividade)=16));
INSERT INTO qa_resultados VALUES ('Quantidade final em credencial', ((SELECT COUNT(*) FROM credencial)=5));
INSERT INTO qa_resultados VALUES ('Oito FKs do modelo', ((SELECT COUNT(*) FROM information_schema.referential_constraints WHERE constraint_schema=DATABASE())=8));
INSERT INTO qa_resultados VALUES ('Heranca palestrante sem orfaos', ((SELECT COUNT(*) FROM palestrante x LEFT JOIN pessoa p ON p.id_pessoa=x.id_pessoa WHERE p.id_pessoa IS NULL)=0));
INSERT INTO qa_resultados VALUES ('Heranca participante sem orfaos', ((SELECT COUNT(*) FROM participante x LEFT JOIN pessoa p ON p.id_pessoa=x.id_pessoa WHERE p.id_pessoa IS NULL)=0));
INSERT INTO qa_resultados VALUES ('Correcao de telefone por UPDATE', ((SELECT telefone FROM pessoa WHERE id_pessoa=6)='11900000006'));
INSERT INTO qa_resultados VALUES ('Cancelamento preservou o participante', ((SELECT COUNT(*) FROM participante WHERE id_pessoa=11)=1 AND (SELECT COUNT(*) FROM inscricoes_atividade WHERE id_participante=11 AND id_atividade=1)=0));
INSERT INTO qa_resultados VALUES ('Procedure criada', ((SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema=DATABASE() AND routine_type='PROCEDURE' AND routine_name='sp_registrar_checkin')=1));
INSERT INTO qa_resultados VALUES ('Function criada', ((SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema=DATABASE() AND routine_type='FUNCTION' AND routine_name='fn_percentual_presenca')=1));
INSERT INTO qa_resultados VALUES ('Trigger criado como BEFORE INSERT', ((SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema=DATABASE() AND trigger_name='trg_inscricao_data' AND action_timing='BEFORE' AND event_manipulation='INSERT')=1));
INSERT INTO qa_resultados VALUES ('View criada', ((SELECT COUNT(*) FROM information_schema.views WHERE table_schema=DATABASE() AND table_name='vw_resumo_atividades')=1));
INSERT INTO qa_resultados VALUES ('Function retorna 75 por cento', (fn_percentual_presenca(3,4)=75.00));
INSERT INTO qa_resultados VALUES ('Function arredonda para 66.67', (fn_percentual_presenca(2,3)=66.67));
INSERT INTO qa_resultados VALUES ('Function trata denominador zero', (fn_percentual_presenca(0,0)=0.00));
INSERT INTO qa_resultados VALUES ('Resumo da atividade 1', ((SELECT COUNT(*) FROM vw_resumo_atividades WHERE id_atividade=1 AND total_inscritos=4 AND total_checkins=3 AND fn_percentual_presenca(total_checkins,total_inscritos)=75)=1));
INSERT INTO qa_resultados VALUES ('Resumo da atividade 2', ((SELECT COUNT(*) FROM vw_resumo_atividades WHERE id_atividade=2 AND total_inscritos=3 AND total_checkins=0 AND fn_percentual_presenca(total_checkins,total_inscritos)=0)=1));
INSERT INTO qa_resultados VALUES ('Resumo da atividade 3', ((SELECT COUNT(*) FROM vw_resumo_atividades WHERE id_atividade=3 AND total_inscritos=3 AND total_checkins=2 AND fn_percentual_presenca(total_checkins,total_inscritos)=66.67)=1));
INSERT INTO qa_resultados VALUES ('Resumo da atividade 4', ((SELECT COUNT(*) FROM vw_resumo_atividades WHERE id_atividade=4 AND total_inscritos=3 AND total_checkins=0 AND fn_percentual_presenca(total_checkins,total_inscritos)=0)=1));
INSERT INTO qa_resultados VALUES ('Resumo da atividade 5', ((SELECT COUNT(*) FROM vw_resumo_atividades WHERE id_atividade=5 AND total_inscritos=3 AND total_checkins=1 AND fn_percentual_presenca(total_checkins,total_inscritos)=33.33)=1));
INSERT INTO qa_resultados VALUES ('Resumo da atividade 6', ((SELECT COUNT(*) FROM vw_resumo_atividades WHERE id_atividade=6 AND total_inscritos=0 AND total_checkins=0 AND fn_percentual_presenca(total_checkins,total_inscritos)=0)=1));
INSERT INTO qa_resultados VALUES ('Resultado da consulta Q1', ((SELECT COUNT(*) FROM (SELECT p.id_pessoa, p.nome, par.tipo_ingresso, c.codigo AS credencial
FROM participante AS par
INNER JOIN pessoa AS p ON p.id_pessoa = par.id_pessoa
LEFT JOIN credencial AS c ON c.id_participante = par.id_pessoa
ORDER BY p.nome) AS resultado_q1)=6));
INSERT INTO qa_resultados VALUES ('Resultado da consulta Q2', ((SELECT COUNT(*) FROM (SELECT e.id_espaco, e.nome_local, e.capacidade_maxima,
       COUNT(a.id_atividade) AS total_atividades,
       SUM(a.duracao_minutos) AS minutos_programados
FROM espaco AS e
LEFT JOIN atividade AS a ON a.id_espaco = e.id_espaco
GROUP BY e.id_espaco, e.nome_local, e.capacidade_maxima
ORDER BY total_atividades DESC, e.nome_local) AS resultado_q2)=5));
INSERT INTO qa_resultados VALUES ('Resultado da consulta Q3', ((SELECT COUNT(*) FROM (SELECT p.id_pessoa, p.nome, COUNT(i.id_atividade) AS total_inscricoes,
       SUM(a.duracao_minutos) AS minutos_inscritos,
       (SELECT COUNT(*)
        FROM inscricoes_atividade AS presenca
        WHERE presenca.id_participante = p.id_pessoa
          AND presenca.status_checkin = TRUE) AS checkins_realizados
FROM participante AS par
INNER JOIN pessoa AS p ON p.id_pessoa = par.id_pessoa
INNER JOIN inscricoes_atividade AS i ON i.id_participante = par.id_pessoa
INNER JOIN atividade AS a ON a.id_atividade = i.id_atividade
GROUP BY p.id_pessoa, p.nome
HAVING COUNT(i.id_atividade) >= 3
ORDER BY total_inscricoes DESC, p.nome) AS resultado_q3)=5));
INSERT INTO qa_resultados VALUES ('Resultado da consulta Q4', ((SELECT COUNT(*) FROM (SELECT pp.nome AS participante, c.codigo AS credencial, a.titulo AS atividade,
       e.nome_local, pl.nome AS palestrante, i.data_inscricao
FROM inscricoes_atividade AS i
INNER JOIN participante AS par ON par.id_pessoa = i.id_participante
INNER JOIN pessoa AS pp ON pp.id_pessoa = par.id_pessoa
INNER JOIN atividade AS a ON a.id_atividade = i.id_atividade
LEFT JOIN credencial AS c ON c.id_participante = par.id_pessoa
LEFT JOIN espaco AS e ON e.id_espaco = a.id_espaco
LEFT JOIN palestrante AS pal ON pal.id_pessoa = a.id_palestrante
LEFT JOIN pessoa AS pl ON pl.id_pessoa = pal.id_pessoa
WHERE i.status_checkin = TRUE
ORDER BY a.data_hora_inicio, pp.nome) AS resultado_q4)=6));
INSERT INTO qa_resultados VALUES ('Resultado da consulta Q5', ((SELECT COUNT(*) FROM (SELECT a.titulo AS atividade, pre.titulo AS prerequisito
FROM atividade AS a
INNER JOIN atividade AS pre ON pre.id_atividade = a.id_atividade_prerequisito
ORDER BY a.id_atividade) AS resultado_q5)=2));
INSERT INTO qa_resultados VALUES ('Resultado da consulta Q6', ((SELECT COUNT(*) FROM (SELECT p.id_pessoa, p.nome
FROM participante AS par
INNER JOIN pessoa AS p ON p.id_pessoa = par.id_pessoa
LEFT JOIN inscricoes_atividade AS i ON i.id_participante = par.id_pessoa
WHERE i.id_atividade IS NULL
ORDER BY p.nome) AS resultado_q6)=1));
START TRANSACTION;
UPDATE inscricoes_atividade SET status_checkin=FALSE WHERE id_participante=8 AND id_atividade=1;
CALL sp_registrar_checkin(8,1);
INSERT INTO qa_resultados VALUES ('Procedure registra presenca', ((SELECT status_checkin FROM inscricoes_atividade WHERE id_participante=8 AND id_atividade=1)=TRUE));
CALL sp_registrar_checkin(8,1);
INSERT INTO qa_resultados VALUES ('Procedure suporta repeticao', ((SELECT status_checkin FROM inscricoes_atividade WHERE id_participante=8 AND id_atividade=1)=TRUE));
CALL sp_registrar_checkin(9999,1);
INSERT INTO qa_resultados VALUES ('Procedure nao inventa inscricao', ((SELECT COUNT(*) FROM inscricoes_atividade WHERE id_participante=9999)=0));
ROLLBACK;
START TRANSACTION;
SET @antes=NOW();
INSERT INTO inscricoes_atividade(id_participante,id_atividade,status_checkin) VALUES(11,6,FALSE);
INSERT INTO qa_resultados VALUES ('Trigger preenche data omitida', ((SELECT data_inscricao IS NOT NULL AND data_inscricao BETWEEN @antes AND NOW() FROM inscricoes_atividade WHERE id_participante=11 AND id_atividade=6)));
ROLLBACK;
INSERT INTO qa_resultados VALUES ('ROLLBACK remove inscricao de teste', ((SELECT COUNT(*) FROM inscricoes_atividade WHERE id_participante=11 AND id_atividade=6)=0));
START TRANSACTION;
INSERT INTO inscricoes_atividade(id_participante,id_atividade,data_inscricao) VALUES(11,6,'2026-01-02 03:04:05');
INSERT INTO qa_resultados VALUES ('Trigger preserva data explicita', ((SELECT data_inscricao FROM inscricoes_atividade WHERE id_participante=11 AND id_atividade=6)='2026-01-02 03:04:05'));
ROLLBACK;
START TRANSACTION;
CALL qa_erro('FK impede palestrante sem pessoa', 'INSERT INTO palestrante(id_pessoa) VALUES(9999)', 1452);
ROLLBACK;
START TRANSACTION;
CALL qa_erro('FK impede participante sem pessoa', 'INSERT INTO participante(id_pessoa,tipo_ingresso) VALUES(9999,''Estudante'')', 1452);
ROLLBACK;
START TRANSACTION;
CALL qa_erro('PK composta impede inscricao repetida', 'INSERT INTO inscricoes_atividade(id_participante,id_atividade) VALUES(6,1)', 1062);
ROLLBACK;
START TRANSACTION;
CALL qa_erro('UNIQUE impede duas credenciais por participante', 'INSERT INTO credencial(codigo,id_participante) VALUES(''QA-NOVO'',6)', 1062);
ROLLBACK;
START TRANSACTION;
CALL qa_erro('UNIQUE impede codigo de credencial repetido', 'INSERT INTO credencial(codigo,id_participante) VALUES(''FEST-2026-006'',11)', 1062);
ROLLBACK;
START TRANSACTION;
CALL qa_erro('NOT NULL exige participante na credencial', 'INSERT INTO credencial(codigo,id_participante) VALUES(''QA-NULO'',NULL)', 1048);
ROLLBACK;
START TRANSACTION;
CALL qa_erro('FK exige participante na inscricao', 'INSERT INTO inscricoes_atividade(id_participante,id_atividade) VALUES(9999,1)', 1452);
ROLLBACK;
START TRANSACTION;
CALL qa_erro('FK exige atividade na inscricao', 'INSERT INTO inscricoes_atividade(id_participante,id_atividade) VALUES(11,9999)', 1452);
ROLLBACK;
START TRANSACTION;
INSERT INTO palestrante(id_pessoa) VALUES(6);
INSERT INTO qa_resultados VALUES ('Heranca permite sobreposicao', ((SELECT COUNT(*) FROM palestrante pal INNER JOIN participante par ON par.id_pessoa=pal.id_pessoa WHERE pal.id_pessoa=6)=1));
ROLLBACK;
START TRANSACTION;
DELETE FROM pessoa WHERE id_pessoa=6;
INSERT INTO qa_resultados VALUES ('CASCADE da pessoa remove subclasse e vinculos', ((SELECT COUNT(*) FROM participante WHERE id_pessoa=6)=0 AND (SELECT COUNT(*) FROM credencial WHERE id_participante=6)=0 AND (SELECT COUNT(*) FROM inscricoes_atividade WHERE id_participante=6)=0));
ROLLBACK;
START TRANSACTION;
DELETE FROM espaco WHERE id_espaco=1;
INSERT INTO qa_resultados VALUES ('SET NULL do espaco preserva atividades', ((SELECT COUNT(*) FROM atividade WHERE id_atividade IN(1,5) AND id_espaco IS NULL)=2));
ROLLBACK;
START TRANSACTION;
DELETE FROM palestrante WHERE id_pessoa=1;
INSERT INTO qa_resultados VALUES ('SET NULL do palestrante preserva atividade', ((SELECT COUNT(*) FROM atividade WHERE id_atividade=1 AND id_palestrante IS NULL)=1));
ROLLBACK;
INSERT INTO qa_resultados VALUES ('Dois usuarios locais criados', ((SELECT COUNT(*) FROM mysql.user WHERE User IN('recepcao_ana','recepcao_bruno') AND Host='localhost')=2));
INSERT INTO qa_resultados VALUES ('ROLE criada', ((SELECT COUNT(*) FROM mysql.user WHERE User='r_recepcao_festival' AND Host='%')=1));
INSERT INTO qa_resultados VALUES ('ROLE concedida aos dois usuarios', ((SELECT COUNT(*) FROM mysql.role_edges WHERE FROM_USER='r_recepcao_festival' AND FROM_HOST='%' AND TO_USER IN('recepcao_ana','recepcao_bruno') AND TO_HOST='localhost')=2));
INSERT INTO qa_resultados VALUES ('ROLE padrao dos dois usuarios', ((SELECT COUNT(*) FROM mysql.default_roles WHERE USER IN('recepcao_ana','recepcao_bruno') AND HOST='localhost' AND DEFAULT_ROLE_USER='r_recepcao_festival' AND DEFAULT_ROLE_HOST='%')=2));
INSERT INTO qa_resultados VALUES ('ROLE com SELECT no banco', ((SELECT COUNT(*) FROM mysql.db WHERE User='r_recepcao_festival' AND Host='%' AND Db=DATABASE() AND Select_priv='Y' AND Insert_priv='N' AND Delete_priv='N' AND Update_priv='N')=1));
INSERT INTO qa_resultados VALUES ('ROLE com UPDATE somente no checkin', ((SELECT COUNT(*) FROM mysql.columns_priv WHERE User='r_recepcao_festival' AND Db=DATABASE() AND Table_name='inscricoes_atividade' AND Column_name='status_checkin' AND FIND_IN_SET('Update',Column_priv)>0)=1));
INSERT INTO qa_resultados VALUES ('ROLE com EXECUTE nas duas rotinas', ((SELECT COUNT(*) FROM mysql.procs_priv WHERE User='r_recepcao_festival' AND Db=DATABASE() AND FIND_IN_SET('Execute',Proc_priv)>0)=2));
INSERT INTO qa_resultados VALUES ('Carga final preservada apos os testes', ((SELECT COUNT(*) FROM inscricoes_atividade)=16 AND (SELECT COUNT(*) FROM pessoa)=11 AND (SELECT COUNT(*) FROM palestrante)=5 AND (SELECT COUNT(*) FROM participante)=6 AND (SELECT COUNT(*) FROM atividade)=6 AND (SELECT COUNT(*) FROM espaco)=5 AND (SELECT COUNT(*) FROM credencial)=5));
SELECT teste, aprovado FROM qa_resultados ORDER BY teste;
SELECT COUNT(*) AS total_testes, SUM(aprovado=1) AS aprovados,
       SUM(aprovado=0 OR aprovado IS NULL) AS reprovados FROM qa_resultados;
DROP PROCEDURE qa_erro;
DROP TEMPORARY TABLE qa_resultados;
