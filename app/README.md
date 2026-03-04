# Event Response App (Go consumer)

Minimal Go web app that performs **create, edit, delete** on an `event` resource in FastSchema. No authentication.

## Prerequisites

- Go 1.21+
- FastSchema running (e.g. on `http://localhost:8000`) with an **event** schema that has at least `title` (string) and `description` (string). Create the schema in the FastSchema dashboard if it does not exist.

## Run locally

```bash
# With FastSchema on default port 8000
export FASTSCHEMA_URL=http://localhost:8000   # optional, default
go run .
```

Then open http://localhost:8080. Use **New event** to create, **Edit** / **Delete** from the list.

## Build Docker image for ECS

From the repo root (or from `app/`):

```bash
cd app
docker build -t event-response-app:latest .
```

Push to your registry (e.g. ECR) and set `web_image` in `terraform/event_response_app/terraform.tfvars` to that image URL.

## Environment

| Variable         | Default                 | Description                          |
|------------------|-------------------------|--------------------------------------|
| `FASTSCHEMA_URL` | `http://localhost:8000` | FastSchema API base URL              |
| `PORT`           | `8080`                  | Port the Go app listens on           |

In ECS, the task definition sets `FASTSCHEMA_URL=http://localhost:8000` so the web container talks to the FastSchema container in the same task.
