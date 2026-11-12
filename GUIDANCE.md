# Dagster code location on Wodby

A Dagster code location built from the app's repository: a gRPC code server that the
[dagster](https://github.com/wodby/service-dagster) service's webserver and daemon load. Use them together, as in the
[buildable Dagster stack](https://github.com/wodby/stack-dagster-buildable).

## Image

The image is built from the app's Git repository on top of the Dagster image of the dagster service's version
(`dagster/dagster-celery-k8s`), so the code server runs the same Dagster as the webserver and daemon. Start the
repository from the [Dagster boilerplate](https://github.com/wodby/dagster-boilerplate). The build:

- copies the repository to `/opt/dagster/app`, which is on the Python path;
- installs the packages in `requirements.txt`, when the repository has one. It fails when they change Dagster's own
  version: Dagster comes with the image, and Dagster libraries must match it;
- writes Dagster's instance settings (`$DAGSTER_HOME/dagster.yaml`), which read the PostgreSQL connection of the
  `postgres` link from the environment.

## Code server

The container runs `dagster code-server start` on port 4000 (private), loading the module in the "Python module"
setting (`DAGSTER_CODE_MODULE`, default `app.definitions`) under the name in the "Location name" setting
(`DAGSTER_CODE_LOCATION`, default `app`). The dagster service's workspace (`workspace.yaml`) must list it as a gRPC
server with the stack service's name as the host, port 4000 and the same location name. Startup and readiness use
`dagster api grpc-health-check`.

A deployment builds a new image and restarts the code server; Dagster reloads the code location.

## Runs

The buildable Dagster stack sets the dagster service's run launcher to Dagster's `DefaultRunLauncher`: the daemon
starts each run inside this code server, which has the project's code and packages, instead of in a Kubernetes job.
Runs and their events are stored in the linked PostgreSQL database. Run outputs that Dagster's default IO manager
writes to the code server's disk don't survive a restart: configure an IO manager that writes to external storage for
outputs that later runs read.

Give the code server enough memory and CPU for the runs it executes.
