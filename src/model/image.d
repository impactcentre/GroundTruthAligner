// -*- mode: d -*-
/*
 *       image.d
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

module model.image;

////////////////
// STD + CORE //
////////////////
import std.stdio;
import std.math;
import core.memory: GC;		// We need to play with the garbage collector

/////////
// GDK //
/////////
import gdk.Pixbuf;
import gdk.Cairo;

///////////
// CAIRO //
///////////
import cairo.Context;
import cairo.ImageSurface;
import cairo.Surface;

/////////
// MVC //
/////////
//import mvc.modelview;

////////////////
// Code begin //
//////////////////////////////////////////////////////////////////////

/**
 * Class Image: This class represents an image. Normally this image
 * will be a scanned page.
 *
 */
class Image {
  
public:
  
  /////////////////
  // Constructor //
  /////////////////
  this () {
    mpxbf_rotated = null;
    mpxbf = null;
    mbase = null;
    mnc   = 0;
    mw    = 0;
    mh    = 0;
    mrs   = 0;
  }
  
  /////////////////
  // Destructor  //
  /////////////////
  ~this () {
    debug writeln ("Destroying Image!");
  }

  ///////////
  // Enums //
  ///////////
  public enum Color { BLACK = 0, WHITE = 255 };

  /////////////
  // Methods //
  /////////////

  @property Pixbuf data () { return mpxbf_rotated; }

  @property int width () {
    if (mpxbf !is null)
      return mpxbf.getWidth();
    else
      return -1;
  }

  @property int height () {
    if (mpxbf !is null)
      return mpxbf.getHeight();
    else
      return -1;
  }

  /**
   * Counts black pixels per line.
   * 
   * Returns: An array where each component represents a vertical line
   * and has the number of black pixles in that line.
   */
  int[] black_pixels_per_line () 
    in { assert (mh > 0); }
  body {
    char r,g,b;
    Color cl = Color.BLACK;

    mbppl = new int[mh];

    for (int y = 0; y < mh; y++) {
      for (int x = 0; x < mw; x++) {
	get_rgb (x, y, r, g, b);
	if (r == cl && g == cl && b == cl)
	  ++mbppl[y];
      }
    }
    return mbppl;
  }

  /**
   * Counts black pixels in one line.
   *
   * Params:
   *   y: The line to search black pixels in.
   *   
   * Returns: the number of black pixels in line 'y'.
   */
  int black_pixels_in_line (int y) 
    in { assert (y <= mh); }
  body {
    char r,g,b;
    Color cl = Color.BLACK;
    int c;

    for (int x = 0; x < mw; x++) {
      get_rgb (x, y, r, g, b);
      if (r == cl && g == cl && b == cl)
	++c;
    }
    return c;
  }

  /**
   * Count how many COLOR pixels are in the image.
   * Params:
   *    cl= the color to search
   */
  int count_color_pixels (Color cl) {
    char r,g,b;
    int c = 0;
    
    for (int x = 0; x < mw; x++)
      for (int y = 0; y < mh; y++) {
	get_rgb (x, y, r, g, b);
	if (r == cl && g == cl && b == cl)
	  c++;
      }
    return c;
  }
  
  /**
   * Loads the image in filename into the pixbuf.
   */
  void load_image (string filename) {

    if (mpxbf !is null) { mpxbf.unref(); }
    if (mpxbf_rotated !is null) { mpxbf_rotated.unref(); }

    mpxbf = new Pixbuf (filename);

    if (mpxbf !is null) {

      if (mpxbf_rotated !is null) { mpxbf_rotated.unref(); }
      mpxbf_rotated = mpxbf.copy ();	// We save the original image
					// in case we rotate/scale it.
      get_image_parameters ();

      debug writefln ("Pixbuf loaded:\nImage is %u X %u pixels\n", 
		      mpxbf.getWidth(), 
		      mpxbf.getHeight());
    } else {
      mbase = null;
      mnc   = 0;
      mw    = 0;
      mh    = 0;
      mrs   = 0;
    }
  }

  /**
   * Get the RGB values from pixel x,y,
   */
  void get_rgb (in int x, in int y, out char r, out char g, out char b) {
    char* e = cast(char*) (mbase + (y * mrs) + (x * mnc));
    r = e[0];
    g = e[1];
    b = e[2];
  }

  /**
   * Set the RGB values for pixel x,y,
   */
  void set_rgb (in int x, in int y, in char r, in char g, in char b) {
    char* e = cast(char*) (mbase + (y * mrs) + (x * mnc));
    e[0] = r;
    e[1] = g;
    e[2] = b;
  }

  /**
   * Checks for a valid image loaded.
   */
  @property bool is_valid () {
    return mpxbf !is null;
  }

  /**
   * Rotate the image by 'deg' degrees.
   * Params:
   *   deg = The number of degrees to rotate the image.
   */
  public void rotate_by (float deg) {

    if (mpxbf !is null) {
      //mpxbf = mpxbf_orig;

      CairoFormat  fmt = mpxbf.getHasAlpha () ? CairoFormat.ARGB32 : CairoFormat.RGB24;
      //int            w = mpxbf.getWidth ();
      //int            h = mpxbf.getHeight ();
      ImageSurface ims = ImageSurface.create (fmt, mw, mh);
      Context      ctx = Context.create (ims);
      float        rad = deg * PI / 180.0;

      // memory free in a much cleaner way...
      scope (exit) {
	GC.collect();
	ctx.destroy ();
	ims.destroy ();

	//writeln ("FREE MEMORY.");
      }

      ctx.translate (mw/2.0, mh/2.0);
      ctx.rotate (rad);
      ctx.setSourcePixbuf (mpxbf, -mw/2.0, -mh/2.0);
      ctx.paint ();

      if (mpxbf_rotated !is null) { mpxbf_rotated.unref(); }
      mpxbf_rotated = Pixbuf.getFromSurface (ims, 0, 0, 
					     ims.getWidth(), ims.getHeight ());
      get_image_parameters ();

    }

  }

private:
  
  /////////////////////
  // Class invariant //
  /////////////////////
  invariant () {
    if (mpxbf is null)
      assert (mbase is null);
  }

  void get_image_parameters () {
      mbase = mpxbf_rotated.getPixels ();
      mnc   = mpxbf_rotated.getNChannels ();
      mw    = mpxbf_rotated.getWidth ();
      mh    = mpxbf_rotated.getHeight ();
      mrs   = mpxbf_rotated.getRowstride ();
  }
  
  //////////
  // Data //
  //////////
  Pixbuf mpxbf;
  Pixbuf mpxbf_rotated;
  char*  mbase;
  int    mnc;
  int    mw ;
  int    mh ;
  int    mrs;
  int[]  mbppl;			// Black Pixels Per Line
}

unittest {
  Image i = new Image;

  assert (i.data   is null);
  assert (!i.is_valid);
  assert (i.width  == -1);
  assert (i.height == -1);

  // hard coded path for now...
  i.load_image ("../../data/318982.tif");
  assert (i.width  != -1);
  assert (i.height != -1);
  assert (i.count_color_pixels (Image.Color.WHITE) >= 0);
  assert (i.count_color_pixels (Image.Color.BLACK) >= 0);

  int[] bp = i.black_pixels_per_line ();
  for (int l = 0; l < bp.length; l++)
    writefln ("Line[%d] has %d black pixels.", l, bp[l]);
  //writeln ("model.Image: All tests passed!");
}
