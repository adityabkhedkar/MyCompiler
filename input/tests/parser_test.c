// Test file for parser functionality
struct Point {
    int x;
    int y;
};

int add(int a, int b) {
    return a + b;
}

int main() {
    int x = 5;
    float y = 3.14;
    struct Point p;
    
    p.x = 10;
    p.y = 20;
    
    if (x > 0) {
        x = add(x, p.x);
    } else {
        x = 0;
    }
    
    while (x > 0) {
        x = x - 1;
    }
    
    return x;
}