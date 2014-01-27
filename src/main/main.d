// -*- mode: d -*-
/*
 *       main.d
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

module main;

import gtk.Main;
import std.stdio;

/**
 * Usage ./gladeText /path/to/your/glade/file.glade
 *
 */
int main(string[] args)
{
  string gladefile;

  Main.init(args);

  if(args.length > 1)
    {
      writefln("Loading %s", args[1]);
      gladefile = args[1];
    }
  else
    {
      writefln("No glade file specified, using default \"app.glade\"");
      gladefile = "app.glade";
    }

  //scope auto app = new AppWindow (gladefile);
  Main.run();

  return 0;
}
