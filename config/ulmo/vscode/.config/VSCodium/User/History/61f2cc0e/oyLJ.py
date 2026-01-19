'''
Functions for extracting logical blocks from extracts of e.land.gov.ua
'''

from typing import Dict, List, Tuple
from dataclasses import fields
from itertools import zip_longest
import base64
import re

from bs4 import BeautifulSoup, Tag

from .table_types import *
from .TableSection import TableSection

__all__ = ["extract_main_attributes", "extract_land_plot",
           "extract_standard_monetary_value", "extract_property_rights_subjects",
           "extract_other_rights_subjects", "extract_restrictions",
           "extract_land_documentation", "extract_explication",
           "extract_cadastral_plan",
           ]

# Sections of main attributes
SECTIONS = (
    "Відомості про земельну ділянку",
    "Відомості про нормативно грошову оцінку ділянки",
    "Інформація про документацію із землеустрою на земельну ділянку",
    "Відомості про сертифікованого інженера - землевпорядника (ВІДПОВІДАЛЬНА ОСОБА)",
    "Відомості про сертифікованого інженера - землевпорядника (БЕЗПОСЕРЕДНІЙ ВИКОНАВЕЦЬ)",
    "Відомості про суб'єктів права власності на земельну ділянку",
    "Відомості про суб'єкта речового права на земельну ділянку",
    "Відомості про зареєстроване обмеження у використанні земельної ділянки",
    "Відомості про суб'єкта речового права",
)


def get_td_text(td: Tag):
    return " ".join(td.get_text(strip=True).split())


def extract_main_attributes(table: Tag) -> Dict:
    '''Extracts sections of e.land.gov.ua html files based on fixed list of that sections'''
    main_attributes = {}
    for row in table.find_all("tr"):
        row = [get_td_text(td) for td in row.find_all("td")]
        print(row, end="\n\n")

        if len(row) == 1:
            header = row[0]
            if header == "":
                # empty tds are assumed to be delimeters of sections under the same header
                if not section.header:
                    raise Exception("Unexpected empty column")
                header = section.header
            elif not header in SECTIONS:
                print(f"Attributes parsing stopped at {header}")
                break

            section = TableSection(header)
            if header not in main_attributes.keys():
                main_attributes[header] = []
            main_attributes[header].append(section.content)

        elif len(row) == 2:
            if not row[1] or row[1].lower() in ["інформація відсутня", "-"]:
                row[1] = None
            section.content = row

        else:
            raise Exception(f"Unexpected amount of columns in {row}")
    return main_attributes


def extract_land_plot(main_attributes: Dict) -> LandPlot:
    land_plot_section = main_attributes.get("Відомості про земельну ділянку")

    if not isinstance(land_plot_section, list) or len(land_plot_section) != 1:
        raise Exception("land_plot section is invalid")

    if not (land_plot_section[0].get("Кадастровий номер земельної ділянки")
            or land_plot_section[0].get("Площа земельної ділянки")):
        raise Exception("land_plot section is invalid")

    if (not land_plot_section[0]["Площа земельної ділянки"].replace('.', '', 1).isdigit()
            and land_plot_section[0]["Площа земельної ділянки"][-2:] != "га"):
        raise Exception("Area is not in ha")

    return LandPlot(**{
        (KEY_SWAPS[key]): (float(re.sub("[^0-9.]", "", value))
                           if KEY_SWAPS[key] == "area_ha"
                           else "Приватна власність"
                           if KEY_SWAPS[key] == "ownership" and value == "приватна"
                           else "Комунальна власність"
                           if KEY_SWAPS[key] == "ownership" and value in ("комунальна", "колективна")
                           else "Державна власність"
                           if KEY_SWAPS[key] == "ownership" and value == "державна"

                           else value.replace(".", ",")
                           if KEY_SWAPS[key] == "plot_cost" and value
                           else value)
        for key, value in land_plot_section[0].items()
    })


def extract_standard_monetary_value(main_attributes: Dict, cadastral_number: str) -> StandardMonetaryValue | None:
    standard_monetary_value_section = main_attributes\
        .get("Відомості про нормативно грошову оцінку ділянки")

    if standard_monetary_value_section is None:
        return None

    if (not isinstance(standard_monetary_value_section, list)
            or len(standard_monetary_value_section) != 1):
        raise Exception("standard_monetary_value section is invalid")

    standard_monetary_value = StandardMonetaryValue(
        cadastral_number=cadastral_number,
        **{KEY_SWAPS[key]: (value.replace(".", ",")
                            if KEY_SWAPS[key] == "monetary_value" and value
                            else value)
           for key, value in standard_monetary_value_section[0].items()}
    )

    if all((getattr(standard_monetary_value, field.name) is None
            if field.name != "cadastral_number" else True
            for field in fields(standard_monetary_value))):
        return None

    return standard_monetary_value


def extract_property_rights_subjects(main_attributes: Dict, cadastral_number: str) -> List[PropertyRightsSubject] | None:
    property_rights_subjects_section = main_attributes\
        .get("Відомості про суб'єктів права власності на земельну ділянку") or []

    property_rights_subjects = []
    for subject_section in property_rights_subjects_section:
        subject = PropertyRightsSubject(
            cadastral_number=cadastral_number,
            entity_type=("Юридична особа"
                         if subject_section.get("Код ЄДРПОУ юридичної особи")
                         else "Фізична особа"),
            **{
                (KEY_SWAPS[key]
                 if key not in ("Найменування юридичної особи",
                                "Прізвище, ім'я та по батькові фізичної особи")
                 else KEY_SWAPS[key](is_restriction=False)): value
                for key, value in subject_section.items()
            }
        )

        if not all((getattr(subject, field.name) is None
                    if field.name not in ("cadastral_number", "entity_type") else True
                    for field in fields(subject))):
            property_rights_subjects.append(subject)

    if not property_rights_subjects:
        return None

    return property_rights_subjects


def extract_other_rights_subjects(main_attributes: Dict, cadastral_number: str) -> List[OtherRightsSubject] | None:
    other_rights_subjects_first_section_part = main_attributes\
        .get("Відомості про суб'єкта речового права на земельну ділянку")
    other_rights_subjects_second_section_part = main_attributes\
        .get("Відомості про суб'єкта речового права")

    if other_rights_subjects_second_section_part:
        other_rights_subjects_second_section_part = [x for x
                                                     in other_rights_subjects_second_section_part
                                                     if x.get("Вид речового права")]

    other_rights_subjects_section = (other_rights_subjects_first_section_part or [])\
        + (other_rights_subjects_second_section_part or [])

    other_rights_subjects = []

    for subject_section in other_rights_subjects_section:
        subject = OtherRightsSubject(
            cadastral_number=cadastral_number,
            entity_type=("Юридична особа"
                         if subject_section.get("Код ЄДРПОУ юридичної особи")
                         else "Фізична особа"),
            **{
                (KEY_SWAPS[key](is_restriction=False)
                 if key in ("Найменування юридичної особи",
                            "Прізвище, ім'я та по батькові фізичної особи")
                    else KEY_SWAPS[key]):
                (OTHER_RIGHT_TYPES[value.capitalize()]
                 if key == "Вид речового права" and value
                 else float(re.sub("[^0-9.]", "", value))
                 if KEY_SWAPS[key] == "sublease_area_ha" and value
                 else value.replace(".", ",")
                 if KEY_SWAPS[key] == "user_fee"
                 else value)
                for key, value in subject_section.items()
            }
        )

        if not all((getattr(subject, field.name) is None
                    if field.name not in ("cadastral_number", "entity_type") else True
                    for field in fields(subject))):
            other_rights_subjects.append(subject)

    if not other_rights_subjects:
        return None

    return other_rights_subjects


def extract_restrictions(main_attributes: Dict, cadastral_number: str) -> List[Restriction] | None:
    restrictions_section = main_attributes\
        .get("Відомості про зареєстроване обмеження у використанні земельної ділянки") or []
    restrictions_rights_section = main_attributes\
        .get("Відомості про суб'єкта речового права") or []
    restrictions_section = restrictions_section.copy()
    restrictions_rights_section = restrictions_rights_section.copy()

    restrictions_rights_section = [right for right in restrictions_rights_section
                                   if not right.get("Вид речового права")]

    restrictions_section = [
        section for section in restrictions_section
        if not "право" in section.get("Вид обмеження").lower() or section.get("Вид обмеження").lower() in ("право прокладення та експлуатації ліній електропередачі, зв’язку, трубопроводів, інших лінійних комунікацій",
                                                                                                           "право прокладення та експлуатації ліній електропередачі. зв'язку. трубопроводів. інших лінійних комунікацій",
                                                                                                           "право прокладення та експлуатації ліній електропередачі, електронних комунікаційних мереж, трубопроводів, інших лінійних комунікацій",
                                                                                                           "право проїзду на транспортному засобі по наявному шляху",
                                                                                                           "право проходу та проїзду на велосипеді",
                                                                                                           "право на розміщення тимчасових споруд (малих архітектурних форм)",
                                                                                                           "")
    ]

    restrictions = []

    for (restriction_section,
         restriction_right_section) in zip_longest(restrictions_section,
                                                   restrictions_rights_section,
                                                   fillvalue={}):
        restriction = Restriction(
            cadastral_number=cadastral_number,
            **{
                KEY_SWAPS[key]: value
                for key, value in restriction_section.items()
            },
            ** {
                (KEY_SWAPS[key](is_restriction=True)
                 if key in ("Найменування юридичної особи",
                            "Прізвище, ім'я та по батькові фізичної особи",
                            )
                 else KEY_SWAPS[key]): value
                for key, value
                in restriction_right_section.items()
                if key in ("Найменування юридичної особи",
                           "Код ЄДРПОУ юридичної особи",
                           "Прізвище, ім'я та по батькові фізичної особи",
                           )
            }
        )

        if not all((getattr(restriction, field.name) is None
                    if field.name not in ("cadastral_number") else True
                    for field in fields(restriction))):
            restrictions.append(restriction)

    if not restrictions:
        return None

    return list(set(restrictions))


def extract_land_documentation(main_attributes: Dict, cadastral_number: str) -> LandDocumentation | None:
    land_documentation_section = main_attributes\
        .get("Інформація про документацію із землеустрою на земельну ділянку") or []
    land_documentation_chief_section = main_attributes\
        .get("Відомості про сертифікованого інженера - землевпорядника (ВІДПОВІДАЛЬНА ОСОБА)") or []
    land_documentation_executor_section = main_attributes\
        .get("Відомості про сертифікованого інженера - землевпорядника (БЕЗПОСЕРЕДНІЙ ВИКОНАВЕЦЬ)") or []

    if (not land_documentation_section
        and not land_documentation_chief_section
            and not land_documentation_executor_section):
        return None

    if (not isinstance(land_documentation_section, list)
            or len(land_documentation_section) != 1):
        raise Exception("land_documentation_section is invalid")

    if (not isinstance(land_documentation_chief_section, list)
            or len(land_documentation_chief_section) > 1):
        raise Exception("land_documentation_chief_section is invalid")

    if (not isinstance(land_documentation_executor_section, list)
            or len(land_documentation_executor_section) > 1):
        raise Exception("land_documentation_executor_section is invalid")

    land_documentation_section = land_documentation_section[0]

    if land_documentation_chief_section:
        land_documentation_chief_section = land_documentation_chief_section[0]
    else:
        land_documentation_chief_section = {}

    if land_documentation_executor_section:
        land_documentation_executor_section = land_documentation_executor_section[0]
    else:
        land_documentation_executor_section = {}

    land_documentation = LandDocumentation(
        cadastral_number=cadastral_number,
        ** {
            KEY_SWAPS[key]: (LAND_DOCUMENTATION_TYPES[value]
                             if value and KEY_SWAPS[key] == "land_documentation_type"
                             else value)
            for key, value
            in land_documentation_section.items()
        },
        ** {
            (KEY_SWAPS[key](surveyor_type="executor")
                if key in ("ПІБ інженера – землевпорядника",
                           "Номер сертифіката та дата видачі",
                           "Місце роботи інженера-землевпорядника"
                           )
                else KEY_SWAPS[key]): value
            for key, value
            in land_documentation_executor_section.items()
        },
        ** {
            (KEY_SWAPS[key](surveyor_type="chief")
                if key in ("ПІБ інженера – землевпорядника",
                           "Номер сертифіката та дата видачі",
                           "Місце роботи інженера-землевпорядника"
                           )
                else KEY_SWAPS[key]): value
            for key, value
            in land_documentation_chief_section.items()
        }
    )

    if all((getattr(land_documentation, field.name) is None
            if field.name != "cadastral_number" else True
            for field in fields(land_documentation))):
        return None

    return land_documentation


def extract_explication(table: Tag, cadastral_number: str) -> Explication | None:
    # looks only for first explication
    explication_section = table.find(attrs={"id": "explication"})
    if explication_section:
        explication_section = [BeautifulSoup.get_text(th_td, " ").strip()
                               for th_td
                               in explication_section.find("table").find_all(["th", "td"])]
    else:
        return None

    # grouping every 3 items
    explication_section_grouped: List[Tuple[str, str, str]]
    explication_section_grouped = tuple(zip(explication_section[::3],
                                            explication_section[1::3],
                                            explication_section[2::3]))

    explication = Explication(
        cadastral_number,
        total_area_ha=explication_section_grouped[0][0].split()[-1],
        lands=tuple(Land(land_type=land[1], land_area_ha=land[2])
                    for land in explication_section_grouped[1:])
    )

    if all((getattr(explication, field.name) is None
            if field.name != "cadastral_number" else True
            for field in fields(explication))):
        return None

    return explication


def extract_cadastral_plan(table: Tag, cadastral_number: str) -> CadastralPlan | None:
    plan_section = table.find("img", recursive=True)
    if not plan_section:
        return None

    plan_scale = plan_section.parent.parent.findNext("tr")\
        .text.strip().split(" ")[-1]
    plan_image = base64.b64decode(BeautifulSoup.get(plan_section, "src")
                                  .replace('data:image/png;base64,', ''))

    plan = CadastralPlan(
        cadastral_number,
        plan=plan_image,
        plan_scale=plan_scale
    )

    if all((getattr(plan, field.name) is None
            if field.name != "cadastral_number" else True
            for field in fields(plan))):
        return None

    return plan
