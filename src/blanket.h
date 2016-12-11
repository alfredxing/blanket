#include <iostream>
#include <string>
#include <vector>
#include <map>

using namespace std;

#define print(a) cout << a << endl;
#define type(T, A) typedef A T;

template<typename T> using Array = vector<T>;
template<typename K, typename V> using Map = map<K, V>;

