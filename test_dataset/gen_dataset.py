#64-bit Digest Dataset Generator
import codecs
import aes_sbox
from operator import xor

def ISHFTC(n, d, N):
    return ((n << d) % (1 << N)) | (n >> (N - d))


H = [int('34',16), int('55',16), int('0F',16), int('14',16), int('DA',16), int('C0',16), int('2B',16), int('EE',16)]

prova = 'abcdefghijklmnopqrstuvwxyz'.encode('utf-8')
print("Messaggio: " + prova.decode('utf-8'))
'''h = 'e'.encode('utf-8').hex()
int_i = int(h, 16)
print(int_i)
print("--------------------")
print(prova[1])
print("--------------------")'''
#int_str = int(hex_of_str, 16)
#print(hex_of_str)
#print(codecs.decode('OF', 'hex_codec'))
#print(aes_sbox.lookup(0))

#print(aes_sbox.print_aes_sbox_serialization(100))

#print(xor(77, 15)) # 42
l = len(prova)
for j in range(0, l):
    int_str = prova[j]
    #print(int_str)
    for r in range(0, 32):
            for i in range(0, 8):
                #print("H mi da: " + str(H[(i+2) % 8]))
                xor_res = xor(H[(i+2) % 8], int_str)
                #index = xor_res << i
                index = ISHFTC(xor_res, i, 8)
                #print("indice: " + str(index))
                #print(aes_sbox.lookup(index))
                #print(aes_sbox.get_aes_sbox(index))
                H[i] = aes_sbox.get_aes_sbox(index)
                #print("salvo in H: " + str(H[i]))


result = ""
result_int = ""
for i in range(0, 8):
    result_int += str(H[i])
    result += hex(H[i]).split('x')[-1]

print("hash: " + result)
print("hash_int: " + result_int)
"""with open('dataset.txt', 'w') as f:
    for r in range(0, 32):
        for i in range(0, 8):

            num_test = i
            num_test_str = str(num_test)+"\n"
            f.write(num_test_str)"""
