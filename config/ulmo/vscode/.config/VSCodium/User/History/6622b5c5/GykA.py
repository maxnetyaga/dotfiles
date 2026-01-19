# /// script
# dependencies = [
#   "pandas",
#   "openpyxl"
# ]
# ///

import os
import json
import pandas as pd

# Шляхи
input_folder = 'input'  # <-- Заміни на свою папку
output_xlsx = 'output.xlsx'            # <-- Куди зберігати результат

# Місце для всіх рядків
all_rows = []
# Усі унікальні заголовки
all_columns = set()

# Прохід по всім JSON-файлам у папці
for filename in os.listdir(input_folder):
    if filename.endswith('.json'):
        filepath = os.path.join(input_folder, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)

        row = {'source_file': filename}  # Додаємо назву файлу

        for section in data.get('sections', []):
            section_key = section.get('key', '')
            for item in section.get('items', []):
                column_name = f"{section_key} | {item['key']}"
                row[column_name] = item.get('value', '')
                if column_name in all_columns:
                    raise Exception()
                all_columns.add(column_name)

        all_rows.append(row)

# Всі колонки впорядковані
all_columns = ['source_file'] + sorted(all_columns)

# Створюємо DataFrame
df = pd.DataFrame(all_rows, columns=all_columns)

# Записуємо у XLSX
df.to_excel(output_xlsx, index=False)
