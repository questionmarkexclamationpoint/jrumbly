read 99
read 98
load 99
sub 98
jmpn 6 //if 98 > 99
jump 12 //if 99 >= 98
load 99 //if 98 > 99
stor 97
load 98
stor 99
load 97
stor 98
load 99 //begin main loop
div 98
mult 98
stor 97
load 99
sub 97
jmpz 25 //if remainder is 0
stor 97
load 98
stor 99
load 97
stor 98
jump 12
writ 98
halt 0