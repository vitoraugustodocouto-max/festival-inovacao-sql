-- Exercício - Integração Python e Java com MySQL (Floricultura)
-- Execute este script no MySQL Workbench ANTES de começar o exercício.

DROP DATABASE IF EXISTS floricultura;
CREATE DATABASE floricultura;
USE floricultura;

CREATE TABLE planta (
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	nome VARCHAR(60) NOT NULL,
	especie VARCHAR(40) NOT NULL,
	preco DECIMAL(6,2) NOT NULL,
	estoque INT NOT NULL
);

INSERT INTO planta (nome, especie, preco, estoque) VALUES
('Rosa Vermelha', 'Rosa', 12.50, 30),
('Orquídea Branca', 'Orquídea', 45.00, 8),
('Girassol', 'Girassol', 6.00, 50),
('Rosa Amarela', 'Rosa', 11.00, 20),
('Samambaia', 'Samambaia', 18.90, 12);

SELECT * FROM planta;
