def capitalize_words(s):
    if not s:
        return s
    return " ".join(word.capitalize() for word in s.split())
