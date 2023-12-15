set terminal pdfcairo size 4.2,2.6 font 'Helvetica,15'

seq = '#cc5258'; pradet = '#52cc52'; pfast = '#5252cc';

set encoding utf8

LCases='abcdefghijklmnopqrstuvwxyz'
SCases='ᴀʙᴄᴅᴇғɢʜɪᴊᴋʟᴍɴᴏᴘǫʀsᴛᴜᴠᴡxʏᴢ'

toscchr(c)= c eq ''  ?  ''  :  substr( SCases.c, strstrt(LCases.c, c), strstrt(LCases.c, c) )

texsc(s) = strlen(s) <= 1 ? toscchr(s) : texsc(s[1:strlen(s)/2]).texsc(s[(strlen(s)/2)+1:strlen(s)])

set ylabel "Longest Execution\nTime (seconds)"
set style data histogram
set style histogram cluster gap 2
set boxwidth 0.9
set xtics format ''
set xtic rotate by -30 scale 0
set output './plots/longest-execution.pdf'
set style fill  solid

plot './plots/max-execution.dat' using 3:xtic(1) title texsc('Sequential') linecolor rgb seq, \
     './plots/max-execution.dat' using 6 title texsc('PraDet') linecolor rgb pradet, \
     './plots/max-execution.dat' using 9 title texsc('Pfast') linecolor rgb pfast
