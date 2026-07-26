from __future__ import annotations

from pathlib import Path
from zipfile import ZipFile
import re
import xml.etree.ElementTree as ET


ROOT_DIR = Path(__file__).resolve().parents[2]
NUTRITION_FILE = ROOT_DIR / "NutritionalFacts_Fruit_Vegetables_Seafood.xlsx"

FOOD_MATCHES = {
    "Apple": ["apple"],
    "Cabbage": ["cabbage"],
    "Carrot": ["carrot"],
    "Cucumber": ["cucumber"],
    "Eggplant": ["eggplant", "aubergine"],
    "Pear": ["pear"],
    "Zucchini": ["zucchini", "courgette"],
}


class NutritionService:
    _rows: list[list[str | float | int | None]] | None = None

    @classmethod
    def get_for_food(cls, food_name: str) -> dict | None:
        rows = cls._load_rows()
        keywords = FOOD_MATCHES.get(food_name, [food_name.lower()])

        for row in rows[2:]:
            serving = str(row[0] or "")
            if any(_contains_food_keyword(serving, keyword) for keyword in keywords):
                return {
                    "serving": serving,
                    "calories": row[1],
                    "total_fat_g": row[3],
                    "sodium_mg": row[5],
                    "potassium_mg": row[7],
                    "carbohydrates_g": row[9],
                    "fiber_g": row[11],
                    "sugars_g": row[13],
                    "protein_g": row[14],
                }

        return None

    @classmethod
    def _load_rows(cls) -> list[list[str | float | int | None]]:
        if cls._rows is not None:
            return cls._rows

        if not NUTRITION_FILE.exists():
            cls._rows = []
            return cls._rows

        cls._rows = _read_xlsx_first_sheet(NUTRITION_FILE)
        return cls._rows


def _read_xlsx_first_sheet(path: Path) -> list[list[str | float | int | None]]:
    ns = {"main": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}

    with ZipFile(path) as archive:
        shared_strings = _read_shared_strings(archive, ns)
        sheet_xml = archive.read("xl/worksheets/sheet1.xml")

    root = ET.fromstring(sheet_xml)
    rows: list[list[str | float | int | None]] = []

    for row_node in root.findall(".//main:sheetData/main:row", ns):
        values: list[str | float | int | None] = []
        for cell in row_node.findall("main:c", ns):
            column_index = _column_to_index(cell.attrib.get("r", "A1"))
            while len(values) < column_index - 1:
                values.append(None)
            values.append(_read_cell(cell, shared_strings, ns))
        rows.append(values)

    return rows


def _read_shared_strings(archive: ZipFile, ns: dict[str, str]) -> list[str]:
    try:
        xml = archive.read("xl/sharedStrings.xml")
    except KeyError:
        return []

    root = ET.fromstring(xml)
    strings: list[str] = []
    for item in root.findall("main:si", ns):
        parts = [node.text or "" for node in item.findall(".//main:t", ns)]
        strings.append("".join(parts))
    return strings


def _read_cell(
    cell: ET.Element,
    shared_strings: list[str],
    ns: dict[str, str],
) -> str | float | int | None:
    value_node = cell.find("main:v", ns)
    if value_node is None or value_node.text is None:
        return None

    value = value_node.text
    if cell.attrib.get("t") == "s":
        return shared_strings[int(value)]

    try:
        number = float(value)
    except ValueError:
        return value

    if number.is_integer():
        return int(number)
    return number


def _column_to_index(cell_ref: str) -> int:
    letters = re.match(r"[A-Z]+", cell_ref.upper())
    if not letters:
        return 1

    index = 0
    for char in letters.group(0):
        index = index * 26 + (ord(char) - ord("A") + 1)
    return index


def _contains_food_keyword(text: str, keyword: str) -> bool:
    normalized_text = _normalize_words(text)
    normalized_keyword = _normalize_words(keyword)
    return f" {normalized_keyword} " in f" {normalized_text} "


def _normalize_words(text: str) -> str:
    text = text.lower()
    text = re.sub(r"[^a-z]+", " ", text)
    return re.sub(r"\s+", " ", text).strip()
