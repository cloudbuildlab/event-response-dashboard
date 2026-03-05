# event_dash_external

FastSchema + web consumer with **RDS (PostgreSQL)** and **S3**. All FastSchema data (content, users, etc.) is stored in RDS; there is no internal SQLite in this stack.

## Confirming data is in RDS (not internal DB)

This stack sets `DB_DRIVER=pgx` and all `DB_*` / `DB_PASS` on the FastSchema container, so FastSchema uses **only** the RDS PostgreSQL instance. The default SQLite internal DB is not used and no SQLite data volume is mounted.

### Option 1: Query RDS with psql

You need network access to RDS (same VPC, or e.g. Session Manager port forward from a host in the VPC).

```bash
# From event_dash_external after terraform apply (use same AWS profile/region as Terraform)
RDS_HOST=$(terraform output -raw rds_endpoint)
DB_NAME=$(terraform output -raw rds_database_name)
export PGPASSWORD=$(aws ssm get-parameter --name $(terraform output -raw rds_password_ssm_name) --with-decryption --query Parameter.Value --output text)

psql -h "$RDS_HOST" -p 5432 -U appuser -d "$DB_NAME" -c "\dt"
# List tables; FastSchema creates tables per schema (e.g. events for event schema). Then:
psql -h "$RDS_HOST" -p 5432 -U appuser -d "$DB_NAME" -c 'SELECT * FROM events LIMIT 5;'
```

### Option 2: Use the app / API

If the record appears in the event response dashboard or via the FastSchema API, it is in the database FastSchema is connected to—which in this stack is RDS only.
