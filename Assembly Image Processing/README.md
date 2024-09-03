# Image-Processing-with-Assembly-80x86
Implementation of image processing using Assembly 80x86

Below features can be done using this implementation:

- Reshape an Image
- Resize an Image
- Apply Convolution Filters (sharpening and emboss)
- Apply Pooling (max and average pooling)
- Add Noise (Salt and pepper)
- Gray Scale an Image


> There is a sample image named ```image.jpg``` which is converted to ```image.txt``` using ```python_code.ipynb```. Also the genetated ```output.txt``` file is displayed using the given python code.


To exacute the code, run the below commands respectively:

1. nasm -f elf64 -o code.o code.asm

2. ld -o code code.o

3. ./code
