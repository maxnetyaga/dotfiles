from operator import xor


INIT_PASSWORD = b"password123_netyaga"
PASSPHRASE = b"1234567891123456789"

encrypted = bytearray()
for i, p in zip(INIT_PASSWORD, PASSPHRASE):
    encrypted.append(xor(i, p))

print(encrypted.decode())