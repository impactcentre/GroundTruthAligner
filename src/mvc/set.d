
module mvc.set;

struct Set(T)
{
  bool[T] data;

  /// Append 'item' to the set
  void opOpAssign (string op)(T item)
    if (op == "~") {
      if (item !in data)
	data [item] = true;
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

  /// Removes item from the set.
  void remove(T item) {
    data.remove(item);
  }

  /// Provides access to the underlying storage.
  @property bool[T] items() {
    return data;
  }

  /// Foreach support with only value (bool)...
  int opApply(int delegate(ref bool) dg)
  {
    int result;

    foreach (i; data) {
      result = dg(i);

      if (result) {
	break;
      }
    }

    return result;
  }

  /// Foreach support with key (T) and value (bool)...
  int opApply(int delegate(ref T, ref bool) dg)
  {
    int result;

    foreach (k, i; data) {
      result = dg(k,i);

      if (result) {
	break;
      }
    }

    return result;
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

  foreach ( i ; s) 
    writefln ("s[i] = %s", i);

  foreach ( k, i ; s) 
    writefln ("s[%s] = %s", k, i);

  if (s.contains (2))
    writeln ("Set contains 2.");
  else
    writeln ("Set does not contain 2.");

  if (s.contains (4))
    writeln ("Set contains 4.");
  else
    writeln ("Set does not contain 4.");

  s2 ~= "hola";
  s2 ~= "hola";
  s2 ~= "adios";
  s2 ~= "adios";
  s2 ~= "adios";
  s2 ~= "adios";

  if (s2.contains ("bhola"))
    writeln ("Set contains 'bhola'.");
  else
    writeln ("Set does not contain 'bhola'.");

  if ("bhola" in s2)
    writeln ("'bhola' in Set.");
  else
    writeln ("'bhola' not in Set.");

  s2.remove ("hola");
  if (s2.contains ("hola"))
    writeln ("After removing 'hola' Set contains 'hola'.");
  else
    writeln ("After removing 'hola' Set does not contain 'hola'.");

  
  writefln ("AFTER length=%s set %s", s2.data.length, s2.data);
}
