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

module view.mainwindow;

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
import gtk.ProgressBar;
import gtk.ToggleButton;
import gtk.Range;
import gtk.Label;
import gtk.FileChooserButton;
import gtk.FileChooserIF;
import gtk.FileFilter;
import gtk.TextView;
import gtk.TextBuffer;
import gtk.Tooltip;

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
import core.memory: GC;         // We need to play with the garbage collector

/////////
// MVC //
/////////
import mvc.modelview;

///////////
// Model //
///////////
import model.alignmodel;

////////////
// Config //
////////////
import config.types;

/////////////
// Aliases //
/////////////
alias Points = model.xmltext.Points;

////////////////
// Code begin //
//////////////////////////////////////////////////////////////////////

/**
 * Class MainWindow: The App main window.
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

    mloading_data = false;

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

    debug writeln ("Update received!!");

    if (!mloading_data) {
      mpage_image.queueDraw (); // 1- The Image part
      show_the_texts ();        // 2- The XmlText part
    } else {

      debug writeln ("Update the pbar!!");

      // Loading data...progress show
      mpbar.setText (malignmodel.get_current_action);
      mpbar.setFraction (malignmodel.get_fraction_current_action);

      mpbar.queueDraw ();       // Update the progressbar.
      process_pending_events (); // I mean it!!
    }
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

  /**
   * Appends the text to the text in the panel.
   *
   * Paremeters:
   *     the_text = The text to append
   */
  void append_text (string the_text) {
    mtextbuffer.insertAtCursor (the_text);
  }

  /**
   * Replaces the text in the panel.
   *
   * Paremeters:
   *     the_text = The texto to replace the one in the panel.
   */
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
        mpage_image.setHasTooltip (true);
        mpage_image.addOnQueryTooltip (&query_tooltip);
      }

      // The paned
      mpaned = cast(Paned) mbuilder.getObject ("paned");

      // The scale
      /*mscale = cast(Scale) mbuilder.getObject ("scale");
        mscale.addOnValueChanged (&rotate_image);*/

      // The progress bar...
      mpbar = cast(ProgressBar) mbuilder.getObject ("pbar");
      //msbbpx.addOnValueChanged (&identify_white_lines);

      // The degrees label
      //mdegrees = cast(Label) mbuilder.getObject ("degrees");

      // The showlines toggle
      mshowlines = cast(ToggleButton) mbuilder.getObject ("showlines");
      mshowlines.addOnToggled (&show_lines_toggle);
      // The showcontours toggle
      mshowcontours = cast(ToggleButton) mbuilder.getObject ("showcontours");
      mshowcontours.addOnToggled (&show_contours_toggle);

      // The showpage toggle
      mshowpage = cast(ToggleButton) mbuilder.getObject ("showpage");
      mshowpage.addOnToggled ( (tb) => update() );
      // The showskyline toggle
      mshowskyline = cast(ToggleButton) mbuilder.getObject ("showskyline");
      mshowskyline.addOnToggled ( (tb) => update() );
      // The showhist toggle
      mshowhist = cast(ToggleButton) mbuilder.getObject ("showhist");
      mshowhist.addOnToggled ( (tb) => update() );

      // The text view + the text buffer
      mtextview = cast(TextView) mbuilder.getObject ("textview");
      mtextbuffer = mtextview.getBuffer();

      ////////////////////////////////////////////////////////
      // Finally reparent the glade window into this one... //
      ////////////////////////////////////////////////////////

      //alias this Widget;
      //alias Widget = this;
      b1.reparent ( this );

      // Get the accel group for the window created in glade...
      auto imw = mbuilder.getObject ("image_window");
      auto agl = AccelGroup.accelGroupsFromObject (imw).toArray!AccelGroup;
      //writefln ("NGrupos: %u\n", agl.length);

      // ...and transplant it onto 'this' window...
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

    // For the update method and the progress bar
    mloading_data = true;
    update ();

    malignmodel.load_image_xmltext (filename, "");
    //fit_image ();
    //mpage_pxbf = malignmodel.get_image_data;

    if (malignmodel.get_image_data !is null) {
      debug writefln ("Pixbuf loaded:\nImage is %u X %u pixels\n", 
                      malignmodel.get_image_data.getWidth(), 
                      malignmodel.get_image_data.getHeight());

      mmaxbpxl = malignmodel.get_image.blackest_line;
      mll = malignmodel.get_image.bpx_in_blackest_line;

      mpage_image.setSizeRequest (malignmodel.get_image_data.getWidth(),
                                  malignmodel.get_image_data.getHeight());

    }
    
    // Reset the progress bar...
    update ();
    mloading_data = false;
  }

  /**
   * Loads an xml into the model.
   */
  private void load_xml (string filename)
    in { assert (malignmodel !is null); }
  body {
    // For the update method and the progress bar
    mloading_data = true;
    mpbar.setText ("Loading texts");
    update ();

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

    // For the update method and the progress bar
    mloading_data = false;
    mpbar.setText ("");
    update ();
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

      // debug writefln ("Image center X: %5.2f, Y: %5.2f", width, height);

      ///////////////////////////////
      // 1. Draw the Scanned image //
      ///////////////////////////////
      if (mshowpage.getActive) {
        ctx.setSourcePixbuf (malignmodel.get_image_data, 0.0, 0.0);
        ctx.paint ();
      }

      ////////////////
      // 2. SkyLine //
      ////////////////
      if (mshowskyline.getActive) {
        show_sky_bottom_lines (ctx);
      }

      //////////////////
      // 3. Histogram //
      //////////////////
      if (mshowhist.getActive) {
        show_histograms (ctx);
      }

      /////////////////////////////////////
      // 4. Draw longest and space lines //
      /////////////////////////////////////
      if (mshowlines.getActive) {
        //show_longest_line (ctx);
        show_text_lines (ctx);
      }

      /////////////////////////////////////////////////
      // 5. Draw the points loaded from the XML file //
      /////////////////////////////////////////////////
      if (mshowcontours.getActive) draw_points_from_xml (ctx);
    }

    return false;
  }

  /**
   * Iterates over the regions extracting the Point[] in each of them
   * and calls one function to paint those points.
   */
  private void draw_points_from_xml (Context ctx) {

    void draw_points (Points p) {
      if (p.length > 0) {
        ctx.save ();

        ctx.setSourceRgb (0.0, 0.76, 0.0);
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
   * Visually show the text skylines for each line.
   */
  private void show_sky_bottom_lines (Context ctx) {

    int s, h;
    int w = malignmodel.get_image_width;
    float delta;
    coord_t[] sl;                       // Skyline
    coord_t[] bl;                       // Bottomline

    ctx.save ();

    ctx.setSourceRgb (0.75, 0.1, 0.1);
    ctx.setLineWidth (1.3);

    for (int l = 0; l < malignmodel.get_image.get_num_textlines; l++) {
      sl = malignmodel.get_image.get_textline_skyline (l);
      bl = malignmodel.get_image.get_textline_bottomline (l);

      // skyline
      //ctx.setSourceRgb (0.75, 0.1, 0.1);
      ctx.moveTo (0, sl[0]);
      for (int x = 1; x < sl.length-1; x++) {
        ctx.lineTo (x+1, sl[x+1]);
      }
      ctx.stroke ();

      // bottomline
      //ctx.setSourceRgb (0.1, 0.75, 0.4);
      ctx.moveTo (0, bl[0]);
      for (int x = 1; x < sl.length-1; x++) {
        ctx.lineTo (x+1, bl[x+1]);
      }
      ctx.stroke ();

    }

    ctx.restore ();
  }

  /**
   * Visually show the text histograms for each line.
   */
  private void show_histograms (Context ctx) {

    int s, h;
    int w = malignmodel.get_image_width;
    float delta;
    int y;
    coord_t[] hist;

    ctx.save ();

    ctx.setSourceRgb (0.2, 0.2, 0.8);
    ctx.setLineWidth (1.0);

    for (int l = 0; l < malignmodel.get_image.get_num_textlines; l++) {

      malignmodel.get_image.get_textline_start_height (l, s, h);
      delta = h / 2.0;
      y = cast (int) (s + h + delta);

      hist  = malignmodel.get_image.get_textline_histogram (l);

      for (int x = 0; x < hist.length; x++) {
        ctx.moveTo (x, y); // Go deepest in the current line
        ctx.lineTo (x, y - hist[x]);
      }
    }

    ctx.stroke ();
    ctx.restore ();
  }

  /**
   * Visually identify text lines, they are painted in pink.
   */
  private void show_text_lines (Context ctx) {

    int s, h;
    int w = malignmodel.get_image_width;
    float delta;

    ctx.save ();

    ctx.setSourceRgb (0.7, 0.1, 0.1);
    ctx.setLineWidth (0.5);

    for (int l = 0; l < malignmodel.get_image.get_num_textlines; l++) {
      malignmodel.get_image.get_textline_start_height (l, s, h);
      delta = h / 2.0;

      // 1- Upper rectangle
      ///////////////////////////////////////
      // ctx.setSourceRgb (0.1, 0.1, 0.6); //
      // ctx.setLineWidth (1);             //
      //                                   //
      // ctx.moveTo(0,s-delta);            //
      // ctx.lineTo (w, s-delta);          //
      // ctx.lineTo (w, s);                //
      // ctx.lineTo (0, s);                //
      // ctx.lineTo (0, s-delta);          //
      // ctx.stroke ();                    //
      ///////////////////////////////////////

      // 2- Inner rectangle
      /*ctx.setSourceRgb (0.7, 0.1, 0.1);
        ctx.setLineWidth (0.5);*/

      //////////////////////////
      // ctx.moveTo(0,s);     //
      // ctx.lineTo (w, s);   //
      // ctx.lineTo (w, s+h); //
      // ctx.lineTo (0, s+h); //
      // ctx.lineTo (0, s);   //
      // ctx.stroke ();       //
      //////////////////////////

      ctx.moveTo (0, s - delta);
      ctx.lineTo (w, s - delta);
      ctx.lineTo (w, s + delta + h);
      ctx.lineTo (0, s + delta + h);
      ctx.lineTo (0, s - delta);

      // 3- Down rectangle
      ///////////////////////////////////////
      // ctx.setSourceRgb (0.1, 0.1, 0.6); //
      // ctx.setLineWidth (1);             //
      //                                   //
      // ctx.moveTo(0,s+h+delta);          //
      // ctx.lineTo (w, s+h+delta);        //
      // ctx.lineTo (w, s+h);              //
      // ctx.lineTo (0, s+h);              //
      // ctx.lineTo (0, s+h+delta);        //
      // ctx.stroke ();                    //
      ///////////////////////////////////////
    }
    ctx.stroke ();

    // Draw the margins...
    ctx.setSourceRgb (0.2, 0.1, 0.7);
    ctx.setLineWidth (1.0);

    int marginx = malignmodel.get_image.left_margin;
    int marginy = malignmodel.get_image_height;
    ctx.moveTo (marginx, 0);
    ctx.lineTo (marginx, malignmodel.get_image_height);

    marginx = malignmodel.get_image.right_margin;
    ctx.moveTo (marginx, 0);
    ctx.lineTo (marginx, malignmodel.get_image_height);
    ctx.stroke ();

    ctx.restore ();
  }

  /**
   * Draw a green line over the one with more black pixels.
   */
  private void show_longest_line (Context ctx) {
    ctx.save ();
    ctx.setSourceRgb (0.0, 0.6, 0.1);
    ctx.setLineWidth (10);
    ctx.moveTo(0,mmaxbpxl);
    ctx.lineTo (malignmodel.get_image_width, mmaxbpxl);
    ctx.stroke ();
    ctx.restore ();
  }

  private void show_lines_toggle (ToggleButton t) {
    update ();                  // Update the view
  }

  private void show_contours_toggle (ToggleButton t) {
    update ();                  // Update the view
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
    //Context c = createContext (wdgt.getWindow());

    if ( malignmodel.get_image_data !is null ) {
      char rval, gval, bval;

      debug writefln ("Black pix. in line [%d]: %d", py, 
                      malignmodel.get_image.get_black_pixels_in_line (py));

      malignmodel.image_get_rgb (px, py, rval, gval, bval);

      debug writefln ("R[%d], G[%d], B[%d]", rval, gval, bval);

    }

    return false;
  }

  private bool query_tooltip (int x, int y, int keyboard_tt, 
                              Tooltip t, Widget w)
  {

    if ( (x < malignmodel.get_image_width()) && 
         (y < malignmodel.get_image_height()) )
      if ( (!keyboard_tt) && (malignmodel.get_image_data !is null) ) {
        auto writer = appender!string();
        char rval, gval, bval;
        uint cv = malignmodel.image_get_composite_value(x,y);
        
        malignmodel.image_get_rgb (x, y, rval, gval, bval);
        formattedWrite(writer, 
                       "@(%d, %d)/(R:%u , G:%u , B: %u)/%u",
                       x, y, rval, gval, bval, cv);

        //writefln ("Tooltip @(%s,%s)", x, y);
        t.setText (writer.data);

        return true;
      }

    return false;
  }

  private void process_pending_events () {
    while (Main.eventsPending ())
      Main.iteration ();
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
  Builder           mbuilder;   /// The Gtk.Builder
  string            m_gf;       /// Glade file
  Button            m_bq;
  ImageMenuItem     _imi;
  DrawingArea       mpage_image;
  Paned             mpaned;
  //SpinButton        msbbpx;
  ProgressBar       mpbar;
  ToggleButton      mshowlines;
  ToggleButton      mshowcontours;
  ToggleButton      mshowpage;
  ToggleButton      mshowskyline;
  ToggleButton      mshowhist;
  FileChooserButton mimagechooser;
  FileChooserButton mxmlchooser;
  TextView          mtextview;
  TextBuffer        mtextbuffer;
  AlignModel        malignmodel;
  int               mll;        // longest line
  int               mmaxbpxl;   // max black pixels
  bool              mloading_data; // Flag for knowing if we are
                                   // loading image/xml-text
}
