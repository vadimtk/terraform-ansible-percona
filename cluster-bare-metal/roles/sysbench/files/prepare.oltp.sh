# prepares dataset, 90GB size
sysbench oltp_read_only --tables=40 --table_size=10000000 --threads=40 --mysql-host=127.0.0.1 --mysql-user=sbtest --mysql-password=sbtest --max-requests=0 --report-interval=1 --rand-type=uniform --mysql-db=sbtest --mysql-ssl=off --create_table_options='DEFAULT CHARSET=utf8mb4' prepare
