## Onboarding Github

General Github usage notes, tips and tricks.

git clone git@github.com:yourusername/your-repo.git  

cd your-repo  
# make changes...
git add .  

git commit -m "made changes"  
git push  
git clone git@github.com:username/repo.git  
git config --global user.email "username@email.com"  
git config --global user.name username  


# branching
git checkout -b feature/some-cool-thing  
git push -u origin feature/some-cool-thing  

# edit files...
git add .  
git commit -m "Add cool feature"  
git push  

# initiate a repo...
cd ~/my-project  
git init  
git add .  
git commit -m "Initial commit"  
git remote add origin git@github.com:youruser/my-project.git  
git push -u origin main  


# enforce workflows like “no direct pushes to main,” and require approvals:

  Go to your GitHub repo → Settings → Branches  

  Under Branch protection rules, click Add rule  

  Set:  

  main as the branch name  

✅ Require pull request before merging  

✅ Require approvals  

✅ Dismiss stale reviews if pushed  

✅ Require status checks if you’re using CI (optional)  

🔒 This locks main down and ensures all changes go through PRs.  

Use git pull origin main --rebase to keep your feature branches up to date  

Name branches clearly: feature/, fix/, chore/, etc.  

Keep PRs focused and small  

Use gh (GitHub CLI) if you like terminal-based PR flow  
