#!/bin/bash

INPUT_FILE="Phase1_APIs.txt"
OUTPUT_FILE="otel_update_status.csv"

echo "Domain,AppSpace,AppNode,Otel_Status" > $OUTPUT_FILE

while IFS=',' read DOMAIN APPSPACE APPNODE
do

echo "-----------------------------------------"
echo "Processing Domain: $DOMAIN"
echo "AppSpace: $APPSPACE"
echo "AppNode: $APPNODE"
echo "-----------------------------------------"

# Execute OTEL update script
echo "$APPSPACE" | ./BW6_otel_config_update_In_Tra.sh $APPSPACE

SCRIPT_STATUS=$?

if [ $SCRIPT_STATUS -eq 0 ]
then
    STATUS="Completed"

    echo "OTEL update completed for $APPSPACE"
    echo "Restarting AppNode: $APPNODE"

    bwadmin stop appnode -d $DOMAIN -n $APPNODE
    sleep 5
    bwadmin start appnode -d $DOMAIN -n $APPNODE

else
    STATUS="Failed"
    echo "OTEL update failed for $APPSPACE"
    echo "Skipping AppNode restart"
fi

# Write result to output file
echo "$DOMAIN,$APPSPACE,$APPNODE,$STATUS" >> $OUTPUT_FILE

done < $INPUT_FILE

echo "-----------------------------------------"
echo "Execution Completed"
echo "Output file generated: $OUTPUT_FILE"