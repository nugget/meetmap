@echo off
neato -Tpng -o graph.png %1 -Goverlap=false -Gsplines=true -Gstart=2 -Gsep=.5
