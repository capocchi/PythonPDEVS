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

Realtime simulation
===================

Realtime simulation is closely linked to normal simulation, with the exception that simulation will not progress as fast as possible. The value returned by the time advance will be interpreted in seconds and the simulator will actually wait (not busy loop) until the requested time has passed. Several realtime backends are supported in PyPDEVS and are mentioned below.

Example model
-------------

The example model will be something else than the *queue* from before, as this isn't really that interesting for realtime simulation. We will instead use the *trafficLight* model. It has a *trafficLight* that is either running autonomous or is in a manual mode. Normally, the traffic light will work autonomously, though it is possible to interrupt the traffic light and switch it to manual mode and back to autonomous again.

This complete model is (:download:`trafficLightModel.py <trafficLightModel.py>`)::

    class TrafficLightMode:
        def __init__(self, current="red"):
            self.set(current)

        def set(self, value="red"):
            self.__colour=value

        def get(self):
            return self.__colour

        def __str__(self):
            return self.get()

    class TrafficLight(AtomicDEVS):
        def __init__(self, name):
            AtomicDEVS.__init__(self, name)
            self.state = TrafficLightMode("red")
            self.INTERRUPT = self.addInPort(name="INTERRUPT")
            self.OBSERVED = self.addOutPort(name="OBSERVED")

        def extTransition(self, inputs):
            input = inputs[self.INTERRUPT][0]
            if input == "toManual":
                if state == "manual":
                    # staying in manual mode
                    return TrafficLightMode("manual")
                if state in ("red", "green", "yellow"):
                    return TrafficLightMode("manual")

            elif input == "toAutonomous":
                if state == "manual":
                    return TrafficLightMode("red")

            raise DEVSException("Unkown input in TrafficLight")

        def intTransition(self):
            state = self.state.get()
            if state == "red":
                return TrafficLightMode("green")
            elif state == "green":
                return TrafficLightMode("yellow")
            elif state == "yellow":
                return TrafficLightMode("red")
            else:
                raise DEVSException("Unkown state in TrafficLight")

        def outputFnc(self):
            state = self.state.get()
            if state == "red":
                return {self.OBSERVED: ["grey"]}
            elif state == "green":
                return {self.OBSERVED: ["yellow"]}
            elif state == "yellow":
                return {self.OBSERVED: ["grey"]}
            else:
                raise DEVSException("Unknown state in TrafficLight")

        def timeAdvance(self):
            if state == "red":
                return 60
            elif state == "green":
                return 50
            elif state == "yellow":
                return 10
            elif state == "manual":
                return INFINITY
            else:
                raise DEVSException("Unknown state in TrafficLight")

With our model being set up, we could run it as-fast-as-possible by starting it like::

    model = TrafficLight("trafficLight")
    sim = Simulator(model)
    sim.simulate()

To make it run in real time, we only need to do some minor changes. First, we need to define on which port we want to put some external input. We can choose a way to address this port, but lets assume that we choose the same name as the name of the port. This gives us::

    refs = {"INTERRUPT": model.INTERRUPT}

Now we only need to pass this mapping to the simulator, together with the choice for realtime simulation. This is done as follows::

    refs = {"INTERRUPT": model.INTERRUPT}
    sim.setRealTime(True)
    sim.setRealTimePorts(refs)

That is all extra configuration that is required for real time simulation. 

As soon as the *simulate()* method is called, the simulation will be started as usual, though now several additional options are enabled. Specifically, the user can now input external data on the declared ports. This input should be of the form *portname data*.

In our example, the model will respond to both *toManual* and *toAutonomous* and we chose *INTERRUPT* as portname in our mapping. So our model will react on the input *INTERRUPT toManual*. This input can then be given through the invocation of the *realtime_interrupt(string)* call as follows::

    sim.realtime_interrupt("INTERRUPT toManual")

Malformed input will cause an exception and simulation will be halted.

.. note:: All input that is injected will be passed to the model as a *string*. If the model is thus supposed to process integers, a string to integer processing step should happen in the model itself.

Input files
-----------

PyPDEVS also supports the use of input files together with input provided at run time. The input file will be parsed at startup and should be of the form *time port value*, with time being the simulation time at which this input should be injected. Again, this input will always be interpreted as a string. If a syntax error is detected while reading through this file, the error will immediately be shown.

.. note:: The file input closely resembles the usual prompt, though it is not possible to define a termination at a certain time by simply stating the time at the end. For this, you should use the termination time as provided by the standard interface.

An example input file for our example could be::

    10 INTERRUPT toManual
    20 INTERRUPT toAutonomous
    30 INTERRUPT toManual

Backends
--------

Several backends are provided for the realtime simulation, each serving a different purpose. The default backend is the best for most people who just want to simulate in realtime. Other options are for when PyPDEVS is coupled to TkInter, or used in the context of a game loop system.

The following backends are currently supported:

* Python threads: the default, provides simple threading and doesn't require any other programs. Activated with *setRealTimePlatformThreads()*.
* TkInter: uses Tk for all of its waiting and delays (using the Tk event list). Activated with *setRealTimePlatformTk()*.
* Game loop: requires an external program to call the simulator after a certain delay. Activated with *setRealTimePlatformGameLoop()*.

For each of these backends, an example is given on how to use and invoke it, using the traffic light model presented above.

Python Threads
^^^^^^^^^^^^^^

This is the simplest platform to use, and is used by default. After the invocation of *sim.simulate()*, simulation will happen in the background of the currently running application. The call to *sim.simulate()* will return immediately. Afterwards, users can do some other operations. Most interestingly, users can provide input to the running simulation by invoking the *realtime_interrupt(string)* method.

Simulation runs as a daemon thread, so exiting the main thread will automatically terminate the simulation.

.. warning:: Python threads can sometimes have a rather low granularity in CPython 2. So while we are simulating in soft realtime anyway, it is important to note that delays could potentially become significant.

An example is given below (:download:`experiment_threads.py <experiment_threads.py>`)::

    from pypdevs.simulator import Simulator
    from trafficLightModel import *
    model = TrafficLight(name="trafficLight")

    refs = {"INTERRUPT": model.INTERRUPT}
    sim = Simulator(model)
    sim.setRealTime(True)
    sim.setRealTimeInputFile(None)
    sim.setRealTimePorts(refs)
    sim.setVerbose(None)
    sim.setRealTimePlatformThreads()
    sim.simulate()

    while 1:
        sim.realtime_interrupt(raw_input())

In this example, users are presented with a prompt where they can inject events in the simulation, for example by typing *INTERRUPT toManual* during simulation. Sending an empty input (*i.e.*, malformed), simulation will also terminate.

TkInter
^^^^^^^

The TkInter event loop can be considered the most difficult one to master, as you will also need to interface with TkInter.

Luckily, PythonPDEVS hides most of this complexity for you. You will, however, still need to define your GUI application and start PythonPDEVS. Upon configuration of PythonPDEVS, a reference to the root window needs to be passed to PythonPDEVS, such that it knows to which GUI to couple.

Upon termination of the GUI, PythonPDEVS will automatically terminate simulation as well.

The following example will create a simple TkInter GUI of a traffic light, visualizing the current state of the traffic light, and providing two buttons to send specific events. Despite the addition of TkInter code, the PythonPDEVS interface is still very similar.

The experiment file is as follows (:download:`experiment_tk.py <experiment_tk.py>`)::

    from pypdevs.simulator import Simulator

    from Tkinter import *
    from trafficLightModel import *

    isBlinking = None

    model = TrafficLight(name="trafficLight")
    refs = {"INTERRUPT": model.INTERRUPT}
    root = Tk()

    sim = Simulator(model)
    sim.setRealTime(True)
    sim.setRealTimeInputFile(None)
    sim.setRealTimePorts(refs)
    sim.setVerbose(None)
    sim.setRealTimePlatformTk(root)

    def toManual():
        global isBlinking
        isBlinking = False
        sim.realtime_interrupt("INTERRUPT toManual")

    def toAutonomous():
        global isBlinking
        isBlinking = None
        sim.realtime_interrupt("INTERRUPT toAutonomous")

    size = 50
    xbase = 10
    ybase = 10

    frame = Frame(root)
    canvas = Canvas(frame)
    canvas.create_oval(xbase, ybase, xbase+size, ybase+size, fill="black", tags="red_light")
    canvas.create_oval(xbase, ybase+size, xbase+size, ybase+2*size, fill="black", tags="yellow_light")
    canvas.create_oval(xbase, ybase+2*size, xbase+size, ybase+3*size, fill="black", tags="green_light")
    canvas.pack()
    frame.pack()

    def updateLights():
        state = model.state.get()
        if state == "red":
            canvas.itemconfig("red_light", fill="red")
            canvas.itemconfig("yellow_light", fill="black")
            canvas.itemconfig("green_light", fill="black")
        elif state == "yellow":
            canvas.itemconfig("red_light", fill="black")
            canvas.itemconfig("yellow_light", fill="yellow")
            canvas.itemconfig("green_light", fill="black")
        elif state == "green":
            canvas.itemconfig("red_light", fill="black")
            canvas.itemconfig("yellow_light", fill="black")
            canvas.itemconfig("green_light", fill="green")
        elif state == "manual":
            canvas.itemconfig("red_light", fill="black")
            global isBlinking
            if isBlinking:
                canvas.itemconfig("yellow_light", fill="yellow")
                isBlinking = False
            else:
                canvas.itemconfig("yellow_light", fill="black")
                isBlinking = True
            canvas.itemconfig("green_light", fill="black")
        root.after(500,  updateLights)

    b = Button(root, text="toManual", command=toManual)
    b.pack()
    c = Button(root, text="toAutonomous", command=toAutonomous)
    c.pack()

    root.after(100, updateLights)

    sim.simulate()
    root.mainloop()

Game Loop
^^^^^^^^^

This mechanism will not block the main thread and if the main thread stops, so will the simulation. The caller can, after the invocation of *simulate()*, give control to PythonPDEVS to process all outstanding events. This methods is called *realtime_loop_call()*. A simple game loop would thus look like::

    sim = Simulator(Model())
    sim.simulate()
    sim.setRealTimePlatformGameLoop()
    while (True):
        # Do rendering and such
        ...

        # Advance the state of the DEVS model, processing all input events
        sim.realtime_loop_call()

The game loop mechanism is thus closely linked to the invoker. The calls to the *realtime_loop_call()* function and the initializer are the only concept of time that this mechanism uses. Newer versions of PythonPDEVS will automatically detect the number of Frames per Second (FPS), so there is no longer any need to do this manually.

An example is presented below (:download:`experiment_loop.py <experiment_loop.py>`)::

    from pypdevs.simulator import Simulator
    from trafficLightModel import *
    model = TrafficLight(name="trafficLight")

    refs = {"INTERRUPT": model.INTERRUPT}
    sim = Simulator(model)
    sim.setRealTime(True)
    sim.setRealTimeInputFile(None)
    sim.setRealTimePorts(refs)
    sim.setVerbose(None)
    sim.setRealTimePlatformGameLoop()
    sim.simulate()

    import time
    while 1:
        before = time.time()
        sim.realtime_loop_call()
        time.sleep(0.1 - (before - time.time()))
        print("Current state: " + str(model.state.get()))

It is important to remark here, that the time management (*i.e.*, invoking sleep and computing how long to sleep), is the responsibility of the invoking code, instead of PythonPDEVS. PythonPDEVS will simply poll for the current wall clock time when it is invoked, and progress simulated time up to that point in time (depending on the scale factor).
