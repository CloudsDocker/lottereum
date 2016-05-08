var registerAddress ="0xb480eadf0619abc5454590efa1fb38b25143417b";
var registerAbiDef = [{
    constant: true,
    inputs: [{
        name: "",
        type: "uint256"
    }],
    name: "draws",
    outputs: [{
        name: "drawDate",
        type: "uint256"
    }, {
        name: "eth_address",
        type: "address"
    }],
    type: "function"
}, {
    constant: true,
    inputs: [],
    name: "getLatestDraw",
    outputs: [{
        name: "_latest",
        type: "address"
    }],
    type: "function"
}, {
    constant: false,
    inputs: [{
        name: "_eth_address",
        type: "address"
    }],
    name: "addDraw",
    outputs: [],
    type: "function"
}, {
    constant: true,
    inputs: [],
    name: "numDraws",
    outputs: [{
        name: "",
        type: "uint256"
    }],
    type: "function"
}, {
    inputs: [],
    type: "constructor"
}];

var register = eth.contract(registerAbiDef).at(registerAddress);

var drawAbiDef = [{
    constant: true,
    inputs: [],
    name: "entryFee",
    outputs: [{
        name: "",
        type: "uint256"
    }],
    type: "function"
}, {
    constant: false,
    inputs: [{
        name: "_newContract",
        type: "address"
    }],
    name: "transferPot",
    outputs: [],
    type: "function"
}, {
    constant: true,
    inputs: [],
    name: "nextDraw",
    outputs: [{
        name: "",
        type: "address"
    }],
    type: "function"
}, {
    constant: true,
    inputs: [],
    name: "numTickets",
    outputs: [{
        name: "",
        type: "uint256"
    }],
    type: "function"
}, {
    constant: true,
    inputs: [{
        name: "",
        type: "uint256"
    }],
    name: "winningaddresses",
    outputs: [{
        name: "",
        type: "address"
    }],
    type: "function"
}, {
    constant: true,
    inputs: [],
    name: "getPot",
    outputs: [{
        name: "",
        type: "uint256"
    }],
    type: "function"
}, {
    constant: true,
    inputs: [],
    name: "winningNumber",
    outputs: [{
        name: "",
        type: "uint256"
    }],
    type: "function"
}, {
    constant: true,
    inputs: [{
        name: "",
        type: "uint256"
    }],
    name: "tickets",
    outputs: [{
        name: "guess",
        type: "uint256"
    }, {
        name: "eth_address",
        type: "address"
    }],
    type: "function"
}, {
    constant: false,
    inputs: [{
        name: "_guess",
        type: "uint256"
    }],
    name: "buyTicket",
    outputs: [{
        name: "ticketid",
        type: "uint256"
    }],
    type: "function"
}, {
    constant: true,
    inputs: [],
    name: "organiser",
    outputs: [{
        name: "",
        type: "address"
    }],
    type: "function"
}, {
    constant: true,
    inputs: [],
    name: "drawDate",
    outputs: [{
        name: "",
        type: "uint256"
    }],
    type: "function"
}, {
    constant: false,
    inputs: [],
    name: "doDraw",
    outputs: [],
    type: "function"
}, {
    constant: true,
    inputs: [],
    name: "drawn",
    outputs: [{
        name: "",
        type: "bool"
    }],
    type: "function"
}, {
    inputs: [{
        name: "_offset",
        type: "uint256"
    }, {
        name: "_entryFee",
        type: "uint256"
    }, {
        name: "_organiser",
        type: "address"
    }],
    type: "constructor"
}, {
    anonymous: false,
    inputs: [{
        indexed: false,
        name: "_ticketid",
        type: "uint256"
    }],
    name: "BuyTicket",
    type: "event"
}, {
    anonymous: false,
    inputs: [{
        indexed: false,
        name: "_winningNumber",
        type: "uint256"
    }],
    name: "DrawDone",
    type: "event"
}];

var  lastDrawAddress = register.getLatestDraw();

var lastDraw =eth.contract(drawAbiDef).at(lastDrawAddress);

var src="contract draw {     address owner;     uint public numTickets;     uint public drawDate;     bool public drawn;     uint public entryFee;     uint public winningNumber;       address public organiser;     address public nextDraw;       struct Ticket {      uint guess;      address eth_address;     }     mapping(uint => Ticket) public tickets;     address[] public winningaddresses;      event BuyTicket(uint _ticketid);     event DrawDone(uint _winningNumber);       function draw(uint _offset, uint _entryFee, address _organiser) {          owner = msg.sender;   	 numTickets = 0;    	 drawn = false;    	 winningNumber = 0;          drawDate = now + _offset;          entryFee = _entryFee;          organiser= _organiser;     }      function getPot() constant returns (uint) {        return this.balance;      }      function buyTicket(uint _guess) returns (uint ticketid) {       if (msg.value != entryFee) throw;       if (_guess > 1000 || _guess < 1) throw;       if (drawn) throw;       ticketid = numTickets++;       tickets[ticketid] = Ticket(_guess, msg.sender);       BuyTicket(ticketid);     }      function doDraw() {      if (drawn) throw;      if (now < drawDate) throw;       winningNumber = (now % 1000) +1 ;       for (uint i = 0; i < numTickets; ++i) {         if (tickets[i].guess == winningNumber) {           winningaddresses.push(tickets[i].eth_address);          }       }       var commission = this.balance / 10;       var payout = this.balance - commission;       for (uint j = 0; j < winningaddresses.length; ++j) {         winningaddresses[j].send(payout / winningaddresses.length);       }       organiser.send(commission);       DrawDone(winningNumber);       drawn = true;     }      function transferPot(address _newContract) {       if (msg.sender != owner) throw;       if (this.balance == 0) throw;       if (!drawn) throw;        _newContract.send(this.balance);       nextDraw = _newContract;      } }";

var srcCompiled = web3.eth.compile.solidity(src);

var drawContract = web3.eth.contract(srcCompiled.draw.info.abiDefinition);

var theminer = eth.accounts[0];

var draw = drawContract.new(30,100000000000000000,theminer,
  {
    from: theminer,
    data: srcCompiled.draw.code, 
    gas: 3000000
  }, function(e, contract){
       if(!e) { 
	 if(!contract.address) {
           console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");
         } else {
           console.log("Contract mined! New draw Address: " + contract.address);
           lastDraw.doDraw({from: theminer, gas: 3000000}, function(e, d) { 
             if(d.address) {
               console.log("Draw done and mined");
               lastDraw.transferPot(contract.address, {from: theminer, gas: 3000000}, function(e, d2) {
                 if(d2.address) {
                   console.log("Pot transferred to ", contract.address);
                   register.addDraw(contract.address, {from: theminer, gas: 3000000}, function(e, d3) {
                     if(d3.address) {
                      console.log("Draw Register updated");
                     }
                   });
                 }
               });
             }
           }); 
         } 
       }
});

