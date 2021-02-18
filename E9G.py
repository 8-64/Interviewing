#!python

import re

# Transform the word to the tag that contains the first letter, the number of the first and last letters between them and the last letter ("Foobar" -> "F4r")
def WordTransform (word):
  digits = len(word) - 2
  if digits < 0:
    return word

  result = word[0:1] + str(digits) + word[-1:]
  return result

print(WordTransform("Foobarius"))
print(WordTransform("A"))

# Transform string like "Rick Sanchez" ->  into "R. Sanchez"
def ShortenName (word):
  name, rest = re.split('\s+', word, 1)
  name = name[0:1] + ". "
  return name + rest

print(ShortenName("Rick Sanchez"))
