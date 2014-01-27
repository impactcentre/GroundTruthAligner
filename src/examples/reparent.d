// gdc -I/usr/include/dmd/gtkd2 reparent.d -o reparent -lgtk-3 -L ~/Descargas/gtkd -l gtkd-2 -ldl

module reparent;

import gtk.Builder;
import gtk.Button, gtk.Entry, 
  gtk.ImageMenuItem, gtk.Box;
import gtk.Main;
import gtk.Widget;
import gtk.Window;

import gobject.Type;

import std.stdio;
import std.c.process;



/**
 * Class AppWindow:
 *
 */
class AppWindow : Window {
  
public:
  
  /////////////////
  // Constructor //
  /////////////////
  this (string gladefile) {

    _gf = gladefile;

    writeln ("Calling load_ui.");
    load_ui ();

    writeln ("Calling super.");
    super ("App Window");

    writeln ("Calling prepare_ui.");
    prepare_ui ();

  }
  
  /////////////////
  // Destructor  //
  /////////////////
  ~this () {
    writeln ("Destroying AppWindow!");
  }

  // The callback
  void show_text (Button b) { 
    writefln ("[%s]", _e.getText ()); 
  }

private:

  /**
   * UI loading:
   * This function loads the UI from the glade file.
   */
  void load_ui () {
    _b = new Builder();

    if( !_b.addFromFile (_gf) )
      {
	writefln("Oops, could not create Glade object, check your glade file ;)");
	exit(1);
      }
  }

  void prepare_ui () {
    Box b1 = cast(Box) _b.getObject("box1");

    if (b1 !is null) {
      setTitle("This is a glade window");
      //w.addOnHide( delegate void(Widget aux){ exit(0); } );
      addOnHide( delegate void(Widget aux){ Main.quit(); } );

      _e = cast(Entry) _b.getObject("wentry_text");

      _bq = cast(Button) _b.getObject("wbutton_quit");
      if(_bq !is null) {
	//b.addOnClicked( delegate void (Button) { Main.quit(); }  );
	_bq.addOnClicked( (b) =>  Main.quit()  );
      }

      _bs = cast(Button) _b.getObject("wbutton_show");
      //if(_bs !is null) _bs.addOnClicked( (b) =>  show_text(b)  );
      if(_bs !is null) _bs.addOnClicked( delegate void (Button b) {show_text(b);}  );

      _imi = cast(ImageMenuItem) _b.getObject("wmenuitem_quit");
      if (_imi !is null) _imi.addOnActivate ( (mi) => Main.quit() );

      //b1.reparent (cast(Widget) this);
      //alias this Widget;
      //alias Widget = this;
      b1.reparent ( this );

      setResizable (false);
      showAll();
    }
    else
      {
	writefln("No window?");
	exit(1);
      }
  }
  
  /////////////////////
  // Class invariant //
  /////////////////////
  invariant () {
    writeln ("\tChecking invariant.");
    assert (_b !is null, "Builder is null!!");
  }
  
  //////////
  // Data //
  //////////
  Builder _b;
  string _gf;
  Entry _e;
  Button _bq;
  Button _bs;
  ImageMenuItem _imi;
}


/**
 * Usage ./gladeText /path/to/your/glade/file.glade
 *
 */
int main(string[] args)
{
  string gladefile;

  Main.init(args);

  if(args.length > 1)
    {
      writefln("Loading %s", args[1]);
      gladefile = args[1];
    }
  else
    {
      writefln("No glade file specified, using default \"app.glade\"");
      gladefile = "app.glade";
    }

  scope auto app = new AppWindow (gladefile);
  Main.run();

  return 0;
}
