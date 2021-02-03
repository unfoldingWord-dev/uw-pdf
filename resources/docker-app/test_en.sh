#! /usr/bin/env bash
set -e

# Start the en uW PDF test
cd /app/uw-pdf/public
python3 test_en.py
