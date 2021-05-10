
#!/bin/sh -x

fmtstr=" \n----\n %b   file size \n %c   comment  \n%d   directory %e  \n filename extension %f \n  filename \n %g   page dimensions and offsets \n %h   height \n %i   input filename \n \
    %k  number of unique colors \n%l   label %m   magick\n %n   number of scenes \n%o   output filename\n %p   page number\n %q   image bit depth \n%r   image type description \n%s   scene number \n \
 %t  top of filename \n %u   unique temporary filename \n %w   width \n %x   horizontal resolution \n %y   vertical resolution \n %A   transparency supported \n %C    compression type \n \
    %D   GIF disposal method \n %G   Original width and height \n %H   page height \n %M   original filename specification  \n%O   page offset (x,y) \n\
    %P  page dimensions (width,height) \n %Q   compression quality \n %T   time delay (in centi-seconds) \n  %U   resolution units \n %W   page width \n %X   page horizontal offset (x) \n \
    %Y   page vertical offset (y) \n %@   trim bounding box \n %#   signature \n   "

gm identify -format "${fmtstr}" $1
