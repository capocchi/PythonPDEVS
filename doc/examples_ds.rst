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

Examples for Dynamic Structure DEVS
===================================

We used the same approach to Dynamic Structure as adevs, meaning that a *modelTransition* method will be called at every step in simulated time on every model that transitioned.

A small *trafficLight* model is included in the *examples* folder of the PyPDEVS distribution. In this section, we introduce the use of the new constructs.

Dynamic structure is possible for both Classic and Parallel DEVS, but only for local simulation.

Starting point
--------------

We will start from a very simple Coupled DEVS model, which contains 2 Atomic DEVS models.
The first model sends messages on its output port, which are then routed to the second model.
Note that, for compactness, we include the experiment part in the same file as the model.

This can be expressed as follows (:download:`base_dsdevs.py <base_dsdevs.py>`)::

    from pypdevs.DEVS import AtomicDEVS, CoupledDEVS
    from pypdevs.simulator import Simulator

    class Root(CoupledDEVS):
        def __init__(self):
            CoupledDEVS.__init__(self, "Root")
            self.models = []
            # First model
            self.models.append(self.addSubModel(Generator()))
            # Second model
            self.models.append(self.addSubModel(Consumer(0)))
            # And connect them
            self.connectPorts(self.models[0].outport, self.models[1].inport)

    class Generator(AtomicDEVS):
        def __init__(self):
            AtomicDEVS.__init__(self, "Generator")
            # Keep a counter of how many events were sent
            self.outport = self.addOutPort("outport")
            self.state = 0

        def intTransition(self):
            # Increment counter
            return self.state + 1

        def outputFnc(self):
            # Send the amount of messages sent on the output port
            return {self.outport: [self.state]}

        def timeAdvance(self):
            # Fixed 1.0
            return 1.0

    class Consumer(AtomicDEVS):
        def __init__(self, count):
            AtomicDEVS.__init__(self, "Consumer_%i" % count)
            self.inport = self.addInPort("inport")

        def extTransition(self, inputs):
            for inp in inputs[self.inport]:
                print("Got input %i on model %s" % (inp, self.name))

    sim = Simulator(Root())
    sim.setTerminationTime(5)
    sim.simulate()

All undefined functions will just use the default implementation.
As such, this model will simply print messages::

    Got input 0 on model Consumer_0
    Got input 1 on model Consumer_0
    Got input 2 on model Consumer_0
    Got input 3 on model Consumer_0
    Got input 4 on model Consumer_0

We will now extend this model to include dynamic structure.

Dynamic Structure
-----------------

To allow for dynamic structure, we need to augment both our experiment and our model.

Experiment
^^^^^^^^^^

First, the dynamic structure configuration parameter should be enabled in the experiment.
For performance reasons, this feature is disabled by default. It can be enabled as follows::

    sim = Simulator(Root())
    sim.setTerminationTime(5)
    sim.setDSDEVS(True)
    sim.simulate()

Model
^^^^^

With dynamic structure enabled, models can define a new method: *modelTransition(state)*.
This method is called on all Atomic DEVS models that executed a transition in that time step.

This method is invoked on the model, and can thus access the state of the model.
For now, ignore the *state* parameter.
In this method, all modifications on the model are allowed, as it was during model construction.
That is, it is possible to invoke the following methods::

    setInPort(portname)
    setOutPort(portname)
    addSubModel(model)
    connectPorts(output, input)

But apart from these known methods, it is also possible to delete existing constructs, with the operations::

    removePort(port)
    removeSubModel(model)
    disconnectPorts(output, input)

On Atomic DEVS models, only the port operations are available. On Coupled DEVS models, all of these are available.
Removing a port or submodel will automatically disconnect all its connections.

The method will also return a boolean, indicating whether or not to propagate the structural changes on to the parent model.
If it is *True*, the method is invoked on the parent as well. Note that the root model should not return *True*.
Propagation is necessary, as models are only allowed to change the structure of their subtree.

.. NOTE::
   In the latest implementation, modifying the structure outside of your own subtree has no negative consequences. However, it should be seen as a best practice to only modify yourself.

For example, to create a second receiver as soon as the generator has output 3 messages, you can modify the following methods (:download:`simple_dsdevs.py <simple_dsdevs.py>`)::

    class Generator(AtomicDEVS):
        ...
        def modelTransition(self, state):
            # Notify parent of structural change if state equals 3
            return self.state == 3

    class Root(CoupledDEVS):
        ...
        def modelTransition(self, state):
            # We are notified, so are required to add a new model and link it
            self.models.append(self.addSubModel(Consumer(1)))
            self.connectPorts(self.models[0].outport, self.models[-1].inport)

            ## Optionally, we could also remove the Consumer(0) instance as follows:
            # self.removeSubModel(self.models[1])

            # Always returns False, as this is top-level
            return False

This would give the following output (or similar, due to concurrency)::

    Got input 0 on model Consumer_0
    Got input 1 on model Consumer_0
    Got input 2 on model Consumer_0
    Got input 3 on model Consumer_0
    Got input 3 on model Consumer_1
    Got input 4 on model Consumer_0
    Got input 4 on model Consumer_1

.. NOTE::
   As structural changes are not a common operation, their performance is not optimized extensively. To make matters worse, many structural optimizations done by PythonPDEVS will automatically be redone after each structural change.

Passing state
^^^^^^^^^^^^^

Finally, we come to the *state* parameter of the modelTransition call.
In some cases, it will be necessary to pass arguments to the parent, to notify it of how the structure should change.
This is useful if the child knows information that is vital to the change.
Since Coupled DEVS models cannot hold state, and should not directly access the state of their children, we can use the *state* parameter for this.

The *state* parameter is simply a dictionary object, which is passed between all the different *modelTransition* calls.
Simply put, it is an object shared by all calls.

For example, if we would want the structural change from before to create a new consumer every time, with an ID provided by the Generator, this can be done as follows (:download:`state_dsdevs.py <state_dsdevs.py>`)::

    class Generator(AtomicDEVS):
        ...
        def modelTransition(self, state):
            # We pass on the ID that we would like to create, which is equal to our counter
            state["ID"] = self.state
            # Always create a new element
            return True

    class Root(CoupledDEVS):
        ...
        def modelTransition(self, state):
            # We are notified, so are required to add a new model and link it
            # We can use the ID provided by the model below us
            self.models.append(self.addSubModel(Consumer(state["ID"])))
            self.connectPorts(self.models[0].outport, self.models[-1].inport)

            # Always returns False, as this is top-level
            return False

This would then create the output (or similar, due to concurrency)::

    Got input 0 on model Consumer_0
    Got input 1 on model Consumer_0
    Got input 1 on model Consumer_1
    Got input 2 on model Consumer_0
    Got input 2 on model Consumer_1
    Got input 2 on model Consumer_2
    Got input 3 on model Consumer_0
    Got input 3 on model Consumer_1
    Got input 3 on model Consumer_2
    Got input 3 on model Consumer_3

More complex example
--------------------

In the PyPDEVS distribution, a more complex example is provided.
That example provides a model of two traffic lights, with a policeman who periodically changes the traffic light he is interrupting.
