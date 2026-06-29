# GitHub Self-Hosted Runners

Notes for setting up, running, testing, and managing GitHub self-hosted runners.

These notes are aimed at a simple lab runner, such as a Raspberry Pi, small Linux VM, or spare host.

---

## What is a self-hosted runner?

A GitHub self-hosted runner is a machine you control that GitHub Actions can send jobs to.

The runner does not do anything by itself. It waits for jobs.

When the runner shows:

```text
Listening for Jobs
```

that means it is healthy and idle.

A workflow must target the runner using `runs-on`.

Example:

```yaml
runs-on: self-hosted
```

or with labels:

```yaml
runs-on: [self-hosted, linux, ARM64]
```

---

## Basic workflow

```text
GitHub workflow triggered
        ↓
GitHub finds a matching runner
        ↓
Runner receives the job
        ↓
Runner runs the workflow steps locally
        ↓
Logs/results are sent back to GitHub
```

The runner usually connects outbound to GitHub, so inbound firewall rules are normally not required.

---

## Where to create a runner

For a repo-level runner:

```text
Repo → Settings → Actions → Runners → New self-hosted runner
```

For an org-level runner:

```text
Org → Settings → Actions → Runners → New runner
```

For learning, start with a repo-level runner attached to a private test repo.

---

## Recommended lab setup

Use:

```text
Dedicated Linux host
Dedicated low-privilege user
Private test repo
No production secrets
No root runner
Custom label such as lab or pi
```

Avoid:

```text
Running jobs as root
Using a sensitive workstation
Using public repos at first
Giving the runner broad sudo access
Putting production secrets on the host
```

---

## Create a runner user

On the runner host:

```bash
sudo useradd -m -s /bin/bash github-runner
sudo passwd github-runner
```

Switch to the runner user:

```bash
sudo su - github-runner
```

Create the runner directory:

```bash
mkdir actions-runner
cd actions-runner
```

---

## Install the runner

GitHub provides the exact commands on the runner setup page.

They usually look like this:

```bash
curl -o actions-runner-linux-arm64.tar.gz -L https://github.com/actions/runner/releases/download/...
tar xzf ./actions-runner-linux-arm64.tar.gz
./config.sh --url https://github.com/ORG/REPO --token GENERATED_TOKEN
```

For a Raspberry Pi, choose the ARM64 runner if the OS is 64-bit.

During setup, add useful labels:

```text
self-hosted
linux
ARM64
pi
lab
```

---

## Run interactively first

Before installing as a service, test it interactively:

```bash
./run.sh
```

Expected output:

```text
Connected to GitHub
Listening for Jobs
```

This means the runner is online and waiting.

---

## Minimal test workflow

Create this file in the repo:

```text
.github/workflows/pi-runner-test.yml
```

Content:

```yaml
name: Pi runner test

on:
  workflow_dispatch:

jobs:
  hello-pi:
    runs-on: self-hosted

    steps:
      - name: Say hello
        run: |
          echo "Hello from the Raspberry Pi runner"
          hostname
          whoami
          uname -a
          pwd
```

Commit and push:

```bash
git add .github/workflows/pi-runner-test.yml
git commit -m "ci: add pi runner test workflow"
git push
```

Run it from GitHub:

```text
Repo → Actions → Pi runner test → Run workflow
```

---

## Using labels

To target a specific runner, use labels.

Example:

```yaml
runs-on: [self-hosted, linux, ARM64, pi]
```

The job will only run on a runner that has all those labels.

If the labels do not match, the job may sit queued forever.

To check labels:

```text
Repo or Org → Settings → Actions → Runners → select runner
```

---

## Install runner as a service

Once `./run.sh` works, stop it:

```text
Ctrl+C
```

From the runner directory:

```bash
cd ~/actions-runner
sudo ./svc.sh install
sudo ./svc.sh start
sudo ./svc.sh status
```

Useful commands:

```bash
sudo ./svc.sh stop
sudo ./svc.sh start
sudo ./svc.sh restart
sudo ./svc.sh status
```

Watch logs:

```bash
journalctl -u 'actions.runner*' -f
```

List runner services:

```bash
systemctl list-units 'actions.runner*'
```

Check status directly:

```bash
sudo systemctl status 'actions.runner*'
```

---

## Remove a runner

Stop the service:

```bash
cd ~/actions-runner
sudo ./svc.sh stop
sudo ./svc.sh uninstall
```

Remove runner registration:

```bash
./config.sh remove
```

GitHub may ask for a removal token from:

```text
Repo/Org → Settings → Actions → Runners
```

---

## Common problems

### Runner says “Listening for Jobs”

This is normal.

It means:

```text
Runner is online
Runner is idle
No matching workflow job has been sent yet
```

Trigger a workflow that uses:

```yaml
runs-on: self-hosted
```

or the correct labels.

---

### Workflow says required property `jobs` is missing

The workflow YAML is probably indented incorrectly.

Correct:

```yaml
name: Pi runner test

on:
  workflow_dispatch:

jobs:
  hello-pi:
    runs-on: self-hosted
    steps:
      - run: echo "hello"
```

Wrong:

```yaml
name: Pi runner test

on:
  workflow_dispatch:

  jobs:
    hello-pi:
      runs-on: self-hosted
```

`jobs:` must be at the top level, not indented under `on:`.

---

### Job is queued forever

Check:

```text
Runner is online
Workflow labels match runner labels
Runner is attached to the repo or org
Org runner group allows the repo
Actions are enabled for the repo
Runner is not already busy
```

Try the simplest target first:

```yaml
runs-on: self-hosted
```

Then add labels later.

---

### Runner works interactively but not as a service

Check service status:

```bash
cd ~/actions-runner
sudo ./svc.sh status
```

Check logs:

```bash
journalctl -u 'actions.runner*' -f
```

Restart:

```bash
sudo ./svc.sh restart
```

---

### Permission issues

Avoid running the runner as root.

Use a dedicated user such as:

```text
github-runner
```

If jobs need specific tools, install those tools on the runner host or use a setup step in the workflow.

---

## Safer runner practices

Use private repos while learning.

Prefer specific labels:

```yaml
runs-on: [self-hosted, linux, ARM64, pi, lab]
```

Avoid overly broad use:

```yaml
runs-on: self-hosted
```

Do not store secrets directly on the runner host unless necessary.

Do not run untrusted pull requests on a self-hosted runner.

Keep the host patched:

```bash
sudo apt update
sudo apt upgrade
```

Keep the runner updated when GitHub prompts for updates.

---

## Useful test workflow with checkout

```yaml
name: Self-hosted runner test

on:
  workflow_dispatch:
  push:

jobs:
  test:
    runs-on: [self-hosted, linux]

    steps:
      - name: Runner info
        run: |
          echo "Hello from self-hosted runner"
          hostname
          whoami
          uname -a
          pwd

      - name: Checkout repo
        uses: actions/checkout@v4

      - name: List files
        run: |
          ls -la
```

---

## Useful commands

From the runner directory:

```bash
./run.sh
sudo ./svc.sh install
sudo ./svc.sh start
sudo ./svc.sh stop
sudo ./svc.sh restart
sudo ./svc.sh status
sudo ./svc.sh uninstall
./config.sh remove
```

Systemd:

```bash
systemctl list-units 'actions.runner*'
sudo systemctl status 'actions.runner*'
journalctl -u 'actions.runner*' -f
```

GitHub CLI:

```bash
gh workflow list
gh workflow run "Pi runner test"
gh run list
gh run watch
```

---

## Quick mental model

```text
Runner online + listening
        +
Workflow with matching runs-on
        =
Job runs on your machine
```

If nothing is happening, the runner is usually fine. It is just waiting for a matching job.

