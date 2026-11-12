# Builds a Dagster code location from the app repository on the Dagster image
# of the dagster service's version: the repository's Python packages are
# installed and its code is put on the Python path. Dagster's instance settings
# read the PostgreSQL connection from the environment, so runs started in this
# container store their events with the rest of Dagster.
ARG WODBY_BASE_IMAGE
FROM ${WODBY_BASE_IMAGE}

ARG COPY_FROM

ENV DAGSTER_HOME=/opt/dagster/dagster_home \
    PYTHONPATH=/opt/dagster/app

COPY ${COPY_FROM} /opt/dagster/app

WORKDIR /opt/dagster/app

RUN set -e; \
    dagster_version="$(python -c 'import dagster; print(dagster.__version__)')"; \
    if [ -f requirements.txt ]; then \
        pip install --no-cache-dir -r requirements.txt; \
    fi; \
    # The code server must run the same Dagster as the webserver and daemon. \
    if [ "$(python -c 'import dagster; print(dagster.__version__)')" != "${dagster_version}" ]; then \
        echo "requirements.txt changed Dagster from ${dagster_version}: remove dagster from it, the image provides it" >&2; \
        exit 1; \
    fi; \
    mkdir -p "${DAGSTER_HOME}"; \
    printf '%s\n' \
        'storage:' \
        '  postgres:' \
        '    postgres_db:' \
        '      hostname: {env: DAGSTER_PG_HOST}' \
        '      port: {env: DAGSTER_PG_PORT}' \
        '      db_name: {env: DAGSTER_PG_DB}' \
        '      username: {env: DAGSTER_PG_USERNAME}' \
        '      password: {env: DAGSTER_PG_PASSWORD}' \
        > "${DAGSTER_HOME}/dagster.yaml"; \
    echo "Dagster ${dagster_version}"
