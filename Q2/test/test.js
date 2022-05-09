const assert = require("assert");
const { expect } = require("chai");
const { ethers } = require("hardhat");
const fs = require("fs");
const { groth16, plonk } = require("snarkjs");

function unstringifyBigInts(o) {
  if (typeof o == "string" && /^[0-9]+$/.test(o)) {
    return BigInt(o);
  } else if (typeof o == "string" && /^0x[0-9a-fA-F]+$/.test(o)) {
    return BigInt(o);
  } else if (Array.isArray(o)) {
    return o.map(unstringifyBigInts);
  } else if (typeof o == "object") {
    if (o === null) return null;
    const res = {};
    const keys = Object.keys(o);
    keys.forEach((k) => {
      res[k] = unstringifyBigInts(o[k]);
    });
    return res;
  } else {
    return o;
  }
}

describe("HelloWorld", function () {
  let Verifier;
  let verifier;

  beforeEach(async function () {
    // Retrieve compiled verification smart contract
    // and deploy it before each test
    Verifier = await ethers.getContractFactory("HelloWorldVerifier");
    verifier = await Verifier.deploy();
    await verifier.deployed();
  });

  it("Should return true for correct proof", async function () {
    //[assignment] Add comments to explain what each line is doing

    // Generate a witness for a set of inputs
    // also generate the public inputs/outputs based on the circuit (only public output in this case)
    const { proof, publicSignals } = await groth16.fullProve(
      { a: "1", b: "2" },
      "contracts/circuits/HelloWorld/HelloWorld_js/HelloWorld.wasm",
      "contracts/circuits/HelloWorld/circuit_final.zkey"
    );
    
    // Log publicSignal to stdout
    console.log("1x2 =", publicSignals[0]);

    // convert the public signal and proof to BigInt
    const editedPublicSignals = unstringifyBigInts(publicSignals);
    const editedProof = unstringifyBigInts(proof);
    
    // Generate parameters to call the verifier smart contract
    // Based on proof and public signals
    const calldata = await groth16.exportSolidityCallData(
      editedProof,
      editedPublicSignals
    );

    // format and split the calldata to their respective params 
    // so that they can be passed in accordingly
    const argv = calldata
      .replace(/["[\]\s]/g, "")
      .split(",")
      .map((x) => BigInt(x).toString());

    const a = [argv[0], argv[1]];
    const b = [
      [argv[2], argv[3]],
      [argv[4], argv[5]],
    ];
    const c = [argv[6], argv[7]];
    const Input = argv.slice(8);

    // verify proof from the verifier solidity contract
    expect(await verifier.verifyProof(a, b, c, Input)).to.be.true;
  });
  it("Should return false for invalid proof", async function () {
    let a = [0, 0];
    let b = [
      [0, 0],
      [0, 0],
    ];
    let c = [0, 0];
    let d = [0];
    expect(await verifier.verifyProof(a, b, c, d)).to.be.false;
  });
});

describe("Multiplier3 with Groth16", function () {
  let Verifier;
  let verifier;

  beforeEach(async function () {
    //[assignment] insert your script here
    // Retrieve compiled verification smart contract
    // and deploy it before each test
    Verifier = await ethers.getContractFactory("Multiplier3Verifier");
    verifier = await Verifier.deploy();
    await verifier.deployed();
  });

  it("Should return true for correct proof", async function () {
    //[assignment] insert your script here
    
    // Generate a witness for a set of inputs
    // also generate the public inputs/outputs based on the circuit (only public output in this case)
    const { proof, publicSignals } = await groth16.fullProve(
      { a: "1", b: "2", c: "3" },
      "contracts/circuits/Multiplier3/Multiplier3_js/Multiplier3.wasm",
      "contracts/circuits/Multiplier3/circuit_final.zkey"
    );

    console.log("1x2x3 =", publicSignals[0]);

    // construct the input parameters to solidity
    const editedPublicSignals = unstringifyBigInts(publicSignals);
    const editedProof = unstringifyBigInts(proof);
    const calldata = await groth16.exportSolidityCallData(
      editedProof,
      editedPublicSignals
    );

    // format and split the calldata to their respective params so that they can be passed 
    // into the verifyProof function accordingly
    const argv = calldata
      .replace(/["[\]\s]/g, "")
      .split(",")
      .map((x) => BigInt(x).toString());

    const a = [argv[0], argv[1]];
    const b = [
      [argv[2], argv[3]],
      [argv[4], argv[5]],
    ];
    const c = [argv[6], argv[7]];
    const Input = argv.slice(8);

    // verify proof from the verifier solidity contract
    expect(await verifier.verifyProof(a, b, c, Input)).to.be.true;
  });
  it("Should return false for invalid proof", async function () {
    //[assignment] insert your script here

    // give a fake proof
    let a = [0, 0];
    let b = [
      [0, 0],
      [0, 0],
    ];
    let c = [0, 0];
    let d = [0];
    expect(await verifier.verifyProof(a, b, c, d)).to.be.false;
  });
});

describe("Multiplier3 with PLONK", function () {
  let Verifier;
  let verifier;

  beforeEach(async function () {
    //[assignment] insert your script here
    // Retrieve compiled verification smart contract
    // and deploy it before each test
    Verifier = await ethers.getContractFactory("PlonkVerifier");
    verifier = await Verifier.deploy();
    await verifier.deployed();
  });

  it("Should return true for correct proof", async function () {
    //[assignment] insert your script here

    // Read pre-tested proof file and it's content
    let filename = "./contracts/circuits/build/Multiplier3_plonk/call.txt";
    var text = fs.readFileSync(filename, 'utf-8');
    
    // Extract Proof and Public Signals
    var calldata = text.split(',');
    
    // Make a call to the Solidity Verifier with the proof and public signals and check result
    expect(await verifier.verifyProof(calldata[0], JSON.parse(calldata[1]))).to.be.true;

    
  });
  it("Should return false for invalid proof", async function () {
    //[assignment] insert your script here
    
    // Create dummy proof values 
    const proofBytes = "0x00";
    const pubSignal = [BigInt(6)];
    
    // Make a call to the Solidity Verifier with the proof and public signals and check result
    expect(await verifier.verifyProof(proofBytes, pubSignal)).to.be.false;
  });
});