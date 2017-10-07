#include <iostream>
#include <string>
#include <vector>
#include <map>
using namespace std;
#define print(a) cout << a << endl;


typedef struct User {
int id;
string email;
} User;
void dump(shared_ptr<User> user){
print(user->id);
print(user->email);
}
int main(){
shared_ptr<User> u = shared_ptr<User>(new User{
145, "jane@example.com"
});
dump(u);
}
