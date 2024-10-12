#!/bin/bash

# Define the variables for file paths
health_files=("./healthcheck.connectionerror" "./healthcheck.exitstate")
reasons=("Connection error" "Fatal error")
status=0  # Default status as healthy (exit code 0)
unhealthy_reason=""  # Variable to hold the reason for being unhealthy

# Function to check the health status of each file
check_health_file() {
  local file=$1
  local reason=$2
  local content

  # Check if the file exists and is readable
  if [[ ! -r "$file" ]]; then
    echo "$reason: file does not exist or is not readable"
    status=1
    unhealthy_reason="$reason"  # Set the reason for unhealthiness
    return
  fi

  # Read the content of the file
  content=$(<"$file")

  # Check if the file marks the container as unhealthy
  if [[ "$content" == "Container is Unhealthy" ]]; then
    status=1  # Mark the status as unhealthy
    unhealthy_reason="$reason"  # Set the reason for unhealthiness
  fi
}

# Loop over each file and check its health
for i in "${!health_files[@]}"; do
  check_health_file "${health_files[$i]}" "${reasons[$i]}"
done

# Determine final health status
if [[ $status -eq 0 ]]; then
  echo "Container is healthy"
else
  echo "Container is unhealthy due to: $unhealthy_reason"
fi

exit $status
