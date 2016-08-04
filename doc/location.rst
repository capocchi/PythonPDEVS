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

Location tracing
================

.. note:: This feature is still being worked on and all information is therefore prone to change.

Location tracing is closely linked to activity tracing. The only major difference is when the files are generated: an activity trace is only created at the end of the simulation run, whereas an location trace is created at the start of the simulation and at every GVT boundary where at least one migration happens. Location traces will always contain the time at which the location as it is presented actually went into effect.

Enabling location tracing is as simple as::

    x, y = 20, 20
    model = FireSpread(x, y)
    sim = Simulator(model)
    sim.setTerminationTime(1000.0)
    sim.setLocationCellMap(True, x, y)
    sim.simulate()

Note that this again shows the location in a Cell view. If this kind of visualisation is not desirable (or possible), you are advised to use standard :doc:`visualisation` using Graphviz.

An example output of location tracing is given below. It isn't really spectacular, as it only shows you your allocations again.

.. image:: location.png
   :alt: Location cell view
   :align: center
   :width: 50%

Cell view visualisation is completely different from the regular :doc:`visualisation`, as it contains some domain specific information and thus more closely resembles your interpretation of the model. Drawing a 6x6 grid with the generic visualisation, would generate something non-intuitive like the 'curly' graph below.

.. image:: location_normal.png
   :alt: Location normal view
   :height: 2000px
   :align: center
