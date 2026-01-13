| poetry | pip + requirements.txt | 
|:-----|:-----|
|Manages dependencies and virtualenvs automatically|Manual venv and dependency management|
|Uses pyproject.toml + poetry.lock|Uses only requirements.txt|
Auto resolves and locks exact versions (including internal libraries)|Manual version pinning needed, sub dependencies may vary|
|poetry add package-name update config|pip install package-name + manual update|
|Clean dev/prod dependency separation|Needs sperate files (E.g. dev-requirements.txt)|
poetry install sets up full environment|pip install -r requirements.txt installs packages|

```
In standard Python, we use requirements.txt. However, this doesn't "lock" sub-dependencies (the dependencies of your dependencies).

pyproject.toml: Defines your project requirements and build settings.

poetry.lock: Ensures that every person (or Docker container) on your team installs the exact same version of every package, down to the last bit. This prevents the "it works on my machine" problem.
```

