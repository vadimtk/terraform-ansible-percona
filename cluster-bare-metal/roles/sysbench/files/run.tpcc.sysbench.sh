HOST="--mysql-socket=/tmp/mysql.sock"
#HOST="--mysql-host=127.0.0.1"
MYSQLDIR=/mnt/data/vadim/servers/mysql-8.0.21-linux-glibc2.12-x86_64
DATADIR=/data/mariadb-10.5.4
BACKUPDIR=/mnt/data/mariadb-10.5.4-copy
CONFIG=/mnt/data/vadim/servers/my.cnf

set -x
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

startmysql(){
  sync
  sysctl -q -w vm.drop_caches=3
  echo 3 > /proc/sys/vm/drop_caches
  ulimit -n 1000000
  #numactl --interleave=all $MYSQLDIR/bin/mysqld --defaults-file=$CONFIG --basedir=$MYSQLDIR --datadir=$DATADIR $1 &
  systemctl set-environment MYSQLD_OPTS="$1"
  systemctl start mysql-cd
}

shutdownmysql(){
  echo "Shutting mysqld down..."
  systemctl stop mysql-cd
  #$MYSQLDIR/bin/mysqladmin shutdown -S /tmp/mysql.sock
}

waitmysql(){
        set +e

        while true;
        do
                $MYSQLDIR/bin/mysql -Bse "SELECT 1" mysql

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
  $MYSQLDIR/bin/mysqladmin ext -i10 > $OUTDIR/mysqladminext.txt &
  PIDMYSQLSTAT=$!
}
collect_dstat_stats(){
  vmstat 1 > $OUTDIR/vmstat.out &
  PIDDSTATSTAT=$!
}



shutdownmysql

#RUNDIR=res-mysql-8.0.21-tpcc-`date +%F-%H-%M`
RUNDIR=res-mariadb-tpcc-`date +%F-%H-%M`
echo "XFS defrag"
xfs_fsr /dev/nvme0n1

for io in 15000
do

echo "Restoring backup"
rm -fr $DATADIR
cp -r $BACKUPDIR $DATADIR
chown mysql.mysql -R $DATADIR
fstrim /data

iomax=$(( 3*$io/2 ))

startmysql "--innodb-io-capacity=${io} --innodb_io_capacity_max=$iomax" &
sleep 10
waitmysql

runid="io$io"

# perform warmup
#./tpcc.lua --mysql-host=127.0.0.1 --mysql-user=sbtest --mysql-password=sbtest --mysql-db=sbtest --time=3600 --threads=56 --report-interval=1 --tables=10 --scale=100 --use_fk=1 run |  tee -a $OUTDIR/res.txt

for i in  56
do

        OUTDIR=$RUNDIR/$runid
        mkdir -p $OUTDIR

        # start stats collection


        time=10000
        /mnt/data/vadim/bench/sysbench-tpcc/tpcc.lua --mysql-host=127.0.0.1 --mysql-user=sbtest --mysql-password=sbtest --mysql-db=sbtest --time=$time --threads=$i --report-interval=1 --tables=10 --scale=100 --use_fk=0 --report-csv=yes run |  tee -a $OUTDIR/res.thr${i}.txt


        sleep 30
done

shutdownmysql

done
