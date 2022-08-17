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
    modifier notOwner(){
        require(msg.sender != owner);
        _;
    }
    modifier afterStart(){
        require(block.number >= startBlock);
        _;
    }
    modifier beforeEnd(){
        require(block.number <= endBlock);
        _;
    }

    receive() external payable notOwner afterStart beforeEnd {
        //addBid(msg.sender, msg.value);
    }

    fallback() external payable{
        revert();
    }

    function placeBid() internal notOwner afterStart beforeEnd{
        require(getAuctionState() == State.RUNNING);
        require(msg.value >= bidIncrement);

        uint currentBid = bids[msg.sender] + msg.value;
        require(currentBid > highestBindingBid);
        bids[msg.sender] = currentBid;

        if(currentBid <= bids[highestBidder]){
            highestBindingBid = min(currentBid + bidIncrement, bids[highestBidder]);        
        } else {
            highestBindingBid = min(currentBid, bids[highestBidder] + bidIncrement);
            highestBidder = payable(msg.sender);
        }
    }

    function min(uint a, uint b) pure internal returns(uint){
        if(a <= b){
            return a;
        }
        return b;
    }

    //auction is running and bidders can add bids
    function getAuctionState() public view returns(State){
        return auctionStatus;
    }

    function startAuction() public onlyOwner afterStart beforeEnd {
        auctionStatus = State.RUNNING;

        startBlock = block.number;
        // approx. one week, 15 seconds per new Block, 40320 new Blocks
        endBlock = startBlock + 40320;
        //clear bids
    }

    function endAuction() public onlyOwner afterStart beforeEnd {        
        auctionStatus = State.ENDED;

        //get Highest Bidder
        //withdraw highest bid to owner
        //withdraw open funds to bidders
        //clear bids
        //clear highestBindingBid
        highestBindingBid = 0;
        //clear highestBidder
        highestBidder= payable(address(0));
    }
}