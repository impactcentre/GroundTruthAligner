import std.xml;
import std.stdio;
import std.string;
import std.file;
import std.conv;

// books.xml is used in various samples throughout the Microsoft XML Core
// Services (MSXML) SDK.
//
// See http://msdn2.microsoft.com/en-us/library/ms762271(VS.85).aspx

struct Point {
  int x;
  int y;
}

struct Text {
  string  id;
  string  the_type;
  Point[] points;
  string  the_content;
}

void main(string[] args)
{

  if(args.length > 1) {
    writefln("Loading %s", args[1]);
    string s = cast(string) std.file.read(args[1]);

    // Check for well-formedness
    // check(s);

    Text[] texts;

    auto xml = new DocumentParser(s);
    xml.onStartTag["TextRegion"] = (ElementParser xml) {
      Text t;

      t.id = xml.tag.attr["id"];
      t.the_type = xml.tag.attr["type"];

      xml.onEndTag["Point"] = (in Element e) { 
	int x, y;
	x = to!int (xml.tag.attr["x"]);
	y = to!int (xml.tag.attr["y"]);
	t.points ~= Point (x,y); 
      };
      xml.onEndTag["Unicode"] = (in Element e) { t.the_content = e.text(); };

      xml.parse();

      texts ~= t;
    };
    xml.parse();

    // Plain-print it

    writefln ("Read %d texts.\n****************\n", texts.length);
    foreach (t ; texts) {
      writefln ("\nID: [%s] - TYPE: [%s] - Points: [%s] - Content:\n%s\n ++++++++++++++++ \n",
		t.id, t.the_type, t.points.length, t.the_content);
      foreach (p ; t.points)
	writefln ("X=[%s], Y=[%s]", p.x, p.y);
      writeln ("=================");
    }
  } else
    writeln ("Uso: xmlprocess file.xml");
}
