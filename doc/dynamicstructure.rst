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

Dynamic Structure
=================

.. note:: Currently, Dynamic Structure DEVS is an *option* for local simulation only. It is not enabled by default due to the additional (relatively costly) check for whether or not to transition.

Dynamic Structure DEVS (DSDEVS) is not actually an 'extension' to DEVS, though it offers some more advanced features in a simpler way. The basic idea is that a model (both coupled and atomic) can now cause a change in the structure of the model. This means adding submodels, deleting submodels, adding ports, removing ports, disconnecting ports and connecting ports. Such changes happen at run-time and cause a slight overhead due to the model being saved internally in a slightly different way.

The way DSDEVS works in PyPDEVS is similar to how it works in adevs. After each transition function, the transitioned model will have its *modelTransition(state)* method called. If it returns *True*, the model will signal its parent model that it requests a structural change. The model will then have its *modelTransition(state)* called too, which is allowed to make structural changes. If it requires changes at a higher level, it should return *True* again, to have the structural change request being propagated upwards. If it returns *False*, no change is requested.

Structural changes can happen in both the atomic model and the coupled model, both happening in the *modelTransition(state)* method.
In *atomic* models, the only structural change allowed is the addition or removal of ports.
Removing a port will also remove all of its current connections.
Adding a port will not yet have any effect on the model itself, as it is not yet connected and requires further structural changes at a higher level.
Note that the *modelTransition(state)* method is **NOT** allowed to perform any changes to the model state, only to the state that is provided as an argument (which contains a dictionary).
In *coupled* models, all changes to that coupled model, or its children, are allowed: creating and deleting children, connections, and ports.

The *modelTransition* method takes a *state* parameter, which is simply a dictionary that will be passed everytime. If you require modularity, it is possible to use e.g. the fully qualified name of the modelas the key and store another dictionary in here. This functionality can be used to support structural changes that require some kind of memory before deciding whether or not to perform such a change.

Interface
---------

Several methods are added or altered to support DSDEVS. These functions are:

* *removePort(port)*: remove the *port* argument from the ports. Any further usage of the port, such as saved references, should no longer be used as they result in simulation errors. It is best practice to manually delete the port by invoking the *del* Python instruction.
* *addInPort(name)*: similar to the normal usage, but now extended to allow changes at run-time.
* *addOutPort(name)*: similar to the normal usage, but now extended to allow changes at run-time.
* *addSubModel(model)*: similar to the normal usage, but now extended to allow changes at run-time.
* *removeSubModel(model)*: remove the *model* as a child, including all its submodels (if applicable). All of the relevant ports are also removed, thus breaking all these connections. After a model is removed, there is no way to get it back.
* *connectPorts(port1, port2)*: similar to the normal usage, but now extended to allow changes at run-time.
* *disconnectPorts(port1, port2)*: removes the connection between the ports. These ports should correspond to the parameters previously passed to the *connectPorts* method.

DSDEVS should also be enabled as a configuration parameter, using the *setDSDEVS(dsdevs)* method of the simulator. The default is *False* due to the simulation overhead.

Example
-------

A complete example will not be provided here, but instead only the relevant *modelTransition(state)* methods will be shown.

Enabling the use of DSDEVS is done as follows::

    sim = Simulator(MyDSModel())
    sim.setDSDEVS(True)
    sim.simulate()

The actual model can be something like::

    class MyAtomicDSModel(AtomicDEVS):
        ...

        def modelTransition(self, state):
            if self.state.currenttime == 5.0:
                self.removePort(self.outport) # Remove the output port
                del self.outport # Remove our own reference to the port
                return True # We need a structural change from the parent too
            else:
                return False # Nothing to do
        ...

    class MyDSModel(CoupledDEVS):
        ...

        def modelTransition(self, state):
            self.removeModel(self.atomic) # Remove the model stored in 'self.atomic' from the simulation
            return False # No need to propagate the change
        ...
