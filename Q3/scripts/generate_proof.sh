#!/bin/bash

cd contracts/circuits

CIRCUIT_NAME=$1

if [[ ! -z $1 ]] 
then 
    CIRCUIT_NAME=$1
    echo "Compiling circuit: $CIRCUIT_NAME" 
else
    CIRCUIT_NAME="LessThan10"
    echo "Not set, using default: $CIRCUIT_NAME"
fi 

mkdir -p "build/$CIRCUIT_NAME"

# generate witness
node "build/$CIRCUIT_NAME/$CIRCUIT_NAME""_js/generate_witness.js" "build/$CIRCUIT_NAME/$CIRCUIT_NAME""_js/$CIRCUIT_NAME.wasm" input.json "build/$CIRCUIT_NAME/witness.wtns"
        
# generate proof
snarkjs plonk prove "build/$CIRCUIT_NAME/circuit_final.zkey" "build/$CIRCUIT_NAME/witness.wtns" "build/$CIRCUIT_NAME/proof.json" "build/$CIRCUIT_NAME/public.json"

# verify proof
snarkjs plonk verify "build/$CIRCUIT_NAME/verification_key.json" "build/$CIRCUIT_NAME/public.json" "build/$CIRCUIT_NAME/proof.json"

# generate call
snarkjs zkey export soliditycalldata "build/$CIRCUIT_NAME/public.json" "build/$CIRCUIT_NAME/proof.json" > "build/$CIRCUIT_NAME/call.txt"