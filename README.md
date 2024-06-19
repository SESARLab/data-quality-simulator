# Data Balance Simulator CLI

To run Swift REPL in a docker container run:

```bash
docker run --rm -it --cap-add=SYS_PTRACE --security-opt seccomp=unconfined swift:5.10.1 swift repl
```

## Run

If you already have Swift Package Manager installed (or you are running the project in a container), then run:

```bash
make run CONFIG_FILE_PATH=config-files/basic.json
```