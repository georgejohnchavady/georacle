pragma solidity ^0.4.25;
import "https://github.com/georgejohnchavady/georacle/blob/master/OracleContractv1.1.sol";
contract BettingContract {

    event LogNewOracleQuery(string description);



    function tossACoin() payable public{
        //send 12 wei while creating contract instance
        address oracle_addr  = 0x8D1EaE39aAA701568b094dF721B5c34528668Fd1;
        Oracle oracle = Oracle(oracle_addr);
        string memory url = "https://www.wolframalpha.com/input";
        string memory attribute = "toss a coin";
        oracle.createRequest(false, url, attribute);
        emit LogNewOracleQuery("request triggered");
    }
}
//oracle contract address - 0xCfa03766fa8a3d8C6521Dca5Af3f6B7D63645300
