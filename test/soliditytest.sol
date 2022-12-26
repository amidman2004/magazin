//SPDX-License-Identifier:UNLICENSED

pragma solidity ^0.8.0;


enum ExampleEnum{a,b,c,d}
contract Test {

    mapping(uint => string) public example;


    function push(uint index,string memory value) public {
        example[index] = value;
    }

    function get() public pure returns (ExampleEnum){
        return ExampleEnum.a;
    }
}
