# /// script
# dependencies = [
#   "pandas",
#   "openpyxl"
# ]
# ///

import os
import json
import pandas as pd

input_folder = 'input'  # <-- Replace with your folder
output_xlsx = 'output.xlsx'

all_rows = []
all_columns = set()

for filename in os.listdir(input_folder):
    if filename.endswith('.json'):
        filepath = os.path.join(input_folder, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)

        row = {'source_file': filename}
        section_counters = {}

        for section in data.get('sections', []):
            section_key = section.get('key', '')
            section_counters[section_key] = section_counters.get(section_key, 0) + 1
            numbered_section_key = f"{section_key}#{section_counters[section_key]}"

            for item in section.get('items', []):
                column_name = f"{numbered_section_key} | {item['key']}"
                row[column_name] = item.get('value', '')
                # if column_name in all_columns:
                #     print(column_name)
                #     raise Exception()
                all_columns.add(column_name)

        all_rows.append(row)

all_columns = ['source_file'] + sorted(all_columns)

df = pd.DataFrame(all_rows, columns=all_columns)
df.to_excel(output_xlsx, index=False)
