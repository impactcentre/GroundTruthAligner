
module mvc.set;

/// Unordered array with O(1) insertion and removal
/// Unordered array with O(1) insertion and removal
struct Set(T)
{
  bool[T] data;

  /// Append 'item' to the set
  void opOpAssign (string op)(T item)
    if (op == "~") {
      if (item !in data)
	data[item] = true;
    }

  /// Checks if item in Set
  bool opBinaryRight (string op) (T item)
    if (op == "in") {
      return contains (item);
    }

  /// Checks if Set contains item
  bool contains (T item) {
    return (item in data) != null;
  }

  void remove(T item) {
    data.remove(item);
  }

  @property bool[T] items() {
    return data;
  }
}

/// For playing with gdc -funittest
version (unittest) int main(string[] args) { return 0; }

unittest
{
  import std.stdio;

  Set!int s;
  Set!string s2;
  
  //  writefln ("BEFORE length=%s set [%s]", s.data.length. s.data);

  s ~= 1;
  s ~= 2;
  s ~= 3;

  if (s.contains (2))
    writeln ("Set contains 2.");
  else
    writeln ("Set does not contain 2.");

  if (s.contains (4))
    writeln ("Set contains 4.");
  else
    writeln ("Set does not contain 4.");

  s2 ~= "hola";
  s2 ~= "adios";

  if (s2.contains ("bhola"))
    writeln ("Set contains 'bhola'.");
  else
    writeln ("Set does not contain 'bhola'.");

  if ("bhola" in s2)
    writeln ("'bhola' in Set.");
  else
    writeln ("'bhola' not in Set.");

  s2.remove ("thola");
  if (s2.contains ("hola"))
    writeln ("After removing it Set contains 'hola'.");
  else
    writeln ("After removing it Set does not contain 'hola'.");

  
  writefln ("AFTER length=%s set [%s]", s2.data.length, s2.data);
}
