#!/bin/bash

# === Configuration ===
read -rp "Enter the target storage device (e.g., /dev/sdX or /mnt/testfile):" TEST_FILE
#TEST_FILE="/tmp/fio_test_file"
TEST_SIZE="1G"
#PRECON_SIZE="60T"
RUNTIME="30s"
OUTPUT_CSV="fio_results.csv"

sudo apt-get install jq fio

BLOCK_SIZES=(4k 8k 16k 32k 64k 128k 256k 1024k 2048k)
QUEUE_DEPTHS=(1 2 4 8 16 32 64 128 256)
READ_RATIOS=(100 99 95 90 75 50 25 10 5 1 0)

# === Preconditioning Step ===
#echo "Preconditioning storage with sequential write ($PRECON_SIZE)..."
#fio --name=precondition --filename="$TEST_FILE" --size="$PRECON_SIZE" \
#    --rw=write --bs=1M --ioengine=libaio --direct=1 --numjobs=1 --time_based \
#    --runtime=600s --group_reporting
#echo "Preconditioning done."

# === Header for CSV Output ===
echo "BlockSize,QueueDepth,ReadRatio,ReadMBps,WriteMBps,ReadIops,WriteIops,Read_SLatency,Read_CLatency,Write_SLatency,Write_CLatency" > "$OUTPUT_CSV"

# === Begin Tests ===
for bs in "${BLOCK_SIZES[@]}"; do
  for qd in "${QUEUE_DEPTHS[@]}"; do
    for rr in "${READ_RATIOS[@]}"; do
      echo "Running test: BS=$bs QD=$qd RR=$rr"
      fio --name=test --filename="$TEST_FILE" --size="$TEST_SIZE" \
          --rw=randrw --rwmixread=$rr --bs=$bs --ioengine=libaio --direct=1 \
          --numjobs=1 --iodepth=$qd --runtime=$RUNTIME \
          --group_reporting --output-format=json > tmp_fio.json

      # Parse JSON results for read/write throughput in MB/s
      read_bw=$(jq '.jobs[0].read.bw' tmp_fio.json)
      write_bw=$(jq '.jobs[0].write.bw' tmp_fio.json)
      read_iops=$(jq '.jobs[0].read.iops' tmp_fio.json)
      write_iops=$(jq '.jobs[0].write.iops' tmp_fio.json)
      read_slat=$(jq '.jobs[0].read.slat' tmp_fio.json)
      read_clat=$(jq '.jobs[0].read.slat' tmp_fio.json)
      write_slat=$(jq '.jobs[0].write.slat' tmp_fio.json)
      write_clat=$(jq '.jobs[0].write.slat' tmp_fio.json)

      # Convert to MB/s from KB/s
      read_mb=$(awk "BEGIN {printf \"%.2f\", $read_bw / 1024}")
      write_mb=$(awk "BEGIN {printf \"%.2f\", $write_bw / 1024}")
      

      echo "$bs,$qd,$rr,$read_mb,$write_mb,$read_iops,$write_iops,$read_slat,$read_clat,$write_slat,$write_clat" >> "$OUTPUT_CSV"
    done
  done
done

# === Final Output ===
echo -e "\nAll tests completed. Results saved to $OUTPUT_CSV"

# Optional: Pretty print the results
column -s, -t "$OUTPUT_CSV" | less -S
