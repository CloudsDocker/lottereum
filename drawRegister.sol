contract drawRegister {
   address owner;
   uint public numDraws;
   struct drawData {
      uint drawDate;
      address eth_address;
   }
   mapping(uint => drawData) public draws;
 


   function drawRegister()  {
      numDraws = 0;
      owner = msg.sender;
   }

   function addDraw (address _eth_address) {
      if (msg.sender != owner) throw;
      draws[numDraws] = drawData(now, _eth_address);
      numDraws += 1;      
   }

   function getLatestDraw () constant returns (address _latest) {
      if (numDraws == 0) throw;
      _latest = draws[numDraws-1].eth_address;
   }

}
