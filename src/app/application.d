// -*- mode: d -*-
/*
 *       application.d
 *
 *       Copyright 2014 Antonio-Miguel Corbi Bellot <antonio.corbi@ua.es>
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

/////////
// STD //
/////////
import std.stdio;

/////////
// GTK //
/////////
import gtk.Main;

///////////////////
// Local imports //
///////////////////
import config.constants;
import view.mainwindow;


/**
 * This class represents the Application.
 */
class Application {

  public this (string[] args) {
    if(args.length > 1) {
      //writefln("Loading %s", args[1]);
      gladefile = args[1];
    }
    else {
      gladefile = UIPATH;
      //debug writefln("·> No glade file specified, using [%s]",gladefile);
    }

    debug writefln("·> No glade file specified, using [%s]",gladefile);
    Main.init(args);

    mw = new MainWindow (gladefile);

    /*
     * Raw strings: r" ... "
     *            : ` ... `
     */
    mw.replace_text (`Calling super.
	Checking invariant.
	Checking invariant.
	Checking invariant.
	Checking invariant.
	Checking invariant.
	Checking invariant.
	Checking invariant.
	Checking invariant.
	Checking invariant.`);
  }

  public void show_main_window () {
    mw.show ();
  }

  public void run () {
    Main.run ();
  }

  private {
    string gladefile;
    MainWindow mw;
  }

}
