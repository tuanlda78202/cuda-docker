# Poetry

## Table of Contents
- [Installation](#installation)
- [Basic Commands](#basic-commands)
- [Project Setup](#project-setup)
- [Managing Dependencies](#managing-dependencies)
- [Virtual Environments](#virtual-environments)
- [Common Workflows](#common-workflows)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Installation

### Install Poetry
```bash
# Linux, macOS, Windows (WSL)
curl -sSL https://install.python-poetry.org | python3 -

# Windows (PowerShell)
(Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | py -
```

### Verify Installation
```bash
poetry --version
```

## Basic Commands

```bash
# Create new project
poetry new project-name

# Initialize existing project
poetry init

# Install dependencies
poetry install

# Activate virtual environment
poetry shell

# Run a command in virtual environment
poetry run python script.py

# Add dependencies
poetry add package-name

# Remove dependencies
poetry remove package-name

# Update dependencies
poetry update

# Show installed packages
poetry show

# Export requirements.txt
poetry export -f requirements.txt --output requirements.txt
```

## Project Setup

### Initialize a New Project
```bash
mkdir my-project
cd my-project
poetry init
```

### Configure Poetry Settings
```bash
# Store virtual environment in project directory
poetry config virtualenvs.in-project true

# Show current configuration
poetry config --list
```

### Project Structure
```
my-project/
├── pyproject.toml      # Project configuration and dependencies
├── poetry.lock        # Lock file for deterministic builds
├── README.md
├── src/
│   └── my_project/
│       ├── __init__.py
│       └── main.py
└── tests/
    └── test_main.py
```

## Managing Dependencies

### Adding Dependencies
```bash
# Add production dependencies
poetry add pandas numpy matplotlib

# Add development dependencies
poetry add --group dev pytest black flake8

# Add dependencies with specific versions
poetry add requests@^2.28.0
poetry add "requests>=2.28.0,<3.0.0"

# Add dependencies from Git
poetry add git+https://github.com/user/project.git

# Add optional dependencies
poetry add --optional docs sphinx
```

### Updating Dependencies
```bash
# Update all dependencies
poetry update

# Update specific packages
poetry update requests urllib3

# Show outdated packages
poetry show --outdated
```

### Groups of Dependencies
```bash
# Install with specific groups
poetry install --with dev,test

# Install without specific groups
poetry install --without dev,docs

# Add to specific group
poetry add pytest --group test
```

## Virtual Environments

### Managing Virtual Environments
```bash
# Create/activate virtual environment
poetry shell

# Deactivate
exit

# Show environment info
poetry env info

# List all environments
poetry env list

# Remove environment
poetry env remove python3.11

# Use specific Python version
poetry env use python3.11
```

## Common Workflows

### Development Workflow
```bash
# 1. Clone project
git clone project
cd project

# 2. Install dependencies
poetry install

# 3. Activate environment
poetry shell

# 4. Run tests
poetry run pytest

# 5. Format code
poetry run black .
poetry run isort .

# 6. Add new dependency
poetry add new-package

# 7. Update lock file
poetry lock
```

### Creating a Package
```bash
# Build package
poetry build

# Publish to PyPI
poetry publish

# Build and publish
poetry publish --build
```

## Best Practices

### Version Control
- Always commit both `pyproject.toml` and `poetry.lock`
- Use `.gitignore` for virtual environment:
```gitignore
.venv/
dist/
*.pyc
__pycache__/
```

### Dependency Management
- Use semantic versioning for dependencies
- Group dependencies logically (dev, test, docs)
- Regular updates for security patches
- Lock file for reproducible builds

### Environment Variables
- Use `.env` file for local development
- Never commit sensitive information
- Use `python-dotenv` for environment variables

## Troubleshooting

### Common Issues and Solutions

1. **Lock file conflicts**
```bash
# Reset lock file
poetry lock --no-update
```

2. **Cache issues**
```bash
# Clear Poetry cache
poetry cache clear . --all
```

3. **Environment issues**
```bash
# Remove and recreate environment
poetry env remove python3.11
poetry install
```

4. **Dependency resolution errors**
```bash
# Show verbose output
poetry install -vvv

# Update Poetry itself
poetry self update
```

### Debug Mode
```bash
# Run commands in debug mode
poetry --debug install
poetry --debug add package-name
```

## Example pyproject.toml

```toml
[tool.poetry]
name = "project-name"
version = "0.1.0"
description = "Project description"
authors = ["Your Name <your.email@example.com>"]
readme = "README.md"
packages = [{include = "my_package"}]

[tool.poetry.dependencies]
python = "^3.11"
requests = "^2.28.0"
pandas = "^2.0.0"

[tool.poetry.group.dev.dependencies]
pytest = "^7.3.1"
black = "^23.3.0"
flake8 = "^6.0.0"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"

[tool.poetry.scripts]
my-command = "my_package.cli:main"
```

## Useful Resources

- [Official Poetry Documentation](https://python-poetry.org/docs/)
- [Poetry GitHub Repository](https://github.com/python-poetry/poetry)
- [Python Packaging User Guide](https://packaging.python.org/)