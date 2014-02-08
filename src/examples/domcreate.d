import std.xml;
import std.stdio;
import std.string;
import std.file;

// books.xml is used in various samples throughout the Microsoft XML Core
// Services (MSXML) SDK.
//
// See http://msdn2.microsoft.com/en-us/library/ms762271(VS.85).aspx

void main()
{
    string s = cast(string)std.file.read("books.xml");

    // Check for well-formedness
    check(s);

    // Make a DOM tree
    auto doc = new Document(s);

    // Plain-print it
    writeln(doc);
}
