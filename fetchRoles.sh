#!/bin/sh
result=$(curl -X GET --header "Accept: */*" "http://localhost:8082/iam/fetchSAcctRoles")
echo "Response from server"
echo $result > roles.json
exit