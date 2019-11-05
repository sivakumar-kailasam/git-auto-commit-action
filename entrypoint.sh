#!/bin/sh
set -eu

# Set up .netrc file with GitHub credentials
git_setup ( ) {
  cat <<- EOF > $HOME/.netrc
        machine github.com
        login $GITHUB_ACTOR
        password $GITHUB_TOKEN

        machine api.github.com
        login $GITHUB_ACTOR
        password $GITHUB_TOKEN
EOF
    chmod 600 $HOME/.netrc

    git config --global user.email "actions@github.com"
    git config --global user.name "GitHub Actions"
}

echo "INPUT_BRANCH value: $INPUT_BRANCH";

# Switch to branch from current Workflow run
if [ -z ${INPUT_BRANCH} ];
then 
  git checkout master
else 
  git checkout $INPUT_BRANCH
fi
    
# Adds untracked files with an intend to add so that they show up on `git diff`
if [ -z ${INPUT_FILE_PATTERN+x} ];
then
    git add -N .
else
    echo "INPUT_FILE_PATTERN value: $INPUT_FILE_PATTERN";
    git add -N $INPUT_FILE_PATTERN
fi

# This section only runs if there have been file changes
echo "Checking for uncommitted changes in the git working tree."
if ! git diff --quiet
then
    git_setup
    
    if [ -z ${INPUT_FILE_PATTERN+x} ];
    then
        git add .
    else
        echo "INPUT_FILE_PATTERN value: $INPUT_FILE_PATTERN";
        git add $INPUT_FILE_PATTERN
    fi

    git commit -m "$INPUT_COMMIT_MESSAGE" --author="$GITHUB_ACTOR <$GITHUB_ACTOR@users.noreply.github.com>"

    git push --set-upstream origin "HEAD:$INPUT_BRANCH"
else
    echo "Working tree clean. Nothing to commit."
fi
