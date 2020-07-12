pragma solidity ^0.4.25;

contract Oracle {
  Request[] requests; //list of requests made to the contract
  uint currentId = 0; //increasing request id
  uint minQtum = 2; //minimum number of responses to receive before declaring final result
  uint totalOracleCount = 3; // Hardcoded oracle count


  event NewRequest (bool apiFlag, uint id, string urlToQuery, string attributeToFetch);
  event UpdatedRequest(uint id, string urlToQuery, string attributeToFetch, string agreedValue);

  // defines a general api request
    struct Request {
      bool api;
      uint id;                          //request id
      string urlToQuery;                //API url
      string attributeToFetch;          //json attribute (key) to retrieve in the response
      address contractAddress;          // address of the contract to return the value
      string agreedValue;               //value from key
      mapping(uint => string) answers;   //answers provided by the oracles
      mapping(address => uint) qtum;  //oracles which will query the answer (1=oracle hasn't voted, 2=oracle has voted)
    }

    function callback(uint id, string result) payable public{

    }

    function createRequest (bool _apiFlag, string memory _urlToQuery, string memory _attributeToFetch) public payable{

      uint length = requests.push(Request(_apiFlag, currentId, _urlToQuery, _attributeToFetch, msg.sender,""));
      Request storage r = requests[length-1];

      // Hardcoded oracles address
      r.qtum[address(0x06517087a60E27621C67FE9221CF0327c0d057f0)] = 1;
      r.qtum[address(0x67f4A64D18B549f5C218fb7A0Ce358af34304510)] = 1;
      r.qtum[address(0x46c18280FBc55ba665177416f316ae151f1baEba)] = 1;

      // launch an event to be detected by oracle outside of blockchain
      emit NewRequest (_apiFlag, currentId, _urlToQuery, _attributeToFetch);

      // increase request id
      currentId++;
    }

    function updateRequest (uint _id, string memory _valueRetrieved) public {

      Request storage currRequest = requests[_id];

      //check if oracle is in the list of trusted oracles
      //and if the oracle hasn't voted yet
      if(currRequest.qtum[address(msg.sender)] == 1){

        //marking that this address has voted
        currRequest.qtum[msg.sender] = 2;

        //iterate through "array" of answers until a position if free and save the retrieved value
        uint tmpI = 0;
        bool found = false;
        while(!found) {
          //find first empty slot
          if(bytes(currRequest.answers[tmpI]).length == 0){
            found = true;
            currRequest.answers[tmpI] = _valueRetrieved;
          }
          tmpI++;
        }

        uint currentQtum = 0;

        //iterate through oracle list and check if enough oracles(minimum quorum)
        //have voted the same answer has the current one
        for(uint i = 0; i < totalOracleCount; i++){
          bytes memory a = bytes(currRequest.answers[i]);
          bytes memory b = bytes(_valueRetrieved);

          if(keccak256(a) == keccak256(b)){
            currentQtum++;
            if(currentQtum >= minQtum){
              currRequest.agreedValue = _valueRetrieved;
              emit UpdatedRequest (
                currRequest.id,
                currRequest.urlToQuery,
                currRequest.attributeToFetch,
                currRequest.agreedValue
              );
              //require(currRequest.contractAddress.call(bytes4(keccak256("__callback(uint, string)")), currRequest.id, currRequest.agreedValue));
              Oracle relyingContract = Oracle(currRequest.contractAddress);
              relyingContract.callback(currRequest.id, currRequest.agreedValue);
            }
          }
        }
      }
    }

}
