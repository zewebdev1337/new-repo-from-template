# New Repo from Template

## Overview

New Repo from Template is a command line utility designed to simplify the process of creating a new GitHub repo from your existing template repositories. This tool leverages the GitHub CLI to get a new repo up and running with one command. Perfect for devs who frequently initialize new projects based on predefined templates.

### NOTE: No git LFS support.

## Features

- **Interactive Mode**: Guided prompts to select a template, define repository details, and set the local repository path.
- **Command-Line Arguments**: Support for creating a repository with parameters for template, name, description, destination, and visibility.
- **Visibility Inheritance**: Option to inherit visibility settings from the template repository.
- **Extended Repository Support**: Ability to create a repository from any GitHub repository, not limited to owned templates or template repositories (via parameters only).

## Install

1. Clone the repository or download the `new-repo-from-template.sh` and `install.sh` scripts to your local machine.
2. Navigate to the directory containing the scripts.
3. :
   ```bash
   sudo ./install.sh
   ```

## Usage

To create a new repository from a template, you can use the tool in interactive mode or pass parameters directly:

### Interactive Mode

Simply run the command without arguments:

```bash
new-repo-from-template
```

Follow the interactive prompts to select a template repository, define the new repository details, and set the local repository path.

### Command-Line Arguments

To create a repository with parameters:

```bash
new-repo-from-template --template=<template-repo> --name=<new-repo-name> [--description=<description>] [--destination=<directory>] [--visibility=<public|private|inherit>]
```

- `--template`, `-t`: Specify the template repository (mandatory if using options).
- `--name`, `-n`: Specify the name of the new repository (mandatory if using options).
- `--description`, `-d`: Specify the description of the new repository (optional).
- `--destination`, `-D`: Specify the destination directory for the local repository (optional).
- `--visibility`, `-v`: Specify the visibility of the new repository (`public`, `private`, `inherit`) (optional).

### Help

To display the help message:

```bash
new-repo-from-template --help
```

## Uninstall

```bash
sudo ./uninstall.sh
```

## Dependencies

- Git
- GitHub CLI

## Support

For support, questions, or contributions, please open an issue or submit a pull request.

## TODO

- Code cleanup and refactoring.
- Group functionality into functions for better maintainability.

## License

This project is licensed under the MIT License - see the LICENSE file for details.