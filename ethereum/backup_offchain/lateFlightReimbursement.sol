pragma solidity ^0.4.25;
contract LateFlightReimbursement{
    uint256 public scheduledDepartureTime;
    uint256 public actualDepartureTime;
    bool public flag;
    address owner;
    address  insured;
    uint256 public ownerBalance;

    constructor(address wallet) public payable {
         flag=false;
         owner=msg.sender;
         ownerBalance=owner.balance;
         insured=wallet;}

    function setScheduledDepartureTime(uint256 _scheduledDepartureTime) public {
        scheduledDepartureTime=_scheduledDepartureTime;}

    function setActualDepartureTime(uint256 _actualDepartureTime) public payable{
        actualDepartureTime=_actualDepartureTime;
        if(actualDepartureTime>scheduledDepartureTime){
                insured.transfer(msg.value);
                flag=true;
                ownerBalance=owner.balance;
        }
        else
            flag = false;
    }

}

