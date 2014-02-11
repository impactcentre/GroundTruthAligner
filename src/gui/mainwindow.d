// -*- mode: d -*-
/*
 *       MainWindow.d
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

module gui.MainWindow;

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
import gtk.Scale;
import gtk.Range;
import gtk.Label;
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
import std.array;
import std.format;
import std.math;

import mvc.modelview;

/**
 * Class MainWindow:
 *
 */
class MainWindow : Window, View {
  
public:
  
  /////////////////
  // Constructor //
  /////////////////
  this (string gladefile) {

    m_gf = gladefile;
    mpage_pxbf = null;

    debug writeln ("Calling load_ui.");
    load_ui ();

    debug writeln ("Calling super.");
    super ("d-images mainWindow");

    debug writeln ("Calling prepare_ui.");
    prepare_ui ();

    // The Paned is now visible...resize it.
    mpaned.setPosition (mpaned.getAllocatedWidth()/2);

    // Initial rotation angle is 0.0
    mangle = 0.0;
  }
  
  /////////////////
  // Destructor  //
  /////////////////
  ~this () {
    debug writeln ("Destroying MainWindow!");
  }

  public void update () {}
  public void set_model (Model m) {}
  public void update_model () {}

private:

  /**
   * UI loading:
   * This function loads the UI from the glade file.
   */
  void load_ui () {
    mbuilder = new Builder();

    if( !mbuilder.addFromFile (m_gf) )
      {
	debug writefln("Oops, could not create Glade object, check your glade file ;)");
	exit(1);
      }
  }

  void prepare_ui () {
    Box b1 = cast(Box) mbuilder.getObject("box1");

    if (b1 !is null) {
      setTitle("This is a glade window");
      //w.addOnHide( delegate void(Widget aux){ exit(0); } );
      addOnHide( delegate void(Widget aux){ Main.quit(); } );

      m_bq = cast(Button) mbuilder.getObject("button_quit");
      if(m_bq !is null) {
	//b.addOnClicked( delegate void (Button) { Main.quit(); }  );
	m_bq.addOnClicked( (b) =>  Main.quit()  );
      }

      _imi = cast(ImageMenuItem) mbuilder.getObject("imenuitem_quit");
      if (_imi !is null) _imi.addOnActivate ( (mi) => Main.quit() );

      // FileChooser button
      mchooser = cast(FileChooserButton) mbuilder.getObject("filechooserbutton");
      init_filechooser_button ();

      // Drawing Area
      mpage_image = cast(DrawingArea) mbuilder.getObject("page_image");
      if (mpage_image !is null) {
	mpage_image.addOnDraw (&redraw_page);
	mpage_image.addOnButtonPress (&button_press);
      }

      // The paned
      mpaned = cast(Paned) mbuilder.getObject ("paned");

      // The scale
      mscale = cast(Scale) mbuilder.getObject ("scale");
      mscale.addOnValueChanged (&rotate_image);

      // The degrees label
      mdegrees = cast(Label) mbuilder.getObject ("degrees");

      //alias this Widget;
      //alias Widget = this;
      b1.reparent ( this );

      /*
       * Get the accel group created in glade.
       */
      auto imw = mbuilder.getObject ("image_window");
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
	debug writeln ("uris.typeid = ", typeid(uris));

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
      debug writefln ("Pixbuf loaded:\nImage is %u X %u pixels\n", 
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

    //auto d = mpaned.getChild1 ();
    auto d = w;
    auto width = d.getWidth () / 2.0;
    auto height = d.getHeight () / 2.0;

    debug writefln ("W: %f, H: %f", width, height);

    if (mpage_pxbf !is null) {
      //ctx.scale (0.5, 0.4);


      if (mangle != 0.0) {
	//ctx.save ();
	ctx.translate (width, height);
	ctx.rotate (mangle);
	//ctx.restore ();
	ctx.setSourcePixbuf (mpage_pxbf, -width, -height);
      } else
	ctx.setSourcePixbuf (mpage_pxbf, 0.0, 0.0);

      ctx.paint ();
    }

    return false;
  }

  private void rotate_image (Range r) {

    auto alpha =  r.getValue();
    auto writer = appender!string();
    formattedWrite(writer, "%6.2f", alpha);

    mdegrees.setText (writer.data);
    mangle = alpha*PI/180.0;
    mpage_image.queueDraw ();

    return;
  }

  public bool button_press (Event ev, Widget w)
  {

    debug writefln ("The widget is: %s \n this: %s", w, this);
    debug writefln ("bpress at x: %f , y: %f", ev.button.x, ev.button.y);

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
    assert (mbuilder !is null, "Builder is null!!");
  }
  
  //////////
  // Data //
  //////////
  double            mangle;
  Builder           mbuilder;	/// The Gtk.Builder
  string            m_gf;	/// Glade file
  Button            m_bq;
  ImageMenuItem     _imi;
  DrawingArea       mpage_image;
  Paned             mpaned;
  Scale             mscale;
  Label             mdegrees;
  FileChooserButton mchooser;
  Pixbuf            mpage_pxbf;
}
