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

//-- GDK -----------------------------------------------
import gdk.Pixbuf;

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
   * Get the maximum rgb color expressed as an uint RGBA.
   */
  @property uint get_min_color_value () { return mincol; }

  /**
   * Get the minimum rgb color expressed as an uint RGBA.
   */
  @property uint get_max_color_value () { return maxcol; }

  /// Load image (pixbuf) from file 'f'
  void load_from_file (string f) {
    file_name = f;

    free_resources ();

    the_pixbuf = new Pixbuf (file_name);
    calc_minmax_colors ();
    binarize ();
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
