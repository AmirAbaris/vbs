USE vbs_bank;

-- Demo branches.
INSERT INTO branches (branch_name, city, address, phone, status) VALUES
('VBS Central Tehran', 'Tehran', 'No. 10, Valiasr Street, Tehran', '02188000001', 'ACTIVE'),
('VBS Saadat Abad', 'Tehran', 'No. 22, Saadat Abad Boulevard, Tehran', '02188000002', 'ACTIVE'),
('VBS Karaj Main', 'Karaj', 'No. 7, Taleghani Street, Karaj', '02634000001', 'ACTIVE'),
('VBS Isfahan North', 'Isfahan', 'No. 14, Chaharbagh Street, Isfahan', '03132000001', 'ACTIVE'),
('VBS Shiraz Zand', 'Shiraz', 'No. 31, Zand Boulevard, Shiraz', '07136000001', 'ACTIVE'),
('VBS Tabriz East', 'Tabriz', 'No. 18, Imam Street, Tabriz', '04133000001', 'INACTIVE');

-- Demo customers. The names/data are fake.
INSERT INTO customers (
    national_code, first_name, last_name, birth_date,
    mobile, email, address, status
) VALUES
('0012345678', 'Arman', 'Rahimi', '1995-03-12', '09120000001', 'arman.rahimi@example.com', 'Tehran, Yousef Abad, No. 11', 'ACTIVE'),
('0012345679', 'Nika', 'Ahmadi', '1998-07-21', '09120000002', 'nika.ahmadi@example.com', 'Tehran, Ekbatan, No. 23', 'ACTIVE'),
('0012345680', 'Sina', 'Moradi', '1992-11-04', '09120000003', 'sina.moradi@example.com', 'Karaj, Mehrshahr, No. 4', 'ACTIVE'),
('0012345681', 'Sara', 'Karimi', '2000-01-16', '09120000004', 'sara.karimi@example.com', 'Isfahan, Abbas Abad, No. 15', 'ACTIVE'),
('0012345682', 'Pouya', 'Hosseini', '1989-09-28', '09120000005', 'pouya.hosseini@example.com', 'Shiraz, Molla Sadra, No. 8', 'ACTIVE'),
('0012345683', 'Mina', 'Jafari', '1996-05-30', '09120000006', 'mina.jafari@example.com', 'Tabriz, Roshdieh, No. 19', 'SUSPENDED'),
('0012345684', 'Reza', 'Ebrahimi', '1984-12-09', '09120000007', 'reza.ebrahimi@example.com', 'Tehran, Narmak, No. 43', 'ACTIVE'),
('0012345685', 'Leila', 'Sadeghi', '1991-04-17', '09120000008', 'leila.sadeghi@example.com', 'Karaj, Gohardasht, No. 20', 'ACTIVE'),
('0012345686', 'Kian', 'Abbasi', '1999-08-01', '09120000009', 'kian.abbasi@example.com', 'Isfahan, Jolfa, No. 5', 'ACTIVE'),
('0012345687', 'Ava', 'Rostami', '1997-02-25', '09120000010', 'ava.rostami@example.com', 'Shiraz, Chamran, No. 33', 'ACTIVE'),
('0012345688', 'Omid', 'Farhadi', '1987-06-11', '09120000011', 'omid.farhadi@example.com', 'Tehran, Sattarkhan, No. 17', 'ACTIVE'),
('0012345689', 'Yasmin', 'Maleki', '2001-10-14', '09120000012', 'yasmin.maleki@example.com', 'Karaj, Azimieh, No. 6', 'ACTIVE'),
('0012345690', 'Shayan', 'Nouri', '1993-03-08', '09120000013', 'shayan.nouri@example.com', 'Tabriz, El Goli, No. 12', 'ACTIVE'),
('0012345691', 'Tara', 'Ghasemi', '1994-12-19', '09120000014', 'tara.ghasemi@example.com', 'Tehran, Pasdaran, No. 29', 'ACTIVE'),
('0012345692', 'Mehrdad', 'Salehi', '1982-01-03', '09120000015', 'mehrdad.salehi@example.com', 'Isfahan, Kaveh, No. 40', 'CLOSED');

-- Demo login users. NULL customer_id means admin user.
INSERT INTO users (customer_id, username, password_hash, role, status) VALUES
(NULL, 'admin.main', 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'ADMIN', 'ACTIVE'),
(NULL, 'admin.audit', 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb', 'ADMIN', 'ACTIVE'),
(1, 'arman.rahimi', '1111111111111111111111111111111111111111111111111111111111111111', 'CUSTOMER', 'ACTIVE'),
(2, 'nika.ahmadi', '2222222222222222222222222222222222222222222222222222222222222222', 'CUSTOMER', 'ACTIVE'),
(3, 'sina.moradi', '3333333333333333333333333333333333333333333333333333333333333333', 'CUSTOMER', 'ACTIVE'),
(4, 'sara.karimi', '4444444444444444444444444444444444444444444444444444444444444444', 'CUSTOMER', 'ACTIVE'),
(5, 'pouya.hosseini', '5555555555555555555555555555555555555555555555555555555555555555', 'CUSTOMER', 'ACTIVE'),
(6, 'mina.jafari', '6666666666666666666666666666666666666666666666666666666666666666', 'CUSTOMER', 'DISABLED'),
(7, 'reza.ebrahimi', '7777777777777777777777777777777777777777777777777777777777777777', 'CUSTOMER', 'ACTIVE'),
(8, 'leila.sadeghi', '8888888888888888888888888888888888888888888888888888888888888888', 'CUSTOMER', 'ACTIVE'),
(9, 'kian.abbasi', '9999999999999999999999999999999999999999999999999999999999999999', 'CUSTOMER', 'ACTIVE'),
(10, 'ava.rostami', '1010101010101010101010101010101010101010101010101010101010101010', 'CUSTOMER', 'ACTIVE'),
(11, 'omid.farhadi', 'abababababababababababababababababababababababababababababababab', 'CUSTOMER', 'ACTIVE'),
(12, 'yasmin.maleki', 'cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd', 'CUSTOMER', 'ACTIVE'),
(13, 'shayan.nouri', 'efefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefef', 'CUSTOMER', 'ACTIVE'),
(14, 'tara.ghasemi', '1212121212121212121212121212121212121212121212121212121212121212', 'CUSTOMER', 'ACTIVE'),
(15, 'mehrdad.salehi', '3434343434343434343434343434343434343434343434343434343434343434', 'CUSTOMER', 'DISABLED');

-- Demo bank accounts with starting balances.
INSERT INTO accounts (
    customer_id, branch_id, account_number, account_type, balance, status
) VALUES
(1, 1, '100100000000000001', 'CHECKING', 12000000.00, 'ACTIVE'),
(1, 2, '100100000000000002', 'SAVINGS', 8500000.00, 'ACTIVE'),
(2, 1, '100100000000000003', 'CHECKING', 6400000.00, 'ACTIVE'),
(2, 3, '100100000000000004', 'SAVINGS', 15000000.00, 'ACTIVE'),
(3, 3, '100100000000000005', 'CHECKING', 4200000.00, 'ACTIVE'),
(3, 3, '100100000000000006', 'BUSINESS', 38000000.00, 'ACTIVE'),
(4, 4, '100100000000000007', 'CHECKING', 5100000.00, 'ACTIVE'),
(4, 4, '100100000000000008', 'SAVINGS', 9600000.00, 'ACTIVE'),
(5, 5, '100100000000000009', 'CHECKING', 7300000.00, 'ACTIVE'),
(5, 5, '100100000000000010', 'BUSINESS', 81000000.00, 'ACTIVE'),
(6, 6, '100100000000000011', 'CHECKING', 2500000.00, 'FROZEN'),
(7, 2, '100100000000000012', 'CHECKING', 18000000.00, 'ACTIVE'),
(7, 1, '100100000000000013', 'SAVINGS', 26000000.00, 'ACTIVE'),
(8, 3, '100100000000000014', 'CHECKING', 9100000.00, 'ACTIVE'),
(8, 3, '100100000000000015', 'SAVINGS', 14000000.00, 'ACTIVE'),
(9, 4, '100100000000000016', 'CHECKING', 3900000.00, 'ACTIVE'),
(10, 5, '100100000000000017', 'CHECKING', 11700000.00, 'ACTIVE'),
(10, 5, '100100000000000018', 'SAVINGS', 22200000.00, 'ACTIVE'),
(11, 1, '100100000000000019', 'CHECKING', 6600000.00, 'ACTIVE'),
(11, 2, '100100000000000020', 'BUSINESS', 45000000.00, 'ACTIVE'),
(12, 3, '100100000000000021', 'CHECKING', 5800000.00, 'ACTIVE'),
(13, 6, '100100000000000022', 'CHECKING', 3200000.00, 'ACTIVE'),
(14, 1, '100100000000000023', 'CHECKING', 20500000.00, 'ACTIVE'),
(14, 2, '100100000000000024', 'SAVINGS', 30500000.00, 'ACTIVE'),
(15, 4, '100100000000000025', 'CHECKING', 0.00, 'CLOSED');

-- Demo loans. remaining_balance shows how much is still unpaid.
INSERT INTO loans (
    customer_id, repayment_account_id, principal_amount,
    annual_interest_rate, term_months, remaining_balance,
    status, start_date, due_date
) VALUES
(1, 1, 50000000.00, 18.00, 24, 47000000.00, 'ACTIVE', '2025-01-15', '2027-01-15'),
(3, 5, 25000000.00, 16.50, 18, 18000000.00, 'ACTIVE', '2025-04-01', '2026-10-01'),
(5, 9, 100000000.00, 20.00, 36, 92500000.00, 'ACTIVE', '2024-11-20', '2027-11-20'),
(8, 14, 30000000.00, 15.00, 12, 0.00, 'PAID_OFF', '2024-01-01', '2025-01-01'),
(11, 19, 60000000.00, 17.50, 30, 56000000.00, 'ACTIVE', '2025-02-10', '2027-08-10'),
(14, 23, 45000000.00, 19.00, 24, 41000000.00, 'ACTIVE', '2025-05-05', '2027-05-05');

-- These CALL commands run the stored procedures to create demo activity.
-- They also create transaction rows and audit log rows.
CALL sp_deposit(1, 1500000.00, 'Salary deposit');
CALL sp_deposit(2, 700000.00, 'Savings top-up');
CALL sp_deposit(3, 900000.00, 'Cash deposit');
CALL sp_deposit(4, 1200000.00, 'Monthly income');
CALL sp_deposit(5, 500000.00, 'ATM deposit');
CALL sp_deposit(6, 2500000.00, 'Business revenue');
CALL sp_deposit(7, 400000.00, 'Cash deposit');
CALL sp_deposit(8, 800000.00, 'Savings deposit');
CALL sp_deposit(9, 650000.00, 'Card-to-account deposit');
CALL sp_deposit(10, 5000000.00, 'Merchant settlement');
CALL sp_deposit(12, 1000000.00, 'Salary deposit');
CALL sp_deposit(13, 1500000.00, 'Savings top-up');
CALL sp_deposit(14, 700000.00, 'Cash deposit');
CALL sp_deposit(15, 800000.00, 'Savings deposit');
CALL sp_deposit(16, 300000.00, 'Student allowance');
CALL sp_deposit(17, 900000.00, 'Salary deposit');
CALL sp_deposit(18, 1400000.00, 'Savings deposit');
CALL sp_deposit(19, 650000.00, 'Cash deposit');
CALL sp_deposit(20, 3500000.00, 'Business revenue');
CALL sp_deposit(21, 400000.00, 'Cash deposit');
CALL sp_deposit(22, 300000.00, 'Salary deposit');
CALL sp_deposit(23, 1100000.00, 'Salary deposit');
CALL sp_deposit(24, 1600000.00, 'Savings deposit');

CALL sp_withdraw(1, 300000.00, 'ATM withdrawal');
CALL sp_withdraw(3, 450000.00, 'Bill payment withdrawal');
CALL sp_withdraw(4, 500000.00, 'Cash withdrawal');
CALL sp_withdraw(6, 1200000.00, 'Supplier payment');
CALL sp_withdraw(8, 250000.00, 'ATM withdrawal');
CALL sp_withdraw(10, 3000000.00, 'Business expense');
CALL sp_withdraw(12, 800000.00, 'Cash withdrawal');
CALL sp_withdraw(15, 600000.00, 'Shopping withdrawal');
CALL sp_withdraw(17, 350000.00, 'ATM withdrawal');
CALL sp_withdraw(20, 1500000.00, 'Office rent payment');

CALL sp_transfer(1, 3, 500000.00, 'Rent transfer');
CALL sp_transfer(4, 5, 750000.00, 'Family transfer');
CALL sp_transfer(6, 10, 2000000.00, 'Business transfer');
CALL sp_transfer(9, 14, 300000.00, 'Personal transfer');
CALL sp_transfer(12, 16, 450000.00, 'Education support');
CALL sp_transfer(18, 2, 900000.00, 'Savings transfer');
CALL sp_transfer(20, 23, 1250000.00, 'Consulting payment');
CALL sp_transfer(23, 24, 1000000.00, 'Savings transfer');
CALL sp_transfer(14, 21, 350000.00, 'Personal transfer');
CALL sp_transfer(5, 7, 250000.00, 'Shared expense');

CALL sp_pay_loan(1, 1, 1000000.00, 'Monthly loan installment');
CALL sp_pay_loan(2, 5, 750000.00, 'Loan repayment');
CALL sp_pay_loan(3, 9, 2500000.00, 'Business loan repayment');
CALL sp_pay_loan(5, 19, 1000000.00, 'Loan repayment');
CALL sp_pay_loan(6, 23, 1500000.00, 'Loan repayment');

-- Demo login attempts: success, failures, and unknown username.
CALL sp_record_login_attempt('arman.rahimi', TRUE);
CALL sp_record_login_attempt('nika.ahmadi', FALSE);
CALL sp_record_login_attempt('nika.ahmadi', FALSE);
CALL sp_record_login_attempt('unknown.user', FALSE);
