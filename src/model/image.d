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
    mpxbf_orig = null;
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
  public enum Color { WHITE = 0, BLACK = 255 };

  /////////////
  // Methods //
  /////////////

  @property Pixbuf data () { return mpxbf; }

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
    mpxbf = new Pixbuf (filename);
    if (mpxbf !is null) {
      mpxbf_orig = mpxbf.copy ();	// We save the original image
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
  public void rotate_image_by (float deg) {
    if (mpxbf !is null) {
      CairoFormat  fmt = mpxbf.getHasAlpha () ? CairoFormat.ARGB32 : CairoFormat.RGB24;
      int            w = mpxbf.getWidth ();
      int            h = mpxbf.getHeight ();
      ImageSurface ims = ImageSurface.create (fmt, w, h);
      Context      ctx = Context.create (ims);
      float        rad = deg * PI / 180.0;

      // memory free in a much cleaner way...
      scope (exit) GC.collect();

      ctx.translate (w/2.0, h/2.0);
      ctx.rotate (rad);
      ctx.setSourcePixbuf (mpxbf, -w/2.0, -h/2.0);
      ctx.paint ();

      mpxbf = Pixbuf.getFromSurface (ims, 0, 0, ims.getWidth() , ims.getHeight ());
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
      mbase = mpxbf.getPixels ();
      mnc   = mpxbf.getNChannels ();
      mw    = mpxbf.getWidth ();
      mh    = mpxbf.getHeight ();
      mrs   = mpxbf.getRowstride ();
  }
  
  //////////
  // Data //
  //////////
  Pixbuf mpxbf;
  Pixbuf mpxbf_orig;
  char* mbase;
  int mnc;
  int mw ;
  int mh ;
  int mrs;
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

  //writeln ("model.Image: All tests passed!");
}
