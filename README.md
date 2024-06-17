# Data Balance Simulator CLI

To run Swift REPL in a docker container run:

```bash
docker run --rm -it --cap-add=SYS_PTRACE --security-opt seccomp=unconfined swift:5.10.1 swift repl
```