contract draw {
    address owner;
    uint public numTickets;
    uint public drawDate;
    uint public actualDrawDate;
    bool public drawn;
    uint public entryFee;
    uint public payout;
    uint public winningNumber;  
    address public organiser;
    address public nextDraw;  
    address public previousDrawAddress;
    struct Ticket {
     uint guess;
     address eth_address;
    }
    mapping(uint => Ticket) public tickets;
    address[] public winningaddresses;

    event Log_BuyTicket(uint _ticketid);
    event Log_DrawDone(uint _winningNumber);
 
    function draw(uint _offset, uint _entryFee, address _organiser, address _previousDrawAddress) {
         owner = msg.sender;
  	 numTickets = 0;
   	 drawn = false;
   	 winningNumber = 0;
         payout = 0;
         drawDate = now + _offset;
         actualDrawDate = 0;
         entryFee = _entryFee;
         organiser= _organiser;
         previousDrawAddress = _previousDrawAddress;
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
      Log_BuyTicket(ticketid);
    }

    function doDraw() {
      if (drawn) throw;
      if (now < drawDate) throw; 
      winningNumber = 50 ;
      actualDrawDate = now;
      for (uint i = 0; i < numTickets; ++i) {
        if (tickets[i].guess == winningNumber) {
          winningaddresses.push(tickets[i].eth_address); 
        }
      }
      var commission = numTickets*entryFee / 10;
      payout = this.balance - commission;
      drawn = true;
      for (uint j = 0; j < winningaddresses.length; ++j) {
        if (!winningaddresses[j].send(payout / winningaddresses.length)) throw;
      }
      // we need to make sure this works with rounding - does commission + payout always equal this.balance
      if(!organiser.send(commission)) throw;
      Log_DrawDone(winningNumber);
    }

    function transferPot(address _newContract) {
      if (msg.sender != owner) throw;
      if (this.balance == 0) throw;
      if (!drawn) throw; 
      nextDraw = _newContract; 
      if(!_newContract.send(this.balance)) throw;
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
