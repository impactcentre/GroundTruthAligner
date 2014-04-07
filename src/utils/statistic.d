// -*- mode: d -*-
/*
 *       statistic.d
 *
 *       Copyright 2014 Antonio-M. Corbi Bellot <antonio.corbi@ua.es>
 *     
 *       This program is free software; you can redistribute it and/or modify
 *       it under the terms of the GNU  General Public License as published by
 *       the Free Software Foundation; either version 3 of the License, or
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

module utils.statistic;

//-- std -------------------------------------------------------------

import std.math;
import std.algorithm;

alias min = std.algorithm.min;

//-- algorithms ------------------------------------------------------

/*T min(T) (T a, T b)
{
    return (a < b) ? a : b;
}

T max(T) (T a, T b)
{
    return (a > b) ? a : b;
}*/

/**
 * @param array array of T
 * @return the sum of all T's in array
 */
public T sum(T)(T[] array) {
  T sum = T.init;

  for (int n = 0; n < array.length; ++n) {
    sum += array[n];
  }
  return sum;
}

/**
 * Transform an int array into a an array of doubles
 *
 * @param array integer array
 * @return the array of double precision values
 */
public double[] toDouble(int[] array) {
  double[] darray = new double[array.length];
  for (int i = 0; i < array.length; i++) {
    darray[i] = array[i];
  }
  return darray;
}

/**
 * Create an array containing the logarithms of the source array
 *
 * @param array integer array
 * @return the array of logs
 */
public double[] log(T) (T[] array) {
  double[] darray = new double[array.length];
  for (int i = 0; i < array.length; i++) {
    darray[i] = std.math.log(array[i]);
  }
  return darray;
}

/**
 * @param array
 * @return the average of all T's in an array
 */
public double average(T) (T[] array) {
  return sum(array) / cast(double) array.length;
}


/**
 * @param array
 * @return the geometric mean (log-average) of all T's in an array
 */
public double logaverage(T)(T[] array) {
  return exp(average(log(array)));
}

/**
 * The scalar product
 *
 * @param x the first array
 * @param y the second array
 * @return the scalar product of x and y
 */
public double scalar(double[] x, double[] y) {
  double sum = 0;
  for (int n = 0; n < x.length; ++n) {
    sum += x[n] * y[n];
  }
  return sum;
}

/**
 * @param array array of T's
 * @return the max value in array
 */
public T max(T)(T[] array) {
  T mu = array[0];

  for (int n = 1; n < array.length; ++n) {
    mu = max(mu, array[n]);
  }
  return mu;
}

/**
 * @param array array of T's
 * @return the min value in array
 */
public T min(T)(T[] array) {
  T mu = array[0];

  for (int n = 1; n < array.length; ++n) {
    mu = min(mu, array[n]);
  }
  return mu;
}


/**
 * @param array int array
 * @return first position containing the max value in int array
 */
public int argmax(T)(T[] array) {
  int pos = 0;

  for (int n = 1; n < array.length; ++n) {
    if (array[n] > array[pos]) {
      pos = n;
    }
  }
  return pos;
}
    
/**
 * @param array int array
 * @return first position containing the min value in int array
 */
public int argmin(T)(T[] array) {
  int pos = 0;

  for (int n = 1; n < array.length; ++n) {
    if (array[n] < array[pos]) {
      pos = n;
    }
  }
  return pos;
}
    
/**
 * @param X array of int
 * @param Y another array of int
 * @return the covariance of two variables X and Y are expected to have same
 * length
 */
public double cov(T)(T[] X, T[] Y) {
  ulong len = std.algorithm.min(X.length, Y.length);
  double sum = 0;  // double safer against overflows

  for (int n = 0; n < len; ++n) {
    sum += X[n] * cast(double) Y[n];
  }

  return (sum / len) - (average(X) * average(Y));
}

/**
 * @param X the array with the values of the variable
 * @return the standard deviation of the values in X
 */
public static double stdev(T)(T[] X) {
  return sqrt(cov(X, X));
}
