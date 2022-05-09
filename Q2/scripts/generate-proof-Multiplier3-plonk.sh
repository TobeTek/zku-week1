#!/bin/bash

cd contracts/circuits

echo "Generating proof for : Multiplier3 (PLONK)" 


mkdir -p build/Multiplier3_plonk 

# generate witness
node Multiplier3_plonk/Multiplier3_js/generate_witness.js Multiplier3_plonk/Multiplier3_js/Multiplier3.wasm input.json ./build/Multiplier3_plonk/witness.wtns
        
# generate proof
snarkjs plonk prove Multiplier3_plonk/circuit_final.zkey ./build/Multiplier3_plonk/witness.wtns ./build/Multiplier3_plonk/proof.json ./build/Multiplier3_plonk/public.json

# verify proof
snarkjs plonk verify Multiplier3_plonk/verification_key.json ./build/Multiplier3_plonk/public.json ./build/Multiplier3_plonk/proof.json

# generate call
snarkjs zkey export soliditycalldata build/Multiplier3_plonk/public.json ./build/Multiplier3_plonk/proof.json > ./build/Multiplier3_plonk/call.txt