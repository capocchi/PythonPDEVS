Performance
===========

For performance benchmarks, it is desirable to achieve as high performance as feasible with PythonPDEVS.
By default, PythonPDEVS offers a lot of features, most of which have a (very) negative impact on actual performance.
While this might not be too noticable on small or medium-sized models, huge models will become unbearably slow in the default configuration.

There are two proposed tweaks, which on average increase performance by a factor 12.

Minimal Simulation Kernel
-------------------------

Using the minimal simulation kernel disables most performance-affecting features, thus significantly increasing performance.
Note, however, that most of the advertised features will simply not work in this configuration.
This option is preferred for a fair comparison with other tools, as the PythonPDEVS defaults were chosen for usability, rather than performance.

To use the minimal simulation kernel, simply replace all imports of PythonPDEVS to include the file ``pypdevs.minimal``.
This includes the ``AtomicDEVS``, ``CoupledDEVS``, and ``Simulator`` classes, and can thus be used instead of the ``pypdevs.DEVS`` and ``pypdevs.simulator`` files.
Both simulation kernels have the same interface, so switching can be done merely by changing the import statements.
When all features are desired, for example for debugging, the imports can easily be changed again to the full version of the PythonPDEVS simulation kernel.

Use of PyPy
-----------

Much of the performance related problems in PythonPDEVS are related to the Python interpreter itself.
We therefore recommend the use of PyPy as an alternative drop-in replacement for the default CPython implementation.
PyPy is the main development platform of PythonPDEVS as well.

Note that at the time of writing, PyPy does not always behave well on Windows systems.
It works perfectly fine on Linux.
