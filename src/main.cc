#include <iostream>

using namespace std;

// Defined by Bison-generated file
int yyparse();

// Universal header for outputted C++ programs
string HEADER =
    "#include <iostream>\n"
    "#include <string>\n"
    "#include <vector>\n"
    "#include <map>\n"
    "using namespace std;\n"
    "#define print(a) cout << a << endl;\n\n";

int main() {
    // Print header
    cout << HEADER << endl;

    // Parse (also prints program)
    yyparse();

    return 0;
}
