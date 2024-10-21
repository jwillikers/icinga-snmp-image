default: build

alias b := build

build attribute="icinga-snmp-image":
    #!/bin/bash -eux
    nix build '.#{{ attribute }}'

alias ch := check

check: && format
    yamllint .
    asciidoctor *.adoc
    lychee --cache *.html

alias f := format
alias fmt := format

format:
    treefmt

alias r := run
run attribute="icinga-snmp-image": (build attribute)
    podman image load --input result
    podman run \
        --cap-add NET_RAW \
        --env ICINGA_MASTER=1 \
        --interactive \
        --name icinga \
        --rm \
        --tty \
        "localhost/icinga-snmp:{{ arch() }}-linux"

alias u := update
alias up := update

update:
    nix flake update
    # todo Update Nix hash in default.nix: vendorHash = "sha256-...";
