// -*- mode: d -*-
/*
 *       AppWindow.d
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

// gdc -I/usr/include/dmd/gtkd2 reparent.d -o reparent -lgtk-3 -L ~/Descargas/gtkd -l gtkd-2 -ldl

module gui.AppWindow;

import gtk.Builder;
import gtk.AccelGroup;
import gtk.Main;
import gtk.Button; 
import gtk.ImageMenuItem;
import gtk.Box;
import gtk.Widget;
import gtk.Window;
import gtk.DrawingArea;
import gtk.Paned;
import gtk.FileChooserButton;
import gtk.FileChooserIF;
import gtk.FileFilter;

import gdk.Pixbuf;
import gdk.Cairo;
import gdk.Event;

import cairo.Context;

import gobject.Type;

import std.stdio;
import std.c.process;
import std.conv;
import std.string;

/**
 * Class AppWindow:
 *
 */
class AppWindow : Window {
  
public:
  
  /////////////////
  // Constructor //
  /////////////////
  this (string gladefile) {

    _gf = gladefile;
    mpage_pxbf = null;

    debug writeln ("Calling load_ui.");
    load_ui ();

    debug writeln ("Calling super.");
    super ("App Window");

    debug writeln ("Calling prepare_ui.");
    prepare_ui ();

  }
  
  /////////////////
  // Destructor  //
  /////////////////
  ~this () {
    writeln ("Destroying AppWindow!");
  }

  // The callbacks...

private:

  /**
   * UI loading:
   * This function loads the UI from the glade file.
   */
  void load_ui () {
    _b = new Builder();

    if( !_b.addFromFile (_gf) )
      {
	debug writefln("Oops, could not create Glade object, check your glade file ;)");
	exit(1);
      }
  }

  void prepare_ui () {
    Box b1 = cast(Box) _b.getObject("box1");

    if (b1 !is null) {
      setTitle("This is a glade window");
      //w.addOnHide( delegate void(Widget aux){ exit(0); } );
      addOnHide( delegate void(Widget aux){ Main.quit(); } );

      _bq = cast(Button) _b.getObject("button_quit");
      if(_bq !is null) {
	//b.addOnClicked( delegate void (Button) { Main.quit(); }  );
	_bq.addOnClicked( (b) =>  Main.quit()  );
      }

      _imi = cast(ImageMenuItem) _b.getObject("imenuitem_quit");
      if (_imi !is null) _imi.addOnActivate ( (mi) => Main.quit() );

      // FileChooser button
      mchooser = cast(FileChooserButton) _b.getObject("filechooserbutton");
      init_filechooser_button ();

      // Drawing Area
      mpage_image = cast(DrawingArea) _b.getObject("page_image");
      if (mpage_image !is null) {
	mpage_image.addOnDraw (&redraw_page);
	mpage_image.addOnButtonPress (&button_press);
      }

      //b1.reparent (cast(Widget) this);
      //alias this Widget;
      //alias Widget = this;
      b1.reparent ( this );

      /*
       * Get the accel group created in glade.
       */
      auto imw = _b.getObject ("image_window");
      auto agl = AccelGroup.accelGroupsFromObject (imw).toArray!AccelGroup;
      //writefln ("NGrupos: %u\n", agl.length);

      addAccelGroup (agl[0]);

      setResizable (false);
      showAll();
    }
    else {
      debug writefln("No window?");
      exit(1);
    }
  }
  

  private void init_filechooser_button () {
    /* Only Images */
    auto filter = new FileFilter;
    filter.setName ("Images");
    filter.addPattern ("*.png");
    filter.addPattern ("*.jpg");
    filter.addPattern ("*.tif");
    filter.addPattern ("*.tiff");
    mchooser.addFilter (filter);

    mchooser.addOnSelectionChanged ( delegate void (FileChooserIF fc) {
	auto uris = mchooser.getUris ();
	writeln ("uris.typeid = ", typeid(uris));
	//foreach (uri ; uris.toArray!(string,string)) {
	for (int f = 0; f < uris.length(); f++) {
	  auto uri = to!string (cast(char*) uris.nthData(f));
	  uri = chompPrefix (uri, "file://");
	  //writefln ("Selection changed: %s", uri);
	  load_image (uri);
	}
      }
      );
  }

  public void load_image (string filename) {
    mpage_pxbf = new Pixbuf (filename);
    //fit_image ();

    if (mpage_pxbf !is null) {
      writefln ("Pixbuf loaded:\nImage is %u X %u pixels\n", 
		mpage_pxbf.getWidth(), 
		mpage_pxbf.getHeight());

      mpage_image.setSizeRequest (mpage_pxbf.getWidth(),
				  mpage_pxbf.getHeight());

    }
  }

  ///////////////
  // Callbacks //
  ///////////////
  private bool redraw_page (Context ctx, Widget w) {

    /*
    writeln ("\nDeberia redibujar imagen.");
    writefln ("this = %s", this);
    writefln ("w = %s\n", w);
    */

    if (mpage_pxbf !is null) {
      setSourcePixbuf (ctx, mpage_pxbf, 0.0, 0.0);
      ctx.paint ();
    }

    return false;
  }

  public bool button_press (Event ev, Widget w)
  {

    writefln ("The widget is: %s \n this: %s", w, this);
    writefln ("bpress at x: %f , y: %f", ev.button.x, ev.button.y);

    Context c = createContext (w.getWindow());
    c.setSourceRgb(0, 0, 0);
    c.moveTo(2, 2);
    c.lineTo(17, 2);
    c.moveTo(2, 5);
    c.lineTo(12, 5);
    c.moveTo(2, 8);
    c.lineTo(17, 8);
    c.moveTo(2, 11);
    c.lineTo(12, 11);
    c.stroke();

    setSourcePixbuf (c, mpage_pxbf, 0.0, 0.0);
    c.paint ();

    return false;
  }

  /////////////////////
  // Class invariant //
  /////////////////////
  invariant () {
    debug writeln ("\tChecking invariant.");
    assert (_b !is null, "Builder is null!!");
  }
  
  //////////
  // Data //
  //////////
  Builder _b;
  string _gf;
  Button _bq;
  ImageMenuItem _imi;
  DrawingArea       mpage_image;
  Paned             mpaned;
  FileChooserButton mchooser;
  Pixbuf            mpage_pxbf;
}
