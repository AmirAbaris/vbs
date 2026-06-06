-- Recreates the whole demo database from zero.
DROP DATABASE IF EXISTS vbs_bank;

-- utf8mb4 supports normal text plus emojis/special characters.
CREATE DATABASE vbs_bank CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- All commands after this run inside the vbs_bank database.
USE vbs_bank;

-- Branches are bank office locations.
CREATE TABLE branches (
    branch_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    city VARCHAR(80) NOT NULL,
    address VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    status ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_branches_phone UNIQUE (phone)
-- InnoDB supports transactions, foreign keys, and row locking in MySQL.
) ENGINE=InnoDB;

-- Customers are the people who own accounts and loans.
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    national_code VARCHAR(10) NOT NULL,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    birth_date DATE NOT NULL,
    mobile VARCHAR(15) NOT NULL,
    email VARCHAR(120) NOT NULL,
    address VARCHAR(255) NOT NULL,
    status ENUM('ACTIVE', 'SUSPENDED', 'CLOSED') NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- constraints are used to enforce the rules on the data
    CONSTRAINT uq_customers_national_code UNIQUE (national_code),
    CONSTRAINT uq_customers_mobile UNIQUE (mobile),
    CONSTRAINT uq_customers_email UNIQUE (email),
    CONSTRAINT chk_customers_national_code CHECK (national_code REGEXP '^[0-9]{10}$'),
    CONSTRAINT chk_customers_mobile CHECK (mobile REGEXP '^09[0-9]{9}$'),
    CONSTRAINT chk_customers_birth_date CHECK (birth_date BETWEEN '1900-01-01' AND '2010-12-31')
) ENGINE=InnoDB;

-- Users are login accounts. A user can be a customer or an admin.
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    -- NULL is allowed because admins are not linked to a customer.
    customer_id INT NULL,
    username VARCHAR(60) NOT NULL,
    password_hash CHAR(64) NOT NULL,
    role ENUM('CUSTOMER', 'ADMIN') NOT NULL,
    status ENUM('ACTIVE', 'LOCKED', 'DISABLED') NOT NULL DEFAULT 'ACTIVE',
    failed_login_count INT NOT NULL DEFAULT 0,
    last_login_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_users_username UNIQUE (username),
    -- FOREIGN KEY connects this table to customers.
    CONSTRAINT fk_users_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        -- If a customer id changes, update it here too.
        ON UPDATE CASCADE
        -- Do not delete a customer if a user still points to it.
        ON DELETE RESTRICT,
    CONSTRAINT chk_users_failed_login_count CHECK (failed_login_count >= 0)
) ENGINE=InnoDB;

-- Accounts store the customer's money balance.
CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    branch_id INT NOT NULL,
    account_number VARCHAR(20) NOT NULL,
    account_type ENUM('CHECKING', 'SAVINGS', 'BUSINESS') NOT NULL,
    balance DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    status ENUM('ACTIVE', 'FROZEN', 'CLOSED') NOT NULL DEFAULT 'ACTIVE',
    opened_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_accounts_account_number UNIQUE (account_number),
    -- Each account belongs to one customer.
    CONSTRAINT fk_accounts_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    -- Each account is opened at one branch.
    CONSTRAINT fk_accounts_branch FOREIGN KEY (branch_id)
        REFERENCES branches(branch_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_accounts_balance CHECK (balance >= 0)
) ENGINE=InnoDB;

-- Transactions are the history of deposits, withdrawals, transfers, and loan payments.
CREATE TABLE transactions (
    -- BIGINT is a large integer type that can store very large numbers.
    transaction_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    source_account_id INT NULL,
    destination_account_id INT NULL,
    amount DECIMAL(18,2) NOT NULL,
    transaction_type ENUM('DEPOSIT', 'WITHDRAWAL', 'TRANSFER', 'FEE', 'LOAN_PAYMENT') NOT NULL,
    status ENUM('PENDING', 'SUCCESS', 'FAILED') NOT NULL DEFAULT 'PENDING',
    description VARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- Source account is used for money leaving an account.
    CONSTRAINT fk_transactions_source_account FOREIGN KEY (source_account_id)
        REFERENCES accounts(account_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    -- Destination account is used for money entering an account.
    CONSTRAINT fk_transactions_destination_account FOREIGN KEY (destination_account_id)
        REFERENCES accounts(account_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_transactions_amount CHECK (amount > 0)
) ENGINE=InnoDB;

-- Loans store borrowed money and the remaining amount to repay.
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    repayment_account_id INT NOT NULL,
    principal_amount DECIMAL(18,2) NOT NULL,
    annual_interest_rate DECIMAL(5,2) NOT NULL,
    term_months INT NOT NULL,
    remaining_balance DECIMAL(18,2) NOT NULL,
    status ENUM('ACTIVE', 'PAID_OFF', 'DEFAULTED', 'CANCELLED') NOT NULL DEFAULT 'ACTIVE',
    start_date DATE NOT NULL,
    due_date DATE NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_loans_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_loans_repayment_account FOREIGN KEY (repayment_account_id)
        REFERENCES accounts(account_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_loans_principal CHECK (principal_amount > 0),
    CONSTRAINT chk_loans_interest CHECK (annual_interest_rate BETWEEN 0 AND 100),
    CONSTRAINT chk_loans_term CHECK (term_months > 0),
    CONSTRAINT chk_loans_remaining CHECK (remaining_balance >= 0),
    CONSTRAINT chk_loans_remaining_max CHECK (remaining_balance <= principal_amount),
    CONSTRAINT chk_loans_dates CHECK (due_date > start_date)
) ENGINE=InnoDB;

-- Loan payments store each payment made toward a loan.
CREATE TABLE loan_payments (
    payment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    account_id INT NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    paid_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_loan_payments_loan FOREIGN KEY (loan_id)
        REFERENCES loans(loan_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_loan_payments_account FOREIGN KEY (account_id)
        REFERENCES accounts(account_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_loan_payments_amount CHECK (amount > 0)
) ENGINE=InnoDB;

-- Audit logs store important events for reporting/security history.
CREATE TABLE audit_logs (
    audit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NULL,
    event_type VARCHAR(80) NOT NULL,
    entity_name VARCHAR(80) NOT NULL,
    entity_id BIGINT NULL,
    old_value VARCHAR(255) NULL,
    new_value VARCHAR(255) NULL,
    description VARCHAR(500) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_logs_user FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON UPDATE CASCADE
        -- If a user is deleted, keep the log but clear user_id.
        ON DELETE SET NULL
) ENGINE=InnoDB;
