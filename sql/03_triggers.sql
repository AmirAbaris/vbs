USE vbs_bank;

DELIMITER $$

DROP TRIGGER IF EXISTS trg_accounts_after_status_update$$
DROP TRIGGER IF EXISTS trg_customers_after_status_update$$
DROP TRIGGER IF EXISTS trg_transactions_before_insert_validate$$
DROP TRIGGER IF EXISTS trg_loans_before_update_remaining$$
DROP TRIGGER IF EXISTS trg_users_before_insert_role_customer$$
DROP TRIGGER IF EXISTS trg_users_before_update_role_customer$$

CREATE TRIGGER trg_users_before_insert_role_customer
BEFORE INSERT ON users
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

CREATE TRIGGER trg_accounts_after_status_update
AFTER UPDATE ON accounts
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
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

CREATE TRIGGER trg_transactions_before_insert_validate
BEFORE INSERT ON transactions
FOR EACH ROW
BEGIN
    IF NEW.amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Transaction amount must be positive';
    END IF;

    IF NEW.transaction_type = 'DEPOSIT'
       AND (NEW.source_account_id IS NOT NULL OR NEW.destination_account_id IS NULL) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Deposit must have only a destination account';
    END IF;

    IF NEW.transaction_type IN ('WITHDRAWAL', 'FEE')
       AND (NEW.source_account_id IS NULL OR NEW.destination_account_id IS NOT NULL) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Withdrawal and fee must have only a source account';
    END IF;

    IF NEW.transaction_type = 'TRANSFER'
       AND (NEW.source_account_id IS NULL OR NEW.destination_account_id IS NULL) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Transfer must have both source and destination accounts';
    END IF;

    IF NEW.transaction_type = 'TRANSFER'
       AND NEW.source_account_id = NEW.destination_account_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Transfer source and destination accounts must be different';
    END IF;

    IF NEW.transaction_type = 'LOAN_PAYMENT'
       AND (NEW.source_account_id IS NULL OR NEW.destination_account_id IS NOT NULL) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loan payment must have only a source account';
    END IF;
END$$

CREATE TRIGGER trg_loans_before_update_remaining
BEFORE UPDATE ON loans
FOR EACH ROW
BEGIN
    IF NEW.remaining_balance < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loan remaining balance cannot be negative';
    END IF;

    IF NEW.remaining_balance = 0 THEN
        SET NEW.status = 'PAID_OFF';
    END IF;
END$$

DELIMITER ;
