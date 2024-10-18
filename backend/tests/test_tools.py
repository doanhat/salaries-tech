import pytest

from backend.api.tools import capitalize_words


@pytest.mark.parametrize(
    "input_string, expected_output",
    [
        ("hello world", "Hello World"),
        ("HELLO WORLD", "Hello World"),
        ("hello WORLD", "Hello World"),
        ("hElLo wOrLd", "Hello World"),
        ("", ""),
        (None, None),
        ("one two three four", "One Two Three Four"),
        ("1st 2nd 3rd", "1st 2nd 3rd"),
        ("hyphenated-word", "Hyphenated-word"),
        ("  extra  spaces  ", "Extra Spaces"),
    ],
)
def test_capitalize_words(input_string, expected_output):
    assert capitalize_words(input_string) == expected_output


def test_capitalize_words_with_numbers():
    assert capitalize_words("test123 456test") == "Test123 456test"


def test_capitalize_words_with_special_characters():
    assert capitalize_words("hello@world.com") == "Hello@world.com"


def test_capitalize_words_with_mixed_case():
    assert capitalize_words("MixEd CaSe WoRdS") == "Mixed Case Words"


def test_capitalize_words_with_single_letter_words():
    assert capitalize_words("a b c d") == "A B C D"


def test_capitalize_words_with_apostrophes():
    assert capitalize_words("it's a test") == "It's A Test"


# Add more tests for your utility functions here
