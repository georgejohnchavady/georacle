pragma solidity ^0.4.25;
import "https://github.com/georgejohnchavady/georacle/blob/master/OracleContractv1.0.sol";
contract ExampleContract {

    event LogNewOracleQuery(string description);



    function updatePrice() payable public{
        //send 12 wei while creating contract instance
        address oracle_addr  = 0x3A821dbB80d68621F02D2C826FEADAE77F25a976;
        Oracle oracle = Oracle(oracle_addr);
        string memory url = "https://api.pro.coinbase.com/products/ETH-USD/ticker";
        string memory attribute = "price";
        oracle.createRequest(false, url, attribute);
    }
}
