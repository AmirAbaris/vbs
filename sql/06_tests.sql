USE vbs_bank;

SELECT 'Initial account status for account 1' AS test_step;
CALL sp_check_account_status(1);

SELECT 'Successful deposit: account 1 receives 250000' AS test_step;
CALL sp_deposit(1, 250000.00, 'Test deposit');
SELECT account_id, account_number, balance FROM accounts WHERE account_id = 1;

SELECT 'Successful withdrawal: account 1 pays 100000' AS test_step;
CALL sp_withdraw(1, 100000.00, 'Test withdrawal');
SELECT account_id, account_number, balance FROM accounts WHERE account_id = 1;

SELECT 'Successful transfer: account 1 sends 200000 to account 2' AS test_step;
CALL sp_transfer(1, 2, 200000.00, 'Test transfer');
SELECT account_id, account_number, balance FROM accounts WHERE account_id IN (1, 2);

SELECT 'Successful loan payment: loan 1 paid from account 1' AS test_step;
CALL sp_pay_loan(1, 1, 500000.00, 'Test loan payment');
SELECT loan_id, remaining_balance, status FROM loans WHERE loan_id = 1;
SELECT account_id, balance FROM accounts WHERE account_id = 1;

SELECT 'Expected failure: insufficient withdrawal. Run manually to see rollback error.' AS test_step;
-- CALL sp_withdraw(1, 999999999999.00, 'Expected insufficient balance failure');

SELECT 'Expected failure: transfer to frozen account. Run manually to see rollback error.' AS test_step;
-- CALL sp_transfer(1, 11, 100000.00, 'Expected inactive account failure');

SELECT 'Customer account summary' AS report_name;
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.status AS customer_status,
    a.account_number,
    a.account_type,
    a.balance,
    a.status AS account_status,
    b.branch_name,
    b.city
FROM customers c
JOIN accounts a ON a.customer_id = c.customer_id
JOIN branches b ON b.branch_id = a.branch_id
ORDER BY c.customer_id, a.account_id;

SELECT 'Transaction history for account 1' AS report_name;
SELECT
    transaction_id,
    source_account_id,
    destination_account_id,
    amount,
    transaction_type,
    status,
    description,
    created_at
FROM transactions
WHERE source_account_id = 1 OR destination_account_id = 1
ORDER BY created_at DESC, transaction_id DESC;

SELECT 'Loan summary by customer' AS report_name;
SELECT
    l.loan_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    l.principal_amount,
    l.remaining_balance,
    l.annual_interest_rate,
    l.term_months,
    l.status,
    l.due_date
FROM loans l
JOIN customers c ON c.customer_id = l.customer_id
ORDER BY l.loan_id;

SELECT 'Branch account counts' AS report_name;
SELECT
    b.branch_name,
    b.city,
    COUNT(a.account_id) AS account_count,
    SUM(a.balance) AS total_balance
FROM branches b
LEFT JOIN accounts a ON a.branch_id = b.branch_id
GROUP BY b.branch_id, b.branch_name, b.city
ORDER BY b.city, b.branch_name;

SELECT 'Recent audit logs' AS report_name;
SELECT
    audit_id,
    event_type,
    entity_name,
    entity_id,
    old_value,
    new_value,
    description,
    created_at
FROM audit_logs
ORDER BY created_at DESC, audit_id DESC
LIMIT 20;

SELECT 'Important indexes on accounts' AS report_name;
SHOW INDEX FROM accounts;

SELECT 'Important indexes on transactions' AS report_name;
SHOW INDEX FROM transactions;

