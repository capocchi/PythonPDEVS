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

Transfer functions
==================

The DEVS formalism (both Classic and Parallel) allows transfer functions for:
* input to input couplings
* output to input couplings
* output to output couplings

The couplings can thus be annotated with functions that translate the actual message on it to another one.
The syntax for this annotation is by passing a function to the *connectPorts* method. 
That function will be called for every event seperatly (for Parallel DEVS: every element of the bag; for Classic DEVS: every element).

Using this functionality does not require any additional configurations.
It is important to note that using such a function will have a severe performance impact for events that are send on this connection. 
Before calling the function, the event itself will already be coupled. After this, the translated event will again be copied.
The first copy will *always* be using the pickle method, the second copy will be the one specified by the user.
If the function does not return anything, default Python semantics will cause the function to return *None*.

Such a function can be passed to every call to *connectPorts*, be it an input-to-input, output-to-input or output-to-output connection.

The 'total translation function' will be constructed only once at the start and this composite function will be called each time.
Couplings with no translation function on them will simply copy the output to the input. 
Thus ommitting the parameter or passing *None* will have no effect.

Example
-------

A simple example is a function which translates *OutputEvent* events to *InputEvent* events::

    def translate_inputevent_to_outputevent(inputEvent):
        # For simplicity, we assume that the OutputEvent constructor
        # takes an InputEvent as its argument
        return OutputEvent(inputEvent)

To use this function on a connection::

    class MyModel(CoupledDEVS):
        def __init__(self, name):
            ...
            self.connectPorts(self.model1.outport, self.model2.inport, translate_inputevent_to_outputevent)
            ...

