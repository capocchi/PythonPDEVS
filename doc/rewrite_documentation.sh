#!/bin/bash

function rewrite {
    echo $1
    sed -i.bak -e s/_downloads/downloads/g $1
    sed -i.bak -e s/_static/static/g $1
    sed -i.bak -e s/_images/images/g $1
    sed -i.bak -e s/_modules/modules/g $1
    sed -i.bak -e s/_sources/sources/g $1
    rm ${1}.bak
}

echo `pwd`
cd _build/html
echo `pwd`

rm -r downloads || true
rm -r images || true
rm -r modules || true
rm -r sources || true
rm -r static || true
mv _downloads downloads 2> /dev/null
mv _static static 2> /dev/null
mv _images images 2> /dev/null
mv _modules modules 2> /dev/null
mv _sources sources 2> /dev/null

export -f rewrite
for f in `find . -type f`
do
    rewrite $f
done
