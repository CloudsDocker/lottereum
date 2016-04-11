## Deployment from the command-line

```sh
> ./deploy.js draw11.sol
```

Then from geth:

```
loadScript("./draw.js")
```

which is the equivalent of:

```js
var srcCompiled = web3.eth.compile.solidity(src);

var drawContract = web3.eth.contract(srcCompiled.draw.info.abiDefinition);


var draw = drawContract.new(
  {
    from: web3.eth.accounts[0],
    data: srcCompiled.draw.code, 
    gas: 3000000
  }, function(e, contract){
       if(!e) { if(!contract.address) {
         console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");
       } else {
         console.log("Contract mined! Address: " + contract.address);
         console.log(contract);
       } 
     }
});
```
## Setting up accounts

```sh
> geth account new
```

## Starting geth in test mode

...


## Buying tickets

```js
var theminer = "0x175b92f61ce2c633354234e50b862832f3e6377a";
var thepot = "0xae775a3520f9c3bfe7dbe06620d39b05cb882885";
var thebuyer = "0x0ebcea3a0d7fb008440fb28e95041d50d1184e95";
personal.unlockAccount(thebuyer, "password")
var theticket = draw.buyTicket(42, {from: thebuyer, gas: 3000000, value: 100000000000000000 });
```

Check whether it worked with:

```js
eth.getTransactionReceipt(theticket);
```

## Transferring money from the miner to other accounts

```js
eth.sendTransaction({from:theminer, to:thebuyer, value: 1000000000})
```

## Interrogating the draw

```js
draw.numTickets();
draw.drawn();
draw.drawDate();
draw.entryFee();
draw.getTicketById(0);
```

## Listening for events

```js
var event = draw.BuyTicket();
event.watch(function(e,r) { console.log("Ticket bought", e, JSON.stringify(r)); });
```

## Doing the draw

```js
draw.doDraw({from: theminer, gas: 3000000});
draw.drawn();
draw.getWinnerByIndex(0);
```

## Transferring the remaing pot to a new contract

```js
var draw2 = ...; // create new contract and wait until its mined
draw.transferPot(draw2.address, {from:theminer, gas: 3000000});
```
