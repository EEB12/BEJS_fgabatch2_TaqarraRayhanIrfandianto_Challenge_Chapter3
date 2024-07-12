CREATE TABLE customers (
    id_cust SERIAL PRIMARY KEY,
    name VARCHAR(100),
    birth_date DATE,
    phone_number VARCHAR(20),
    address VARCHAR(100),
    parent_name VARCHAR(100)
);
CREATE TABLE accounts (
    id_acc SERIAL PRIMARY KEY,
    acc_number VARCHAR(20) UNIQUE,
    acc_name VARCHAR(100),
    acc_balance float,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    id_cust INT,
    CONSTRAINT fk_accounts_customer FOREIGN KEY (id_cust) REFERENCES customers (id_cust)
);

CREATE TABLE transaction_types (
    id_type SERIAL PRIMARY KEY,
    name VARCHAR(50),
    description TEXT
);

CREATE TABLE transactions (
    id_transaction SERIAL PRIMARY KEY,
    id_acc INT,
    id_type INT,
    amount NUMERIC,
    transaction_date TIMESTAMP,
    description TEXT,
    CONSTRAINT fk_transactions_account FOREIGN KEY (id_acc) REFERENCES accounts (id_acc),
    CONSTRAINT fk_transactions_type FOREIGN KEY (id_type) REFERENCES transaction_types (id_type)
);

CREATE OR REPLACE FUNCTION update_account_balance()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT name FROM transaction_types WHERE id_type = NEW.id_type) = 'Deposit' THEN
        UPDATE accounts
        SET acc_balance = acc_balance + NEW.amount
        WHERE id_acc = NEW.id_acc;
    ELSIF (SELECT name FROM transaction_types WHERE id_type = NEW.id_type) = 'Withdrawal' THEN
        UPDATE accounts
        SET acc_balance = acc_balance - NEW.amount
        WHERE id_acc = NEW.id_acc;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_transaction_insert
AFTER INSERT ON transactions
FOR EACH ROW
EXECUTE FUNCTION update_account_balance();


INSERT INTO customers (name, birth_date, phone_number, address, parent_name)
VALUES 
('rayhan', '1980-01-01', '123-456-7890', 'JL. Soehat', 'ibunya rayhan'),
('irfandianto', '1990-02-02', '987-654-3210', 'JL. Soekarno', 'ibunya irfan');

INSERT INTO transaction_types (name, description)
VALUES 
('Deposit', 'deposit money to the account'),
('Withdrawal', 'withdraw money fromaccount');



INSERT INTO accounts (acc_number, acc_name, acc_balance, created_at, updated_at, id_cust)
VALUES 
('1234567890', 'rayhan', 1000.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1),
('9876543210', 'irfan', 2000.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 2),
('1345666323', 'rayhan amtp', 1000.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1);


INSERT INTO transactions (id_acc, id_type, amount, transaction_date, description)
VALUES 
(1, 1, 500.00, CURRENT_TIMESTAMP, 'Deposit to savings account'),
(2, 2, 200.00, CURRENT_TIMESTAMP, 'ATM Withdrawal from account'),
(3, 1, 700.00, CURRENT_TIMESTAMP, 'Deposit to savings account');


SELECT t.id_transaction, a.acc_name, a.acc_balance, tt.name AS transaction_type_name, t.amount, t.transaction_date,t.description
FROM 
    transactions t
JOIN 
    accounts a ON t.id_acc = a.id_acc
JOIN 
    transaction_types tt ON t.id_type = tt.id_type;

