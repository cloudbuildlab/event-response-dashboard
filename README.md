# event-response-dashboard

Centralized dashboard for managing and responding to operational events.

## FastSchema on ECS

FastSchema runs on an existing ECS cluster (EC2 launch type) with standard config: SQLite, port 8000, basic (ephemeral) storage, and an optional ALB. Infrastructure is defined in **pure Terraform** under `terraform/`. Data is stored in the container filesystem and does not persist across task replacements; add EFS later if you need persistence.

### Prerequisites

- Existing ECS cluster (EC2 launch type) with capacity
- VPC with private subnets (for tasks) and public subnets (for ALB, if used)
- Terraform >= 1.0 and AWS provider >= 4.0

### Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `ecs_cluster_arn` | ARN of the ECS cluster | Yes |
| `vpc_id` | VPC ID | Yes |
| `private_subnet_ids` | Private subnet IDs for ECS tasks | Yes |
| `public_subnet_ids` | Public subnet IDs for the ALB (if `enable_alb` is true) | If ALB enabled |
| `enable_alb` | Create an ALB for FastSchema | No (default: true) |
| `desired_count` | Number of FastSchema tasks | No (default: 1) |
| `environment` | Environment name | No (default: dev) |
| `app_key_secret_arn` | Secrets Manager ARN for APP_KEY (optional) | No |

### Apply

```bash
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Pass variables via `-var`, `-var-file`, or `terraform.tfvars`:

```bash
terraform apply -var="ecs_cluster_arn=arn:aws:ecs:us-east-1:123456789012:cluster/my-cluster" \
  -var="vpc_id=vpc-xxx" \
  -var='private_subnet_ids=["subnet-a","subnet-b"]' \
  -var='public_subnet_ids=["subnet-c","subnet-d"]'
```

### Post-deploy

1. **Dashboard URL** (when ALB is enabled):
   ```bash
   terraform output dashboard_url
   ```
   Open that URL in a browser (e.g. `http://<alb_dns_name>/dash`).

2. **First-run setup**: On first start, FastSchema prints a setup link with a token to the task logs. View logs in CloudWatch:
   ```bash
   terraform output log_group_name
   ```
   In the log group, find the line like:
   ```
   Visit the following URL to setup the app: http://localhost:8000/dash/setup/?token=...
   ```
   Use the same path on your ALB: `http://<alb_dns_name>/dash/setup/?token=<token>`.

3. **Without ALB**: If `enable_alb` is false, reach FastSchema via the task’s private IP (e.g. from a bastion or VPN) on port 8000.
