set terminal pdfcairo size 4.2,2.6 font 'Helvetica,15'

seq = '#cc5258'; pradet = '#52cc52'; pfast = '#5252cc';

set encoding utf8

LCases='abcdefghijklmnopqrstuvwxyz'
SCases='ᴀʙᴄᴅᴇғɢʜɪᴊᴋʟᴍɴᴏᴘǫʀsᴛᴜᴠᴡxʏᴢ'

toscchr(c)= c eq ''  ?  ''  :  substr( SCases.c, strstrt(LCases.c, c), strstrt(LCases.c, c) )

texsc(s) = strlen(s) <= 1 ? toscchr(s) : texsc(s[1:strlen(s)/2]).texsc(s[(strlen(s)/2)+1:strlen(s)])

set ylabel '# Schedules Run'
set style data histogram
set style histogram cluster gap 2
set boxwidth 0.9
set xtics format ''
set xtic rotate by -30 scale 0
set output './plots/schedules-run.pdf'
set style fill   solid

plot './plots/schedules-run.dat' using 3:xtic(1) title texsc('PraDet') linecolor rgb pradet, \
     './plots/schedules-run.dat' using 6 title texsc('Pfast') linecolor rgb pfast
