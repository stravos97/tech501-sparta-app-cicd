#!/bin/bash

# GCloud SSH Wrapper for Ansible
# This script translates Ansible SSH calls to gcloud compute ssh commands

set -e

# Debug: Log all arguments
echo "SSH Wrapper called with args: $*" >&2

# Parse command line arguments
HOST=""
COMMAND=""
USER=""
SKIP_NEXT=false
FOUND_HOST=false
TTY_FLAG=""

# Parse arguments
args=("$@")
for ((i=0; i<${#args[@]}; i++)); do
    arg="${args[i]}"
    
    if [[ $SKIP_NEXT == true ]]; then
        SKIP_NEXT=false
        continue
    fi
    
    case "$arg" in
        -l|-i|-o)
            SKIP_NEXT=true
            ;;
        -tt)
            TTY_FLAG="--ssh-flag=-tt"
            ;;
        -*)
            # Skip other options
            ;;
        *)
            if [[ $FOUND_HOST == false ]]; then
                HOST="$arg"
                FOUND_HOST=true
            else
                # Everything after the host is the command
                COMMAND="${args[@]:$i}"
                break
            fi
            ;;
    esac
done

# Extract instance name from host (remove any user@ prefix)
INSTANCE_NAME="${HOST#*@}"

# Default project and zone
PROJECT="gcp-sparta"
ZONE="us-central1-a"

echo "Connecting to instance: $INSTANCE_NAME" >&2

# Build gcloud command array
GCLOUD_ARGS=(
    "compute" "ssh"
    "--zone=$ZONE"
    "$INSTANCE_NAME"
    "--project=$PROJECT"
)

# Add tunnel-through-iap for private instances (db-instance)
if [[ $INSTANCE_NAME == "db-instance" ]]; then
    GCLOUD_ARGS+=("--tunnel-through-iap")
fi

# Add TTY flag if needed
if [[ -n $TTY_FLAG ]]; then
    GCLOUD_ARGS+=("$TTY_FLAG")
fi

# If there's a command to execute, add it
if [[ -n $COMMAND ]]; then
    GCLOUD_ARGS+=("--command=$COMMAND")
fi

echo "Executing: gcloud ${GCLOUD_ARGS[*]}" >&2

# Execute the gcloud command
exec gcloud "${GCLOUD_ARGS[@]}"
