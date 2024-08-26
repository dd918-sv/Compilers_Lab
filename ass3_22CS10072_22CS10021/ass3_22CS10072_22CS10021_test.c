/*
   Multi-line comment
   Testing various tokens including
   keywords, identifiers, constants,
   string literals, punctuators, and more.
*/


volatile float y = 3.14f;  
// This a single line comment
auto int x = 42;   
char c = 'z';   
char* str = "This is a string\nwith escape sequences";  

int* arr[10];   
struct Point {  
    int x, y;
};

union Data {  
    int i;
    float f;
    char str[20];
};

enum Colors {RED, GREEN, BLUE};  

void func(int a, float b) { 
    a += 10;   
    b *= 2.5;  
    if (a > 100 || b < 50.0) { 
        return;  
    } else {  
        while (a--) {  
            arr[a] = &a; 
        }
    }
}

int main() {
    struct Point p1 = {0, 1};
    union Data d1;
    d1.i = 100;
    d1.f = 220.5;
    int color = GREEN;  
    for (int i = 0; i < 10; i++) {
        func(i, (float)i / 2.0);  
    }
    int max = (p1.x > p1.y) ? p1.x : p1.y;

    return 0;  
}