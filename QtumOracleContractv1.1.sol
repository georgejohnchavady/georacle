pragma solidity ^0.4.25;

contract Oracle {
  Request[] requests; //list of requests made to the contract
  uint currentId = 0; //increasing request id
  uint minQtumOracles = 2; //minimum number of responses to receive before declaring final result
  uint totalQtumOracles = 3; // Hardcoded oracle count


  event oracleQuery (bool flag, uint id, string source, string attribute);
  event updateQuery(uint id, string source, string attribute, string finalOutcome);

  // defines a general api request
    struct Request {
      bool api;
      uint id;                          //request id
      string source;                //source url
      string attribute;          //json attribute (key) to retrieve in the response
      address contractAddress;          // address of the contract to return the value
      string finalOutcome;               //value from key
      mapping(uint => string) outcomes;   //outcomes provided by the oracles
      mapping(address => uint) qtum;  //0=oracle hasn't voted, 1=oracle has voted
    }

    function callback(uint id, string result) payable public{

    }

    function oracleQuery(bool _flag, string memory _source, string memory _attribute) public payable{

      uint length = requests.push(Request(_flag, currentId, _source, _attribute, msg.sender,""));
      Request storage r = requests[length-1];

      //Qtum oracle addresses
      r.qtum[address(qSii6LL4yjedo25oi2VjEDFKkGQKKekB3S)] = 0;
      r.qtum[address(qHjKMZ9qQMT7uhotZq8tMYJ2531PfHJ6et)] = 0;
      r.qtum[address(qaPW1ZUg7eTsMM6SrcLXWTJs42d8KGvPvq)] = 0;

      // emit an event to be accessed by the off-chain component
      emit oracleQuery(_flag, currentId, _source, _attribute);

      // increase request id
      currentId++;
    }

    function updateQuery(uint _id, string memory _outcome) public {

      Request storage currentQuery = requests[_id];

      //check if oracle hasn't voted and is in the list of trusted oracles
      if(currentQuery.qtum[address(msg.sender)] == 0){

        //marking that this address has voted
        currentQuery.qtum[msg.sender] = 1;
        uint count = 0;
        bool found = false;
        while(!found) {
          if(bytes(currentQuery.outcomes[count]).length == 0){
            found = true;
            currentQuery.outcomes[count] = _outcome;
          }
          count++;
        }

        uint currentQtum = 0;

        //icheck if k out of n oracles have reported
        for(uint i = 0; i < totalQtumOracles; i++){
          bytes memory oracleEntry = bytes(currentQuery.outcomes[i]);
          bytes memory outcome = bytes(_outcome);

          if(keccak256(oracleEntry) == keccak256(outcome)){
            currentQtum++;
            if(currentQtum >= minQtumOracles){
              currentQuery.finalOutcome = _outcome;
              emit updateQuery (
                currentQuery.id,
                currentQuery.source,
                currentQuery.attribute,
                currentQuery.finalOutcome
              );

              Oracle relyingContract = Oracle(currentQuery.contractAddress);
              relyingContract.callback(currentQuery.id, currentQuery.finalOutcome);
            }
          }
        }
      }
    }
}
