# Dagster code location service for Kubernetes on Wodby

Run your own Dagster assets, jobs and schedules on Kubernetes with Wodby.

This repository defines the Wodby service manifest for a Dagster code location
built from your Git repository: a gRPC code server that the
[Dagster](https://github.com/wodby/service-dagster) service loads.

- [Browse Wodby services](https://wodby.com/services)
- [Wodby service documentation](https://wodby.com/docs/2.0/services/)
- [Service manifest reference](https://wodby.com/docs/2.0/services/template/)

## Service overview

| Property | Manifest configuration |
| --- | --- |
| Service name | `dagster-code` |
| Versions | Dagster `1`, as in the Dagster service |
| Type | Application service |
| Image | Built from your repository on top of `dagster/dagster-celery-k8s` |
| Application build | Your Dagster project and `requirements.txt`; start from the [Dagster boilerplate](https://github.com/wodby/dagster-boilerplate) |
| Endpoint | gRPC on port 4000, private |
| Links | `postgres`: the Dagster service's database |
| Settings | Python module (`app.definitions`) and location name (`app`) |

## Use this service

Reference `dagster-code` from a Wodby stack together with the Dagster service,
and list it in the Dagster service's workspace, as the
[buildable Dagster stack](https://github.com/wodby/stack-dagster-buildable)
does.

## Maintain a custom version

1. Fork this repository.
2. Edit the service manifest and referenced files.
3. Import the repository as a [Git-backed service](https://wodby.com/docs/2.0/services/create/#create-a-git-backed-service).
4. Reference the service from a stack manifest.

Validate the manifest with:

```bash
wodby service validate-manifest service.yml --org <org-id>
```

See the [service manifest reference](https://wodby.com/docs/2.0/services/template/) and the [managed services index](https://github.com/wodby/services).
