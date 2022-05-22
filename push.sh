#!/bin/bash
start=$(date +%s)

IFS="\n"
commitFile='update.txt'

. ./gen.sh

git add .

if test -f "$commitFile"; then
	for line in $(<$commitFile); do
		if [[ $commitMsg == "" ]]; then
			commitMsg="${line}"
		else  
			commitMsg="$commitMsg
$line"
		fi 
	done
fi
while [[ $commitMsg == "" ]];
do
	echo "Enter your commit message: "
	while read tmsg; do
		if [[ $tmsg == "" ]]; then
			break
		fi
		if [[ "$commitMsg" == "" ]]; then
			commitMsg="$tmsg"
		else
			commitMsg="$commitMsg
$tmsg"
		fi
	done
done
echo "" > $commitFile
git commit -m "$commitMsg"
git push

end=$(date +%s)
time=$(expr $end - $start)
echo "completed in $time seconds"