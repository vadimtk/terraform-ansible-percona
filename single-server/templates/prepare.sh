sysbench oltp_read_write --report-interval=1 --time=1800 --threads=24 --tables=10 --table-size=10000000 --mysql-user=root --mysql-socket=/tmp/mysql.sock prepare
