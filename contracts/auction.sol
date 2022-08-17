//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

contract Auction{

    address payable public owner;
    enum State {RUNNING, ENDED, CANCLED}
    State public auctionStatus;

    uint public highestBindingBid;
    address payable public highestBidder;

    mapping(address => uint) public bids;

    uint bidIncrement = 100;

    uint public startBlock;
    uint public endBlock;

    constructor(){
        owner = payable(msg.sender);
        startAuction();
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    receive() external payable{
        require(auctionIsOpen() == State.RUNNING);
        require(msg.sender != owner);
        addBid(msg.sender, msg.value);
    }

    fallback() external payable{
        revert();
    }

    function addBid(address addr, uint bid) internal{
        //add new address or add increment bid to mapping
    }

    //auction is open and bidders can add bids
    function auctionIsOpen() public view returns(State){
        return auctionStatus;
    }


    function getHighestBidder() public view returns(address){

    }

    function getHighestBindingBid() public view returns(uint){

    }

    function startAuction() public onlyOwner {
        require(auctionIsOpen() != State.RUNNING);

        auctionStatus = State.RUNNING;

        startBlock = block.number;
        // approx. one week, 15 seconds per new Block, 40320 new Blocks
        endBlock = startBlock + 40320;

        //clear bids
    }

    function endAuction() public onlyOwner {
        require(auctionIsOpen() == State.RUNNING);
        
        auctionStatus = State.ENDED;

        //get Highest Bidder
        //withdraw highest bid to owner
        //withdraw open funds to bidders
        //clear bids
    }
}