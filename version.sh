#!/bin/bash
control="control"
controlFind="Version:"
controlVersion=0

makefile="Makefile"
makefileFind="PACKAGE_VERSION="
makefileVersion=0

f() { v=("${BASH_ARGV[@]}"); }

updateVersion(){
	file=$1
	shift 1
	findMe=$1

	oldVersion=$(sed -n '/'^$findMe'/p' $file)
	old=$(sed -n 's/'^$findMe'//p' $file)
	IFS="." read -r -a v <<< $old

	shopt -s extdebug
	f "${v[@]}"
	shopt -u extdebug

	index=0
	if [[ ${#v[@]} == 1 ]]; then
		return
	fi

	for i in ${v[@]}
	do
		if [ $i != $findMe ]; then
			if [[ $i -eq 9 ]]; then
				v[$index]=0
			else
				v[$index]=$((i+1))
				break
			fi
		fi

		index=$((index+1))
	done

	shopt -s extdebug
	f "${v[@]}"
	shopt -u extdebug

	index=1

	if [[ $file == $control ]]; then
		oldControlVersion=$oldVersion
	else
		oldMakefileVersion=$oldVersion
	fi

	for i in ${v[@]}; do
		if [[ ${index} -le 2 ]]; then
			if [[ $file == $control ]]; then
				newVersion="${findMe} ${i}"
			else
				newVersion="${findMe}${i}"
			fi
			newV=${i}
		elif [[ $i == $findMe ]]; then
			v[$index]=
		else
			newVersion="${newVersion}.${i}"
			newV="${newV}.${i}"
		fi

		index=$((index+1))
		if [[ $index -eq ${#v[@]} ]]; then
		break
		fi
	done

#	echo -e "
#********\e[31m$file\e[0m********"
#	echo "oldVersion: $old
#newVersion: ${newVersion}"
	if [[ $file == $control ]]; then
		controlVersion=$newV
	else
		makefileVersion=$newV
	fi

	sed -i "/$oldVersion/ { c \\$newVersion
}" $file
}

updateVersion $makefile $makefileFind
updateVersion $control $controlFind

if ([[ $controlVersion == $makefileVersion ]] && [[ $oldControlVersion != $controlVersion ]] && [[ $oldMakefileVersion != $makefileVersion ]]) || ([[ $makefileVersion == 0 ]] && [[ $oldControlVersion != $controlVersion ]]); then
	echo -e "\e[1;32mVERSION INCREMENTATION SUCCESSFUL\e[0m"
else
	echo -e "\e[31mVERSION INCREMENTATION FAILED\e[0m
CONTROL: $controlVersion
MAKEFILE: $makefileVersion"
	return 1
fi