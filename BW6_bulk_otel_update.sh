#!/bin/bash

INPUT_FILE="Phase1_APIs.txt"

while IFS=',' read DOMAIN APPSPACE APPNODE
do

echo "--------------------------------------"
echo "Processing AppSpace: $APPSPACE"
echo "AppNode: $APPNODE"
echo "--------------------------------------"

# Run otel config script
echo "Updating TRA file..."
echo "$APPSPACE" | ./BW6_otel_config_update_In_Tra.sh $APPSPACE

# Restart AppNode
echo "Restarting AppNode..."

bwadmin stop appnode -d $DOMAIN -n $APPNODE
sleep 5
bwadmin start appnode -d $DOMAIN -n $APPNODE

echo "Completed for $APPSPACE"

done < $INPUT_FILE