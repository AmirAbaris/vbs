# VBS - Virtual Banking System Database

This project is a MySQL 8.0 database design for a Virtual Banking System (VBS). It manages customers, bank accounts, transactions, loans, authentication users, branches, and audit logs for both end users and administrators.

The project includes conceptual and logical design, normalization to Third Normal Form (3NF), constraints, stored procedures, transaction management, triggers, indexes, fake seed data, and test scenarios.

## Requirements Coverage

| Requirement | Implemented In |
| --- | --- |
| Customers, accounts, transactions, loans, branches | `sql/01_schema.sql` |
| Authentication for customers/admins | `users` table in `sql/01_schema.sql` |
| Conceptual and logical design | `docs/design.md` |
| 3NF normalization explanation | `docs/design.md` |
| Primary keys and foreign keys | `sql/01_schema.sql` |
| Check constraints | `sql/01_schema.sql` |
| FK-column business rules for MySQL 9.6 | `sql/03_triggers.sql` |
| Stored procedures | `sql/04_procedures.sql` |
| Transaction management | `sql/04_procedures.sql` |
| Triggers | `sql/03_triggers.sql` |
| Clustered/non-clustered indexing discussion | `docs/design.md`, `sql/02_indexes.sql` |
| Fake sample dataset | `sql/05_seed_data.sql` |
| Runnable tests and reports | `sql/06_tests.sql` |

## MySQL Version

Target database engine: **MySQL 8.0.16 or newer** with InnoDB.

MySQL InnoDB stores table rows clustered by the primary key. Therefore, this project treats each primary key as the clustered index. Additional indexes created with `CREATE INDEX` are secondary indexes, which are the MySQL equivalent of non-clustered indexes.

## How To Run

Run the scripts in this order:

```sql
SOURCE sql/01_schema.sql;
SOURCE sql/02_indexes.sql;
SOURCE sql/03_triggers.sql;
SOURCE sql/04_procedures.sql;
SOURCE sql/05_seed_data.sql;
SOURCE sql/06_tests.sql;
```

Or from a terminal:

```bash
mysql -u root -p < sql/01_schema.sql
mysql -u root -p vbs_bank < sql/02_indexes.sql
mysql -u root -p vbs_bank < sql/03_triggers.sql
mysql -u root -p vbs_bank < sql/04_procedures.sql
mysql -u root -p vbs_bank < sql/05_seed_data.sql
mysql -u root -p vbs_bank < sql/06_tests.sql
```

## Main Banking Operations

The stored procedures support:

- Deposit
- Withdrawal
- Transfer between accounts
- Loan payment
- Login attempt recording
- Account status checking

All financial procedures use transactions and rollback on errors.
