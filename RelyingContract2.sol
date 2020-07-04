pragma solidity ^0.4.25;
import "https://github.com/georgejohnchavady/georacle/blob/master/OracleContract.sol";
contract BettingContract {

    event LogNewOracleQuery(string description);



    function tossACoin() payable public{
        //send 12 wei while creating contract instance
        address oracle_addr  = 0x8D1EaE39aAA701568b094dF721B5c34528668Fd1;
        Oracle oracle = Oracle(oracle_addr);
        string memory url = "https://www.wolframalpha.com/input";
        string memory attribute = "toss a coin";
        oracle.createRequest(url, attribute);
        emit LogNewOracleQuery("request triggered");
    }
}
//contract address - 0x3fde321809ef049127111dccc1c83234632ca0f9
