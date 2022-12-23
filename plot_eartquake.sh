#!/bin/sh
PROJ="-JM15c"
LIMS="-R80/110/0/35“
PSFILE=“earthquakes.ps“
gmt pscoast $PROJ $LIMS -W1p -Dc -N1/0.5p -K > $PSFILE
gmt psbasemap $PROJ $LIMS -Bxa10g10 -Bya5g5 -BWeSn \
-K -O >> $PSFILE
