#!/bin/bash

# === Configuration ===
read -rp "Enter the target storage device (e.g., /dev/sdX or /mnt/testfile):" TEST_FILE
#TEST_FILE="/tmp/fio_test_file"
#TEST_SIZE="1G"
read -rp "Enter Percent Fill of target storage device (e.g. 90%):" PRECON_SIZE
#RUNTIME="600s"
#OUTPUT_CSV="fio_results.csv"
sudo apt-get install fio

 === Preconditioning Step ===
echo "Preconditioning storage with sequential write to fill($PRECON_SIZE) of target disk..."
fio --name=precondition --filename="$TEST_FILE" --size="$PRECON_SIZE"% \
    --rw=write --bs=1M --ioengine=libaio --direct=1 --numjobs=1 \
    --group_reporting
echo "Preconditioning done."
