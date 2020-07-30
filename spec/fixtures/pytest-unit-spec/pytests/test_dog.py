import pytest
from dog import *

@pytest.fixture
def dog():
  return(Dog("Fido", "Good Boy"))

def test_dog_name(dog):
  assert dog.name == "Fido"

def test_dog_breed(dog):
  assert dog.breed == "Good Boy"