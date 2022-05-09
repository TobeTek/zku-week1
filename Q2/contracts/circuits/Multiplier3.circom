pragma circom 2.0.0;

// [assignment] Modify the circuit below to perform a multiplication of three signals

template Multiplier3 () {  

   // Declaration of signals.  
   signal input a;  
   signal input b;
   signal input c;
   signal output d;  
   signal inter;

   inter <== a * b;
   // Constraints.  
   d <== inter * c; 

   // How did I solve it?
   // I made use of an intermediate signal to avoid triggering the quadratic limit exception
    
}

component main = Multiplier3();