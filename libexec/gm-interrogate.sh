
#!/bin/sh -x

fmtstr=" \n----\n %b   file size \n %c   comment  \n%d   directory %e  \n filename extension %f \n  filename \n %g   page dimensions and offsets \n %h   height \n %i   input filename \n \
    %k  number of unique colors %l   label %m   magick %n   number of scenes %o   output filename %p   page number %q   image bit depth %r   image type description %s  \n scene number %t  \
    top of filename %u   unique temporary filename %w   width %x   horizontal resolution %y   vertical resolution %A   transparency supported %C   \n compression type \
    %D   GIF disposal method \n %G   Original width and height \n %H   page height \n %M   original filename specification  \n%O   page offset (x,y) \n\
    %P  page dimensions (width,height) \n %Q   compression quality \n %T   time delay (in centi-seconds) \n  %U   resolution units \n %W   page width \n %X   page horizontal offset (x) \n \
    %Y   page vertical offset (y) \n %@   trim bounding box \n %#   signature \n   "

gm identify -format "${fmtstr}" $1
