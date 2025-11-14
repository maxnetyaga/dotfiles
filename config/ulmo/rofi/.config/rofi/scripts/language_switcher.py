#!/bin/python
# Author: https://github.com/caschb/rofi-language-switcher/blob/main/language_switcher.py
import os
import csv
from pathlib import Path
import sys

class Rofi:
    def __init__(self, args=None):
        self.args = args

    def select(self, prompt, options, selected):
        items = "\n".join(options)
        ans = os.popen(f"echo '{items}' | rofi -dmenu -p '{prompt}' -format i \
            -selected-row {selected} -me-select-entry ''\
            -me-accept-entry 'MousePrimary' {self.args}").read().strip()

        if ans == "":
            return -1

        return int(ans)


def show_menu(languages: list[tuple[str, str]]):
    rofi = Rofi()
    tmp = Path("~/.config/rofi/scripts/lang").expanduser()
    tmp.touch()

    names, codes = zip(*languages)

    code = tmp.read_text()
    code_i = codes.index(code) if code and code in codes else 0

    code_i = rofi.select("Select layout", names, code_i)
    code = tmp.write_text(codes[code_i])

    if code_i != -1:
        os.popen(f"swaymsg 'input * xkb_layout \"{codes[code_i]}\"'")
        os.putenv("XKB_LAYOUT", codes[code_i])
        # os.environ["XKB_LAYOUT"] = codes[cur_code_i]


if (__name__ == "__main__"):
    languages_file = os.path.join(sys.path[0], 'languages.txt')
    languages = []
    with open(languages_file, 'r', encoding='utf8') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            languages.append((row['language'], row['code']))

    show_menu(languages)
