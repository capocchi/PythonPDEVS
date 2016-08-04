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

Minimal Simulation Kernel
=========================

Due to the many features that PythonPDEVS supports, the code is quite big and many additional steps need to be taken during simulation.
Certainly with Python, this causes problems due to the lack of compilation (and consequently optimization).
For this reason, but also to show the minimal simulation algorithm of PythonPDEVS, a minimal simulation kernel is added.

Such a minimal kernel, even without any special features, is useful for benchmarking different algorithms, without needing to worry about the supported features.
It can also be useful for end-users, if the user is only interested in the state of the simulated model.

Its use is identical to the normal simulation kernel, but the import is different.
Instead of importing *Simulator* from the file *simulator.py*, it needs to be imported from *minimal.py*.
So the only change is the import, which becomes something like::

    from pypdevs.minimal import Simulator

All other code remains exactly the same.
Unless configuration options (apart from *setTerminationTime*) are used, as these will no longer be possible.
The only supported option is *setTerminationTime*, which works exactly the same as in the normal simulation kernel.
While it is still possible to define transfer functions or define allocations in the model construction, these are ignored during simulation.

The polymorphic scheduler is used automatically, so the performance will automatically be optimized to the different access patterns.
There is thus no need to manually specify the scheduler.
