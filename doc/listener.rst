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

Listening to realtime simulation
================================

During realtime simulation, there frequently exists the need to listen to specific ports, monitoring the events passing over them. In PythonPDEVS, it is possible to register a function that is invoked for each event passing over that port. This is called a *listener* in PythonPDEVS.

Example model
-------------

We can simply reuse the traffic light model from the previous section on realtime simulation (:download:`trafficLightModel.py <trafficLightModel.py>`). All that needs to be changed now, is adding a listener on an output port of a *coupled* DEVS model. First and foremost, therefore, we must put our traffic light in a container::

    class TrafficLightSystem(CoupledDEVS):
        def __init__(self):
            CoupledDEVS.__init__(self, "System")
            self.light = self.addSubModel(TrafficLight("Light"))
            self.observed = self.addOutPort(name="observed")

In the experiment file, it is then possible to register a listener on this port as follows (:download:`injection.py <injection.py>`)::

    def my_function(event):
        print("Observed the following event: " + str(event))
        
    sim.setListenPorts(model.observed, my_function)

Since this function is invoked with the complete bag, the received event will contain a list of events, exactly as how it would be invoked in the external transition function.

.. note:: Listeners are only supported on output ports of Coupled DEVS models. This is because the listeners are invoked upon event routing, for which the source port is not checked.
