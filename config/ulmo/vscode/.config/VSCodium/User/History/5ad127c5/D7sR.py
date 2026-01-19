from operator import xor


INIT_PASSWORD = b"password123_netyaga"
PASSPHRASE = b"1LwRBuw111nSOfhYdOd"

encrypted = bytearray()
for i, p in zip(INIT_PASSWORD, PASSPHRASE):
    encrypted.append(xor(i, p))

print(encrypted.decode())