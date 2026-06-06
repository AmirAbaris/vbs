USE vbs_bank;

-- Faster branch filtering by city or status.
CREATE INDEX idx_branches_city ON branches(city);
CREATE INDEX idx_branches_status ON branches(status);

-- Faster customer lookup by name or status.
CREATE INDEX idx_customers_name ON customers(last_name, first_name);
CREATE INDEX idx_customers_status ON customers(status);

-- Faster user filtering by role/status and joining to customers.
CREATE INDEX idx_users_role_status ON users(role, status);
CREATE INDEX idx_users_customer ON users(customer_id);

-- Faster account lookups by owner, branch, and status.
CREATE INDEX idx_accounts_customer ON accounts(customer_id);
CREATE INDEX idx_accounts_branch ON accounts(branch_id);
CREATE INDEX idx_accounts_status ON accounts(status);
CREATE INDEX idx_accounts_customer_status ON accounts(customer_id, status);

-- Faster transaction history queries by account and date.
CREATE INDEX idx_transactions_source_date ON transactions(source_account_id, created_at);
CREATE INDEX idx_transactions_destination_date ON transactions(destination_account_id, created_at);
CREATE INDEX idx_transactions_type_status ON transactions(transaction_type, status);
CREATE INDEX idx_transactions_created_at ON transactions(created_at);

-- Faster loan reports by customer, account, status, and due date.
CREATE INDEX idx_loans_customer_status ON loans(customer_id, status);
CREATE INDEX idx_loans_repayment_account ON loans(repayment_account_id);
CREATE INDEX idx_loans_due_date ON loans(due_date);

-- Faster loan payment history queries.
CREATE INDEX idx_loan_payments_loan_date ON loan_payments(loan_id, paid_at);
CREATE INDEX idx_loan_payments_account_date ON loan_payments(account_id, paid_at);

-- Faster audit log search by affected record and date.
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_name, entity_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
