#!/bin/env bash

# Debug code to start on minute boundary and to
# gradually increase maximum payload duration to
# see what happens when the payload exceeds 30 seconds.

WIFI_SSID="Umar"

while true; do
    # Start a background timer BEFORE the payload runs.
    # The original script had a 30-second sleep here.
    # If the goal is to check connectivity roughly every 30 seconds,
    # and the wget can take some time, this sleep might need adjustment
    # or be placed differently depending on the exact desired timing.
    # For now, I'll keep it as it was.
    sleep 30 &
    TIMER_PID=$! # Capture the PID of the background sleep

    echo "Checking internet connectivity..."
    wget -q --spider http://google.com

    if [ $? -eq 0 ]; then
        echo "Online"
    else
        echo "Offline"
        echo "Attempting to connect to Wi-Fi: $WIFI_SSID"
        # Attempt to connect to the specified Wi-Fi network
        # The `nmcli device wifi connect` command might ask for a password
        # if the connection is not already configured and saved.
        # If the network is already known and saved, it should connect without prompting.
        nmcli device wifi connect "$WIFI_SSID"
        if [ $? -eq 0 ]; then
            echo "Successfully initiated connection to $WIFI_SSID."
            echo "Waiting a few seconds for connection to establish..."
            sleep 10 # Give some time for the connection to establish
            # Optionally, re-check connectivity
            wget -q --spider http://google.com
            if [ $? -eq 0 ]; then
                echo "Now Online after connecting to $WIFI_SSID."
            else
                echo "Still Offline after attempting to connect to $WIFI_SSID."
            fi
        else
            echo "Failed to initiate connection to $WIFI_SSID."
        fi
    fi
    # Wait for timer to finish before next cycle.
    echo "Waiting for background timer (PID: $TIMER_PID) to complete..."
    wait $TIMER_PID
    echo "Timer complete. Restarting cycle."
    echo "------------------------------------"
done