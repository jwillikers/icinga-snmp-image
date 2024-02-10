set dotenv-load := true

default: build

alias b := build

# Build the container image.
build tag="icinga-snmp":
    podman build . --tag icinga-snmp
