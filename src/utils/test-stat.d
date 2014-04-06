
// -*- mode: d -*-
/*
 *       test-stat.d
 *
 *       Copyright 2014 Antonio-M. Corbi Bellot <antonio.corbi@ua.es>
 *     
 *       This program is free software; you can redistribute it and/or modify
 *       it under the terms of the GNU  General Public License as published by
 *       the Free Software Foundation; either version 2 of the License, or
 *       (at your option) any later version.
 *     
 *       This program is distributed in the hope that it will be useful,
 *       but WITHOUT ANY WARRANTY; without even the implied warranty of
 *       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *       GNU General Public License for more details.
 *      
 *       You should have received a copy of the GNU General Public License
 *       along with this program; if not, write to the Free Software
 *       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 *       MA 02110-1301, USA.
 */

module test_stat;

import std.stdio;

import utils.statistic;

void main () {

  int[] X = [0,0,1,1,1];
  int[] Y = [0,0,0,0,1];
  int[] Z = [1,1,1,1,1];
  

  writefln ("%s -> average: %f stdev: %f", 
	    X, X.average, X.stdev);

  writefln ("%s -> average: %f stdev: %f", 
	    Y, Y.average, Y.stdev);

  writefln ("%s -> average: %f stdev: %f", 
	    Z, Z.average, Z.stdev);

}
