#!/bin/sh

mdb-tables -d ',' sr28.accdb | xargs -L1 -d',' -I{} bash -c 'mdb-export sr28.accdb "$1" >"$1".csv' -- {}
