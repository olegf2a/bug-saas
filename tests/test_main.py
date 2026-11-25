import pytest

from main import greet, main


def test_greet() -> None:
    assert greet("Alice") == "Hello, Alice!"


def test_main_prints_greeting(capsys: pytest.CaptureFixture[str]) -> None:
    main()
    assert capsys.readouterr().out == "Hello, world!\n"
