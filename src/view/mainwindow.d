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
import gtk.ToggleButton;
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

///////////
// Model //
///////////

import model.alignmodel;
/*
import model.image;
import model.xmltext;
*/

////////////////
// Code begin //
//////////////////////////////////////////////////////////////////////

/**
 * Class MainWindow: The App main window.
 *
 */
class MainWindow : Window, View {
  
public:
  
  /////////////////
  // Constructor //
  /////////////////
  this (string gladefile) {

    ////////////////////
    // 1- The UI part //
    /////////////////////////////////////////////////////////
    m_gf = gladefile;
    //mpage_pxbf = null;

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
    /////////////////////////////////////////////////////////

    //////////////////
    // 2- The model //
    /////////////////////////////////////////////////////////
    create_model ();
    /////////////////////////////////////////////////////////

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


  ////////////////////////
  // Base class methods //
  ///////////////////////////////////////////////////////////
  override void update () {
    ///////////////////////
    // 1- The Image part //
    ///////////////////////
    mpage_image.queueDraw ();

    /////////////////////////
    // 2- The XmlText part //
    /////////////////////////
    show_the_texts ();
  }

  override void set_model (Model m) {
    malignmodel = cast(AlignModel) m;
    malignmodel.add_view (this);
  }

  override void update_model () {}
  ///////////////////////////////////////////////////////////

  ////////////////////////////////
  // Methods for the text panel //
  ///////////////////////////////////////////////////////////
  void append_text (string the_text) {
    mtextbuffer.insertAtCursor (the_text);
  }

  void replace_text (string the_text) {
    mtextbuffer.setText (the_text);
  }
  ///////////////////////////////////////////////////////////

  /////////////////////
  // Private methods //
  /////////////////////

  /**
   * Creates the model and sets 'this' as it's View.
   * 
   * The model (AlignModel) consists of an Image and a XmlText.
   */
  private void create_model () {
    //malignmodel = new AlignModel;
    set_model (new AlignModel);
  }

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

      // FileChooser buttons
      mimagechooser = cast(FileChooserButton) mbuilder.getObject("imagefilechooserbutton");
      init_imagefilechooser_button ();

      mxmlchooser = cast(FileChooserButton) mbuilder.getObject("xmlfilechooserbutton");
      init_xmlfilechooser_button ();

      // Drawing Area
      mpage_image = cast(DrawingArea) mbuilder.getObject("page_image");
      if (mpage_image !is null) {
	mpage_image.addOnDraw (&redraw_page);
	mpage_image.addOnButtonPress (&button_press);
      }

      // The paned
      mpaned = cast(Paned) mbuilder.getObject ("paned");

      // The scale
      /*mscale = cast(Scale) mbuilder.getObject ("scale");
	mscale.addOnValueChanged (&rotate_image);*/

      // The black pixels divisor
      msbbpx = cast(SpinButton) mbuilder.getObject ("bpdivisor");
      msbbpx.addOnValueChanged (&identify_white_lines);

      // The degrees label
      //mdegrees = cast(Label) mbuilder.getObject ("degrees");

      // The showlines toggle
      mshowlines = cast(ToggleButton) mbuilder.getObject ("showlines");
      mshowlines.addOnToggled (&show_lines_toggle);

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
   * This method creates a filter for the Image file chooser.
   */
  private void init_imagefilechooser_button () {
    /* Only Images */
    auto filter = new FileFilter;
    filter.setName ("Images");
    filter.addPattern ("*.png");
    filter.addPattern ("*.jpg");
    filter.addPattern ("*.tif");
    filter.addPattern ("*.tiff");
    mimagechooser.addFilter (filter);

    mimagechooser.addOnSelectionChanged ( delegate void (FileChooserIF fc) {
	auto uris = mimagechooser.getUris ();
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

  /**
   * This method creates a filter for the XML file chooser.
   */
  private void init_xmlfilechooser_button () {
    /* Only XML */
    auto filter = new FileFilter;
    filter.setName ("XML");
    filter.addPattern ("*.xml");
    mxmlchooser.addFilter (filter);

    mxmlchooser.addOnSelectionChanged ( delegate void (FileChooserIF fc) {
	auto uris = mxmlchooser.getUris ();
	debug writeln ("uris.typeid = ", typeid(uris));

	//foreach (uri ; uris.toArray!(string,string)) {
	for (int f = 0; f < uris.length(); f++) {
	  auto uri = to!string (cast(char*) uris.nthData(f));
	  uri = chompPrefix (uri, "file://");
	  //writefln ("Selection changed: %s", uri);
	  load_xml (uri);
	}
      }
      );
  }

  /**
   * Loads an image into the model.
   */
  private void load_image (string filename) 
    in  { assert (malignmodel !is null); }
  body {
    //mpage_pxbf = new Pixbuf (filename);

    malignmodel.load_image_xmltext (filename, "");
    //fit_image ();
    //mpage_pxbf = malignmodel.get_image_data;

    if (malignmodel.get_image_data !is null) {
      debug writefln ("Pixbuf loaded:\nImage is %u X %u pixels\n", 
		      malignmodel.get_image_data.getWidth(), 
		      malignmodel.get_image_data.getHeight());

      mmaxbpxl = malignmodel.get_image.get_max_black_pixels_line (mll);

      mpage_image.setSizeRequest (malignmodel.get_image_data.getWidth(),
				  malignmodel.get_image_data.getHeight());

    }
  }

  /**
   * Loads an xml into the model.
   */
  private void load_xml (string filename)
    in { assert (malignmodel !is null); }
  body {
    //debug writefln ("We must load [%s] xml file.", filename);
    malignmodel.load_image_xmltext ("", filename);
    
    debug {
      writefln ("Loaded text has [%s] regions. The texts are:", 
		malignmodel.text_nregions);
      foreach (r ; 0..malignmodel.text_nregions) {
	writefln ("region-%d has %d points associated.", 
		  r, malignmodel.text_get_points (cast(int) r).length);
      }
    }
  }

  /**
   * Shows the texts loaded from an xml file.
   */
  private void show_the_texts () {
    replace_text ("");
    foreach (r ; 0..malignmodel.text_nregions) {
      append_text (malignmodel.text_get_content (cast(int) r)~"\n");
    }
  }

  ///////////////
  // Callbacks //
  ///////////////////////////////////////////////////////////////////////////////

  /**
   * Redraws the scaned page loaded.
   */
  private bool redraw_page (Context ctx, Widget w) {
    //auto d = mpaned.getChild1 ();

    // memory free in a much cleaner way...
    scope (exit) GC.collect();

    if (malignmodel.get_image_data !is null) {
      auto width  = w.getWidth () / 2.0;
      auto height = w.getHeight () / 2.0;

      debug writefln ("Image center X: %5.2f, Y: %5.2f", width, height);

      ///////////////////////////////
      // 1. Draw the Scanned image //
      ///////////////////////////////
      ctx.setSourcePixbuf (malignmodel.get_image_data, 0.0, 0.0);
      ctx.paint ();

      /////////////////////////////////////
      // 2. Draw longest and space lines //
      /////////////////////////////////////
      debug writefln ("mll: %s mmaxbpxl: %s", mll, mmaxbpxl);
      if (mshowlines.getActive) {
	show_longest_line (ctx);
	show_possible_space_lines (ctx);
      }

      /////////////////////////////////////////////////
      // 3. Draw the points loaded from the XML file //
      /////////////////////////////////////////////////
      draw_points_from_xml (ctx);
    }

    return false;
  }

  /**
   * Iterates over the regions extracting the Point[] in each of them
   * and calls one function to paint those points.
   */
  private void draw_points_from_xml (Context ctx) {

    void draw_points (model.xmltext.Points p) {
      if (p.length > 0) {
	ctx.save ();

	ctx.setSourceRgb (0.6, 0.1, 0.1);
	ctx.setLineWidth (2.0);

	ctx.moveTo (p[0].x, p[0].y);
	for (int i = 1; i < p.length; i++) {
	  ctx.lineTo (p[i].x, p[i].y);
	}
	ctx.lineTo (p[0].x, p[0].y);

	ctx.stroke ();
	ctx.restore ();
      }
    }

    for (int r = 0 ; r < malignmodel.text_nregions; r++) {
      draw_points (malignmodel.text_get_points (r));
    }
  }

  /**
   * Visually identify blank lines, they are painted in pink.
   */
  private void show_possible_space_lines (Context ctx) {
    int d = msbbpx.getValueAsInt ();

    ctx.save ();
    ctx.setSourceRgb (0.5, 0.0, 0.1);
    ctx.setLineWidth (0.5);
    for (int l = 0; l < malignmodel.get_image_height; l++) {

      if (malignmodel.get_image.get_black_pixels_in_line (l) < (mmaxbpxl / d)) {
	ctx.moveTo(0,l);
	ctx.lineTo (malignmodel.get_image_width, l);
	ctx.stroke ();
      }
    }
    ctx.restore ();
  }

  /**
   * Draw a green line over the one with more black pixels.
   */
  private void show_longest_line (Context ctx) {
    ctx.save ();
    ctx.setSourceRgb (0.0, 0.6, 0.1);
    ctx.setLineWidth (10);
    ctx.moveTo(0,mll);
    ctx.lineTo (malignmodel.get_image_width, mll);
    ctx.stroke ();
    ctx.restore ();
  }

  /**
   * Callback invoked whenever the user increases the divisor in the UI.
   * This is done in order to visually identify blank lines,
   */
  private void identify_white_lines (SpinButton s) {
    /*auto alpha =  s.getValue();
    auto writer = appender!string();
    formattedWrite(writer, "%6.2f", alpha);

    //mdegrees.setText (writer.data);
    mangle = alpha*PI/180.0;
    debug writefln ("Deg: %5.2f, Rad: %5.2f", alpha, mangle);

    mpage_image.queueDraw ();*/

    update ();

    return;
  }

  private void show_lines_toggle (ToggleButton t) {
    update ();			// Update the view
  }

  private void rotate_image (Range r) {
    auto alpha  = r.getValue();
    auto writer = appender!string();
    formattedWrite(writer, "%s", cast(int) alpha);

    //mdegrees.setText (writer.data);
    //    mangle = alpha*PI/180;
    mangle = alpha;
    debug writefln ("Deg: %5.2f, Rad: %5.2f", alpha, mangle);

    //malignmodel.get_image.rotate_by (mangle);
    malignmodel.image_rotate_by (mangle);

    // Not necessary because of MVC
    //mpage_image.queueDraw ();

    return;
  }

  private bool button_press (Event ev, Widget wdgt) {
    int px = cast(int) ev.button.x;
    int py = cast(int) ev.button.y;

    debug writefln ("The widget is: %s \n this: %s", wdgt, this);
    debug writefln ("bpress at x: [%d] , y: [%d]", px, py);
    debug writefln ("Black pix. in line [%d]: %d", py, 
		    malignmodel.get_image.get_black_pixels_in_line (py));

    //Context c = createContext (wdgt.getWindow());

    if ( malignmodel.get_image_data !is null ) {
      char rval, gval, bval;

      malignmodel.image_get_rgb (px, py, rval, gval, bval);

      debug writefln ("R[%d], G[%d], B[%d]", rval, gval, bval);

    }

    return false;
  }

  /////////////////////
  // Class invariant //
  /////////////////////
  invariant () {
    /*debug writeln ("\tChecking invariant.");
      assert (mbuilder !is null, "Builder is null!!");*/
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
  SpinButton        msbbpx;
  ToggleButton      mshowlines;
  FileChooserButton mimagechooser;
  FileChooserButton mxmlchooser;
  TextView          mtextview;
  TextBuffer        mtextbuffer;
  AlignModel        malignmodel;
  int               mll;	// longest line
  int               mmaxbpxl;	// max black pixels
}
