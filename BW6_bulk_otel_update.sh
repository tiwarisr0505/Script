#!/bin/bash

INPUT_FILE="Phase1_APIs.txt"
OUTPUT_FILE="otel_update_status.csv"

echo "Domain,AppSpace,AppNode,Otel_Status" > $OUTPUT_FILE

while IFS=',' read DOMAIN APPSPACE APPNODE
do

echo "----------------------------------------"
echo "Processing OTEL Update AppSpace: $APPSPACE"
echo "AppNode: $APPNODE"
echo "----------------------------------------"

TMP_LOG=$(mktemp)

printf "%s\ny\nn\n" "$APPSPACE" | ./BW6_Otel_Config_Update_In_Tra.sh > $TMP_LOG 2>&1

# Determine status
if grep -q "No change required" "$TMP_LOG"
then
    STATUS="AlreadyUpdated"

elif grep -q "Updated:" "$TMP_LOG"
then
    STATUS="Updated"

else
    STATUS="Failed"
fi

# Restart AppNode if script didn't fail
if [ "$STATUS" != "Failed" ]
then
    echo "Restarting AppNode: $APPNODE"
    bwadmin restart -d $DOMAIN -n $APPNODE
fi

echo "$DOMAIN,$APPSPACE,$APPNODE,$STATUS" >> $OUTPUT_FILE

rm -f "$TMP_LOG"

done < "$INPUT_FILE"

echo "----------------------------------------"
echo "Execution completed"
echo "Output file: $OUTPUT_FILE"