#!/bin/bash

# Define the variables for file paths and timestamp maximum age
connectionerror_file="./healthcheck.connectionerror"
exitstate_file="./healthcheck.exitstate"
timestamp_file="./healthcheck.timestamp"
maximum_age=300

# Function to check if a exitstate_file and connectionerror_file exists, is readable, and contains valid status
check_health_file() {
  local file=$1
  local reason=$2
  local content

  # Check if the file exists and is readable
  if [[ ! -r "$file" ]]; then
    echo "$reason file does not exist or is not readable"
    exit 1
  fi

  # Read the content of the file
  content=$(<"$file")

  # Check the content and determine if the container is unhealthy
  if [[ "$content" == "Container is Unhealthy" ]]; then
    echo "Container is marked as unhealthy due to $reason"
    exit 1
  elif [[ "$content" != "Container is Healthy" ]]; then
    echo "Unknown status in $file: $content"
    exit 1
  fi
}

# Check the health status in both specified files
check_health_file "$connectionerror_file" "Connection error"
check_health_file "$exitstate_file" "Exit state issue"

# Check if the timestamp file exists and is readable
if [[ ! -r "$timestamp_file" ]]; then
  echo "Timestamp file does not exist or is not readable"
  exit 1
fi

# Get the current Unix timestamp
current_timestamp=$(date +%s)

# Read the timestamp from the file and check if it’s a valid number
if ! last_timestamp=$(<"$timestamp_file") || ! [[ "$last_timestamp" =~ ^[0-9]+$ ]]; then
  echo "Invalid timestamp in file"
  exit 1
fi

# Calculate the difference between the current timestamp and the last recorded timestamp
difference=$((current_timestamp - last_timestamp))

# Determine if the timestamp is within the acceptable range
if (( difference < maximum_age )); then
  echo "Timestamp is valid"
  exit 0
else
  echo "Timestamp is outdated"
  exit 1
fi
