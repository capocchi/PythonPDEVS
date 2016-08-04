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

Custom Activity Prediction
==========================

The general activity tracking methodology has the disadvantage that it only looks at the time spent within a transition function. It is therefore unable to return stable values for a model. Calls to the Python time library might also have a too big overhead. Custom activity tracking will offer a solution to this, by offering the user a custom way of defining activity.

These functions are the *preActivityCalculation()* and *postActivityCalculation(prevalue)* methods. Right before the transition, the *preActivityCalculation()* method will be executed. This method can return a value that should be passed to the *postActivityCalculation(prevalue)* method, as the prevalue. The duality of these methods is necessary, since otherwise the custom activity function would only have access to the new state of the model, while it might be possible that activity is defined in terms of the difference between two states.

To give an idea of a simple implementation, the general activity tracking is defined as follows::

    def preActivityCalculation(self):
        return time.time()

    def postActivityCalculation(self, prevalue):
        return time.time() - prevalue

Of course, some activity definitions don’t care about the previous state, so they can simply write an empty *preActivityCalculation()* method and ignore the prevalue in the *postActivityCalculation(prevalue)* method.

While we have only elaborated on the time definition of activity, activity can also be defined in several different ways, all of which are possible with this custom activity function. However, due to the use of simple activity tracking, relocations will still try to balance the activity over the nodes. The next sections will provide solutions to that problem.

No special simulation options are necessary to use the custom *preActivityCalculation()* and *postActivityCalculation(prevalue)* methods, since this is handled by polymorphism already.

.. note:: All atomic models should have these two methods defined, as otherwise they will simply fall back to the general activity tracking. This might be problematic in situations where the values get mixed unknowingly.

