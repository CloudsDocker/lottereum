contract draw {
    address owner;
    uint public numTickets;
    uint public drawDate;
    bool public drawn;
    uint public entryFee;
    uint public payout;
    uint public winningNumber;  
    address public organiser;
    address public nextDraw;  
    struct Ticket {
     uint guess;
     address eth_address;
    }
    mapping(uint => Ticket) public tickets;
    address[] public winningaddresses;

    event BuyTicket(uint _ticketid);
    event DrawDone(uint _winningNumber);
 
    function draw(uint _offset, uint _entryFee, address _organiser) {
         owner = msg.sender;
  	 numTickets = 0;
   	 drawn = false;
   	 winningNumber = 0;
         payout = 0;
         drawDate = now + _offset;
         entryFee = _entryFee;
         organiser= _organiser;
    }

    function getPot() constant returns (uint) {
       return this.balance; 
    }

    function buyTicket(address _buyer, uint _guess) returns (uint ticketid) {
      if (msg.value != entryFee) throw;
      if (_guess > 1000 || _guess < 1) throw;
      if (drawn) throw;
      ticketid = numTickets++;
      tickets[ticketid] = Ticket(_guess, _buyer);
      BuyTicket(ticketid);
    }

    function doDraw() {
     if (drawn) throw;
     if (now < drawDate) throw; 
     winningNumber = (now % 1000) +1 ;
     winningNumber = 50;
      for (uint i = 0; i < numTickets; ++i) {
        if (tickets[i].guess == winningNumber) {
          winningaddresses.push(tickets[i].eth_address); 
        }
      }
      var commission = numTickets*entryFee / 10;
      payout = this.balance - commission;
      for (uint j = 0; j < winningaddresses.length; ++j) {
        winningaddresses[j].send(payout / winningaddresses.length);
      }
      organiser.send(commission);
      DrawDone(winningNumber);
      drawn = true;
    }

    function transferPot(address _newContract) {
      if (msg.sender != owner) throw;
      if (this.balance == 0) throw;
      if (!drawn) throw; 
      _newContract.send(this.balance);
      nextDraw = _newContract; 
    }

    function getPrizeValue (address _query) constant returns (uint _value) {
      if (!drawn) throw;
      _value =0;
      for (uint i = 0; i < winningaddresses.length; ++i) {
        if (winningaddresses[i] == _query) {
          _value += payout / winningaddresses.length;        
        }
      }
    } 
}
