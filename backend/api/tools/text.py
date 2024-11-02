def capitalize_words(s: str) -> str:
    if not s:
        return s
    return " ".join(word.capitalize() for word in s.split())
