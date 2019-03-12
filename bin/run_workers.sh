#!/bin/bash

set -e

for port in {12000..12004}
do
	echo "Starting worker on $port..."
	R -f /app/run.R --gui-none --no-save --args $port &
done
