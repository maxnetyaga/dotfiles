from operator import xor


# INIT_PASSWORD = b"password123_netyaga"
INIT_PASSWORD = b"password123_net"
PASSPHRASE = b"NLwRBuwCFMnSOfhYdOd"

encrypted = bytearray()
for i, p in zip(INIT_PASSWORD, PASSPHRASE):
    encrypted.append(xor(i, p))

print("h, ".join(encrypted.hex(sep=",").split(",")) + "h")