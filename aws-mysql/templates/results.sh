uname -a
lscpu
for i in 1 2 4 8 12 16 20 24 30 36 42 48 56 64 72 80 90 100 128 192 256 512 1024
do
 cat res${i}.txt | grep transactions: | awk -v t=$i ' { print t,"|",$3 } ' | tr -d '('
done
