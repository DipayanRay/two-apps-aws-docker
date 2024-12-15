#!/bin/bash

echo "--------------------------------------------------"
echo "Starting Production Environment"
source $(pwd)/.venv/bin/activate
echo "--------------------------------------------------"
echo "Production Environment Started"
echo "--------------------------------------------------"
echo "Starting Flask App"
echo "--------------------------------------------------"

# Run Gunicorn on the specified port
FLASK_APP=run.py FLASK_DEBUG=False $(pwd)/.venv/bin/gunicorn -w $(($(nproc) * 2 + 1)) -b 0.0.0.0:5000 run:app

echo
echo "Closing Flask App"
echo "--------------------------------------------------"
source deactivate
echo "Closing Production Environment"
echo "--------------------------------------------------"