// -*- mode: d -*-
/*
 *       pixmap.d
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

module model.pixmap;

//-- STD + CORE ----------------------------------------
import std.stdio;
import core.memory: GC;         // We need to play with the garbage collector
import std.math;

//-- GDK -----------------------------------------------
import gdk.Pixbuf;
import gdk.Cairo;

//-- CAIRO ---------------------------------------------
import cairo.Context;
import cairo.ImageSurface;
import cairo.Surface;

/**
 * Class Pixmap:
 *
 * This class represents the abstraction of a Pixmap. In order to
 * achieve this it uses the Gdk.Pixbuf class. Mostly it's a thin
 * wrapper around it.
 */
class Pixmap {
  
public:
  
  /////////////////
  // Constructor //
  /////////////////
  this () { init_instance_variables (); }

  /////////////////
  // Destructor  //
  /////////////////
  ~this () {
    //debug writeln ("Pixmap destructor!");
    free_resources ();
    //debug writeln ("After freeing pixmap resources!");
  }
  
  //-- Methods -----------------------------------------------

  @property bool has_alpha () {
    if (the_pixbuf !is null)
      return cast(bool) the_pixbuf.getHasAlpha ();
    else
      return false;
  }

  @property char* base () {
    if (the_pixbuf !is null)
      return the_pixbuf.getPixels ();
    else
      return null;
  }

  @property int nchannels () {
    if (the_pixbuf !is null)
      return the_pixbuf.getNChannels ();
    else
      return -1;
  }

  @property int width () {
    if (the_pixbuf !is null)
      return the_pixbuf.getWidth ();
    else
      return -1;
  }

  @property int height () {
    if (the_pixbuf !is null)
      return the_pixbuf.getHeight ();
    else
      return -1;
  }

  @property int row_stride () {
    if (the_pixbuf !is null)
      return the_pixbuf.getRowstride();
    else
      return -1;
  }

  /// Low level access
  //@property Pixbuf data () { return the_pixbuf; }
  @property Pixbuf get_gdkpixbuf () { return the_pixbuf; }
  void set_gdkpixbuf (Pixbuf p) {
    if (the_pixbuf !is null) { the_pixbuf.unref(); }
    the_pixbuf = p;
  }

  /**
   * Get the value of pixel @x,y as an uint.
   */
  uint get_composite_value (in int x, in int y) {
    IntUnion iu;
    char r,g,b;
    
    get_rgb (x, y, r, g, b);
    iu.ca[0] = r; iu.ca[1] = g; iu.ca[2] = b; iu.ca[3] = 0;

    return iu.i;
  }

  /**
   * Get the RGB values from pixel x,y,
   */
  void get_rgb (in int x, in int y, out char r, out char g, out char b) 
    in {
      assert ( x>=0, "Pixmap.get_rgb 'x' coord must be >=0.");
      assert ( y>=0, "Pixmap.get_rgb 'y' coord must be >=0.");
    }
  body {
    if (the_pixbuf !is null) {
      if ( (x < width) && (y < height) ) {
        char* e = cast(char*) (base + (y * row_stride) + (x * nchannels));
        r = e[0]; g = e[1]; b = e[2];
      } else r = g = b = 0;
    } else r = g = b = 0;
  }

  /**
   * Set the RGB values for pixel x,y,
   */
  void set_rgb (in int x, in int y, in char r, in char g, in char b) 
    in {
      assert ( x>=0, "Pixmap.set_rgb 'x' coord must be >=0.");
      assert ( y>=0, "Pixmap.set_rgb 'y' coord must be >=0.");
    }
  body {
    if (the_pixbuf !is null) {
      if ( (x < width) && (y < height) ) {
        char* e = cast(char*) (base + (y * row_stride) + (x * nchannels));
        e[0] = r; e[1] = g; e[2] = b;
      }
    }
  }

  /**
   * Simple binarization algorithm.
   */
  void binarize () {
    uint threshold = (maxcol + mincol) / 2;
    int w  = width;
    int h  = height;

    for (int x = 0; x < w; x++)
      for (int y = 0; y < h; y++) {
        uint v = get_composite_value (x, y);
        char nv = v < threshold ? 0 : 255;
        char r, g, b;

        r = g = b = nv;
        set_rgb (x, y, r, g, b);
      }
  }

  /**
   * This algorithm tries to convert the image to grayscale.
   */
  void to_grayscale () {
    int w  = width;
    int h  = height;
    char r,g,b, gray;

    for (int x = 0; x < w; x++)
      for (int y = 0; y < h; y++) {
	get_rgb (x, y, r, g, b);
	gray = cast (char) ((r * 0.3) + (g * 0.59) + (b * 0.11));
	set_rgb (x, y, gray, gray, gray);
      }
  }

  /**
   * Rotate the image by 'deg' degrees.
   * 
   * Params:
   *   deg = The number of degrees to rotate the image.
   */
  void rotate_by (float deg) {
    if (is_valid_pixmap) {
      //mpxbf = mpxbf_orig;

      CairoFormat  fmt = has_alpha () ? CairoFormat.ARGB32 : CairoFormat.RGB24;
      int            w = width ();
      int            h = height ();
      ImageSurface ims = ImageSurface.create (fmt, w, h);
      Context      ctx = Context.create (ims);
      float        rad = deg * PI / 180.0;

      // memory free in a much cleaner way...
      scope (exit) {
        ctx.destroy ();
        ims.destroy ();
        GC.collect();
      }

      ctx.translate (w/2.0, h/2.0);
      ctx.rotate (rad);
      ctx.setSourcePixbuf (get_gdkpixbuf, -w/2.0, -h/2.0);
      ctx.paint ();

      set_gdkpixbuf (Pixbuf.getFromSurface (ims, 0, 0,
                                            ims.getWidth(),
                                            ims.getHeight()));
    }
  }

  /**
   * Get the minimum rgb color expressed as an uint RGBA.
   */
  @property uint get_min_color_value () { return mincol; }

  /**
   * Get the maximum rgb color expressed as an uint RGBA.
   */
  @property uint get_max_color_value () { return maxcol; }

  /**
   * The luminance (weighted average, see
   * http://en.wikipedia.org/wiki/Luminance_(colorimetry)) of a pixel
   *
   * Parameters: 
   * x = x coordinate
   * y = y coordinate
   *
   * Returns:
   * the luminance of pixel at (x,y), as defined in colorimetry
   */
  uint luminance(in int x, in int y) {
    char r, g, b;

    get_rgb (x, y, r, g, b);
    return cast (int) (0.2126 * r + 0.7152 * g + 0.0722 * b);
  }

  /// Get the array of black pixels per line.
  @property uint[] get_bppl () { return mbppl; }

  /// Get the line that has the most black pixels in it.
  @property int get_lwmbp () { return mlwmbp; }

  /**
   * Counts and caches black pixels per line.
   */
  void count_black_pixels_per_line () 
    in {
      assert (is_valid_pixmap); 
    }
  body {
    enum Color { BLACK = 0, WHITE = 255 };
    char   r,g,b;
    Color  cl  = Color.BLACK;
    uint   mbp = 0;

    mbppl = new uint[height];

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        get_rgb (x, y, r, g, b);
        if (r == cl && g == cl && b == cl)
          ++mbppl[y];
      }

      if (mbppl[y] > mbp) {
        mbp = mbppl[y];
        mlwmbp = y;
      }
    }

    // --> HERE!!!
    // Calculate the average and the variance of black pixels.
    //calculate_average_variance_bpixels ();
  }

  /**
   * Calculates the average and the variance of the black pixels
   * from the Image.
   */
  void calculate_average_variance_bpixels (out float average, 
					   out float variance)
  {
    average = variance = 0.0;
    if (mbppl !is null) {
      // Average
      for (int i = 0; i < mbppl.length ; i++) {
	average += mbppl[i];
      }
      average /= mbppl.length;

      // Variance
      for (int i = 0; i<mbppl.length ; i++) {
	variance += (mbppl[i] - average)^^2.0;
      }
      variance /= mbppl.length;

      /*
      debug {
	writefln ("Old avg[%s] / stdvev[%s] - New avg[%s] / stdev[%s]",
		  average, sqrt(variance),
		  mbppl.average(), mbppl.stdev());
		  } */

    }
  }


  /// Load image (pixbuf) from file 'f'
  void load_from_file (string f) {
    file_name = f;

    free_resources ();

    the_pixbuf = new Pixbuf (file_name);

    to_grayscale ();
    calc_minmax_colors ();

    //binarize ();

    count_black_pixels_per_line ();
    /*original_pixbuf = new Pixbuf (file_name);
      if (original_pixbuf !is null)
      the_pixbuf = original_pixbuf.copy ();*/
  }

  @property bool is_valid_pixmap () { return (the_pixbuf !is null); }

private:
  
  //-- Class invariant -----------------------------------------

  /// The exported pixbuf is null iff original_pixbuf is null
  invariant () {
  }

  /**
   * This union is used to transform values
   * between char[4] <-> uint.
   */
  union IntUnion {
    uint     i;                 // 32 bits unsigned integer
    ubyte[4] ca;                // 32 bits as 4 unsigned chars
  }

  /// Initializes instance variables of the Pixmap class
  void init_instance_variables () { 
    file_name = "";
    the_pixbuf = original_pixbuf = null;
    mincol = uint.max;
    maxcol = 0;
    mbppl = null;
    //free_resources ();
  }

  /// Frees the resources, the two Gdk.Pixbuf's
  void free_resources () {
    //debug writeln ("pixbuf_unref");
    if (the_pixbuf !is null) the_pixbuf.unref ();

    //debug writeln ("orig-pixbuf_unref");
    if (original_pixbuf !is null) original_pixbuf.unref ();

    //the_pixbuf = original_pixbuf = null;
  }

  /**
   * Gets the 'maximum' value of all colors in the image.
   */
  void calc_minmax_colors () {
    int w  = width;
    int h  = height;

    for (int x = 0; x < w; x++)
      for (int y = 0; y < h; y++) {
        uint v = get_composite_value (x, y);
        mincol = v < mincol ? v : mincol;
        maxcol = v > maxcol ? v : maxcol;
      }
  }

  //////////
  // Data //
  //////////
  Pixbuf the_pixbuf;
  Pixbuf original_pixbuf;
  string file_name;
  uint   mincol, maxcol;
  uint[] mbppl;
  int    mlwmbp;      // Line with most black pixels
}

unittest {
  import std.stdio;

  Pixmap p = new Pixmap;

  p.load_from_file ("../../data/439040.tif");

  writefln ("Image is ../../data/439040.tif, width (%s), height (%s), Alpha (%s)",
            p.width, p.height, p.has_alpha);
  writefln ("nchannels (%s), row stride (%s).", p.nchannels, p.row_stride);
  writefln ("maxcolor (%s), mincolor (%s).", 
            p.get_max_color_value, p.get_min_color_value);
}
