pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib-matrix/circuits/matMul.circom"; // hint: you can use more than one templates in circomlib-matrix to help you

template SystemOfEquations(n) { // n is the number of variables in the system of equations
    signal input x[n]; // this is the solution to the system of equations
    signal input A[n][n]; // this is the coefficient matrix
    signal input b[n]; // this are the constants in the system of equations
    signal output out; // 1 for correct solution, 0 for incorrect solution

    // [bonus] insert your code here

    // Multiply A * x = b
    // Ensure final value Ax == b

    component matrixMultiplier = matMul(1,n,n);

    for(var j=0; j<n; j++){
        matrixMultiplier.a[0][j] <== x[j];

        for(var i=0; i<n; i++){
            matrixMultiplier.b[i][j] <== A[i][j];
            
        }
    }
    
    component equalityChecker[n];
    
    for(var i=0; i<n; i++){
        equalityChecker[i] = IsEqual();
    }
    
    component compileIsEqual[n];

    for(var i=0; i<n; i++){
        compileIsEqual[i] = IsEqual();
    }

    for(var i=0; i<n; i++){
        equalityChecker[i].in[0] <== matrixMultiplier.out[0][i];
        equalityChecker[i].in[1] <== b[i];
    }
    
    // indx 0 = 1 AND equalityChecker 0
    // indx 1 = compileIsEqual 0 and equalityChecker1
    // indx 2 = compileIsEqual 0 and equalityChecker2
    // indx 3 = compileIsEqual 0 and equalityChecker3
    // indx 4 = compileIsEqual 0 and equalityChecker4
    // indx 5 = compileIsEqual 0 and equalityChecker5

    compileIsEqual[0].in[0] <== 1;
    compileIsEqual[0].in[1] <== equalityChecker[0].out;

    for(var i=1; i<n; i++){
        compileIsEqual[i].in[0] <== compileIsEqual[i-1].out;
        compileIsEqual[i].in[1] <== equalityChecker[i].out;    
    }

    out <== compileIsEqual[n-1].out;
    
}

component main {public [A, b]} = SystemOfEquations(3);