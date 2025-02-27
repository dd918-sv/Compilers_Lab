// Variable declarations
int x;               // Global variable
float z = 3.14;      // Global variable
unsigned char a[10]; // Array declaration

// Function declarations and definitions
void myFunction(int param1, float param2) {
    int localVar = param1 * 2;
    float result = param2 / 2.0;

    // Selection statement
    if (localVar > 10) {
        result += 1.0;
    } else {
        result -= 1.0;
    }

    // Iteration statement (while loop)
    while (localVar > 0) {
        localVar--;
        if (localVar == 5) goto label;  // Jump statement (goto)
    }

    // Iteration statement (for loop)
    for (int i = 0; i < 10; i++) {
        a[i] = i;
    }

    // Switch statement
    switch (localVar) {
        case 0:
            printf("Local variable is zero.\n");
            break;
        case 1:
            printf("Local variable is one.\n");
            break;
        default:
            printf("Local variable is greater than one: %d\n", localVar);
            break;
    }

label:                          // Labeled statement
    printf("Jumped to label! Local variable: %d\n", localVar);
    return;
}


// Function with multiple return statements
int computeSum(int a, int b)
{
    int sum = a + b;
    if (sum > 100)
    {
        return sum - 100;
    }
    return sum;
}

// Main function to execute the program
int main()
{
    // Call to myFunction
    myFunction(5, 2.5);

    // Using computeSum
    int total = computeSum(x, z);

    // Testing various operators
    int a = 1, b = 1;
    a++;
    a--;
    a = a & b;
    a = a * b;
    a += b;
    a -= b;
    a = !b;
    a = ~b;
    a = a / b;
    a = a % b;
    a <<= 1;
    a >>= 1;
    a ^= b;
    a |= b;

    // Testing identifiers and constants
    short signed int number0 = 40;
    float f1_ = 23.56;
    float f2_ = 23.0E-2;
    float f3_ = 23.56e+3;
    float f4_ = 0.56E2;
    float f5_ = 232e3;
    char _1 = '$';
    char _2 = '\b';

    // Testing string literals
    char s[2] = "";                               // Empty string
    char str[] = "This is a test string\\\"\'\n"; // String with escape sequences

    // Return statement
    return 0;
}