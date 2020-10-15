DROP DATABASE IF EXISTS bancario;

CREATE DATABASE bancario;

USE bancario;


/*1. [analise_criacao_objetos] Analise o script scripts/load-script.sql 
quanto a criação de objetos. Altere-o caso julgue necessário, caso necessite melhorias.*/

CREATE TABLE conta (
    numero_conta INT UNSIGNED,
    nome_cliente VARCHAR(15) NOT NULL , 
    sobrenome_cliente VARCHAR(30) NOT NULL,
    dtnasc_cliente DATE,
    dtabertura_conta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    saldo DECIMAL(10 , 2 ) NOT NULL DEFAULT 0,
    PRIMARY KEY (numero_conta)
)  ENGINE=INNODB;

CREATE TABLE movimentacao (
    numero_conta INT UNSIGNED,
    dtmovimentaçao_conta TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'NÃO USAR ISSO NA PRÁTICA!',
    valor_mov DECIMAL(10 , 2 ) NOT NULL,
    descricao_mov VARCHAR(255),
    PRIMARY KEY (numero_conta , dtmovimentaçao_conta),
    INDEX (numero_conta),
    FOREIGN KEY (numero_conta)
        REFERENCES conta (numero_conta)
)  ENGINE=INNODB;

INSERT INTO conta VALUES(12345, 'João', 'Silva', '1995-12-25', null, 0);
INSERT INTO conta VALUES(23497, 'Maria', 'Santos','1980-02-17', null, 0);
INSERT INTO conta VALUES(876, 'Pedro', 'Ferreira','1943-10-20', null, 0);
INSERT INTO conta VALUES(1236, 'Jéssica', 'Santos','1976-09-30', null, 0);
INSERT INTO conta VALUES(9875, 'Stephani','Pereira', '1990-05-07', null, 0);
INSERT INTO conta VALUES(6320, 'Paulo', 'Gomes','1987-03-24', null, 0);
INSERT INTO conta VALUES(470, 'Augusto', 'Oliveira','1995-01-15', null, 0);
INSERT INTO conta VALUES(987, 'Luana', 'Farias','1985-11-30', null, 0);

/*2. [sp_deposito] Crie uma procedure que faça um depósito na conta. As especificações dela são:*/

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_deposito
CREATE PROCEDURE sp_deposito (IN p_conta SMALLINT(5) UNSIGNED, 
                 IN p_valor DECIMAL(10 , 2))
BEGIN
    DECLARE descricao varchar(55);
    DECLARE v_saldo , c_conta int;
    
    SELECT numero_conta INTO c_conta
    FROM conta 
    WHERE numero_conta = p_conta LIMIT 1;
    
    SELECT saldo 
    INTO v_saldo
    FROM conta 
    WHERE c_conta = p_conta LIMIT 1;
    
    IF (c_conta=p_conta) THEN
        IF (p_valor>0) THEN
        
            START TRANSACTION;
                SET SQL_SAFE_UPDATES=0;
                
                UPDATE conta 
                SET saldo = saldo + p_valor 
                WHERE nr_conta = p_conta;
                SELECT CONCAT('Seu saldo',p_valor) INTO descricao;  
                INSERT INTO movimentacao (nr_conta,dtmov_conta,vl_mov,ds_mov) 
                    values(c_conta,default,p_valor,descricao);
                SET SQL_SAFE_UPDATES=1;
            COMMIT;
        ELSE
            SELECT concat(v_saldo,' Valor inválido para a operação.');
        END IF;
  
DELIMITER $$ 
DROP PROCEDURE IF EXISTS sp_saque$$
CREATE PROCEDURE sp_saque

(IN p_conta INT , saldo DECIMAL (10,2))
BEGIN 
DECLARE descricao VARCHAR (55);
   
  IF(p_valor>0) THEN 
  
START TRANSACTION;
  UPDATE p_conta SET saldo= p_saldo - p_conta WHERE numero_conta = conta ;
   SELECT CONCAT ('Saque de:' + saldo) INTO descricao;
  INSERT INTO movimentacao (data_atual, p_conta, saldo)
   values (p_data_atual, p_conta, saldo, descricao);
COMMIT;

  ELSE
     SELECT 'Valor Invalido para a operaçao';
  END IF;
  END $$
  
  DELIMITER $$ 
  DROP FUNCTION IF EXISTS f_transferencia$$
  CREATE FUNCTION f_transferencia ( p_conta_origem smallint(5) , p_conta_destino SMALLINT(5) , p_valor DECIMAL (10,2))
  BEGIN 
  DECLARE v_mensagem_resultado VARCHAR(55);
  DECLARE descricao VARCHAR (55);
  
  IF(c_conta = p_valor) THEN
	IF(p_valor>0) THEN 
	START TRANSACTION; 
    UPDATE conta FROM p_conta_origem = p_conta_origem - p_valor WHERE p_conta_destino = p_conta_origem;
    UPDATE conta FROM p_conta_destino = p_conta_destino + p_valor WHERE  p_conta_destino= p_valor;
    
    INSERT INTO movimentacao INSERT INTO movimentacao (p_conta_origem, data_atual, p_valor)
    values  (p_conta_origem, data_atual, p_valor);
     CONCAT ('Transferência para ',p_conta_destino ,' de ', p_valor) INTO descricao;
     
	INSERT INTO movimentacao INSERT INTO movimentacao  (p_conta_destino, data_atual, p_valor)
    values (p_conta_destino, data_atual, p_valor);
    CONCAT('Transferência de ' + p_conta_origem + ' de ' + p_valor) INTO descricao;
    CONCAT ('Transferência efetuada com sucesso!') INTO v_mensagem_resultado;
    RETURN v_mensagem_resultado;
COMMIT;
END IF;
 ELSE 
    CONCAT ('Valor inválido para a operação') INTO v_mensagem_resultado;
 END IF;
 ELSE 
   CONCAT ('Conta de origem inexistente.') INTO v_mensagem_resultado;
END IF
END $$ 


DELIMITER $$
DROP TRIGGER IF EXISTS t_nova_conta$$
CREATE TRIGGER t_nova_conta BEFORE INSERT ON conta
FOR EACH ROW
BEGIN
   IF (NEW.saldo < 0) THEN
      SET NEW.saldo = 0;
   END IF;
END;
$$


DELIMITER $$
DROP TRIGGER IF EXISTS t_registra_nova_conta$$
CREATE TRIGGER t_registra_nova_conta AFTER INSERT ON conta
FOR EACH ROW
BEGIN
   INSERT INTO movimentacao VALUES
      (NEW.numero_conta, NOW(), NEW.saldo, CONCAT('Conta ', NEW.numero_conta, ' aberta com ', NEW.saldo));
END;
$$

DELIMITER $$
DROP TRIGGER IF EXISTS t_altera_conta$$
CREATE TRIGGER t_altera_conta AFTER UPDATE ON conta
FOR EACH ROW
BEGIN
   INSERT INTO movimentacao VALUES
      (NEW.numero_conta
      , NOW()
      , NEW.saldo
      , CONCAT('Alteração manual de dados em '
               , NEW.numero_conta
               , '. Saldo anterior: '
               , OLD.saldo
               , '. Saldo atual: '
               , NEW.saldo
               )
      );
END;
$$
 
    
     
    
    
    
  


   
  