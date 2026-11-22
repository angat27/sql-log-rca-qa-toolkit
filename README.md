# SQL & Log RCA QA Toolkit

SQL reconciliation queries and a Python log parser designed to support production troubleshooting, data integrity checks, and root cause analysis.

## Contents

- `sql/data_integrity_checks.sql` - Queries for orphaned records, duplicate transactions, balance mismatches, and stuck pending items
- `scripts/log_analyzer.py` - Python script to scan log files for `ERROR`, `CRITICAL`, and `5xx` HTTP responses and summarize findings
- `sample.log` - Sample application log file for testing the script

## Usage

Run the log analyzer against the sample log file:

```bash
python scripts/log_analyzer.py sample.log
```
