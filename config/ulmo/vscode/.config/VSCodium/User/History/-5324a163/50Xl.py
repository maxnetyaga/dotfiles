#!/usr/bin/env python
import logging
import shutil
from datetime import datetime
from pathlib import Path

import html

import click
from colorama import Fore

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

    (RESULT_DIR / "archived").mkdir(parents=True)
    (RESULT_DIR / "present_updated").mkdir(parents=True)
    (RESULT_DIR / "present_notupdated").mkdir(parents=True)
    (RESULT_DIR / "new").mkdir(parents=True)

    origin_index = build_paths_index(origin)
    new_index = build_paths_index(new)

    for path in Path(new).iterdir():
        pass


if __name__ == '__main__':
    sort()
