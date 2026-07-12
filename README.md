# ARC Runner Ubuntu 26.04

Build local

```bash
docker build -t arc-runner .
```

Run

```bash
docker run --rm arc-runner cat /etc/os-release
```

Published image

```
ghcr.io/<owner>/actions-runner:26.04
```

Use with Actions Runner Controller

```yaml
template:
  spec:
    containers:
      - name: runner
        image: ghcr.io/<owner>/actions-runner:26.04
        command:
          - /home/runner/run.sh
```