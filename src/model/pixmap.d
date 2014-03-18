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
  this () {
    
  }
  
  /////////////////
  // Destructor  //
  /////////////////
  ~this () {
    if (the_pixbuf !is null) the_pixbuf.unref ();
    if (original_pixbuf !is null) original_pixbuf.unref ();
  }
  
  //-- Methods -----------------------------------------------

  @property char* base () {
    if (the_pixbuf !is null)
      return the_pixbuf.getPixels();
    else
      return null;
  }

  @property int nchannels () {
    if (the_pixbuf !is null)
      return the_pixbuf.getNChannels();
    else
      return -1;
  }

  @property int width () {
    if (the_pixbuf !is null)
      return the_pixbuf.getWidth();
    else
      return -1;
  }

  @property int height () {
    if (the_pixbuf !is null)
      return the_pixbuf.getHeight();
    else
      return -1;
  }

  @property int row_stride () {
    if (the_pixbuf !is null)
      return the_pixbuf.getRowstride();
    else
      return -1;
  }

  /**
   * Get the RGB values from pixel x,y,
   */
  void get_rgb (in int x, in int y, out char r, out char g, out char b)
  {
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
  {
    if (the_pixbuf !is null) {
      if ( (x < width) && (y < height) ) {
	  char* e = cast(char*) (base + (y * row_stride) + (x * nchannels));
	  e[0] = r; e[1] = g; e[2] = b;
	}
    }
  }

private:
  
  /////////////////////
  // Class invariant //
  /////////////////////
  invariant () {
    
  }
  
  //////////
  // Data //
  //////////
  Pixbuf         the_pixbuf;
  Pixbuf         original_pixbuf;

}
