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

Multiple Simulators
===================

In some situations, having multiple models (and their respective simulator) in the same Python script is useful for comparing the performance. 

Local simulation
----------------

In local simulation, it is possible to create multiple Simulator instances without any problems::
    
    sim1 = Simulator(Model1())
    # Any configuration you want on sim1
    sim1.simulate()

    sim2 = Simulator(Model2())
    # Any configuration you want on sim2
    sim2.simulate()

Distributed simulation
----------------------

Starting up multiple Simulator classes is not supported in distributed simulation. This is because starting a simulator will also impose the construction of different MPI servers, resulting in an inconsistency.

It is supported in distributed simulation to use :doc:`reinitialisation <reinitialisation>`, simply because it is the same model and is coordinated by the same simulator.
