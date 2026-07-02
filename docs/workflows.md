#Workflow YAML
This is an example workflow to deploy a github repo to a webserver (WWW_HOST)

This requires github secrets to pass the required variables.

```yaml
name: Deploy to website

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repo
        uses: actions/checkout@v4

      - name: Configure SSH key
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.DH_KEY }}" > ~/.ssh/server_key
          chmod 600 ~/.ssh/server_key
          ssh-keyscan -H "${{ secrets.WWW_HOST }}" >> ~/.ssh/known_hosts

      - name: Deploy repo to website.com/public
        run: |
          rsync -avz \
            --exclude ".git/" \
            --exclude ".github/" \
            --exclude "README.md" \
            --exclude ".gitignore" \
            -e "ssh -i ~/.ssh/server_key" \
            ./ \
            "${{ secrets.WWW_USER }}@${{ secrets.WWW_HOST }}:${{ secrets.WWW_PATH }}"
```
