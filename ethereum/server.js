var http = require('http');
var fs = require('fs');
const Web3 = require('web3');
const https = require('https');
const ethereumjs = require('ethereumjs-tx');
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
            const sender = '0x45311c331cED3ca4272671AD7E72c8F73140012F';
            const senderPrivateKey = Buffer.from('E00E7F652B4674D66C1A10B4595626D05A633821DFD2797E7928BC4DCB41D9BA');

            //add the oracle account as default account. Note: it is not the contract account
web3.eth.Contract.defaultAccount='0x45311c331cED3ca4272671AD7E72c8F73140012F';
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
var oracleContracAddress = '0xCfa03766fa8a3d8C6521Dca5Af3f6B7D63645300';
var oracleContract =  new web3.eth.Contract(abi, oracleContracAddress);
var eventlist = [];
var eventsFromDB = [];
var request_list = [];
var apiData;
var apiDataField;
var id;

/*var loop = new Infiniteloop();
//use loop.add to add a function
//fisrt argument should be the fn, the rest is the fn's arguments
loop.add(getRequests);
//make it run
loop.run();*/

setInterval(polling, 5000);


function polling(){

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
        console.log("events from db: ")
        console.log(eventsFromDB);

        for(i=0;i<request_list.length;i++){
            var flag = false;
            for(j=0;j<eventsFromDB.length;j++){
                if(request_list[i][0]!=null){
                    if(request_list[i][0]==eventsFromDB[j].id && eventsFromDB[j].granted==true){
                        flag = true;
                        break;
                    }
                }}

                //insert row into requests table with granted = false -> create api request and send signed transaction -> update granted to true
            if(flag==false){
                id = request_list[i][0];
                apiDataField = request_list[i][2];
                console.log('api data field: ', apiDataField);
                insertEventDB(request_list[i][0], request_list[i][1], request_list[i][2], true, false);
                https.get(request_list[i][1], (res) => {
                    console.log('statusCode:', res.statusCode);
                    console.log('headers:', res.headers);

                    res.on('data', function(body){
                            console.log('body :', body);
                            apiData = d.apiDataField;
                            console.log('api data: ', apiData);
                    });

                });
                updateEventDB(id, apiData);
            }
        }

        /*var idListDB = [];
        for(i=0;i<eventsFromDB.length;i++){
            idListDB.push(eventsFromDB[i].id, eventsFromDB[i].granted);
        }

        console.log("id list of events from DB: ");
        console.log(idListDB);*/
    }

async function  updateEventDB(id, data) {
    try {
        await client.query(
        `update requests set data = '${data}', granted = true where id = ${id}`
        );

    } catch(e) {
      //if it's 'duplicate record' error, do nothing;
      // otherwise rethrow
      if(e.code != 'ER_DUP_ENTRY') {
        throw e;
      }
    }
 }

async function  getEventsFromDB() {
    try {
        await client.query(
        `select id, granted from requests`, function(err, results) {
            if (err) {
              throw err;
            }
            eventsFromDB = results.rows;
            console.log("events from DB: ");
            console.log(eventsFromDB);
        });

    } catch(e) {
      //if it's 'duplicate record' error, do nothing;
      // otherwise rethrow
      if(e.code != 'ER_DUP_ENTRY') {
        throw e;
      }
    }
 }

 async function  insertEventDB(id, urlToQuery, attributeToFetch, apiFlag, granted) {
    try {
        await client.query(
        `insert into requests values(${id}, '${urlToQuery}', '${attributeToFetch}', ${apiFlag}, ${granted} )`
        );

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
    for(i=0;i<eventlist.length;i++){
        if(eventlist[i].returnValues.apiFlag==true)

            request_list.push([eventlist[i].returnValues.id, eventlist[i].returnValues.urlToQuery, eventlist[i].returnValues.attributeToFetch])
    }
    console.log(request_list[0]);
    return request_list;
}


