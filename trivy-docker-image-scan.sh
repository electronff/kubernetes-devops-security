#!/bin/bash

# Extract the Docker image name from the Dockerfile
dockerImageName=$(awk '/^FROM /{print $2}' Dockerfile)
echo "Scanning Docker image: $dockerImageName"

# Run Trivy to scan the Docker image for HIGH and CRITICAL vulnerabilities
docker run --rm -v /tmp/.cache:/root/.cache/ aquasec/trivy:0.17.2 -q image \
  --exit-code 1 --severity HIGH,CRITICAL --light "$dockerImageName"

# Capture the exit code from the Trivy scan
exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo "No HIGH or CRITICAL vulnerabilities found in $dockerImageName"
elif [ $exit_code -eq 1 ]; then
    echo "HIGH or CRITICAL vulnerabilities found in $dockerImageName"
else
    echo "Trivy scan failed."
fi

exit $exit_code
