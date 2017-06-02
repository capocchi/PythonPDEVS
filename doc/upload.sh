#!/bin/bash
rsync -v --progress --recursive _build/html/* msdl.uantwerpen.be:/var/www/msdl/documentation/PythonPDEVS/
