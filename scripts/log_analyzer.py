import re
import sys
from collections import Counter
from pathlib import Path


def analyze_logs(log_file_path: str) -> None:
    path = Path(log_file_path)
    if not path.exists():
        print(f"Log file not found: {log_file_path}")
        return

    error_pattern = re.compile(r"\b(ERROR|CRITICAL|5\d{2})\b")
    error_counts = Counter()
    total_lines = 0
    matched_lines = 0

    with path.open("r", encoding="utf-8", errors="replace") as file:
        for line in file:
            total_lines += 1
            match = error_pattern.search(line)
            if match:
                matched_lines += 1
                error_counts[match.group(1)] += 1
                print(f"[Line {total_lines}] {line.strip()}")

    print("\n--- Incident Log Summary ---")
    print(f"Total lines scanned : {total_lines}")
    print(f"Error/5xx matches   : {matched_lines}")
    for key, count in error_counts.items():
        print(f"  {key}: {count}")


if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else "sample.log"
    analyze_logs(target)
