#!/bin/sh
set -ex

if [ ! -d m4 ]
then
   mkdir m4
fi

autoreconf -f -i -Wall,error
./configure
