pragma solidity ^0.4.25;
import "https://github.com/georgejohnchavady/georacle/blob/master/OracleContractv1.0.sol";
contract ExampleContract {

    event LogNewOracleQuery(string description);



    function updatePrice() payable public{
        //send 12 wei while creating contract instance
        address oracle_addr  = 0xCfa03766fa8a3d8C6521Dca5Af3f6B7D63645300;
        Oracle oracle = Oracle(oracle_addr);
        string memory url = "https://api.pro.coinbase.com/products/ETH-USD/ticker";
        string memory attribute = "price";
        oracle.createRequest(true, url, attribute);
        emit LogNewOracleQuery("request triggered");
    }
}
//oracle contract address - 0xCfa03766fa8a3d8C6521Dca5Af3f6B7D63645300
