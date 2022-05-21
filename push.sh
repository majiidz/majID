###
## Automate building latest demo and supporter packages and packing for repos
###

#dpkg-scanpackages debs /dev/null >Packages
#cd ./debs
#../gen.sh > ../Release
#cd ../

#rm -rf Packages.bz2

#bzip2 -fks Packages

./gen.sh

git add .
git commit -m "."
git push