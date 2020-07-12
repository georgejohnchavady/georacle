var http = require('http');
var fs = require('fs');
const Web3 = require('web3');
const https = require('https');
var Tx = require('ethereumjs-tx');
var Infiniteloop = require('infinite-loop');

const {Client} = require('pg')
let client = new Client({
  user: 'admin',
  host: 'localhost',
  database: 'oraclesquare',
  password: 'admin',
  port: 5432,
});


client.connect();


const web3 = new Web3(new Web3.providers.HttpProvider("https://ropsten.infura.io/v3/8a20eb34182e4ddabd54630bcea55eb7"));
const sender = '0x46c18280FBc55ba665177416f316ae151f1baEba';
const senderPrivateKey = Buffer.from('A9C678D92C65A218C12CD942B6B2F3A0008A6C94A01F21595B0AFC48639E14D0','hex');

//add the oracle account as default account. Note: it is not the contract account
web3.eth.Contract.defaultAccount='0x46c18280FBc55ba665177416f316ae151f1baEba';
abi = [
    {
        "constant": false,
        "inputs": [
            {
                "name": "_apiFlag",
                "type": "bool"
            },
            {
                "name": "_urlToQuery",
                "type": "string"
            },
            {
                "name": "_attributeToFetch",
                "type": "string"
            }
        ],
        "name": "createRequest",
        "outputs": [],
        "payable": true,
        "stateMutability": "payable",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "_id",
                "type": "uint256"
            },
            {
                "name": "_valueRetrieved",
                "type": "string"
            }
        ],
        "name": "updateRequest",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "apiFlag",
                "type": "bool"
            },
            {
                "indexed": false,
                "name": "id",
                "type": "uint256"
            },
            {
                "indexed": false,
                "name": "urlToQuery",
                "type": "string"
            },
            {
                "indexed": false,
                "name": "attributeToFetch",
                "type": "string"
            }
        ],
        "name": "NewRequest",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "id",
                "type": "uint256"
            },
            {
                "indexed": false,
                "name": "urlToQuery",
                "type": "string"
            },
            {
                "indexed": false,
                "name": "attributeToFetch",
                "type": "string"
            },
            {
                "indexed": false,
                "name": "agreedValue",
                "type": "string"
            }
        ],
        "name": "UpdatedRequest",
        "type": "event"
    }
];
//address of the oracle contract
var oracleContracAddress = '0x21e3aDF90013ab2ecAC1e47e605339e5FE5A2233';
var oracleContract =  new web3.eth.Contract(abi, oracleContracAddress);
var eventlist = [];
var eventsFromDB = [];
var request_list = [];
var apiData;
var apiDataField;
var id;
var responseStatus;
var oracleData;
var duplicateRecordsList = [];

/*var loop = new Infiniteloop();
//use loop.add to add a function
//fisrt argument should be the fn, the rest is the fn's arguments
loop.add(getRequests);
//make it run
loop.run();*/

setInterval(polling, 5000);


function polling(){

    console.log('-----------------------------------------------------------------------------------------');
    console.log('-----------------------------------------------------------------------------------------');

    oracleContract.getPastEvents(
        //'AllEvents',
        'NewRequest',
        {
            fromBlock: 0,
            toBlock: 'latest'
        },
        (err, events) => {
        eventlist=events;
        //printing all the events
        // console.log(eventlist);

        });

        //request that have the true flag
        request_list= aggregateRequests();
        console.log('request list :', request_list);


        getEventsFromDB();
        if(eventsFromDB.length==0){
            for(i=0;i<request_list.length;i++){
                    initEventDB(request_list[i][0], request_list[i][1], request_list[i][2], true);
            }
        }

        for(i=0;i<request_list.length;i++){
            var flag = false;
            for(j=0;j<eventsFromDB.length;j++){

                if(request_list[i][0]!=null){
                    if(request_list[i][0]==eventsFromDB[j].id && eventsFromDB[j].granted_3==true){
                        flag = true;
                        break;
                    }
                }}

                //insert row into requests table with granted = false -> create api request and send signed transaction -> update granted to true
                if(eventsFromDB.length!=0){
                    if(flag==false){
                        console.log(request_list[i][0]);
                        id = request_list[i][0];
                        apiDataField = request_list[i][2];
                        console.log('api data field: ', apiDataField);
                        duplicateRecords(id)
                        if(duplicateRecordsList.length>0)
                            insertDuplicateEventDB(id);
                        else
                            insertEventDB(request_list[i][0], request_list[i][1], request_list[i][2], true, false,);
                        https.get(request_list[i][1], (res) => {
                            responseStatus = res.statusCode;
                            console.log('statusCode:', res.statusCode);

                            res.on('data', function(body){
                                apiData='';
                                if(responseStatus==200)
                                    apiData += body;
                            });

                            // The whole response has been received. Print out the result.
                            res.on('end', () => {
                                console.log('explanation: ');
                                //var response = JSON.stringify(apiData);
                                if(responseStatus==200){
                                    console.log((JSON.parse(apiData))[apiDataField]);
                                    oracleData = (JSON.parse(apiData))[apiDataField];
                                }

                                console.log(apiDataField);
                            });

                        }).on("error", (err) => {
                            console.log("Error: " + err.message);
                            });

                        if(responseStatus==200){
                            //updating the DB
                            updateEventDB(id, oracleData);

                            //creating a transaction object and sending a signed transaction
                            var txCount = web3.eth.getTransactionCount(sender);
                            web3.eth.getTransactionCount(sender, (err, txCount) => {

                                const txObject1 = {
                                nonce:    web3.utils.toHex(txCount),
                                gasLimit: web3.utils.toHex(800000), // Raise the gas limit to a much higher amount
                                gasPrice: web3.utils.toHex(web3.utils.toWei('10', 'gwei')),
                                to: oracleContracAddress,
                                data: oracleContract.methods.updateRequest(id, oracleData).encodeABI()
                                }

                            const tx = new Tx(txObject1);
                            console.log('transaction: ', tx);
                            tx.sign(senderPrivateKey);
                            const serializedTx = tx.serialize()
                            const raw = '0x' + serializedTx.toString('hex')

                            web3.eth.sendSignedTransaction(raw, (err, txHash) => {
                                console.log('err:', err, 'txHash:', txHash)
                                // Use this txHash to find the contract on Etherscan!
                            })
                            })
                            getEventsFromDB();
                        }
                    }

                }

        }

        /*var idListDB = [];
        for(i=0;i<eventsFromDB.length;i++){
            idListDB.push(eventsFromDB[i].id, eventsFromDB[i].granted);
        }

        console.log("id list of events from DB: ");
        console.log(idListDB);*/
    }

function  updateEventDB(id, data) {
    try {
        client.query(
        `update requests set data_3 = '${data}', granted_3 = true where id = ${id}`
        );

    } catch(e) {
      //if it's 'duplicate record' error, do nothing;
      // otherwise rethrow
    }
 }

function  getEventsFromDB() {
    try {
        client.query(
        `select id, granted_3 from requests`, function(err, results) {
            if (err) {
              throw err;
            }
            else{
                eventsFromDB = results.rows;
            }
        });

    } catch(e) {
      //if it's 'duplicate record' error, do nothing;
      // otherwise rethrow
      if(e.code != 'ER_DUP_ENTRY') {
        throw e;
      }
    }
 }

 function  initEventDB(id, urlToQuery, attributeToFetch, apiFlag) {
    try {
        client.query(
        `insert into requests(id, urltoquery, attributetofetch, apiflag) values(${id}, '${urlToQuery}', '${attributeToFetch}', ${apiFlag})`
        );

    } catch(e) {
      //if it's 'duplicate record' error, do nothing;
      // otherwise rethrow
      if(e.code != 'ER_DUP_ENTRY') {
        throw e;
      }
    }
 }

 function  insertEventDB(id, urlToQuery, attributeToFetch, apiFlag, granted) {
    try {
        client.query(
        `insert into requests(id, urlToQuery, attributeToFetch, apiFlag, granted_3 ) values(${id}, '${urlToQuery}', '${attributeToFetch}', ${apiFlag}, ${granted} )`
        );

    } catch(e) {
      //if it's 'duplicate record' error, do nothing;
      // otherwise rethrow
      if(e.code != 'ER_DUP_ENTRY') {
        throw e;
      }
    }
 }

 function  insertDuplicateEventDB(id) {
    try {
        client.query(
        `update requests set granted_3 = false where id = ${id}`
        );

    } catch(e) {
      //if it's 'duplicate record' error, do nothing;
      // otherwise rethrow
      if(e.code != 'ER_DUP_ENTRY') {
        throw e;
      }
    }
 }

function duplicateRecords(id){
    try {
        client.query(
        `select id from requests where id = ${id}`, function(err, results) {
            if (err) {
              throw err;
            }
            else{
                duplicateRecordsList = results.rows;
            }
        });

    } catch(e) {
      //if it's 'duplicate record' error, do nothing;
      // otherwise rethrow
      if(e.code != 'ER_DUP_ENTRY') {
        throw e;
      }
    }

}

function aggregateRequests() {
    //Build an array containing Customer records.

    var i, j, k;
    request_list = [];
    for(i=1;i<eventlist.length;i++){
        if(eventlist[i].returnValues.apiFlag==true)

            request_list.push([eventlist[i].returnValues.id, eventlist[i].returnValues.urlToQuery, eventlist[i].returnValues.attributeToFetch])
    }
    console.log(request_list[0]);
    return request_list;
}


