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
class AlignModel : Object {
  
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
      assert (image_file != "");
      assert (xmltext_file != "");
      assert (mimage !is null);
      assert (mxmltext !is null);
    }
    body {
      mimage.load_image (image_file);
      mxmltext.load_xml_contents_from (xmltext_file);
    }
  
  @property Image get_image () { return mimage; }
  @property XmlText get_xmltext () { return mxmltext; }
  
private:
  
  /////////////////////
  // Class invariant //
  /////////////////////
  invariant () {
    
  }
  
  //////////
  // Data //
  //////////
  Image mimage;
  XmlText mxmltext;
}
