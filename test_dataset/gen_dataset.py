#64-bit Digest Dataset Generator
import codecs
import aes_sbox
from operator import xor

def ISHFTC(n, d, N):
    return ((n << d) % (1 << N)) | (n >> (N - d))


H = [int('34',16), int('55',16), int('0F',16), int('14',16), int('DA',16), int('C0',16), int('2B',16), int('EE',16)]

print(int('55',16))
print("---------------------------------------------------------------")
prova = 'M'.encode('utf-8')
hex_of_str = prova.hex()
int_str = int(hex_of_str, 16)
#print(hex_of_str)
#print(codecs.decode('OF', 'hex_codec'))
#print(aes_sbox.lookup(0))

#print(aes_sbox.print_aes_sbox_serialization(100))

#print(xor(77, 15)) # 42
#for j in range
for r in range(0, 32):
        for i in range(0, 8):
            print("H mi da: " + str(H[(i+2) % 8]))
            xor_res = xor(H[(i+2) % 8], int_str)
            print(xor_res)
            #index = xor_res << i
            index = ISHFTC(xor_res, i, 8)
            print("indice: " + str(index))
            print(aes_sbox.lookup(index))
            H[i] = aes_sbox.lookup(index)
            print("salvo in H: " + str(H[i]))


result = ""
for i in range(0,8):
    result += hex(H[i]).split('x')[-1]

print(result)
"""with open('dataset.txt', 'w') as f:
    for r in range(0, 32):
        for i in range(0, 8):

            num_test = i
            num_test_str = str(num_test)+"\n"
            f.write(num_test_str)"""
