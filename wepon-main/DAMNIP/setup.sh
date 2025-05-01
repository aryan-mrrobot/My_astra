#!/bin/bash

pip install pipenv

pipenv install shodan==0.17.0 httpx==0.21.1 nuclei==2.6.0 --dev

pipenv lock

pipenv run pipenv_to_requirements --freeze | pipenv run shiv --compile-pyc -o bundled_script.py -e your_script:main -

echo "Setup complete. Run the bundled script using:"
echo "  ./bundled_script.py"
