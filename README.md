# event-response-dashboard

Centralized dashboard for managing and responding to operational events.

This repo has **two Terraform stacks** (separate state, apply from each subfolder):

| Path | Description |
|------|-------------|
| `terraform/fastschema/` | R&D stack: FastSchema only, own ALB, IP-restricted. |
| `terraform/event_response_app/` | Event response stack: one ECS task with **FastSchema + Go web app**; separate ALB; web container uses `ghcr.io/platformfuzz/event-response-image:latest`. |

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

One ECS task with two containers: **FastSchema** (backend) and **Go web app** (consumer). ALB targets the web container; the web app uses the published image `ghcr.io/platformfuzz/event-response-image:latest` and calls FastSchema at `http://localhost:8000`.

**Apply the stack:**

```bash
cd terraform/event_response_app
cp terraform.tfvars.example terraform.tfvars   # edit: VPC, cluster, etc.
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

The web container image defaults to `ghcr.io/platformfuzz/event-response-image:latest`. Override with `web_image` in `terraform.tfvars` if needed.

Outputs: `web_url` (ALB URL for the Go app), `log_group_fastschema`, `log_group_web`.

**FastSchema in this stack:** Create an **event** schema in the FastSchema dashboard (e.g. fields: `title`, `description`) so the web app's CRUD calls work. Optional: set `fastschema_admin_username` / `fastschema_admin_password` (and optionally `fastschema_app_key`) in tfvars; the task runs `fastschema setup` at start.

**Web app source and image:** Built and published from [platformfuzz/event-response-image](https://github.com/platformfuzz/event-response-image). Use that repo for local dev (Docker Compose) and CI/CD.
