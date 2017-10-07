type User = {
    int id;
    string email;
};

void dump(User user) {
    print(user.id);
    print(user.email);
}

int main() {
    User u = User{145, "jane@example.com"};
    dump(u);
}
