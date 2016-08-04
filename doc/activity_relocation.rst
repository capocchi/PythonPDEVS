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

Automatic activity-based relocation
===================================

As was mentioned in the previous section, manual relocation is possible in PyPDEVS. However, the knowledge of the modeler about which models need to be moved and at what time exactly, might be rather vague or even non-existent. Clearly, slightly altering the models parameters could completely alter the time at which relocation would be ideal. Additionally, such manual relocation is time consuming to write and benchmark.

In order to automate the approach, PyPDEVS can use *activity* to guide it into making autonomous decisions. Since activity is a rather broad concept, several options are possible, most of them also offering the modeller the possibility to plug in its own relocators or activity definitions. Together with custom modules, comes also the possibility for inserting domain specific knowledge.

We distinguish several different situations:

.. toctree::
    
   Activity Tracking <activitytracking>
   Custom Activity Tracking <customactivitytracking>
   Custom Activity Prediction <activityprediction>
