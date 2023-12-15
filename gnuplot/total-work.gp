set terminal pdfcairo size 3.1,2.3 font 'Helvetica,10'

seq = '#cc5258'; pradet = '#52cc52'; pfast = '#5252cc';

set encoding utf8

LCases='abcdefghijklmnopqrstuvwxyz'
SCases='ᴀʙᴄᴅᴇғɢʜɪᴊᴋʟᴍɴᴏᴘǫʀsᴛᴜᴠᴡxʏᴢ'

toscchr(c)= c eq ''  ?  ''  :  substr( SCases.c, strstrt(LCases.c, c), strstrt(LCases.c, c) )

texsc(s) = strlen(s) <= 1 ? toscchr(s) : texsc(s[1:strlen(s)/2]).texsc(s[(strlen(s)/2)+1:strlen(s)])

set ylabel 'Total Work (seconds)'
set style data histogram
set style histogram cluster gap 2
set boxwidth 0.9
set xtics format ''
set xtic rotate by -30 scale 0
set output './plots/total-work.pdf'
set style fill   solid

plot './plots/tot-work.dat' using 3:xtic(1) title texsc('Sequential') linecolor rgb seq, \
     './plots/tot-work.dat' using 6 title texsc('PraDet') linecolor rgb pradet, \
     './plots/tot-work.dat' using 9 title texsc('Pfast') linecolor rgb pfast
