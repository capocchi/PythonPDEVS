#!/bin/bash
###########
# Creates a package of PyPDEVS: strips of most useless data and tars it all up
###########

mkdir pypdevs
cp notes.txt pypdevs/releasenotes.txt
cp install_mpi4py.sh pypdevs/install_mpi4py.sh
cd doc/sphinx
rm -r _build/html
make html
./rewrite_documentation.sh
cd ../..
cp -R doc/sphinx/_build/html/ pypdevs/doc
cp -R src/ pypdevs/
cp -R examples/ pypdevs/
rm test/output/*
cp -R test/ pypdevs/
cp LICENSE pypdevs/
cp NOTICE pypdevs/
mkdir pypdevs/tests/output
rm pypdevs/src/pypdevs/*.pyc
rm pypdevs/examples/*/*.pyc
rm pypdevs/examples/*/*.pyo
rm pypdevs/src/pypdevs/*.pyo
rm pypdevs/src/pypdevs/*/*.pyc
rm pypdevs/src/pypdevs/*/*.pyo
rm pypdevs/tests/tests/*.pyc
rm pypdevs/tests/tests/*.pyo
rm pypdevs/tests/expected/normal_long
rm pypdevs/tests/expected/checkpoint
rm pypdevs/*.pyc
rm pypdevs/*.pyo
rm -R pypdevs/src/build
rm -R pypdevs/src/__pycache__
rm -R pypdevs/src/pypdevs/__pycache__

tar -czf pypdevs.tgz pypdevs
rm -R pypdevs
