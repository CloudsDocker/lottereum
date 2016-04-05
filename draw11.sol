
contract mortal {
    address owner;

    function mortal() {
   	 owner = msg.sender;
    }

    function kill() {
   	 if (msg.sender == owner) suicide(owner);
    }
}

contract draw is mortal {

    uint numTickets;
    string drawdate;
    bool drawn;
    uint entryfee;
    uint winningnumber;    
    struct Ticket {
     uint guess;
     address eth_address;
    }
    mapping(uint => Ticket) tickets;
    address[] winningaddresses;

    function draw() {
  	 numTickets = 0;
   	 drawn = false;
   	 winningnumber = 0;
         drawdate = '2016-03-31';
         entryfee = 100000000000000000;  // one tenth of a ether
    }

    function getEntryFee() constant returns (uint) {
      return entryfee;
    }

    function getDrawDate() constant returns (string) {
      return drawdate; 
    }

    function getPot() constant returns (uint) {
       return this.balance; 
    }

    function buyTicket(uint _guess) returns (uint ticketid) {
      if (msg.value != 100000000000000000) throw;
      if (_guess > 1000 || _guess < 1) throw;
      ticketid = numTickets++;
      tickets[ticketid] = Ticket(_guess, msg.sender);
    }

    function doDraw() {
     if (drawn) throw; 
     winningnumber = 50;
      for (uint i = 0; i < numTickets; ++i) {
        if (tickets[i].guess == winningnumber) {
          winningaddresses.push(tickets[i].eth_address); 
        }
      }
      var temppot = this.balance;
      for (uint j = 0; j < winningaddresses.length; ++j) {
        winningaddresses[j].send(temppot / winningaddresses.length);
      }
      drawn = true;
    }

    function transferPot(address _newContract) {
      if (this.balance == 0) throw;
      _newContract.send(this.balance);
    }

    function getNumTickets() constant returns (uint) {
       return numTickets;
    }

    function getTicketById(uint _ticketid) constant returns (uint a, address b) {
      var t = tickets[_ticketid];
      a = t.guess;
      b = t.eth_address;
    }

    function getWinners() constant returns (address a) {
      a = winningaddresses[0];
    }
}
