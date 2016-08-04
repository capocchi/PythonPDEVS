.. _elapsed_time:

Elapsed time
============

In PythonPDEVS, the elapsed time is present in the attribute *elapsed*.
While the attribute is always there, its value is only guaranteed to be correct during the execution of an external transition.
For compatibility reasons, in Parallel DEVS, the confluent transition will also set the elapsed time to 0.

It might seem strange to put the elapsed time as an attribute, instead of a parameter.
The reason for this is that, during model initialization, it is possible to set the elapsed time to some value.
The time at which that specific atomic model was initialized, will then be set to the negative elapsed time.
This implies that the initial time advance is larger than the configured elapsed time.

For example, if a model sets its elapsed time to -1.5 during model initialization, and has a time advance of 2, the first transition will happen at simulated time 0.5.
Note, however, that for the model it will seem as if the actual 2 units of simulated time have passed.
It thus merely allows for a fixed deviation between the starting point of different models.
