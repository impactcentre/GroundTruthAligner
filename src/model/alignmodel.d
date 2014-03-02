// -*- mode: d -*-
/*
 *       alignmodel.d
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

module model.alignmodel;

/////////
// STD //
/////////
import std.stdio;

/////////
// GDK //
/////////
import gdk.Pixbuf;

/////////
// MVC //
/////////
import mvc.modelview;

////////////////
// Components //
////////////////
import model.image;
import model.xmltext;


////////////////
// Code begin //
//////////////////////////////////////////////////////////////////////

/**
 * Class AlignModel: This class represents the model of the aligner.
 * It contains an Image an a XmlText.
 *
 */
class AlignModel : Model {
  
public:
  
  /////////////////
  // Constructor //
  /////////////////
  this () {
    mimage = new Image;
    mxmltext = new XmlText;
  }
  
  /////////////////
  // Destructor  //
  /////////////////
  ~this () {
    
  }

  void load_image_xmltext (in string image_file, in string xmltext_file)
    in {
      //assert (image_file != "");
      //assert (xmltext_file != "");
      assert (mimage !is null);
      assert (mxmltext !is null);
    }
  body {
    if (image_file != "")
      mimage.load_image (image_file);

    if (xmltext_file != "")
      mxmltext.load_xml_contents_from (xmltext_file);

    notify_views ();
  }

  ////////////////////////////
  // Image relative methods //
  ////////////////////////////
  @property Pixbuf get_image_data() { return mimage.data; }
  @property int get_image_width() { return mimage.width; }
  @property int get_image_height() { return mimage.height; }

  void image_rotate_by (float deg) { 
    mimage.rotate_by (deg);
    notify_views ();
  }

  void image_get_rgb (in int x, in int y, out char r, out char g, out char b) {
    mimage.get_rgb (x, y, r, g, b);
  }

  //////////////////////////////
  // XmlText relative methods //
  //////////////////////////////

  /**
   * Returns the number of regions that conform the text.
   */
  @property ulong text_nregions () {
    return mxmltext.get_texts.length;
  }

  /**
   * Returns the text content for region 'r'.
   */
  string text_get_content (int r) {
    return mxmltext.get_text(r);
  }

  /**
   * Returns the array of points associated to region 'r'.
   */
  Points text_get_points (int r) {
    return mxmltext.get_points(r);
  }

  //////////////////////////////////
  // Subcomponents access methods //
  //////////////////////////////////
  @property Image get_image () { return mimage; }
  @property XmlText get_xmltext () { return mxmltext; }
  
private:
  
  /////////////////////
  // Class invariant //
  /////////////////////
  invariant () {
    assert (mimage !is null);
    assert (mxmltext !is null);
  }
  
  //////////
  // Data //
  //////////
  Image mimage;
  XmlText mxmltext;
}

unittest {
  auto am = new AlignModel;

  writeln ("alignmodel tests BEGIN...");
  assert (am.get_image !is null);
  assert (am.get_xmltext !is null);
  writeln ("alignmodel tests END...");
}
