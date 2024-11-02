from backend.api.models.technical_stack import TechnicalStack


def test_technical_stack_model():
    stack = TechnicalStack(name="Python")
    assert stack.name == "Python"
