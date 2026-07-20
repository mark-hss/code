# ⚡ code

> A working collection of reusable code, operational snippets, experiments, and small utilities.

`code` is a general-purpose repository for sharing practical scripts, notes, helpers, and examples.  
Most content will be **Ruby** and **Bash**, with some **Go** and other tooling where it makes sense.

This repo is not tied to a single application or product. It is a shared workspace for useful code that may support operations, security, automation, troubleshooting, DevSecOps, and day-to-day engineering.

---

## 🧭 Purpose

This repository exists to provide a clean, accessible place to:

- share useful scripts and snippets
- collaborate on small automation tasks
- keep examples in one place
- document repeatable commands and workflows
- provide controlled access to code for team members and trusted collaborators
- avoid burying useful code in tickets, chats, home directories, or one-off notes

If it is useful, repeatable, and safe to share, it probably belongs here.

---

## 🛠️ Primary Languages

| Language | Intended Use |
|---|---|
| Ruby | automation, parsing, API helpers, CLI tools |
| Bash | Linux/macOS administration, glue scripts, operational snippets |
| Go | small compiled tools, network utilities, experiments |
| Markdown | notes, examples, runbooks, usage docs |

---

## 📁 Repository Structure

```text
code/
├── README.md
├── ruby/
│   ├── cli/
│   ├── api/
│   ├── parsing/
│   └── examples/
├── bash/
│   ├── linux/
│   ├── macos/
│   ├── networking/
│   └── security/
├── go/
│   ├── tools/
│   └── experiments/
├── snippets/
│   ├── git/
│   ├── wazuh/
│   ├── checkpoint/
│   ├── azure/
│   └── misc/
├── docs/
│   ├── style.md
│   ├── access.md
│   └── examples.md
└── archive/
```

### Directory intent

| Directory | Purpose |
|---|---|
| `ruby/` | Ruby scripts, helpers, small command-line tools |
| `bash/` | Shell scripts and operational commands |
| `go/` | Go utilities and experiments |
| `snippets/` | Short reusable examples, fragments, command patterns |
| `docs/` | Notes, usage guides, conventions, access information |
| `archive/` | Old code retained for reference but not actively maintained |

---

## 🚀 Getting Started

Clone the repository:

```bash
git clone <repo-url>
cd code
```

Create a branch for your change:

```bash
git checkout -b feature/my-useful-script
```

Add your code:

```bash
git add .
git commit -m "Add useful script"
git push origin feature/my-useful-script
```

Open a pull request or request review according to the team workflow.

---

## ✅ Contribution Guidelines

Before adding code, try to keep it:

- readable
- commented where useful
- safe to run
- free of secrets, tokens, passwords, private keys, or sensitive data
- placed in the right directory
- documented with basic usage examples

For scripts, include a short header where possible:

```bash
#!/usr/bin/env bash
#
# Name: example.sh
# Purpose: Short description of what this script does.
# Usage: ./example.sh <args>
```

For Ruby:

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

# Name: example.rb
# Purpose: Short description of what this script does.
# Usage: ruby example.rb
```

For Go:

```go
go mod init <dir/module>
or better
go mod init github.com/mark-hss/<package>
```

---

## 🔐 Security Rules

Do **not** commit:

- passwords
- API keys
- private keys
- certificates with private material
- production credentials
- customer-sensitive data
- internal-only IP lists unless approved
- exported logs containing sensitive information
- exploit code without clear approval and context

Before pushing, check your changes:

```bash
git diff --cached
```

Optional secret scanning before commit:

```bash
git grep -nEi 'password|passwd|secret|token|apikey|api_key|private key'
```

If you accidentally commit a secret, assume it is compromised and rotate it.

---

## 🧪 Testing

Where practical, scripts should have a basic test or at least a dry-run mode.

Examples:

```bash
./script.sh --help
./script.sh --dry-run
ruby script.rb --help
go test ./...
```

For potentially destructive scripts, include clear warnings and safe defaults.

---

## 🧹 Style

General rules:

- prefer clarity over cleverness
- use meaningful variable names
- include usage examples
- avoid hardcoded environment-specific values
- keep scripts idempotent where possible
- fail safely
- print useful error messages

Bash scripts should generally start with:

```bash
set -euo pipefail
```

Ruby scripts should generally start with:

```ruby
# frozen_string_literal: true
```

---

## 🗂️ Naming Conventions

Use descriptive names:

```text
good:
  wazuh-agent-check.sh
  parse-checkpoint-logs.rb
  azure-route-summary.go

avoid:
  test.sh
  script.rb
  thing.py
  newnew2.sh
```

Use lowercase with hyphens for script names:

```text
verb-target-context.ext
```

Examples:

```text
check-disk-usage.sh
parse-radius-log.rb
list-azure-routes.go
```

---

## 🤝 Collaboration Model

Suggested workflow:

```text
main branch
  stable/shared code

feature branches
  new scripts, changes, experiments

pull requests
  review, discussion, approval, merge
```

Avoid pushing directly to `main` unless agreed by the team.

Recommended branch names:

```text
feature/add-wazuh-check
fix/ruby-parser-error
docs/update-access-notes
experiment/go-port-scanner
```

---

## 📌 Useful Git Commands

Show current status:

```bash
git status
```

Create a branch:

```bash
git checkout -b feature/my-change
```

Pull latest changes:

```bash
git pull
```

Commit changes:

```bash
git add .
git commit -m "Describe the change"
```

Push branch:

```bash
git push -u origin feature/my-change
```

View branches:

```bash
git branch -a
```

Review differences:

```bash
git diff
```

---

## 🧾 Documentation Expectations

Each larger script or tool should include:

```text
Purpose
Requirements
Usage
Example
Expected output
Known limitations
```

Small snippets should include enough context that someone else can safely reuse them later.

---

## ⚠️ Disclaimer

Code in this repository may include experiments, work-in-progress examples, and operational snippets.

Review before use.

Do not run scripts blindly against production systems.

---

## 🧠 Repository Motto

> Useful code, clearly shared, safely reviewed.

