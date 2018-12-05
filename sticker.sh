#!/bin/bash

wd=$(pwd)

if [[ ! -d parts/ ]] ; then
	echo "The parts folder did not exist so we are making a new one with a sample part"
	mkdir -p parts/part001
	echo '#!/bin/bash' > parts/part001/cmd.sh
	echo 'touch success' >> parts/part001/cmd.sh
	chmod +x parts/part001/cmd.sh
	echo "You can change parts/part001/cmd.sh to do what you need it to do with assets"
	echo "placed in that part folder. Result files should be placed in new part folders"
	echo "To add new parts create new folders in the parts folder in alphanumeric run"
	echo "order each containing their own cmd.sh scripts. When you are done adding parts"
	echo "and editing command scripts, run this script again to run all command scripts"
	echo "and cache the state of the part folders upon successful run of each script."
	echo "In a later run if a part contain no changes, cmd.sh will be skipped. You can"
	echo "create dependancies by creating a file in another part folder as a flag, and"
	echo "change the cached hash to cause that part command script to run. Then the"
	echo "flag can be removed so it will not run again unless changed again by a "
	echo "change in itself or a dependant part."
	exit 1
fi

#./beforecmd.sh

for folder in parts/*; do
	hashsum=$(find "$wd/$folder" -type f -exec md5sum {} \; | md5sum); 
	oldhashsum=""
	[[ -f $wd/cache/$folder/hash ]] && oldhashsum=$(cat $wd/cache/$folder/hash)
	if [[ "$hashsum" == "$oldhashsum" ]]; then
		echo "$folder unchanged, skipping"
	else
		echo "$folder changed, running command script"
		if [[ ! -f $wd/$folder/cmd.sh ]]; then
			echo $folder command script not found. Creating a new one.
			echo '#!/bin/bash' > $wd/$folder/cmd.sh
			echo 'touch success' >> $wd/$folder/cmd.sh
		fi
		if [[ ! -x $wd/$folder/cmd.sh ]]; then
			echo $folder command script not executable. Updating permissions.
			chmod +x $wd/$folder/cmd.sh
		fi
		cd $folder/
		./cmd.sh
		if [[ $? -eq 0 ]]; then
			echo command script finished in $folder, caching state
			mkdir -p $wd/cache/$folder/
			touch $wd/cache/$folder/hash
			find "$wd/$folder" -type f -exec md5sum {} \; | md5sum > $wd/cache/$folder/hash
		else
			echo $folder error running command script
			exit 1
		fi
		cd  $wd
	fi
done
#./aftercmd.sh
