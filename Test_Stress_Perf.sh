#!/bin/bash

sudo apt-get -y install stress-ng sysbench

Cores=$(nproc)
Mem=$(cat /proc/meminfo | grep 'MemTotal:' | awk '{print $2}')

mkdir "TestLogs_$(date '+%Y-%m-%d_%H:%M:%S')" && cd "$_" || exit;

stress-ng --cpu 0 --cpu-method all -t 600s --metrics --timestamp --log-file "CPU_StressResults.yaml";
# shellcheck disable=SC2129
echo "-----------CPU Test 1a-----------" >> "CPU_PerfLog.yaml";
sysbench --cpu-max-prime=999999 --threads=1 --time=300 --thread-stack-size=2048K --validate=on --histogram=off --percentile=99 --debug=off cpu run | cat >> "CPU_PerfLog.yaml";
echo "-----------CPU Test 1b-----------" >> "CPU_PerfLog.yaml";
sysbench --cpu-max-prime=999999 --threads=$Cores --time=300 --thread-stack-size=2048K --validate=on --histogram=off --percentile=99 --debug=off cpu run | cat >> "CPU_PerfLog.yaml";
echo "-----------CPU Test 1c-----------" >> "CPU_PerfLog.yaml";
sysbench --thread-yields=1024 --threads=1 --time=300 --thread-stack-size=2048K --validate=on --histogram=off --percentile=99 --debug=off threads run | cat >> "CPU_PerfLog.yaml";
echo "-----------CPU Test 1d-----------" >> "CPU_PerfLog.yaml";
sysbench --thread-yields=1024 --threads=$Cores --time=300 --thread-stack-size=2048K --validate=on --histogram=off --percentile=99 --debug=off threads run | cat >> "CPU_PerfLog.yaml";
cat "CPU_PerfLog.yaml" | egrep -E '99th|---|Number|total' > "CPU_PerfResults.yaml";

stress-ng --vm 2 --vm-bytes 80% --timeout 600s --metrics --timestamp --log-file "Mem_StressResults.yaml";
echo "------------Mem Test 1a-----------" >> "Mem_PerfLog.yaml";
sysbench --memory-block-size=1024K --memory-total-size=$Mem --memory-scope=global --memory-hugetlb=off --memory-oper=read --memory-access-mode=rnd --threads=1 --time=60 --thread-stack-size=64K --validate=on --histogram=off --percentile=99 --debug=off memory run | cat >> "Mem_PerfLog.yaml";
echo "------------Mem Test 1b-----------" >> "Mem_PerfLog.yaml";
sysbench --memory-block-size=1024K --memory-total-size=$Mem --memory-scope=global --memory-hugetlb=off --memory-oper=read --memory-access-mode=seq --threads=1 --time=60 --thread-stack-size=64K --validate=on --histogram=off --percentile=99 --debug=off memory run | cat >> "Mem_PerfLog.yaml";
echo "------------Mem Test 1c-----------" >> "Mem_PerfLog.yaml";
sysbench --memory-block-size=1024K --memory-total-size=$Mem --memory-scope=global --memory-hugetlb=off --memory-oper=write --memory-access-mode=rnd --threads=1 --time=60 --thread-stack-size=64K --validate=on --histogram=off --percentile=99 --debug=off memory run | cat >> "Mem_PerfLog.yaml";
echo "------------Mem Test 1d-----------" >> "Mem_PerfLog.yaml";
sysbench --memory-block-size=1024K --memory-total-size=$Mem --memory-scope=global --memory-hugetlb=off --memory-oper=write --memory-access-mode=seq --threads=1 --time=60 --thread-stack-size=64K --validate=on --histogram=off --percentile=99 --debug=off memory run | cat >> "Mem_PerfLog.yaml";
echo "------------Mem Test 1e-----------" >> "Mem_PerfLog.yaml";
sysbench --memory-block-size=1024K --memory-total-size=$Mem --memory-scope=global --memory-hugetlb=off --memory-oper=read --memory-access-mode=rnd --threads=$Cores --time=60 --thread-stack-size=64K --validate=on --histogram=off --percentile=99 --debug=off memory run | cat >> "Mem_PerfLog.yaml";
echo "------------Mem Test 1f-----------" >> "Mem_PerfLog.yaml";
sysbench --memory-block-size=1024K --memory-total-size=$Mem --memory-scope=global --memory-hugetlb=off --memory-oper=read --memory-access-mode=seq --threads=$Cores --time=60 --thread-stack-size=64K --validate=on --histogram=off --percentile=99 --debug=off memory run | cat >> "Mem_PerfLog.yaml";
echo "------------Mem Test 1g-----------" >> "Mem_PerfLog.yaml";
sysbench --memory-block-size=1024K --memory-total-size=$Mem --memory-scope=global --memory-hugetlb=off --memory-oper=write --memory-access-mode=rnd --threads=$Cores --time=60 --thread-stack-size=64K --validate=on --histogram=off --percentile=99 --debug=off memory run | cat >> "Mem_PerfLog.yaml";
echo "------------Mem Test 1h-----------" >> "Mem_PerfLog.yaml";
sysbench --memory-block-size=1024K --memory-total-size=$Mem --memory-scope=global --memory-hugetlb=off --memory-oper=write --memory-access-mode=seq --threads=$Cores --time=60 --thread-stack-size=64K --validate=on --histogram=off --percentile=99 --debug=off memory run | cat >> "Mem_PerfLog.yaml";

cat "Mem_PerfLog.yaml" | grep -E 'Number of threads|---|operation|transferred|99th' >> "Mem_PerfResults.yaml";

cat *Results.yaml >> "$HOSTNAME"_$(date '+%Y-%m-%d_%H:%M:%S').yaml;
