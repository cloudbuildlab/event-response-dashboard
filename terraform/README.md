# Terraform stacks

There is **no root Terraform configuration** here. Apply from one of the subfolders:

| Directory | Purpose |
|-----------|---------|
| **fastschema/** | R&D: FastSchema only, own ALB, IP-restricted. |
| **event_response_app/** | Event response: one task with FastSchema + Go web app, separate ALB. |

From the project root, see the main [README.md](../README.md) for prerequisites, variables, and apply steps for each stack.
