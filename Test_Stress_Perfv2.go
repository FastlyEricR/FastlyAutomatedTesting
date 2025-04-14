package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
	"time"
)

var logFile = "benchmark_results.log"

func runCommand(name string, args ...string) string {
	cmd := exec.Command(name, args...)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Sprintf("Error running %s %v: %v\n%s", name, args, err, string(output))
	}
	return string(output)
}

func writeLog(title string, content string, log *os.File) {
	log.WriteString("====================\n")
	log.WriteString(title + "\n")
	log.WriteString("====================\n")
	log.WriteString(content + "\n\n")
}

func main() {
	logFileHandler, err := os.Create(logFile)
	if err != nil {
		log.Fatalf("Failed to create log file: %v", err)
	}
	defer logFileHandler.Close()

	summary := []string{}

	// CPU Test
	cpuParams := [][]string{
		{"--cpu", "8", "--timeout", "30s"}, //Placeholder
		{"--cpu", "16", "--timeout", "30s"}, //Placeholder
	}
	for i, params := range cpuParams {
		title := fmt.Sprintf("CPU Test %d - stress-ng %v", i+1, params)
		result := runCommand("stress-ng", params...)
		writeLog(title, result, logFileHandler)
		summary = append(summary, fmt.Sprintf("CPU Test %d: Completed", i+1))
	}

	// Memory Test
	memParams := [][]string{
		{"--vm", "4", "--vm-bytes", "2G", "--timeout", "30s"}, //Placeholder
		{"--vm", "8", "--vm-bytes", "1G", "--timeout", "30s"}, //Placeholder
	}
	for i, params := range memParams {
		title := fmt.Sprintf("Memory Test %d - stress-ng %v", i+1, params)
		result := runCommand("stress-ng", params...)
		writeLog(title, result, logFileHandler)
		summary = append(summary, fmt.Sprintf("Memory Test %d: Completed", i+1))
	}

	// Storage Test
	fioParams := [][]string{
		{"--name=write_test", "--rw=write", "--bs=1M", "--size=512M", "--numjobs=1", "--time_based", "--runtime=30s"}, //Placeholder
		{"--name=randrw_test", "--rw=randrw", "--bs=4k", "--size=512M", "--numjobs=4", "--time_based", "--runtime=30s"}, //Placehoder
	}
	for i, params := range fioParams {
		title := fmt.Sprintf("Storage Test %d - fio %v", i+1, params)
		result := runCommand("fio", params...)
		writeLog(title, result, logFileHandler)
		summary = append(summary, fmt.Sprintf("Storage Test %d: Completed", i+1))
	}

	// Network Test (Using iperf3)
	netParams := [][]string{
		{"-c", "127.0.0.1", "-t", "10"},
		{"-c", "127.0.0.1", "-t", "10", "-u", "-b", "100M"},
	}
	for i, params := range netParams {
		title := fmt.Sprintf("Network Test %d - iperf3 %v", i+1, params)
		result := runCommand("iperf3", params...)
		writeLog(title, result, logFileHandler)
		summary = append(summary, fmt.Sprintf("Network Test %d: Completed", i+1))
	}

	// Write Summary
	summaryHeader := "Server Benchmark Summary - " + time.Now().Format(time.RFC1123) + "\n"
	logFileHandler.Seek(0, 0)
	logFileHandler.WriteString(summaryHeader + strings.Join(summary, "\n") + "\n\n")

	fmt.Println("Benchmark completed. Results written to", logFile)
}
