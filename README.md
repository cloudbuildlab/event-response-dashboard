# event-response-dashboard

Centralized dashboard for managing and responding to operational events.

This repo has **two Terraform stacks** (separate state, apply from each subfolder) and a **Go consumer app**:

| Path | Description |
|------|-------------|
| `terraform/fastschema/` | R&D stack: FastSchema only, own ALB, IP-restricted. |
| `terraform/event_response_app/` | Event response stack: one ECS task with **FastSchema + Go web app**; separate ALB; web app does CRUD against FastSchema. |
| `app/` | Go web app (CRUD demo on FastSchema `event` resource). No auth. Build from here for `event_response_app`’s `web_image`. |

---

## Terraform stacks

- **Prerequisites:** Existing ECS cluster (EC2), VPC with private and public subnets, Terraform >= 1.5, AWS provider >= 4.0.
- **No shared root:** Run `terraform init` and `terraform apply` from **each** stack directory.

### 1. FastSchema (R&D) — `terraform/fastschema/`

Single FastSchema service, optional ALB, IP-restricted ingress.

```bash
cd terraform/fastschema
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Variables: `ecs_cluster_arn`, `vpc_id`, `private_subnet_ids`, `public_subnet_ids`, `enable_alb`, `desired_count`, `environment`, `fastschema_app_key`, `fastschema_admin_username`, `fastschema_admin_password`, `app_port`, `fastschema_image`, `tags`. See `variables.tf` and `terraform.tfvars`.

**Web UI password:** FastSchema has no env-based admin creation. Use the **setup URL** from task logs (CloudWatch log group from `terraform output log_group_name`): look for `Visit the following URL to setup the app: .../dash/setup/?token=...` and open that path on your ALB host. If you set `fastschema_admin_username` and `fastschema_admin_password`, the task runs `fastschema setup` at start so you can log in with those credentials.

### 2. Event response app — `terraform/event_response_app/`

One ECS task with two containers: **FastSchema** (backend) and **Go web app** (consumer). ALB targets the web container; the Go app calls FastSchema at `http://localhost:8000`.

1. **Build the Go app image** (from repo root):
   ```bash
   cd app
   docker build -t event-response-app:latest .
   ```
   Push to your registry (e.g. ECR) and set `web_image` in `terraform.tfvars`.

2. **Apply the stack:**
   ```bash
   cd terraform/event_response_app
   cp terraform.tfvars.example terraform.tfvars   # edit: web_image, VPC, cluster, etc.
   terraform init
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

Outputs: `web_url` (ALB URL for the Go app), `log_group_fastschema`, `log_group_web`.

**FastSchema in this stack:** Create an **event** schema in the FastSchema dashboard (e.g. fields: `title`, `description`) so the Go app’s CRUD calls work. Optional: set `fastschema_admin_username` / `fastschema_admin_password` (and optionally `fastschema_app_key`) in tfvars; the task runs `fastschema setup` at start.

---

## Go consumer app (`app/`)

Minimal CRUD UI for a single FastSchema resource (`event`: title, description). No authentication.

- **Run locally:** With FastSchema on port 8000, run `FASTSCHEMA_URL=http://localhost:8000 go run .` in `app/`; open http://localhost:8080.
- **Build for ECS:** `docker build -t your-registry/event-response-app:latest app/`; push and set `web_image` in `terraform/event_response_app/terraform.tfvars`.
- **Env:** `FASTSCHEMA_URL` (default `http://localhost:8000`), `PORT` (default `8080`). In ECS, the task definition sets `FASTSCHEMA_URL=http://localhost:8000`.

See `app/README.md` for details.
