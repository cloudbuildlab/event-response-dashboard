# event-dash-auth

Same as [event_dash](../event_dash/) (FastSchema + Go web app behind an ALB) but with **Cognito authentication** and read/write RBAC at the ALB.

- **ALB**: HTTP redirects to HTTPS; HTTPS listener uses `authenticate-cognito` then forwards to the web container. `/health` and `/static/*` bypass auth.
- **Cognito**: User pool, hosted UI domain, app client (callback `https://<alb>/oauth2/idpresponse`), groups `viewers`, `editors`, `admins`.
- **Web container**: Receives `COGNITO_USER_POOL_ID` and `AWS_REGION`; the same [event-response-image](https://github.com/platformfuzz/event-response-image) image can be used once it supports Cognito (JWT from `x-amzn-oidc-data`, group lookup, view/write permissions).
- **Task role**: Has `cognito-idp:AdminListGroupsForUser` on the user pool.

**Required**: Set `certificate_arn` (ACM) in `terraform.tfvars`. Optional: `cognito_domain_prefix` for the Cognito hosted UI domain.

See [terraform.tfvars.example](terraform.tfvars.example).
