import re

ARABIC_DIACRITICS = re.compile(r"[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]")

def normalize_query(value: str) -> str:
    value = value.strip().lower()
    value = ARABIC_DIACRITICS.sub("", value)
    value = value.replace("أ", "ا").replace("إ", "ا").replace("آ", "ا")
    value = value.replace("ى", "ي").replace("ة", "ه")
    value = re.sub(r"\s+", " ", value)
    return value

ROMAN_VARIANTS = {
    "murgi": "murghi",
    "murghee": "murghi",
    "alu": "aloo",
    "pyaz": "pyaaz",
}

def normalized_search_terms(query: str) -> list[str]:
    q = normalize_query(query)
    terms = [q]
    if q in ROMAN_VARIANTS:
        terms.append(ROMAN_VARIANTS[q])
    return list(dict.fromkeys(terms))
