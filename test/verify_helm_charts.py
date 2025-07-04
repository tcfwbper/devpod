from pathlib import Path
import yaml
from typing import Any
import re

PROJECT_ROOT_DIR: Path = Path(__file__).resolve().parent.parent
CONFIG_FILE: Path = PROJECT_ROOT_DIR / "test" / "checklist.yaml"

def get_config() -> dict:
    with CONFIG_FILE.open("r") as file:
        return yaml.safe_load(file)

def verify_chart_versions(config: dict) -> bool:
    are_chart_versions_correct = True
    for chart_name in config:
        chart_root: Path = PROJECT_ROOT_DIR / chart_name
        chart_yaml: Path = chart_root / "Chart.yaml"
        with chart_yaml.open("r") as file:
            chart_data: dict = yaml.safe_load(file)
            cur_chart_version = chart_data["version"]
            if cur_chart_version != config[chart_name]["chart"]:
                print(f"Chart version mismatch for {chart_name}: expected {config[chart_name]['chart']}, found {cur_chart_version}")
                are_chart_versions_correct = False
    return are_chart_versions_correct

def parse_key_path(key_path: str) -> list[str | int]:
    tokens = []
    pattern = re.compile(
        r"""
        (?:
            '([^']+)'           # group 1: single-quoted key
            | "([^"]+)"         # group 2: double-quoted key
            | ([a-zA-Z0-9_\-]+) # group 3: plain key
        )
        ((?:\[\d+\])*)          # group 4: array indices
    """,
        re.VERBOSE,
    )

    for part in key_path.split("."):
        m = pattern.fullmatch(part)
        if not m:
            raise ValueError(f"Invalid key_path part: {part}")
        # quoted key
        if m.group(1) is not None:
            tokens.append(m.group(1))
        elif m.group(2) is not None:
            tokens.append(m.group(2))
        # plain key
        elif m.group(3) is not None:
            tokens.append(m.group(3))
        # array indices
        indices = re.findall(r"\[(\d+)\]", m.group(4))
        for idx in indices:
            tokens.append(int(idx))
    return tokens

def get_value_from_dict(values_data: dict, key: str) -> tuple[Any, bool]:
    tokens = parse_key_path(key)
    for token in tokens:
        if not values_data.__contains__(token):
            print(f"Key {key} not found in values.yaml")
            return None, False    
        values_data = values_data[token]
    return values_data, True

def verify_chart_values(config: dict) -> bool:
    are_values_correct = True
    for chart_name in config:
        chart_root: Path = PROJECT_ROOT_DIR / chart_name
        values_yaml: Path = chart_root / "values.yaml"
        with values_yaml.open("r") as file:
            values_data: dict = yaml.safe_load(file)
            # Check if the checklist exists for the chart
            if not config[chart_name].__contains__("checklist"):
                continue
            checklist = config[chart_name]["checklist"]
            # Check if the checklist is a dictionary
            if not isinstance(checklist, dict):
                print(f"Checklist for {chart_name} is not a dictionary")
                are_values_correct = False
                continue
            # Check if the values match the checklist
            for key, value in checklist.items():
                if not isinstance(key, str):
                    print(f"Key {key} in checklist for {chart_name} is not a string")
                    are_values_correct = False
                    continue
                cur_value, get_value_success = get_value_from_dict(values_data, key)
                if not get_value_success:
                    are_values_correct = False
                    continue
                if not cur_value == value:
                    print(f"Values mismatch for {chart_name}: expected {key}={value}, found {cur_value}")
                    are_values_correct = False
    return are_values_correct

if __name__ == "__main__":
    config = get_config()
    result = True
    result = verify_chart_versions(config) and result
    result = verify_chart_values(config) and result
    if not result:
        exit(1)

