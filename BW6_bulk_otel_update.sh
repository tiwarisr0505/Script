#!/bin/bash

INPUT_FILE="Phase1_APIs.txt"
OUTPUT_FILE="otel_update_status.csv"

echo "Domain,AppSpace,AppNode,Otel_Status" > $OUTPUT_FILE

while IFS=',' read DOMAIN APPSPACE APPNODE
do

echo "------------------------------------"
echo "Processing $APPSPACE"

# Run OTEL update script
echo "$APPSPACE" | ./BW6_otel_config_update_In_Tra.sh $APPSPACE

if [ $? -eq 0 ]
then
    STATUS="Completed"
else
    STATUS="Failed"
fi

# Restart AppNode
bwadmin stop appnode -d $DOMAIN -n $APPNODE
sleep 5
bwadmin start appnode -d $DOMAIN -n $APPNODE

# Write output
echo "$DOMAIN,$APPSPACE,$APPNODE,$STATUS" >> $OUTPUT_FILE

done < $INPUT_FILE

echo "------------------------------------"
echo "Execution completed"
echo "Output file: $OUTPUT_FILE"