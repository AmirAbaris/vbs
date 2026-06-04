USE vbs_bank;

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_deposit$$
DROP PROCEDURE IF EXISTS sp_withdraw$$
DROP PROCEDURE IF EXISTS sp_transfer$$
DROP PROCEDURE IF EXISTS sp_pay_loan$$
DROP PROCEDURE IF EXISTS sp_record_login_attempt$$
DROP PROCEDURE IF EXISTS sp_check_account_status$$

CREATE PROCEDURE sp_deposit(
    IN p_destination_account_id INT,
    IN p_amount DECIMAL(18,2),
    IN p_description VARCHAR(255)
)
BEGIN
    DECLARE v_status VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Deposit amount must be positive';
    END IF;

    START TRANSACTION;

    SELECT status
    INTO v_status
    FROM accounts
    WHERE account_id = p_destination_account_id
    FOR UPDATE;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Destination account not found';
    END IF;

    IF v_status <> 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Destination account is not active';
    END IF;

    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_destination_account_id;

    INSERT INTO transactions (
        source_account_id, destination_account_id, amount,
        transaction_type, status, description
    )
    VALUES (
        NULL, p_destination_account_id, p_amount,
        'DEPOSIT', 'SUCCESS', p_description
    );

    INSERT INTO audit_logs (event_type, entity_name, entity_id, new_value, description)
    VALUES ('DEPOSIT_COMPLETED', 'accounts', p_destination_account_id, p_amount, p_description);

    COMMIT;
END$$

CREATE PROCEDURE sp_withdraw(
    IN p_source_account_id INT,
    IN p_amount DECIMAL(18,2),
    IN p_description VARCHAR(255)
)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_balance DECIMAL(18,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Withdrawal amount must be positive';
    END IF;

    START TRANSACTION;

    SELECT status, balance
    INTO v_status, v_balance
    FROM accounts
    WHERE account_id = p_source_account_id
    FOR UPDATE;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Source account not found';
    END IF;

    IF v_status <> 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Source account is not active';
    END IF;

    IF v_balance < p_amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance';
    END IF;

    UPDATE accounts
    SET balance = balance - p_amount
    WHERE account_id = p_source_account_id;

    INSERT INTO transactions (
        source_account_id, destination_account_id, amount,
        transaction_type, status, description
    )
    VALUES (
        p_source_account_id, NULL, p_amount,
        'WITHDRAWAL', 'SUCCESS', p_description
    );

    INSERT INTO audit_logs (event_type, entity_name, entity_id, old_value, new_value, description)
    VALUES ('WITHDRAWAL_COMPLETED', 'accounts', p_source_account_id, v_balance, v_balance - p_amount, p_description);

    COMMIT;
END$$

CREATE PROCEDURE sp_transfer(
    IN p_source_account_id INT,
    IN p_destination_account_id INT,
    IN p_amount DECIMAL(18,2),
    IN p_description VARCHAR(255)
)
BEGIN
    DECLARE v_source_status VARCHAR(20);
    DECLARE v_destination_status VARCHAR(20);
    DECLARE v_source_balance DECIMAL(18,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transfer amount must be positive';
    END IF;

    IF p_source_account_id = p_destination_account_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transfer accounts must be different';
    END IF;

    START TRANSACTION;

    IF p_source_account_id < p_destination_account_id THEN
        SELECT status, balance
        INTO v_source_status, v_source_balance
        FROM accounts
        WHERE account_id = p_source_account_id
        FOR UPDATE;

        SELECT status
        INTO v_destination_status
        FROM accounts
        WHERE account_id = p_destination_account_id
        FOR UPDATE;
    ELSE
        SELECT status
        INTO v_destination_status
        FROM accounts
        WHERE account_id = p_destination_account_id
        FOR UPDATE;

        SELECT status, balance
        INTO v_source_status, v_source_balance
        FROM accounts
        WHERE account_id = p_source_account_id
        FOR UPDATE;
    END IF;

    IF v_source_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Source account not found';
    END IF;

    IF v_destination_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Destination account not found';
    END IF;

    IF v_source_status <> 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Source account is not active';
    END IF;

    IF v_destination_status <> 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Destination account is not active';
    END IF;

    IF v_source_balance < p_amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance';
    END IF;

    UPDATE accounts
    SET balance = balance - p_amount
    WHERE account_id = p_source_account_id;

    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_destination_account_id;

    INSERT INTO transactions (
        source_account_id, destination_account_id, amount,
        transaction_type, status, description
    )
    VALUES (
        p_source_account_id, p_destination_account_id, p_amount,
        'TRANSFER', 'SUCCESS', p_description
    );

    INSERT INTO audit_logs (event_type, entity_name, entity_id, description)
    VALUES ('TRANSFER_COMPLETED', 'transactions', LAST_INSERT_ID(), CONCAT('Transfer from account ', p_source_account_id, ' to account ', p_destination_account_id, ': ', p_description));

    COMMIT;
END$$

CREATE PROCEDURE sp_pay_loan(
    IN p_loan_id INT,
    IN p_account_id INT,
    IN p_amount DECIMAL(18,2),
    IN p_description VARCHAR(255)
)
BEGIN
    DECLARE v_account_status VARCHAR(20);
    DECLARE v_account_balance DECIMAL(18,2);
    DECLARE v_loan_status VARCHAR(20);
    DECLARE v_remaining_balance DECIMAL(18,2);
    DECLARE v_payment_amount DECIMAL(18,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loan payment amount must be positive';
    END IF;

    START TRANSACTION;

    SELECT status, balance
    INTO v_account_status, v_account_balance
    FROM accounts
    WHERE account_id = p_account_id
    FOR UPDATE;

    SELECT status, remaining_balance
    INTO v_loan_status, v_remaining_balance
    FROM loans
    WHERE loan_id = p_loan_id
    FOR UPDATE;

    IF v_account_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payment account not found';
    END IF;

    IF v_loan_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loan not found';
    END IF;

    IF v_account_status <> 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payment account is not active';
    END IF;

    IF v_loan_status <> 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loan is not active';
    END IF;

    SET v_payment_amount = LEAST(p_amount, v_remaining_balance);

    IF v_account_balance < v_payment_amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance for loan payment';
    END IF;

    UPDATE accounts
    SET balance = balance - v_payment_amount
    WHERE account_id = p_account_id;

    UPDATE loans
    SET remaining_balance = remaining_balance - v_payment_amount
    WHERE loan_id = p_loan_id;

    INSERT INTO loan_payments (loan_id, account_id, amount)
    VALUES (p_loan_id, p_account_id, v_payment_amount);

    INSERT INTO transactions (
        source_account_id, destination_account_id, amount,
        transaction_type, status, description
    )
    VALUES (
        p_account_id, NULL, v_payment_amount,
        'LOAN_PAYMENT', 'SUCCESS', p_description
    );

    INSERT INTO audit_logs (event_type, entity_name, entity_id, old_value, new_value, description)
    VALUES ('LOAN_PAYMENT_COMPLETED', 'loans', p_loan_id, v_remaining_balance, v_remaining_balance - v_payment_amount, p_description);

    COMMIT;
END$$

CREATE PROCEDURE sp_record_login_attempt(
    IN p_username VARCHAR(60),
    IN p_success BOOLEAN
)
BEGIN
    DECLARE v_user_id INT;
    DECLARE v_failed_login_count INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT user_id, failed_login_count
    INTO v_user_id, v_failed_login_count
    FROM users
    WHERE username = p_username
    FOR UPDATE;

    IF v_user_id IS NULL THEN
        INSERT INTO audit_logs (event_type, entity_name, description)
        VALUES ('LOGIN_FAILED', 'users', CONCAT('Unknown username: ', p_username));
    ELSEIF p_success THEN
        UPDATE users
        SET failed_login_count = 0,
            last_login_at = CURRENT_TIMESTAMP
        WHERE user_id = v_user_id;

        INSERT INTO audit_logs (user_id, event_type, entity_name, entity_id, description)
        VALUES (v_user_id, 'LOGIN_SUCCESS', 'users', v_user_id, CONCAT('Successful login for ', p_username));
    ELSE
        UPDATE users
        SET failed_login_count = failed_login_count + 1,
            status = CASE WHEN failed_login_count + 1 >= 3 THEN 'LOCKED' ELSE status END
        WHERE user_id = v_user_id;

        INSERT INTO audit_logs (user_id, event_type, entity_name, entity_id, old_value, new_value, description)
        VALUES (
            v_user_id, 'LOGIN_FAILED', 'users', v_user_id,
            v_failed_login_count, v_failed_login_count + 1,
            CONCAT('Failed login for ', p_username)
        );
    END IF;

    COMMIT;
END$$

CREATE PROCEDURE sp_check_account_status(
    IN p_account_id INT
)
BEGIN
    SELECT
        a.account_id,
        a.account_number,
        a.account_type,
        a.balance,
        a.status AS account_status,
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.status AS customer_status,
        b.branch_name,
        b.city
    FROM accounts a
    JOIN customers c ON c.customer_id = a.customer_id
    JOIN branches b ON b.branch_id = a.branch_id
    WHERE a.account_id = p_account_id;
END$$

DELIMITER ;
