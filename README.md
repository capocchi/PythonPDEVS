Installation
============

You can easily install PythonPDEVS with the following command.
```sh
cd src
python setup.py install --user
```

Performance
-----------

For optimal performance results, we recommend the use of [PyPy](http://pypy.org).

By default, PythonPDEVS is optimized for distributed simulation, therefore doing a lot of additional bookkeeping.
For optimal performance in local simulations, we recommend the use of the *minimal* simulation kernel instead: just update all imports from
```python
from pypdevs.simulator import Simulator
from pypdevs.DEVS import AtomicDEVS, CoupledDEVS
```
to
```python
from pypdevs.minimal import Simulator
from pypdevs.minimal import AtomicDEVS, CoupledDEVS
```
Note that this disables many features.

Distributed simulation (optional)
---------------------------------

To use distributed simulation capabilities, run the script *install_mpi4py.sh* to install the necessary MPI library and bindings.

Documentation
=============

Detailed documentation of the installation and use of PythonPDEVS can be found in the [PythonPDEVS documentation](https://msdl.uantwerpen.be/documentation/PythonPDEVS).
