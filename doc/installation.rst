..
    Copyright 2014 Modelling, Simulation and Design Lab (MSDL) at 
    McGill University and the University of Antwerp (http://msdl.cs.mcgill.ca/)

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

Installation
============

This section describes the necessary steps for installing PyPDEVS.

Dependencies
------------

The following dependencies are mandatory:

* python 2.7

For parallel and distributed simulation, the following additional dependencies are required:

* MPICH3 with socket device
* mpi4py

Installation instructions are given for these two dependencies further in this section.

Realtime simulation using the Tk backend, obviously requires Tk.

PyPDEVS Installation
--------------------

Execute the following command in the 'src' folder::
    
    python setup.py install --user

Afterwards, PyPDEVS should be installed. This can easily be checked with the command::

    python -c "import pypdevs"

If this returns without errors, PyPDEVS is sucessfully installed.

Parallel and distributed simulation with mpi4py
-----------------------------------------------

.. note:: An installation script for mpi4py and MPICH3 is provided in :download:`install_mpi4py.sh <install_mpi4py.sh>`. At the end, you will still need to add mpi to your PATH though, as explained by the script.

First of all, an MPI middleware has to be installed, for which I recommend MPICH3.
Due to some non-standard configuration options, it is required to install MPICH manually instead of using the one from the repositories.

You can use either the official installation guide, or follow the steps below.
Just make sure that the correct configuration options are used.

The following commands should work on most systems, just replace the '/home/you' part with a location of your choosing::

    mkdir mpich-build
    mkdir mpich
    base=`pwd`
    cd mpich-build
    wget http://www.mpich.org/static/downloads/3.1.2/mpich-3.1.2.tar.gz
    tar -xvzf mpich-3.1.2.tar.gz
    cd mpich-3.1.2
    ./configure --prefix=$base/mpich --with-device=ch3:sock --disable-fortran
    make
    make install
    export PATH=$base/mpich/bin:$PATH
    cd ../..

You will probably want to put this final export of PATH to your .bashrc file, to make sure that mpi is found in new terminals too.
After that, make sure that the following command does not cause any errors and simply prints your hostname 4 times::

    mpirun -np 4 hostname

Now you just need to install mpi4py, which is easy if you have MPICH installed correctly::

    mkdir mpi4py
    cd mpi4py
    wget https://pypi.python.org/packages/source/m/mpi4py/mpi4py-1.3.1.tar.gz
    tar -xvzf mpi4py-1.3.1.tar.gz
    cd mpi4py-1.3.1
    python setup.py build --mpicc=../../mpich/bin/mpicc
    python setup.py install --user
    cd ../..

Testing whether or not everything works can be done by making sure that the following command prints '4' four times::

    mpirun -np 4 python -c "from mpi4py import MPI; print(MPI.COMM_WORLD.Get_size())"
