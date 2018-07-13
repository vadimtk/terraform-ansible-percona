ulimit -n 10000
sysbench oltp_read_only --tables=16 --table_size=10000000 --threads=48 --mysql-socket=/tmp/mysql.sock --mysql-user=root --time=600 --max-requests=0 --report-interval=1 --rand-type=uniform --mysql-db=sbtest --mysql-ssl=off --time=600 --db-driver=mysql prewarm
sysbench oltp_read_only --tables=16 --table_size=10000000 --threads=48 --mysql-socket=/tmp/mysql.sock --mysql-user=root --time=600 --max-requests=0 --report-interval=1 --rand-type=uniform --mysql-db=sbtest --mysql-ssl=off --time=600 --db-driver=mysql run | tee -a res${i}.warmup.txt
for i in 1 2 4 8 12 16 20 24 30 36 42 48 56 64 72 80 90 100 128 192 256 512 1024
do
echo $i
sysbench oltp_read_only --tables=16 --table_size=10000000 --threads=$i --mysql-socket=/tmp/mysql.sock --mysql-user=root --time=600 --max-requests=0 --report-interval=1 --rand-type=uniform --mysql-db=sbtest --mysql-ssl=off --time=300 --db-driver=mysql run | tee -a res${i}.txt
done
