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

Relocation directives
=====================

If your model is distributed, there is the possibility to move models to a different node. Model relocations only happen at the GVT boundaries, so the GVT interval that was configured previously will also be the interval for checking for relocation directives and actually performing them.

Setting a relocation directive is as simple as using the configuration option *setRelocationDirective(time, model, destination)*. At the first GVT boundary where *time* is reached, the *model* will be transfered to node *destination*. The *model* can be both the internal *model_id*, or simply the model itself. The *destination* should be the integer specifying the node to send the model to.

Since the model relocation directives are only checked sporadically, it is possible for several relocation directives to be in conflict. In that case, the latest relocation directive (in terms of requested time) will be used for that specific model. 

The actual sending of a model is not that time consuming, but mainly the locking and unlocking cost of both models (and the subsequent revert). To maximize performance, transfer as many models simultaneously as possible, because the algorithm is optimised for such situations.

A simple example to swap the location of the *generator* and the first *queue* from our previous example is::

    model = DQueue()
    sim = Simulator(model)
    sim.setRelocationDirective(20, model.generator, 1)
    sim.setRelocationDirective(20, model.queue1, 0)
    sim.simulate()

Of course, the GVT algorithm will probably never run in this small example and thus the relocation will also never happen. 

Relocating a model to the node where it is currently running will not impose a revertion to the GVT. Such directives will simply be ignored.

.. note:: Executing a relocation causes a revertion to the GVT on both nodes that are involved. This is to avoid transferring the complete state history and sent messages.
