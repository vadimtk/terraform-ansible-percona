HOST="--mysql-socket=/tmp/mysql.sock"
MYSQLDIR=/opt/vadim/ps/mysql-5.7.12-linux-glibc2.5-x86_64
DATADIR=/mnt/data/mem/mysql
CONFIG=/etc/mysql/my.cnf

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

startmysql(){
  pushd $MYSQLDIR
  sync
  sysctl -q -w vm.drop_caches=3
  echo 3 > /proc/sys/vm/drop_caches
  LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.1 numactl --interleave=all bin/mysqld --defaults-file=$CONFIG --datadir=$DATADIR --basedir=$PWD --user=root --ssl=0 --log-error=$DATADIR/error.log --innodb-buffer-pool-size=${BP}G
}

shutdownmysql(){
  echo "Shutting mysqld down..."
  $MYSQLDIR/bin/mysqladmin shutdown -S /tmp/mysql.sock
}

waitmysql(){
        set +e

        while true;
        do
                mysql -Bse "SELECT 1" mysql

                if [ "$?" -eq 0 ]
                then
                        break
                fi

                sleep 30

                echo -n "."
        done
        set -e
}

initialstat(){
  cp $CONFIG $OUTDIR
  cp $0 $OUTDIR
}

collect_mysql_stats(){
  mysqladmin ext -i10 > $OUTDIR/mysqladminext.txt &
  PIDMYSQLSTAT=$!
}
collect_dstat_stats(){
  dstat --output=$OUTDIR/dstat.txt 10 > $OUTDIR/dstat.out &
  PIDDSTATSTAT=$!
}


# cycle by buffer pool size

runid="mysql80.point-select.BP"

# perform warmup
#sysbench oltp_read_only --mysql-ssl=off --report-interval=1 --time=600 --threads=24 --tables=10 --table-size=10000000 --mysql-user=root run | tee -a res.warmup.ro.txt

for i in 1 4 16 24 32 48 64 128 256
do

        OUTDIR=res-OLTP-memory/$runid/thr$i
        mkdir -p $OUTDIR

        # start stats collection
        initialstat
        collect_mysql_stats 
        collect_dstat_stats 

        time=300
        sysbench oltp_point_select --mysql-ssl=off --report-interval=1 --time=$time --threads=$i --tables=10 --table-size=10000000 --mysql-user=root run |  tee -a $OUTDIR/res.txt

        # kill stats
        set +e
        kill $PIDDSTATSTAT
        kill $PIDMYSQLSTAT
        set -e

        sleep 30
done
