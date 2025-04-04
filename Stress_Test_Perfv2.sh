#!/bin/bash

# Performance testing script for CPU, Memory, Storage, and Networking
# Dependencies: stress-ng, sysbench, fio, iperf3
# Usage: sudo ./performance_test.sh

LOGFILE="performance_results_$(date +%F_%H-%M-%S).log"
SUMMARYFILE="/tmp/perf_summary.txt"
RAWFILE="/tmp/perf_raw.txt"
mkdir "TestLogs_$(date '+%Y-%m-%d_%H:%M:%S')" && cd "$_" || exit;

echo "Starting performance tests... Results will be saved in $LOGFILE"
echo "Performance Test Summary - $(date)" > "$SUMMARYFILE"
echo "Raw Output Begins Below" > "$RAWFILE"
echo "=================================================" >> "$RAWFILE"

### CPU TESTS ###
echo "[CPU TEST] Running stress-ng and sysbench..." | tee -a "$RAWFILE"
{
    echo "---- CPU Stress Test (stress-ng) ----"
    stress-ng --cpu 0 --cpu-method all -t 600s --metrics-brief
    echo "-----------CPU Sysbench Test 1a-----------" >> "CPU_PerfLog.yaml";
    sysbench --cpu-max-prime=999999 --threads=1 --time=300 --thread-stack-size=2048K --validate=on --histogram=off --percentile=99 --debug=off --verbosity=5 cpu run
    echo "-----------CPU Sysbench Test 1b-----------" >> "CPU_PerfLog.yaml";
    sysbench --cpu-max-prime=999999 --threads=$Cores --time=300 --thread-stack-size=2048K --validate=on --histogram=off --percentile=99 --debug=off --verbosity=5 cpu run
    echo "-----------CPU Sysbench Test 1c-----------" >> "CPU_PerfLog.yaml";
    sysbench --thread-yields=1024 --threads=1 --time=300 --thread-stack-size=2048K --validate=on --histogram=off --percentile=99 --debug=off --verbosity=5 threads run
    echo "-----------CPU Sysbench Test 1d-----------" >> "CPU_PerfLog.yaml";
    sysbench --thread-yields=1024 --threads=$Cores --time=300 --thread-stack-size=2048K --validate=on --histogram=off --percentile=99 --debug=off --verbosity=5 threads run
} >> "$RAWFILE" 2>&1

### MEMORY TESTS ###
echo "[MEMORY TEST] Running stress-ng and sysbench..." | tee -a "$RAWFILE"
{
    echo "---- Memory Stress Test (stress-ng) ----"
    stress-ng --vm 2 --vm-bytes 80% --metrics-brief --timeout 600s --timestamp
    echo "------------Mem Test 1a-----------" >> "Mem_PerfLog.yaml";
    sysbench --memory-block-size=1024K --memory-total-size=$Mem --memory-scope=global --memory-hugetlb=off --memory-oper=read --memory-access-mode=rnd --threads=1 --time=60 --thread-stack-size=64K --validate=on --histogram=off --percentile=99 --debug=off --verbosity=5 memory run
    echo "------------Mem Test 1b-----------" >> "Mem_PerfLog.yaml";
    sysbench --memory-block-size=1024K --memory-total-size=$Mem --memory-scope=global --memory-hugetlb=off --memory-oper=read --memory-access-mode=seq --threads=1 --time=60 --thread-stack-size=64K --validate=on --histogram=off --percentile=99 --debug=off --verbosity=5 memory run
    echo "------------Mem Test 1c-----------" >> "Mem_PerfLog.yaml";
    sysbench --memory-block-size=1024K --memory-total-size=$Mem --memory-scope=global --memory-hugetlb=off --memory-oper=write --memory-access-mode=rnd --threads=1 --time=60 --thread-stack-size=64K --validate=on --histogram=off --percentile=99 --debug=off --verbosity=5 memory run
    echo "------------Mem Test 1d-----------" >> "Mem_PerfLog.yaml";
    sysbench --memory-block-size=1024K --memory-total-size=$Mem --memory-scope=global --memory-hugetlb=off --memory-oper=write --memory-access-mode=seq --threads=1 --time=60 --thread-stack-size=64K --validate=on --histogram=off --percentile=99 --debug=off --verbosity=5 memory run
    echo "------------Mem Test 1e-----------" >> "Mem_PerfLog.yaml";
    sysbench --memory-block-size=1024K --memory-total-size=$Mem --memory-scope=global --memory-hugetlb=off --memory-oper=read --memory-access-mode=rnd --threads=$Cores --time=60 --thread-stack-size=64K --validate=on --histogram=off --percentile=99 --debug=off --verbosity=5 memory run
    echo "------------Mem Test 1f-----------" >> "Mem_PerfLog.yaml";
    sysbench --memory-block-size=1024K --memory-total-size=$Mem --memory-scope=global --memory-hugetlb=off --memory-oper=read --memory-access-mode=seq --threads=$Cores --time=60 --thread-stack-size=64K --validate=on --histogram=off --percentile=99 --debug=off --verbosity=5 memory run 
    echo "------------Mem Test 1g-----------" >> "Mem_PerfLog.yaml";
    sysbench --memory-block-size=1024K --memory-total-size=$Mem --memory-scope=global --memory-hugetlb=off --memory-oper=write --memory-access-mode=rnd --threads=$Cores --time=60 --thread-stack-size=64K --validate=on --histogram=off --percentile=99 --debug=off --verbosity=5 memory run
    echo "------------Mem Test 1h-----------" >> "Mem_PerfLog.yaml";
    sysbench --memory-block-size=1024K --memory-total-size=$Mem --memory-scope=global --memory-hugetlb=off --memory-oper=write --memory-access-mode=seq --threads=$Cores --time=60 --thread-stack-size=64K --validate=on --histogram=off --percentile=99 --debug=off --verbosity=5 memory run
} >> "$RAWFILE" 2>&1

### STORAGE TESTS ###
echo "[STORAGE TEST] Running fio..." | tee -a "$RAWFILE"
{
    echo "---- Sequential Read/Write (fio) ----"
    fio --name=seq_rw --rw=readwrite --size=1G --bs=1M --numjobs=1 --runtime=60 --group_reporting

    echo "---- Random Read/Write (fio) ----"
    fio --name=rand_rw --rw=randrw --size=1G --bs=4k --numjobs=4 --runtime=60 --group_reporting
} >> "$RAWFILE" 2>&1

### NETWORK TESTS ###
echo "[NETWORK TEST] Running iperf3 (requires a server)..." | tee -a "$RAWFILE"
echo "NOTE: iperf3 server must be running on a known host (e.g., 192.168.1.10:5201)" >> "$RAWFILE"
SERVER_IP="192.168.1.10"  # CHANGE THIS to your iperf3 server IP

{
    echo "---- iperf3 Bandwidth Test ----"
    iperf3 -c "$SERVER_IP" -t 30
} >> "$RAWFILE" 2>&1

### SUMMARY EXTRACTION ###
echo "Generating summary..."
grep -E "(CPU|Memory|Storage|iperf3).*" "$RAWFILE" | head -n 100 >> "$SUMMARYFILE"
echo "Summary generation complete."

### FINAL LOG ASSEMBLY ###
cat "$SUMMARYFILE" > "$LOGFILE"
echo -e "\n\n===== RAW OUTPUT BELOW =====\n" >> "$LOGFILE"
cat "$RAWFILE" >> "$LOGFILE"
cp "$LOGFILE" "results/$LOGFILE"

echo "All tests complete. Log saved to results/$LOGFILE"
