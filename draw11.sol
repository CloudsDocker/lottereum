contract draw {
    address owner;
    uint public numTickets;
    uint public drawDate;
    bool public drawn;
    uint public entryFee;
    uint public winningNumber;    
    struct Ticket {
     uint guess;
     address eth_address;
    }
    mapping(uint => Ticket) tickets;
    address[] winningaddresses;

    event BuyTicket(uint _ticketid);

    function draw(uint _offset, uint _entryFee) {
         owner = msg.sender;
  	 numTickets = 0;
   	 drawn = false;
   	 winningNumber = 0;
         drawDate = now + _offset;
         entryFee = _entryFee;
    }

    function getPot() constant returns (uint) {
       return this.balance; 
    }

    function buyTicket(uint _guess) returns (uint ticketid) {
      if (msg.value != entryFee) throw;
      if (_guess > 1000 || _guess < 1) throw;
      ticketid = numTickets++;
      tickets[ticketid] = Ticket(_guess, msg.sender);
      BuyTicket(ticketid);
    }

    function doDraw() {
     if (drawn) throw;
     if (now < drawDate) throw; 
     winningNumber = 50;
      for (uint i = 0; i < numTickets; ++i) {
        if (tickets[i].guess == winningNumber) {
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
      if (msg.sender != owner) throw;
      if (this.balance == 0) throw;
      _newContract.send(this.balance);
    }

    function getTicketById(uint _ticketid) constant returns (uint a, address b) {
      var t = tickets[_ticketid];
      a = t.guess;
      b = t.eth_address;
    }

    function getWinnerByIndex(uint _i) constant returns (address a) {
      a = winningaddresses[_i];
    }
    
}
