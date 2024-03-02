#!/bin/bash


# Update the repository
git pull

# Add all changes to the staging area
git add .

# Commit the changes with a custom message
git commit -m "Update files"

# Push the changes to the remote repository
git push