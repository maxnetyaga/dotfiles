import sys
import os
from pathlib import Path
import shutil
import subprocess
import re
import json
import zipfile
from platformdirs import user_desktop_dir, user_data_dir

from bs4.element import NavigableString

from PyQt5.QtCore import QObject, QThread, pyqtSignal, Qt
from PyQt5.QtGui import QColor, QIcon, QPalette, QBrush
from PyQt5.QtWidgets import (
    QTableWidgetItem,
    QHeaderView,
    QAbstractItemView,
    QApplication,
    QFileDialog,
    QFrame,
    QLabel,
    QTableWidget,
    QMainWindow,
    QMessageBox,
    QPushButton,
    QVBoxLayout,
    QWidget,
)
from bs4 import BeautifulSoup, Tag

icon_path = Path(__file__).parent / 'app_icon.png'
print(Path(__file__).parent)

TMP_PATH = Path(user_data_dir()) / 'GeoInfo' / 'PropertyRegisterProcessor'
TMP_RAW_PATH = TMP_PATH / 'raw'

POPPLER_PATH = Path(__file__).parent / 'poppler/Library/bin/pdftohtml.exe'

CONFIG_PATH = Path(__file__).parent / 'config'
PATTERNS_TO_REMOVE_PATH = CONFIG_PATH / 'patterns_to_remove.json'
FIELDS_TO_REMOVE_PATH = CONFIG_PATH / 'fields_to_remove.json'


def load_config():
    if not PATTERNS_TO_REMOVE_PATH.is_file():
        raise Exception('Файл з налаштуваннями видалення шаблонів відсутній!')
    if not FIELDS_TO_REMOVE_PATH.is_file():
        raise Exception('Файл з налаштуваннями видалення полів відсутній!')

    try:
        patterns_to_remove: list[str] = json.loads(
            PATTERNS_TO_REMOVE_PATH.read_text(encoding='utf8')
        )
    except Exception:
        raise Exception(
            'Файл з налаштуваннями видалення шаблонів нe у json форматі!'
        )

    try:
        fields_to_remove: list[str] = json.loads(
            FIELDS_TO_REMOVE_PATH.read_text(encoding='utf8')
        )
    except Exception:
        raise Exception(
            'Файл з налаштуваннями видалення полів нe у json форматі!'
        )

    if not isinstance(patterns_to_remove, list):
        raise Exception(
            'Файл з налаштуваннями видалення шаблонів містить не список!'
        )

    if not isinstance(fields_to_remove, list):
        raise Exception(
            'Файл з налаштуваннями видалення полів містить не список!'
        )

    if not all([isinstance(pattern, str) for pattern in patterns_to_remove]):
        raise Exception(
            'Список з файлу налаштування видалення шаблонів має містити лише строки!'
        )

    if not all([isinstance(field, str) for field in fields_to_remove]):
        raise Exception(
            'Список з файлу налаштування видалення полів має містити лише строки!'
        )

    try:
        patterns_to_remove_regexps = [re.compile(p) for p in patterns_to_remove]
    except Exception:
        raise Exception(
            'Файл з налаштуваннями видалення шаблонів містить невалідні регулярні вирази!'
        )

    return (patterns_to_remove_regexps, fields_to_remove)


FIELD_REMOVE_INTERVAL = 10


# Worker thread for processing files
class FileProcessor(QObject):
    processed = pyqtSignal(int, bool)  # filename, content
    progress = pyqtSignal(int)
    done = pyqtSignal()

    def __init__(self, files: list[Path], patterns_to_remove, fields_to_remove):
        super().__init__()
        self.patterns_to_remove = patterns_to_remove
        self.fields_to_remove = fields_to_remove
        self.files = files
        self._stop = False

    def run(self):
        for file_i, file_path in enumerate(self.files):
            output_tmp_path = (TMP_PATH / file_path.name).with_suffix('.html')

            if self._stop:
                break

            creationflags = 0
            if sys.platform == 'win32':
                creationflags = subprocess.CREATE_NO_WINDOW

            convertion_process = subprocess.run(
                [
                    str(POPPLER_PATH.relative_to(Path(__file__).parent)),
                    '-s',
                    '-i',
                    '-noframes',
                    str(file_path),
                    str(TMP_RAW_PATH / file_path.with_suffix('.html').name),
                ],
                capture_output=True,
                text=True,
                creationflags=creationflags,
            )
            if convertion_process.returncode != 0:
                self.processed.emit(file_i, False)
                return

            if output_tmp_path.is_file():
                output_tmp_path.unlink()
            shutil.move(next(TMP_RAW_PATH.iterdir()), output_tmp_path)

            soup = BeautifulSoup(output_tmp_path.read_text('utf8'), 'lxml')
            for element in soup.descendants:
                if isinstance(element, NavigableString):
                    new_text = element.get_text(strip=True, separator=' ')
                    for pattern in self.patterns_to_remove:
                        new_text = pattern.sub('$ВИДАЛЕНО$', new_text)
                        # print(new_text)
                    element.replace_with(NavigableString(new_text))

            if soup.body is None:
                self.processed.emit(file_i, False)
                return

            for page in soup.body.find_all('div'):
                if not isinstance(page, Tag):
                    continue
                tops_to_remove: list[int] = []
                for p in page.find_all('p'):
                    if not isinstance(p, Tag):
                        continue

                    styles = p.attrs['style']
                    styles = [
                        style.split(':') for style in str(styles).split(';')
                    ]
                    styles_dict: dict[str, str] = {}
                    for j in range(len(styles)):
                        style = styles[j]
                        if len(style) != 2:
                            continue
                        styles_dict[style[0].strip()] = style[1].strip()

                    top = styles_dict.get('top')
                    if top is None:
                        continue

                    try:
                        top_value = int(top.replace('px', ''))
                    except Exception:
                        continue

                    if (
                        p.get_text(strip=True, separator=' ').strip(': ')
                        in self.fields_to_remove
                    ):
                        tops_to_remove.append(top_value)

                    for top_to_remove in tops_to_remove:
                        if (
                            abs(top_value - top_to_remove)
                            <= FIELD_REMOVE_INTERVAL
                        ):
                            # print(top_value, top_to_remove)
                            p.clear()
                            p.append('$ВИДАЛЕНО$')

            # print('Writing text...')
            output_tmp_path.write_text(str(soup), encoding='utf8')
            # print('Wrote text!')

            self.processed.emit(file_i, True)
            # print('Sent processed event')

        self.done.emit()
        # print('Sent done event!')

    def stop(self):
        self._stop = True


# Main window
class MainWindow(QMainWindow):
    def __init__(self, patterns_to_remove, fields_to_remove):
        super().__init__()

        self.patterns_to_remove = patterns_to_remove
        self.fields_to_remove = fields_to_remove

        self.processing_done = False

        self.setWindowTitle('Обробник ДРРП')
        self.resize(700, 500)

        layout = QVBoxLayout()

        self.label = QLabel('Оберіть файли для обробки...')
        layout.addWidget(self.label)

        self.table = QTableWidget()
        self.table_header = self.table.horizontalHeader()
        self.init_table()
        layout.addWidget(self.table)
        # self.table.itemChanged.connect(self.on_files_changed)

        self.btnOpenFile = QPushButton('Відкрити файл')
        self.btnOpenFile.clicked.connect(self.open_file)
        layout.addWidget(self.btnOpenFile)

        self.btnOpenDir = QPushButton('Відкрити теку з файлами')
        self.btnOpenDir.clicked.connect(self.open_directory)
        layout.addWidget(self.btnOpenDir)

        line = QFrame()
        line.setFrameShape(QFrame.HLine)
        line.setFrameShadow(QFrame.Sunken)
        line.setFixedHeight(20)
        layout.addWidget(line)

        self.btnSaveOne = QPushButton('Зберегти обраний файл')
        self.btnSaveOne.setDisabled(True)
        self.btnSaveOne.clicked.connect(self.save_selected_file)
        layout.addWidget(self.btnSaveOne)

        self.btnSaveAll = QPushButton('Зберегти всі файли у папку')
        self.btnSaveAll.setDisabled(True)
        self.btnSaveAll.clicked.connect(self.save_all_files)
        layout.addWidget(self.btnSaveAll)

        self.btnSaveArchive = QPushButton('Зберегти всі файли архівом')
        self.btnSaveArchive.setDisabled(True)
        self.btnSaveArchive.clicked.connect(self.save_archive)
        layout.addWidget(self.btnSaveArchive)

        container = QWidget()
        container.setLayout(layout)
        self.setCentralWidget(container)

        shutil.rmtree(TMP_PATH, ignore_errors=True)
        TMP_PATH.mkdir(parents=True)
        TMP_RAW_PATH.mkdir()

    # def on_files_changed(self):
    #     files_count = self.table.rowCount()
    #     if files_count and self.processing_done:
    #         self.btnSaveAll.setDisabled(False)
    #     else:
    #         self.btnSaveAll.setDisabled(True)

    def on_selection_changed(self):
        selected_items = self.table.selectedIndexes()
        self.btnSaveOne.setDisabled(
            not (bool(selected_items) and self.processing_done)
        )

    def _process_files(self, files: list[Path]):
        self.processing_done = False
        table = self.table
        for i, file in enumerate(files):
            table.setRowCount(self.table.rowCount() + 1)
            name = QTableWidgetItem(file.stem)
            name.setFlags(
                Qt.ItemFlag(name.flags() & ~Qt.ItemFlag.ItemIsEditable)
            )
            status = QTableWidgetItem('Обробляється...')
            status.setTextAlignment(Qt.AlignmentFlag.AlignCenter)
            status.setFlags(
                Qt.ItemFlag(status.flags() & ~Qt.ItemFlag.ItemIsEditable)
            )
            table.setItem(self.table.rowCount() - 1, 0, name)
            table.setItem(self.table.rowCount() - 1, 1, status)
            if file.suffix != '.pdf':
                self.on_file_processed(i, False)
                return

        self.file_proc_thread = QThread()
        self.file_proc_worker = FileProcessor(
            files, self.patterns_to_remove, self.fields_to_remove
        )

        thread = self.file_proc_thread
        worker = self.file_proc_worker

        worker.moveToThread(self.file_proc_thread)

        worker.progress.connect(self.on_file_proc_progress)
        worker.processed.connect(self.on_file_processed)

        worker.done.connect(self.on_processing_done)
        worker.done.connect(thread.quit)
        worker.done.connect(worker.deleteLater)

        thread.started.connect(worker.run)
        thread.finished.connect(self.file_proc_thread.deleteLater)

        thread.start()

    def reset(self):
        self.label.setText('Оберіть файли для обробки...')
        self.processing_done = False
        self.init_table()
        self.init_buttons()

    def init_buttons(self):
        self.btnSaveAll.setDisabled(True)
        self.btnSaveOne.setDisabled(True)
        self.btnSaveArchive.setDisabled(True)

    def init_table(self):
        self.table.clear()

        self.table.setColumnCount(2)
        self.table.setRowCount(0)
        self.table.setHorizontalHeaderLabels(['Назва', 'Статус'])
        self.table.setColumnWidth(1, 200)
        self.table.setSelectionBehavior(
            QAbstractItemView.SelectionBehavior.SelectRows
        )
        assert self.table_header is not None
        self.table_header.setSectionResizeMode(
            0, QHeaderView.ResizeMode.Stretch
        )
        self.table_header.setSectionResizeMode(1, QHeaderView.ResizeMode.Fixed)
        self.table.itemSelectionChanged.connect(self.on_selection_changed)

    def open_file(self):
        self.reset()

        choice, _ = QFileDialog.getOpenFileName(
            self,
            'Обрати файл',
            filter='PDF files (*.pdf)',
            directory=user_desktop_dir(),
        )

        if not choice:
            return

        self.label.setText('Обробка...')
        self._process_files([Path(choice)])

    def open_directory(self):
        self.reset()

        dir_choice = QFileDialog.getExistingDirectory(
            self,
            'Обрати теку',
            directory=user_desktop_dir(),
        )
        if not dir_choice:
            return

        files = [
            Path(p)
            for p in Path(dir_choice).iterdir()
            if p.is_file() and p.suffix == '.pdf'
        ]

        self._process_files(files)

    def on_file_processed(self, file_index: int, status: bool):
        # print('Hello from on_file_processed!')
        table = self.table
        text = 'Оброблено' if status else 'Помилка'
        background = (
            QBrush(QColor('#2AE58E')) if status else QBrush(QColor('#FA5647'))
        )
        item = QTableWidgetItem(text)
        item.setTextAlignment(Qt.AlignmentFlag.AlignCenter)
        item.setBackground(background)
        item.setFlags(Qt.ItemFlag(item.flags() & ~Qt.ItemFlag.ItemIsEditable))
        # print(f'Setting item... {text}')
        table.setItem(file_index, 1, item)

    def on_file_proc_progress(self, progress: int):
        pass

    def on_processing_done(self):
        self.processing_done = True

        selected_items = self.table.selectedIndexes()
        self.btnSaveOne.setDisabled(
            not (bool(selected_items) and self.processing_done)
        )

        self.btnSaveAll.setDisabled(False)
        self.btnSaveArchive.setDisabled(False)

        self.label.setText('Обробка завершена!')

    def save_selected_file(self):
        item = self.table.currentItem()
        if not item:
            return
        filestem = item.text()
        save_path, _ = QFileDialog.getSaveFileName(
            self,
            'Зберегти файл',
            str(Path(user_desktop_dir()) / (filestem + '_оброблено.html')),
        )

        if not save_path:
            return

        save_path = Path(save_path)
        tmp_path = TMP_PATH / (filestem + '.html')

        if save_path.is_file():
            save_path.unlink()

        shutil.copy(tmp_path, save_path)
        QMessageBox.information(self, 'Збережено', 'Файл збережено!')

    def save_all_files(self):
        table = self.table
        folder = QFileDialog.getExistingDirectory(
            self,
            'Обрати теку для збереження всіх файлів',
            directory=user_desktop_dir(),
        )
        if not folder:
            return

        folder = Path(folder)
        for i in range(table.rowCount()):
            item = table.item(i, 0)
            if not item:
                continue
            filestem = item.text()
            tmp_path = TMP_PATH / (filestem + '.html')
            save_path = folder / (filestem + '_оброблено.html')

            if save_path.is_file():
                save_path.unlink()
            shutil.copy(tmp_path, save_path)
        QMessageBox.information(self, 'Збережено', 'Всі файли збережено!')

    def save_archive(self):
        table = self.table

        first_item = table.item(0, 0)
        if first_item is None:
            return
        archive_name = first_item.text() + '_та_інші.zip'
        archive_path, _ = QFileDialog.getSaveFileName(
            self,
            'Зберегти архів',
            str(Path(user_desktop_dir()) / archive_name),
        )
        if not archive_path:
            return

        archive_path = Path(archive_path)

        if archive_path.is_file():
            archive_path.unlink()

        for i in range(table.rowCount()):
            item = table.item(i, 0)
            if not item:
                continue
            filestem = item.text()
            tmp_path = TMP_PATH / (filestem + '.html')

            with zipfile.ZipFile(
                archive_path, 'a', compression=zipfile.ZIP_DEFLATED
            ) as zipf:
                zipf.write(tmp_path, filestem + '_оброблено.html')
        QMessageBox.information(self, 'Збережено', 'Архів збережено!')


class ConfigErrorWindow(QMainWindow):
    def __init__(self, config_error: str):
        super().__init__()
        self.setWindowTitle('Обробник ДРРП')
        QMessageBox.information(self, 'Помилка в налаштуваннях', config_error)
        self.close()


def apply_dark_theme(app):
    dark_palette = QPalette()
    dark_palette.setColor(QPalette.Window, QColor(45, 45, 45))
    dark_palette.setColor(QPalette.WindowText, QColor(220, 220, 220))
    dark_palette.setColor(QPalette.Base, QColor(30, 30, 30))
    dark_palette.setColor(QPalette.AlternateBase, QColor(45, 45, 45))
    dark_palette.setColor(QPalette.ToolTipBase, QColor(255, 255, 255))
    dark_palette.setColor(QPalette.ToolTipText, QColor(0, 0, 0))
    dark_palette.setColor(QPalette.Text, QColor(220, 220, 220))
    dark_palette.setColor(QPalette.Button, QColor(45, 45, 45))
    dark_palette.setColor(QPalette.ButtonText, QColor(220, 220, 220))
    dark_palette.setColor(QPalette.BrightText, QColor(255, 0, 0))
    dark_palette.setColor(QPalette.Highlight, QColor(100, 100, 255))
    dark_palette.setColor(QPalette.HighlightedText, QColor(255, 255, 255))
    app.setPalette(dark_palette)


style_sheet = """
* {
    font: 8pt "Segoe UI Semibold";
}
"""

if __name__ == '__main__':
    os.environ['QT_ENABLE_HIGHDPI_SCALING'] = '1'
    os.environ['QT_AUTO_SCREEN_SCALE_FACTOR'] = '1'
    os.environ['QT_SCALE_FACTOR'] = '1'
    app = QApplication(sys.argv)
    QApplication.setStyle('Fusion')
    # apply_dark_theme(app)
    app.setStyleSheet(style_sheet)
    app.setWindowIcon(QIcon(str(icon_path)))

    try:
        (patterns_to_remove, fields_to_remove) = load_config()
    except Exception as e:
        QMessageBox.information(None, 'Помилка в налаштуваннях', str(e))
        sys.exit()

    window = MainWindow(patterns_to_remove, fields_to_remove)
    window.show()
    sys.exit(app.exec_())
