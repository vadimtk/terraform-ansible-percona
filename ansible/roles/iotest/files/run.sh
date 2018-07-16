cd /mnt/data
sysbench fileio --file-total-size=200GB --threads=4 --file-extra-flags=direct --file-test-mode=rndrw --file-io-mode=async --report-interval=1 --time=3600 --file-fsync-freq=0 run 
