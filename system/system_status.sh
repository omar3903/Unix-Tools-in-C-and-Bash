#!/bin/bash

################################################################################
# System Status Script
# Author: Omar Abdeen
# Date: 3/25/2024
#
# Description:
#   This script monitors various system metrics such as CPU utilization, free memory,
#   and disk usage, and provides warnings if any metric exceeds a specified threshold.
#
# Usage: ./system_status.sh [email_address]
#   Prints the report, and also emails it when an address is given.
#   printf instead of echo "...\n", so the blank lines come out the same in bash and sh



cpu_utilization() {
# Function to check CPU Utilization and compare it with a threshold percentage
# Usage: cpu_utilization <cpu_threshold_percentage>
# Arguments:
#   - cpu_threshold_percentage: The threshold percentage for CPU usage (between 0 and 100)
# Returns:
    #   - "cpu ok!!" if CPU utilization is below the threshold
    #   - "cpu warning!!" if CPU utilization is above threshold
    printf "#############################################\n\n"
    cpu_threshold_percentage=$1
    if [ -z "$1" ]; then
	echo "Usage: cpu_utilization <cpu_threshold_percentage>"
	return 1
    fi
    # %d keeps it a whole number, -gt only compares integers
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{printf "%d", 100 - $1}')
    printf "cpu utilization: %s\n\n" "$cpu_usage"
    if [ "$cpu_usage" -gt "$cpu_threshold_percentage" ]; then
        printf "cpu warning!!\n\n"
    else
        printf "cpu ok!!\n\n"
    fi
}

mem_free() {
# Function to check the percentage of free memory and compare it with a threshold
# Usage: mem_free <free_memory_threshold_percentage>
# Arguments:
#   - free_memory_threshold_percentage: The threshold percentage of free memory (between 0 to 100)
# Returns:
#   - "memory warning!!" if the memory free is below the threshold
    #   - "memory ok!!" if the memory free is above the threshold
    printf "#############################################\n\n"
    mem_usage=$(free | grep Mem | awk '{print $4/$2 * 100.0}')
    free_memory_threshold_percentage=$1
    if [ -z "$1" ]; then
	echo "Usage: mem_free <free_memory_threshold_percentage>"
	return 1
    fi
    printf "percent memory free is : %s %%\n\n" "$mem_usage"
    # the percentage has decimals, so awk does the comparison. warning when free memory is BELOW the threshold
    if awk -v free="$mem_usage" -v threshold="$free_memory_threshold_percentage" 'BEGIN { exit !(free < threshold) }'; then
	printf "memory warning!!\n\n"
    else
	printf "memory ok!!\n\n"
    fi
}

disk_usage() {
# Function to check disk usage and display warning if it exceeds a threshold percentage
# Usage: disk_usage <disk_threshold_percentage>
# Arguments:
#   - disk_threshold_percentage: The threshold percentage for disk usage (0-100)
# Returns:
#   - "Disk ok!!" if disk usage is below the threshold
    #   - "Disk warning!!" if disk usage is above the threshold
    printf "#############################################\n\n"
    # the fullest disk, so one disk over the threshold is enough for a warning
    curr_disk_usage=$(df -H | grep -v -E '^Filesystem|tmpfs|cdrom' | awk '{print $5}' | cut -d '%' -f1 | sort -n | tail -1)
    disk_threshold_percentage=$1
    if [ -z "$1" ]; then
	echo "Usage: disk_usage <disk_threshold_percentage>"
	return 1
    fi
    printf "Disk usage: %s\n\n" "$curr_disk_usage"
    if [ "$curr_disk_usage" -gt "$disk_threshold_percentage" ]; then
	printf "Disk warning!!\n\n"
    else
	printf "Disk ok!!\n\n"
    fi
}
send_report() {
# Function to send a system status report via email
# Usage: send_report <email_address>
# Arguments:
    #   - email_address: The email address to send the report to
    report=$(check_all)
    # show the report on the console too, not only in the email
    printf "%s\n\n" "$report"
    printf "#############################################\n\n"
    printf "Capturing the system status\n\n"
    if [ -z "$1" ]; then
        printf "No email address given, so the report was only printed\n\n"
    elif ! command -v mail > /dev/null; then
        printf "The mail program is not installed, so the report was not sent to %s\n\n" "$1"
    else
        printf "Sending email with the system status to %s\n\n" "$1"
        printf "%s\n" "$report" | mail -s "System Status Report" "$1"
    fi
    printf "#############################################\n\n"
}

check_all() {
# Function to check CPU utilization, free memory, and disk usage
    # Usage: check_all
    printf "#############################################\n\n"
    curr_time=$(date "+%a %b %d %T %Z %Y")
    printf "Testing CPU utilization, free memory, disk usage status of the system on %s\n\n" "$curr_time"
    cpu_utilization 80
    mem_free 95
    disk_usage 80
}

send_report "$1"
