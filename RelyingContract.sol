pragma solidity ^0.4.25;
import "https://github.com/georgejohnchavady/georacle/blob/master/OracleContract.sol";
contract ExampleContract {

    event LogNewOracleQuery(string description);



    function updatePrice() payable public{
        //send 12 wei while creating contract instance
        address oracle_addr  = 0x8D1EaE39aAA701568b094dF721B5c34528668Fd1;
        Oracle oracle = Oracle(oracle_addr);
        string memory url = "https://api.pro.coinbase.com/products/ETH-USD/ticker";
        string memory attribute = "price";
        oracle.createRequest(url, attribute);
        emit LogNewOracleQuery("request triggered");
    }
}
