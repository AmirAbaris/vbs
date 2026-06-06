USE vbs_bank;

-- DELIMITER changes the statement ending from ; to $$.
-- This lets MySQL read a full trigger body that contains many ; lines.
DELIMITER $$

-- Drop old triggers first so the script can be run again without errors.
DROP TRIGGER IF EXISTS trg_accounts_after_status_update$$
DROP TRIGGER IF EXISTS trg_customers_after_status_update$$
DROP TRIGGER IF EXISTS trg_transactions_before_insert_validate$$
DROP TRIGGER IF EXISTS trg_loans_before_update_remaining$$
DROP TRIGGER IF EXISTS trg_users_before_insert_role_customer$$
DROP TRIGGER IF EXISTS trg_users_before_update_role_customer$$

-- BEFORE INSERT runs before a new user row is saved.
CREATE TRIGGER trg_users_before_insert_role_customer
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    -- NEW means the new row being inserted or updated.
    IF NEW.role = 'CUSTOMER' AND NEW.customer_id IS NULL THEN
        -- SIGNAL stops the insert/update and shows an error message.
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Customer users must reference a customer';
    END IF;

    IF NEW.role = 'ADMIN' AND NEW.customer_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Admin users cannot reference a customer';
    END IF;
END$$

-- Same rule as insert, but this checks changes to existing users.
CREATE TRIGGER trg_users_before_update_role_customer
BEFORE UPDATE ON users
FOR EACH ROW
BEGIN
    IF NEW.role = 'CUSTOMER' AND NEW.customer_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Customer users must reference a customer';
    END IF;

    IF NEW.role = 'ADMIN' AND NEW.customer_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Admin users cannot reference a customer';
    END IF;
END$$

-- AFTER UPDATE runs after an account row is changed.
CREATE TRIGGER trg_accounts_after_status_update
AFTER UPDATE ON accounts
FOR EACH ROW
BEGIN
    -- OLD is the value before update, NEW is the value after update.
    IF OLD.status <> NEW.status THEN
        -- Save status changes into audit_logs for history.
        INSERT INTO audit_logs (
            user_id, event_type, entity_name, entity_id,
            old_value, new_value, description
        )
        VALUES (
            NULL, 'ACCOUNT_STATUS_CHANGED', 'accounts', NEW.account_id,
            OLD.status, NEW.status,
            CONCAT('Account ', NEW.account_number, ' status changed')
        );
    END IF;
END$$

-- Save customer status changes into audit_logs.
CREATE TRIGGER trg_customers_after_status_update
AFTER UPDATE ON customers
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO audit_logs (
            user_id, event_type, entity_name, entity_id,
            old_value, new_value, description
        )
        VALUES (
            NULL, 'CUSTOMER_STATUS_CHANGED', 'customers', NEW.customer_id,
            OLD.status, NEW.status,
            CONCAT('Customer ', NEW.national_code, ' status changed')
        );
    END IF;
END$$

-- Validate the account columns before a transaction is inserted.
CREATE TRIGGER trg_transactions_before_insert_validate
BEFORE INSERT ON transactions
FOR EACH ROW
BEGIN
    -- Every transaction must have a positive amount.
    IF NEW.amount IS NULL OR NEW.amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Transaction amount must be positive';
    END IF;

    -- Deposit: money enters one destination account.
    IF NEW.transaction_type = 'DEPOSIT'
       AND (NEW.source_account_id IS NOT NULL OR NEW.destination_account_id IS NULL) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Deposit must have only a destination account';
    END IF;

    -- Withdrawal/Fee: money leaves one source account.
    IF NEW.transaction_type IN ('WITHDRAWAL', 'FEE')
       AND (NEW.source_account_id IS NULL OR NEW.destination_account_id IS NOT NULL) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Withdrawal and fee must have only a source account';
    END IF;

    -- Transfer: money moves from one account to another.
    IF NEW.transaction_type = 'TRANSFER'
       AND (NEW.source_account_id IS NULL OR NEW.destination_account_id IS NULL) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Transfer must have both source and destination accounts';
    END IF;

    -- Do not allow transferring to the same account.
    IF NEW.transaction_type = 'TRANSFER'
       AND NEW.source_account_id = NEW.destination_account_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Transfer source and destination accounts must be different';
    END IF;

    -- Loan payment: money leaves the payment account.
    IF NEW.transaction_type = 'LOAN_PAYMENT'
       AND (NEW.source_account_id IS NULL OR NEW.destination_account_id IS NOT NULL) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loan payment must have only a source account';
    END IF;
END$$

-- When a loan is updated, keep the loan status consistent with its balance.
CREATE TRIGGER trg_loans_before_update_remaining
BEFORE UPDATE ON loans
FOR EACH ROW
BEGIN
    -- Remaining loan balance cannot go below zero.
    IF NEW.remaining_balance < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loan remaining balance cannot be negative';
    END IF;

    -- If the loan is fully paid, automatically mark it as PAID_OFF.
    IF NEW.remaining_balance = 0 THEN
        SET NEW.status = 'PAID_OFF';
    END IF;
END$$

-- Change the delimiter back to normal SQL.
DELIMITER ;
