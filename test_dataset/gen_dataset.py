#64-bit Digest Dataset Generator
import aes_sbox

aes_box.print_aes_sbox()

with open('dataset.txt', 'w') as f:
    for r in range(0, 32):
        for i in range(0, 8):

            num_test = i
            num_test_str = str(num_test)+"\n"
            f.write(num_test_str)

print("Hello world")
