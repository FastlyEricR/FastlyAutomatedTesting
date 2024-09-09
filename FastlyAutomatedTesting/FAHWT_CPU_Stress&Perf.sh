#!/bin/bash

mk dir "TestLogs_$(date '+%Y-%m-%d_%H:%M:%S')" && cd "$_" || exit;
# shellcheck disable=SC2129
sysbench --cpu-max-prime=999999 --threads=1 --time=300 --thread-stack-size=2048K --validate=on --histogram=off --percentile=99 --debug=off cpu run | tee >> "CPU_PerfLog.yaml";
sysbench --cpu-max-prime=999999 --threads=128 --time=300 --thread-stack-size=2048K --validate=on --histogram=off --percentile=99 --debug=off cpu run | tee >> "CPU_PerfLog.yaml";
sysbench --thread-yields=1024 --threads=1 --time=300 --thread-stack-size=2048K --validate=on --histogram=off --percentile=99 --debug=off threads run | tee >> "CPU_PerfLog.yaml";
sysbench --thread-yields=1024 --threads=128 --time=300 --thread-stack-size=2048K --validate=on --histogram=off --percentile=99 --debug=off threads run | tee >> "CPU_PerfLog.yaml";
# shellcheck disable=SC2129
sysbench --memory-block-size=1024K --memory-total-size=1024G --memory-scope=global --memory-hugetlb=off --memory-oper=read --memory-access-mode=rnd --threads=128 --time=60 --thread-stack-size=64K --validate=on --histogram=off --percentile=99 --debug=off memory run | tee >> "Mem_PerfLog.yaml";
sysbench --memory-block-size=1024K --memory-total-size=1024G --memory-scope=global --memory-hugetlb=off --memory-oper=read --memory-access-mode=seq --threads=128 --time=60 --thread-stack-size=64K --validate=on --histogram=off --percentile=99 --debug=off memory run | tee >> "Mem_PerfLog.yaml";
sysbench --memory-block-size=1024K --memory-total-size=1024G --memory-scope=global --memory-hugetlb=off --memory-oper=write --memory-access-mode=rnd --threads=128 --time=60 --thread-stack-size=64K --validate=on --histogram=off --percentile=99 --debug=off memory run | tee >> "Mem_PerfLog.yaml";
sysbench --memory-block-size=1024K --memory-total-size=1024G --memory-scope=global --memory-hugetlb=off --memory-oper=write --memory-access-mode=seq --threads=128 --time=60 --thread-stack-size=64K --validate=on --histogram=off --percentile=99 --debug=off memory run | tee >> "Mem_PerfLog.yaml";
# shellcheck disable=SC2035
cat *.yaml >> "'HOSTNAME'_$(date '+%Y-%m-%d_%H:%M:%S').yaml"
end
