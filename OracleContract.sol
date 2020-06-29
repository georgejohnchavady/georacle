pragma solidity ^0.4.25;

contract Oracle {
  Request[] requests; //list of requests made to the contract
  uint currentId = 0; //increasing request id
  uint minQtum = 2; //minimum number of responses to receive before declaring final result
  uint totalOracleCount = 3; // Hardcoded oracle count
  
  
  event NewRequest (uint id, string urlToQuery, string attributeToFetch);
  event UpdatedRequest(uint id, string urlToQuery, string attributeToFetch, string agreedValue);
  
  // defines a general api request
    struct Request {
      uint id;                          //request id
      string urlToQuery;                //API url
      string attributeToFetch;          //json attribute (key) to retrieve in the response
      string agreedValue;               //value from key
      mapping(uint => string) anwers;   //answers provided by the oracles
      mapping(address => uint) qtum;  //oracles which will query the answer (1=oracle hasn't voted, 2=oracle has voted)
    }
    
    function createRequest (string memory _urlToQuery, string memory _attributeToFetch) public{
      uint lenght = requests.push(Request(currentId, _urlToQuery, _attributeToFetch, ""));
      Request storage r = requests[lenght-1];
    
      // Hardcoded oracles address
      r.qtum[address(0xdD870fA1b7C4700F2BD7f44238821C26f7392148)] = 1;
      r.qtum[address(0x583031D1113aD414F02576BD6afaBfb302140225)] = 1;
      r.qtum[address(0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB)] = 1;
    
      // launch an event to be detected by oracle outside of blockchain
      emit NewRequest (currentId, _urlToQuery, _attributeToFetch);
    
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
          if(bytes(currRequest.anwers[tmpI]).length == 0){
            found = true;
            currRequest.anwers[tmpI] = _valueRetrieved;
          }
          tmpI++;
        }
    
        uint currentQtum = 0;
    
        //iterate through oracle list and check if enough oracles(minimum quorum)
        //have voted the same answer has the current one
        for(uint i = 0; i < totalOracleCount; i++){
          bytes memory a = bytes(currRequest.anwers[i]);
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
            }
          }
        }
      }
    }
    
}