pragma solidity ^0.4.25;

contract myContract {

   string fName;
   uint age;

   function setAccount(string _fName, uint _age) public {
       fName = _fName;
       age = _age;
   }

   function getAccount() public constant returns (string, uint) {
       return (fName, age);
   }

}
