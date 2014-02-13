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

/////////
// GTK //
/////////
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
import gtk.SpinButton;
import gtk.Range;
import gtk.Label;
import gtk.FileChooserButton;
import gtk.FileChooserIF;
import gtk.FileFilter;
import gtk.TextView;
import gtk.TextBuffer;

/////////
// GDK //
/////////
import gdk.Pixbuf;
import gdk.Cairo;
import gdk.Event;

///////////
// CAIRO //
///////////
import cairo.Context;

/////////////
// GOBJECT //
/////////////
import gobject.Type;

////////////////
// STD + CORE //
////////////////
import std.stdio;
import std.c.process;
import std.conv;
import std.string;
import std.array;
import std.format;
import std.math;
import core.memory: GC;		// We need to play with the garbage collector

/////////
// MVC //
/////////
import mvc.modelview;

////////////////
// Code begin //
//////////////////////////////////////////////////////////////////////

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
    super ("Impact Aligner");

    debug writeln ("Calling prepare_ui.");
    prepare_ui ();

    // The Paned is now visible...resize it.
    mpaned.setPosition (mpaned.getAllocatedWidth()/2);

    // Initial rotation angle is 0.0
    mangle = 0.0;

    setResizable (true);
    debug writeln ("Resizable: ", getResizable());

    /*
    GdkGeometry hints;
    hints.minWidth = 800;
    hints.minHeight = 600;
    setGeometryHints (null, hints, WindowHints.HINT_MIN_SIZE | WindowHints.HINT_USER_POS | WindowHints.HINT_USER_SIZE);
    */
  }
  
  /////////////////
  // Destructor  //
  /////////////////
  ~this () {
    debug writeln ("Destroying MainWindow!");
  }

  ////////////////////
  // Public methods //
  ////////////////////
  public override void update () {}
  public override void set_model (Model m) {}
  public override void update_model () {}

  public void show_text (string the_text) {
    mtextbuffer.insertAtCursor (the_text);
  }

  /////////////////////
  // Private methods //
  /////////////////////
  /**
   * UI loading:
   * This function loads the UI from the glade file.
   */
  private void load_ui () {
    mbuilder = new Builder();

    if( !mbuilder.addFromFile (m_gf) ) {
      debug writefln("Oops, could not create Glade object, check your glade file ;)");
      exit(1);
    }
  }

  /**
   * This function extracts the UI from the builder.
   * It reparents the window created in glade to the window created in
   * the code.
   */
  private void prepare_ui () {
    Box b1 = cast(Box) mbuilder.getObject("box1");

    if (b1 !is null) {
      //setTitle("This is a glade window");
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
      /*msb = cast(SpinButton) mbuilder.getObject ("sbangle");
	msb.addOnValueChanged (&rotate_image);*/

      // The degrees label
      mdegrees = cast(Label) mbuilder.getObject ("degrees");

      // The text view + the text buffer
      mtextview = cast(TextView) mbuilder.getObject ("textview");
      mtextbuffer = mtextview.getBuffer();

      ////////////////////////////////////////////////////////
      // Finally reparent the glade window into this one... //
      ////////////////////////////////////////////////////////

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
    }
    else {
      debug writefln("No window?");
      exit(1);
    }
  }
  
  /**
   * This method creates a filter for the file chooser.
   */
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

  private void load_image (string filename) {
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
    //auto d = mpaned.getChild1 ();

    if (mpage_pxbf !is null) {
      auto width  = w.getWidth () / 2.0;
      auto height = w.getHeight () / 2.0;

      debug writefln ("Image center X: %5.2f, Y: %5.2f", width, height);

      // memory free in a much cleaner way...
      scope (exit) GC.collect();

      // Disable GC when rotating and painting the image
      //GC.disable ();

      if (mangle != 0.0) {
	//ctx.save ();
	ctx.translate (width, height);
	ctx.rotate (mangle);
	//ctx.restore ();
	ctx.setSourcePixbuf (mpage_pxbf, -width, -height);
      } else
	ctx.setSourcePixbuf (mpage_pxbf, 0.0, 0.0);
      ctx.paint ();

      // enable GC after rotating and painting the image
      //GC.enable ();
    }

    return false;
  }

  private void rotate_image (SpinButton s) {
    auto alpha =  s.getValue();
    auto writer = appender!string();
    formattedWrite(writer, "%6.2f", alpha);

    //mdegrees.setText (writer.data);
    mangle = alpha*PI/180.0;
    debug writefln ("Deg: %5.2f, Rad: %5.2f", alpha, mangle);

    mpage_image.queueDraw ();

    return;
  }

  private void rotate_image (Range r) {
    auto alpha  = r.getValue();
    auto writer = appender!string();
    formattedWrite(writer, "%s", cast(int)alpha);

    mdegrees.setText (writer.data);
    mangle = alpha*PI/180;
    debug writefln ("Deg: %5.2f, Rad: %5.2f", alpha, mangle);

    mpage_image.queueDraw ();
    //queueDraw ();

    return;
  }

  private bool button_press (Event ev, Widget w)
  {
    debug writefln ("The widget is: %s \n this: %s", w, this);
    debug writefln ("bpress at x: %f , y: %f", ev.button.x, ev.button.y);

    Context c = createContext (w.getWindow());

    //setSourcePixbuf (c, mpage_pxbf, 0.0, 0.0);
    c.setSourceRgb(0, 0, 0);
    c.moveTo(0, 0);
    c.lineTo(ev.button.x, ev.button.y);
    c.stroke();

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
  SpinButton        msb;
  Label             mdegrees;
  FileChooserButton mchooser;
  Pixbuf            mpage_pxbf;
  TextView          mtextview;
  TextBuffer        mtextbuffer;
}
