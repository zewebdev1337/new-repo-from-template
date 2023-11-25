#!/bin/bash

NOTE="NOTE: Running with parameters can download other people's repos, even non-template repos, but interactive mode only shows your template repos."
# Function to display help message
show_help() {
    echo "Usage: $0 [arguments]"
    echo "Arguments:"
    echo "  -t, --template=REPO     Specify the template repository as 'user/repo' (mandatory if using arguments)"
    echo "  -n, --name=NAME         Specify the name of the new repository (mandatory if using arguments)"
    echo "  -d, --description=DESC  Specify the description of the new repository (optional)"
    echo "  -D, --destination=DIR   Specify the destination directory for the local repository (optional, defaults to .)"
    echo "  -v, --visibility=VIS    Specify the visibility of the new repository (public, private, inherit) (optional, defaults to 'Inherit')"
    echo "  -h, --help              Display this help message and exit"
    echo
    echo "If no options are provided, an interactive prompt will guide you through the process."
    echo ${NOTE}
}

GITHUB_USER=$(gh api user --jq .login)

# Function to fetch visibility from the GitHub API
fetch_visibility() {
    local repo_full_name="$1"
    gh api "repos/${repo_full_name}" --jq '.visibility' 2>/dev/null || echo "public"
}

# Check for dependencies
if ! command -v git &> /dev/null; then
    echo "git could not be found. Please install git."
    exit 1
fi

if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) could not be found. Please install GitHub CLI."
    exit 1
fi

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t=*|--template=*)
            TEMPLATE="${1#*=}"
            shift # past argument
            ;;
        -n=*|--name=*)
            NEW_REPO="${1#*=}"
            shift # past argument
            ;;
        -d=*|--description=*)
            NEW_REPO_DESCRIPTION="${1#*=}"
            shift # past argument
            ;;
        -D=*|--destination=*)
            DEST_DIR="${1#*=}"
            shift # past argument
            ;;
        -v=*|--visibility=*)
            NEW_REPO_VISIBILITY="${1#*=}"
            shift # past argument
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            show_help >&2
            exit 1
            ;;
    esac
done

# Check for mandatory parameters if any parameters are provided
if [[ -n "$TEMPLATE" ]] || [[ -n "$NEW_REPO" ]]; then
    if [[ -z "$TEMPLATE" ]] || [[ -z "$NEW_REPO" ]]; then
        echo "Error: --template and --name are mandatory when using options." >&2
        show_help >&2
        exit 1
    fi
else
  # Interactive mode
  if [[ -z "$TEMPLATE" ]] && [[ -z "$NEW_REPO" ]]; then

    echo ${NOTE}
    echo "Fetching template repositories..."
    PAGE=1
    TEMPLATE_REPOS=()
    while : ; do
      PAGE_REPOS=$(gh api "user/repos?per_page=100&page=$PAGE" --jq '.[] | select(.is_template==true) | .full_name')
      if [[ -z "$PAGE_REPOS" ]]; then
        break
      fi
      TEMPLATE_REPOS+=($PAGE_REPOS)
      ((PAGE++))
    done

    if [ ${#TEMPLATE_REPOS[@]} -eq 0 ]; then
      echo "No template repositories found."
      exit 1
    fi

    echo "Select a template repository:"
    select TEMPLATE in "${TEMPLATE_REPOS[@]}"; do
      if [ -n "$TEMPLATE" ]; then
        break
      else
        echo "Invalid selection. Please try again."
      fi
    done

    read -p "Enter a name for the new repository: " NEW_REPO
    read -p "Enter a description for the new repository (Defaults to: Created from $TEMPLATE template): " NEW_REPO_DESCRIPTION

    if [[ -z "$NEW_REPO_DESCRIPTION" ]]; then
        NEW_REPO_DESCRIPTION="Created from $TEMPLATE template"
    fi

    echo "Select visibility for the new repository:"
    echo "1) inherit"
    echo "2) public"
    echo "3) private"
    echo -n " "

    read -p "Select visibility for the new repository(1-3, defaults to: inherit):" -e REPLY
    case $REPLY in
        1) NEW_REPO_VISIBILITY="inherit";;
        2) NEW_REPO_VISIBILITY="public";;
        3) NEW_REPO_VISIBILITY="private";;
        "") NEW_REPO_VISIBILITY="inherit"; echo "Visibility set to default: 'inherit'";;
        *) echo "Invalid selection. Please try again."; exit 1;;
    esac


    read -p "Select a directory for the repository (defaults to: .): " DEST_DIR
    DEST_DIR=${DEST_DIR:-$(pwd)}
  fi

  # If visibility is "inherit", fetch the visibility from the template repository
  if [[ "$NEW_REPO_VISIBILITY" == "inherit" ]]; then
      NEW_REPO_VISIBILITY=$(fetch_visibility "$TEMPLATE")
  fi

  # Validate visibility
  if ! [[ "$NEW_REPO_VISIBILITY" =~ ^(public|private)$ ]]; then
      echo "Error: Invalid visibility. Must be 'public', 'private', or 'inherit'."
      exit 1
  fi
fi

# If visibility is "inherit", fetch the visibility from the template repository
if [[ "$NEW_REPO_VISIBILITY" == "inherit" ]]; then
  NEW_REPO_VISIBILITY=$(fetch_visibility "$TEMPLATE")
fi

# Validate visibility
if ! [[ "$NEW_REPO_VISIBILITY" =~ ^(public|private)$ ]]; then
  echo "Error: Invalid visibility. Must be 'public', 'private', or 'inherit'."
  exit 1
fi

# Set default description if none is provided
if [[ -z "$NEW_REPO_DESCRIPTION" ]]; then
  NEW_REPO_DESCRIPTION="Created from $TEMPLATE template"
fi

# Clone the template repository to the destination directory
DEST_DIR=${DEST_DIR:-$(pwd)}
git clone "git@github.com:${TEMPLATE}.git" "${DEST_DIR}/${NEW_REPO}"

# Create the new repository on GitHub
gh repo create "${NEW_REPO}" --description "${NEW_REPO_DESCRIPTION}" --${NEW_REPO_VISIBILITY} --confirm

# Change to the destination directory and remove the original .git directory
cd "${DEST_DIR}/${NEW_REPO}"
rm -rf .git

# Initialize a new git repository and push to the new GitHub repository
git init
git add .
git commit -m "Initial commit from template"
git branch -M main
git remote add origin "git@github.com:${GITHUB_USER}/${NEW_REPO}.git"
git push -u origin main

echo "

${NEW_REPO_VISIBILITY} repo '${NEW_REPO}' created from template '${TEMPLATE}'. Local clone is set up at '${DEST_DIR}${NEW_REPO}'."