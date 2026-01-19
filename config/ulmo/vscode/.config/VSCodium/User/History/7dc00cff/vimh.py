import os
import json
import csv

# Шлях до папки з JSON-файлами
input_folder = 'ррп_html_result'
# Шлях до результативного CSV
output_csv = 'output.csv'

# Збираємо всі дані сюди
all_rows = []
# Унікальні заголовки
all_columns = set(['section_key'])

# Обробка кожного файлу
for filename in os.listdir(input_folder):
    if filename.endswith('.json'):
        filepath = os.path.join(input_folder, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        for section in data.get('sections', []):
            section_key = section.get('key', '')
            for item in section.get('items', []):
                row = {'section_key': section_key}
                row[item['key']] = item['value']
                all_columns.update(row.keys())
                all_rows.append(row)

# Перетворюємо в список і впорядковуємо заголовки
all_columns = list(all_columns)

# Запис у CSV
with open(output_csv, 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=all_columns)
    writer.writeheader()
    for row in all_rows:
        writer.writerow(row)
