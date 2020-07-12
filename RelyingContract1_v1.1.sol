pragma solidity ^0.4.25;
import "https://github.com/georgejohnchavady/georacle/blob/master/OracleContractv1.1.sol";
contract ExampleContract is Oracle{

    event LogNewOracleQuery(string description);

    event LogNewOracleResponse(uint id, string response);


    function updatePrice() payable public{
        //send 12 wei while creating contract instance
        address oracle_addr  = 0xcBFF55037620fB1797ea4Da6a293947387267e74;
        Oracle oracle = Oracle(oracle_addr);
        string memory url = "https://api.pro.coinbase.com/products/ETH-USD/ticker";
        string memory attribute = "price";
        oracle.createRequest(true, url, attribute);
    }

    function callback(uint id, string result) payable public{
        emit LogNewOracleResponse(id, result);
    }
}
