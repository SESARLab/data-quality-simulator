# Data Balance Simulator CLI

To run Swift REPL in a docker container run:

```bash
docker run --rm -it --cap-add=SYS_PTRACE --security-opt seccomp=unconfined swift:5.10.1 swift repl
```

## Run

To run the project in a container, then:

```bash
make run CONFIG_FILE_PATH=config-files/base_config.json SIMULATOR_ARGS=[...]
```

If the environment already have Swift installed (e.g. when you are developing using VSCode devcontainer feature):

```bash
make run IS_DEVCONTAINER=true CONFIG_FILE_PATH=config-files/base_config.json SIMULATOR_ARGS=[...]
```

### Logging

To set the logger level, create an env variable called `LOGGER_LEVEL` with one of the following values: `trace, debug, info, notice, warning, error, critical` ( default is `info`). The alternative is to pass this variable to `make run`.

---

### DB Migrations and DB queries

For DB migration, run `make migrate-db SQL_CODE="your_migration_sql"`.

To run queries on DB, run `make run-query SQL_CODE="your_plain_sql"`.

---

[Deepnote experiments](https://deepnote.com/workspace/test-efaa-1feb6c70-6750-4e6b-8afd-854661b4e01a/project/Dataset-generation-17111468-e773-4c18-b5d3-b951c564e2bc/notebook/a0b70c155f2e4a4db16548fdf4ff4ddf)