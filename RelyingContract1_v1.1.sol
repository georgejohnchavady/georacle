pragma solidity ^0.4.25;
import "https://github.com/georgejohnchavady/georacle/blob/master/OracleContractv1.0.sol";
contract ExampleContract {

    event LogNewOracleQuery(string description);
    event LogNewOracleResponse(string response);
    event LogId(uint id);



    function updatePrice() payable public{
        //send 12 wei while creating contract instance
        address oracle_addr  = 0x189ef95f5e90c05e79f1be12b111108c96920389;
        Oracle oracle = Oracle(oracle_addr);
        string memory url = "https://api.pro.coinbase.com/products/ETH-USD/ticker";
        string memory attribute = "price";
        oracle.createRequest(false, url, attribute);
        emit LogNewOracleQuery("request triggered");
    }

    function __callback(uint id, string result) payable public{
        emit LogId(id);
        emit LogNewOracleResponse(result);
    }
}
