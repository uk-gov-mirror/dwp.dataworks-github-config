#!/bin/bash
TF_REPO_NAME=dataworks-repo-template-terraform
NEW_REPO_NAME=$1

git config --global user.name "${GIT_USERNAME}"
git config --global user.email "${GIT_EMAIL}"

git clone https://github.com/dwp/$NEW_REPO_NAME
cd $NEW_REPO_NAME

git submodule add https://github.com/dwp/dataworks-githooks .githooks
make git-hooks

find ci -type f -exec sed -i '' "s/$TF_REPO_NAME/$NEW_REPO_NAME/g" {} +
find terraform -type f -exec sed -i '' "s/$TF_REPO_NAME/$NEW_REPO_NAME/g" {} +
find aviator.yml -type f -exec sed -i '' "s/$TF_REPO_NAME/$NEW_REPO_NAME/g" {} +

rm initial-commit.sh

git add --all
git commit -m "Renamed pipeline and Terraform to fit repository"
git push --quiet --set-upstream origin initial-commit