# to scan everything into the clipboard

# to ready for commit

	ci/do-format-source.sh;

# to make only one version

	rm -rf .git;
	git init;
	git checkout -b main;
	find . -name ".DS_Store" -depth -exec rm {} \;
	find . -exec touch {} \;
	git add .;
	git commit -m "checkpoint commit";

	git archive --output=../caida.zip HEAD;

# to make only one version on github

	rm -rf .git;
	git init;
	git checkout -b main;
	find . -name ".DS_Store" -depth -exec rm {} \;
	find . -exec touch {} \;
	git add .;
	git commit -m "checkpoint commit";
	git remote add origin https://github.com/2n1nyn1n2/caida.git
	git push -u --force origin main;
	git branch --set-upstream-to=origin/main main;
	git pull;git push;
