#64-bit Digest Dataset Generator
import base64

import aes_sbox

prova = "questa è una prova"
print(bytes(prova))

H = [int('34',16), int('55',16), int('0F',16), int('14',16), int('DA',16), int('C0',16), int('2B',16), int('EE',16)]

#aes_sbox.print_aes_sbox_serialization(100)

print(H[0])


for r in range(0, 32):
        for i in range(0, 8):
            index = (H[(i+2) % 8] ^ bytes(prova, 'utf-8')) << i
            print(index)
            #H[i] =

"""with open('dataset.txt', 'w') as f:
    for r in range(0, 32):
        for i in range(0, 8):

            num_test = i
            num_test_str = str(num_test)+"\n"
            f.write(num_test_str)"""
