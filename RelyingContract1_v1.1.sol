pragma solidity ^0.4.25;
import "https://github.com/georgejohnchavady/georacle/blob/master/OracleContractv1.0.sol";
contract ExampleContract {

    event LogNewOracleQuery(string description);

    event LogNewOracleResponse(uint id, string response);


    function updatePrice() payable public{
        //send 12 wei while creating contract instance
        address oracle_addr  = 0xA6DF3F81d2Ac0C773aC2dC8bb22b50973d5D0059;
        Oracle oracle = Oracle(oracle_addr);
        string memory url = "https://api.pro.coinbase.com/products/ETH-USD/ticker";
        string memory attribute = "price";
        oracle.createRequest(false, url, attribute);
    }

    function __callback(uint id, string result) payable public{
        emit LogNewOracleResponse(id, result);
    }
}
