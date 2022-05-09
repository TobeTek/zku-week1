#!/bin/bash

#export NODE_OPTIONS="--max-old-space-size=16384"

cd contracts/circuits

if [ -f ./powersOfTau28_hez_final_16.ptau ]; then
    echo "powersOfTau28_hez_final_16.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_16.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_16.ptau
fi

CIRCUIT_NAME=$1
if [[ ! -z $1 ]] 
then 
    CIRCUIT_NAME=$1
    echo "Compiling circuit: $CIRCUIT_NAME" 
else
    CIRCUIT_NAME="LessThan10"
    echo "Not set, using default: $CIRCUIT_NAME"
fi 

mkdir -p "./build/$CIRCUIT_NAME"

# compile circuit

if [ -f "./build/$CIRCUIT_NAME/$CIRCUIT_NAME.r1cs" ]; then
    echo "Circuit already compiled. Skipping."
else
    circom "$CIRCUIT_NAME.circom" --r1cs --wasm --sym -o "build/$CIRCUIT_NAME"
    snarkjs r1cs info "build/$CIRCUIT_NAME/$CIRCUIT_NAME.r1cs"
fi

# Start a new zkey and make a contribution

if [ -f "./build/$CIRCUIT_NAME/verification_key.json" ]; then
    echo "verification_key.json already exists. Skipping."
else
    snarkjs plonk setup "build/$CIRCUIT_NAME/$CIRCUIT_NAME.r1cs" powersOfTau28_hez_final_16.ptau "build/$CIRCUIT_NAME/circuit_final.zkey" #circuit_0000.zkey
    #snarkjs zkey contribute build/sudoku/circuit_0000.zkey build/sudoku/circuit_final.zkey --name="1st Contributor Name" -v -e="random text"
    snarkjs zkey export verificationkey "build/$CIRCUIT_NAME/circuit_final.zkey" "build/$CIRCUIT_NAME/verification_key.json"
fi

# generate solidity contract
snarkjs zkey export solidityverifier "build/$CIRCUIT_NAME/circuit_final.zkey" "build/$CIRCUIT_NAME/verifier.sol"