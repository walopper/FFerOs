#pasa el contenido del .asm a compilado
nasm boot_sect.asm -f bin -o boot_sect.bin
#muestra el contenido el archivo en exadecimal
od -t x1 -A n boot_sect.bin 
