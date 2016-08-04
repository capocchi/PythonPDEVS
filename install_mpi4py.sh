#!/bin/bash
set -e
rm -r build-mpi || true
mkdir build-mpi
cd build-mpi
mkdir mpich-build
mkdir mpich
base=`pwd`
cd mpich-build
wget http://www.mpich.org/static/downloads/3.1.2/mpich-3.1.2.tar.gz
tar -xvzf mpich-3.1.2.tar.gz
cd mpich-3.1.2
./configure --prefix=$base/mpich --with-device=ch3:sock --disable-fortran
make -j5
make install
export PATH=$base/mpich/bin:$PATH
cd ../..
mkdir mpi4py
cd mpi4py
wget https://pypi.python.org/packages/source/m/mpi4py/mpi4py-1.3.1.tar.gz
tar -xvzf mpi4py-1.3.1.tar.gz
cd mpi4py-1.3.1
# Force the correct MPI distribution
rm mpi.cfg || true
echo "[mpi]" >> mpi.cfg
echo "" >> mpi.cfg
echo "include_dirs = $base/mpich/include" >> mpi.cfg
echo "libraries = mpi" >> mpi.cfg
echo "library_dirs = $base/mpich/lib" >> mpi.cfg
echo "runtime_library_dirs = $base/mpich/lib" >> mpi.cfg
echo "mpicc = $base/mpich/bin/mpicc" >> mpi.cfg
echo "mpicxx = $base/mpich/bin/mpicxx" >> mpi.cfg
python setup.py build --mpi=mpi
python setup.py install --user

echo "=============================="
echo "==        All done          =="
echo "=============================="
echo ""
echo "Please add $base/mpich/bin to your PATH"
echo "This is done by adding the line"
echo "  export PATH=$base/mpich/bin:\$PATH"
echo "to a file parsed at system startup, e.g. ~/.bashrc"
echo "For example for Ubuntu: http://askubuntu.com/questions/60218/how-to-add-a-directory-to-my-path"
echo ""
echo "Alternative:"
echo "A symbolic link can be made from /usr/local/bin/mpirun to $base/mpich/bin/mpirun (probably requires root)"
echo "This is done with the command:"
echo "  sudo ln -s $base/mpich/bin/mpirun /usr/local/bin/mpirun"
