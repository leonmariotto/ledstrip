#!/usr/bin/env python3
"""Convert the CI/PCBWay BOM into a compact Mouser upload CSV."""

import argparse
import csv
import re
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "bom.csv"
OUTPUT = ROOT / "mouser_bom.csv"
EXCEPTIONS = ROOT / "mouser_bom_exceptions.csv"

def expand_references(text):
    result = []
    for item in text.split(","):
        item = item.strip()
        match = re.fullmatch(r"([A-Za-z]+)(\d+)-([A-Za-z]*)(\d+)", item)
        if not match:
            result.append(item)
            continue
        prefix, start, end_prefix, end = match.groups()
        if end_prefix and end_prefix != prefix:
            raise ValueError(f"unsupported reference range: {item}")
        result.extend(f"{prefix}{number}" for number in range(int(start), int(end) + 1))
    return result


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=SOURCE, help="KiCad/PCBWay BOM CSV")
    parser.add_argument("--output", type=Path, default=OUTPUT, help="Mouser-compatible CSV")
    parser.add_argument(
        "--exceptions", type=Path, default=EXCEPTIONS, help="CSV containing unresolved parts"
    )
    return parser.parse_args()


def main():
    args = parse_args()

    grouped = defaultdict(lambda: {"qty": 0, "refs": [], "manufacturer": ""})
    exceptions = []
    with args.source.open(newline="", encoding="utf-8-sig") as handle:
        reader = csv.DictReader(handle)
        required_fields = {"Reference", "Value", "Exclude from BOM", "MPN"}
        missing_fields = required_fields.difference(reader.fieldnames or [])
        if missing_fields:
            missing = ", ".join(sorted(missing_fields))
            raise ValueError(
                f"{args.source} is missing required BOM field(s): {missing}. "
                "Check the KiCad PCBWay BOM preset."
            )

        for row in reader:
            if row["Exclude from BOM"].strip():
                continue
            refs = expand_references(row["Reference"])
            mpn = row["MPN"].strip()
            manufacturer = row.get("Manufacturer", "").strip()
            for ref in refs:
                if not mpn:
                    exceptions.append((ref, 1, row["Value"], "No MPN in schematic BOM data"))
                    continue
                entry = grouped[mpn]
                entry["qty"] += 1
                entry["refs"].append(ref)
                entry["manufacturer"] = manufacturer

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(["Manufacturer Part Number", "Quantity", "Customer Part Number"])
        for mpn, entry in sorted(grouped.items()):
            writer.writerow([mpn, entry["qty"], " ".join(entry["refs"])])

    args.exceptions.parent.mkdir(parents=True, exist_ok=True)
    with args.exceptions.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(["Reference", "Quantity", "Value", "Reason"])
        writer.writerows(exceptions)

    print(f"wrote {len(grouped)} Mouser lines to {args.output}")
    print(f"wrote {len(exceptions)} exception lines to {args.exceptions}")


if __name__ == "__main__":
    main()
