// -*- mode: d -*-
/*
 *       xmltext.d
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

module model.xmltext;

////////////////
// STD + CORE //
////////////////
import std.stdio;
import std.xml;
import std.string;
import std.file;
import std.conv;

////////////////
// Code begin //
//////////////////////////////////////////////////////////////////////

struct Point {
  int x;
  int y;
}

struct Text {
  string  id;
  string  type;
  Point[] points;
  string  content;
}

////////////////////
// Useful aliases //
////////////////////
alias Points = Point[];
alias Texts  = Text[];

/**
 * Class XmlText:
 *
 * This class represents the xml structure of the text in a scanned
 * image.
 */
class XmlText {
  
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
    debug writeln ("XmlText destroyed!");
  }

  @property Texts get_texts () { return mtexts; }
  @property ulong get_ntexts () { return mtexts.length; }

  string get_text (int t)
    in {
      assert (t < mtexts.length, "No such region");
    }
  body {
    return mtexts[t].content;
  }

  string get_type (int t)
    in {
      assert (t < mtexts.length, "No such region");
    }
  body {
    return mtexts[t].type;
  }

  Points get_points (int t)
    in {
      assert (t < mtexts.length, "No such region");
    }
  body {
    return mtexts[t].points;
  }

  /////////////
  // Methods //
  /////////////
  
  void load_from_file (string the_file) 
    in { assert (the_file != "", "XmlText: empty file!"); }
  body {
    mtexts = [];
    string s = cast(string) std.file.read(the_file);

    // Check for well-formedness
    // check(s);

    auto xml = new DocumentParser (s);
    xml.onStartTag["TextRegion"] = (ElementParser xml) {
      Text t;

      t.id = xml.tag.attr["id"];
      t.type = xml.tag.attr["type"];

      xml.onEndTag["Point"] = delegate (in Element e) { 
        int x, y;
        x = to!int (xml.tag.attr["x"]);
        y = to!int (xml.tag.attr["y"]);
        t.points ~= Point (x,y); 
      };
      xml.onEndTag["Unicode"] = (in Element e) { t.content = e.text(); };

      xml.parse();

      mtexts ~= t;
    };

    xml.parse();
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
  Texts mtexts;
}

unittest {
  XmlText t = new XmlText;
  Texts tt;

  // Hard coded path for now...
  t.load_from_file ("../../data/318982.xml");
  tt = t.get_texts;

  writeln ("xmltext tests BEGIN...");
  assert (tt.length > 0);

  assert (tt[1].type == "paragraph");
  assert (tt[1].points.length == 314);
  writeln(tt[1].content);

  assert (tt[2].type == "catch-word");
  assert (tt[2].points.length == 8);
  writeln ("xmltext tests END...");
}
