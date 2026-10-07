# t with all seven kernels, at the versions every published table was measured on (t/RUN-ON-LINUX.md).
#
#   docker build -t t-proof-engine .
#   docker run --rm t-proof-engine verify t/tasks/abs.t
#   docker run --rm -v "$PWD/mytasks:/work" t-proof-engine verify /work --jobs 4 --table /work/AGREEMENT.md
#
# Every download is pinned by the sha256 its project's release page reports. Each kernel lives under $HOME exactly
# where t/verifiers/discover.py's globs look, so no T_* variable is needed.
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8
RUN apt-get update -q \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl git unzip xz-utils python3 \
      build-essential m4 pkg-config libgmp-dev zlib1g-dev autoconf \
      libicu74 libgomp1 graphviz \
 && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --shell /bin/bash prover
USER prover
WORKDIR /home/prover
ENV PATH=/home/prover/.cargo/bin:/home/prover/.opam/default/bin:/home/prover/.elan/bin:/home/prover/.local/bin:$PATH

# fetch URL SHA256 FILE: download and check one pinned asset
RUN mkdir -p .local/bin && printf '%s\n' '#!/bin/sh' 'set -e' \
      'curl -fsSL --retry 3 -o "$3" "$1"' 'echo "$2  $3" | sha256sum -c -' > .local/bin/fetch \
 && chmod +x .local/bin/fetch

# Dafny 4.11.0: self-contained .NET with its own Z3
RUN fetch https://github.com/dafny-lang/dafny/releases/download/v4.11.0/dafny-4.11.0-x64-ubuntu-22.04.zip \
      a46a9ff7cdd720f7955854c78e95df13f4cfe6b80691b05f8654fe19e8267179 /tmp/dafny.zip \
 && unzip -q /tmp/dafny.zip -d .local && rm /tmp/dafny.zip && .local/dafny/dafny --version

# GNATprove FSF 16.1.0 (SPARK): Why3, Alt-Ergo, cvc5 and Z3 bundled
RUN fetch https://github.com/alire-project/GNAT-FSF-builds/releases/download/gnatprove-16.1.0-1/gnatprove-x86_64-linux-16.1.0-1.tar.gz \
      82528bef29857e239373fcc36732837d743f5a00805d502c70455422ffc97191 /tmp/gnatprove.tgz \
 && mkdir -p .local/gnatprove && tar -xzf /tmp/gnatprove.tgz -C .local/gnatprove && rm /tmp/gnatprove.tgz \
 && .local/gnatprove/gnatprove-x86_64-linux-16.1.0-1/bin/gnatprove --version

# F* 2026.08.30, with the Z3 versions it ships
RUN fetch https://github.com/FStarLang/FStar/releases/download/v2026.08.30/fstar-v2026.08.30-Linux-x86_64.tar.gz \
      fb8dc48fe1a5e7e8fdcd9dc841129e9b10d9ed594c12f52d8ecdb0837754b5ac /tmp/fstar.tgz \
 && mkdir -p .local/fstar && tar -xzf /tmp/fstar.tgz -C .local/fstar && rm /tmp/fstar.tgz \
 && .local/fstar/fstar/bin/fstar.exe --version

# Verus 0.2026.08.30 and the Rust toolchain its version.json names (Verus's INSTALL.md)
RUN curl -fsSL --proto '=https' --tlsv1.2 https://sh.rustup.rs \
      | sh -s -- -y --profile minimal --default-toolchain 1.97.1-x86_64-unknown-linux-gnu \
 && fetch https://github.com/verus-lang/verus/releases/download/release/0.2026.08.30.b432e82/verus-0.2026.08.30.b432e82-x86-linux.zip \
      067f5f72a457fe66b77c0c10b180f2a919a9c7481a8baa024ffc716aa931a41b /tmp/verus.zip \
 && mkdir -p .local/verus && unzip -q /tmp/verus.zip -d .local/verus && rm /tmp/verus.zip \
 && .local/verus/verus-x86-linux/verus --version

# Lean 4.33.1 through elan (the lowering imports only the toolchain's own Std)
RUN curl -fsSL https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh \
      | sh -s -- -y --no-modify-path --default-toolchain leanprover/lean4:v4.33.1 \
 && lean --version

# Rocq 9.2 and Frama-C 33.0 in one opam switch on OCaml 4.14.4, with alt-ergo-free 2.4.3 (never alt-ergo 2.6, which
# is not free for commercial use). opam cannot nest its bwrap sandbox inside a container (opam FAQ). Frama-C's
# opam file needs graphviz (conf-graphviz), installed above.
RUN fetch https://github.com/ocaml/opam/releases/download/2.5.2/opam-2.5.2-x86_64-linux \
      edfca2630c373b44b7ee1c2f81cd8dcf67468d0db57d6c02158de553ac63dbd4 .local/bin/opam \
 && chmod +x .local/bin/opam \
 && opam init -y --bare --disable-sandboxing --no-setup \
 && opam switch create -y default ocaml-base-compiler.4.14.4 \
 && opam pin add -y -n rocq-stdlib.9.2.0 https://github.com/rocq-prover/stdlib/releases/download/V9.2.0/stdlib-9.2.0.tar.gz \
 && opam install -y rocq-core.9.2.0 coq-core.9.2.0 rocq-stdlib why3.1.8.2 frama-c.33.0 alt-ergo-free.2.4.3 \
 && opam clean -a -c -s --logs \
 && why3 config detect \
 && coqc -v && frama-c -version && alt-ergo --version

# Why3's detection cannot read alt-ergo-free's version string (`2.4.3-free`): it registers Alt-Ergo versionless,
# under drivers that emit Alt-Ergo 2.6 input, and 2.4.3 fails every goal Qed leaves open. This is the stanza every
# published table was measured with: Alt-Ergo 2.4.3, driver alt_ergo, a step bound.
RUN printf '%s\n' '[main]' 'magic = 14' 'memlimit = 1000' 'running_provers_max = 2' 'timelimit = 5.000000' '' \
      '[prover]' 'command = "/home/prover/.opam/default/bin/alt-ergo --timelimit %.t %f"' \
      'command_steps = "/home/prover/.opam/default/bin/alt-ergo --steps-bound=%S %f"' 'driver = "alt_ergo"' \
      'in_place = false' 'interactive = false' 'name = "Alt-Ergo"' 'shortcut = "alt-ergo"' 'version = "2.4.3"' \
      > .why3.conf \
 && why3 config list-provers

# t itself: standard-library Python 3.12
COPY --chown=prover:prover . /home/prover/t-proof-engine
WORKDIR /home/prover/t-proof-engine
RUN printf '%s\n' '#!/bin/sh' 'exec python3 /home/prover/t-proof-engine/t/cli.py "$@"' > /home/prover/.local/bin/t \
 && chmod +x /home/prover/.local/bin/t
ENTRYPOINT ["t"]
CMD ["--help"]
