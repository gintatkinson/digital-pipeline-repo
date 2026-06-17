#!/usr/bin/env python3
# Copyright Gint Atkinson, gint.atkinson@gmail.com

import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../parity_auditor/src")))

from parity_auditor.cli import main

if __name__ == "__main__":
    main()
