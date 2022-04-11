gh-login :
	gh auth login --hostname github.com --web --git-protocol https
	gh auth setup-git

gh-create-repo:
	- gh repo create $(github_user)/$(github_repo) --private --source . --push

gh-connect-repo:
	- GH_TOKEN=$(github_token) git remote add origin https://x-access-token:$(github_token)@github.com/$(github_user)/$(github_repo).git
