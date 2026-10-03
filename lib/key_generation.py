from string import ascii_lowercase, ascii_uppercase, digits
from random import randint

CHARS = ascii_lowercase + ascii_uppercase + digits

def generateKey(length):
    return ''.join(CHARS[randint(0, len(CHARS) - 1)] for _ in range(length))

print(generateKey(16))
print(generateKey(32))