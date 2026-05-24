# Shell scripts
find . -name "*.sh" -print0 | xargs -0 shfmt -w -i 2

# Json files
find . -name "*.json" -print0 | xargs -0 npx prettier --write