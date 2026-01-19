#!/usr/bin/env python
import json
import logging
import shutil
from datetime import datetime
from pathlib import Path

import click
from bs4 import BeautifulSoup, Tag
from colorama import Fore
from deepdiff import DeepDiff

from html_parser.extractors import extract_main_attributes as extract

logging.basicConfig(
    level=logging.DEBUG,
    format='[%(asctime)s] %(levelname)s in %(module)s: %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)  # Module-specific logger


def get_num(name):
    return name.split("_")[0]


def get_date(name):
    return datetime.fromisoformat(name.split("_")[1].replace("_", "-"))


def build_paths_index(dir: Path):
    index = {}
    for path in dir.iterdir():
        num = get_num(path.stem)
        if num in index:
            newest = max(path, index[num],
                         key=lambda path: get_date(path.stem))
            logger.warning(
                f"{Fore.GREEN}Файл для ділянки {num} повторюється у теці.\n{Fore.RESET}"
                f"Останній індексований файл: {index[num]}.\n"
                f"Поточний файл: {path}.\n"
                f"Використовую новіший для порівняння: {newest}")
            index[num] = newest
        else:
            index[num] = path
    return index


@click.command()
@click.option('-o',
              '--origin',
              help='Path to old directory.',
              type=click.Path(file_okay=False, path_type=Path),
              required=True)
@click.option('-n',
              '--new',
              help='Path to directory with files to sort.',
              type=click.Path(file_okay=False, path_type=Path),
              required=True)
def sort(origin, new):
    RESULT_DIR = Path("sorted")
    ARCHIVED = (RESULT_DIR / "archived")
    MODIFIED = (RESULT_DIR / "modified")
    UNMODIFIED = (RESULT_DIR / "unmodified")
    NEW = (RESULT_DIR / "new")

    if RESULT_DIR.exists():
        print('"sorted" directory exists. Overwrite? (y/n): ', end="")
        while True:
            answear = input()
            if answear in ["y", "n"]:
                break
        if answear == "y":
            shutil.rmtree(RESULT_DIR)
        else:
            return

    ARCHIVED.mkdir(parents=True)
    MODIFIED.mkdir(parents=True)
    UNMODIFIED.mkdir(parents=True)
    NEW.mkdir(parents=True)

    origin_index: dict[str, Path] = build_paths_index(origin)
    origin_keys = origin_index.keys()
    new_index: dict[str, Path] = build_paths_index(new)
    new_keys = new_index.keys()

    archived = origin_keys - new_keys
    for num in archived:
        shutil.copy2(origin_index[num], ARCHIVED)

    new = new_keys - origin_keys
    for num in new:
        shutil.copy2(new_index[num], NEW)

    # modified & unmodified
    DIFF_TRIGGERS = [
        "Відомості про земельну ділянку/Цільове призначення",
        "Відомості про земельну ділянку/Форма власності",
        "Відомості про нормативно грошову оцінку ділянки/Значення, гривень",
    ]
    rest = new_keys & origin_keys
    for num in rest:
        old = origin_index[num]
        new = new_index[num]
        old_table = BeautifulSoup(old.read_text(encoding="utf-8"), "lxml") \
            .find("table")
        new_table = BeautifulSoup(new.read_text(encoding="utf-8"), "lxml") \
            .find("table")

        if not isinstance(old_table, Tag):
            logger.warning(
                f"{Fore.RED}No table in old table {old}!{Fore.RESET}")
            return
        if not isinstance(new_table, Tag):
            logger.warning(
                f"{Fore.RED}No table in new table {new}!{Fore.RESET}")
            return

        print(num)
        old_extracted = extract(old_table)
        new_extracted = extract(new_table)
        if old_extracted == new_extracted:
            print("YEE")
        else:
            print("NOO")
            diff = DeepDiff(old_extracted, new_extracted)
            print(json.dumps(DeepDiff(old_extracted, new_extracted),
                  indent=4, ensure_ascii=False))


if __name__ == '__main__':
    sort()
