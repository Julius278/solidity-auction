//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

contract Auction{

    address payable public owner;
    enum State {RUNNING, ENDED, CANCELED}
    State private auctionStatus;
    bool public ownerFinalized;

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

    function placeBid() public payable notOwner afterStart beforeEnd{
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


    function startAuction() private onlyOwner {
        auctionStatus = State.RUNNING;

        startBlock = block.number;
        // approx. one week, 15 seconds per new Block, 40320 new Blocks
        endBlock = startBlock + 40320;
        //clear bids
    }

    function finalizeAuction() public afterStart {        
        require(auctionStatus == State.CANCELED || block.number > endBlock);
        require(msg.sender == owner || bids[msg.sender] > 0);
        
        auctionStatus = State.ENDED;
        address payable recipient;
        uint value;

        if(auctionStatus == State.CANCELED){
            recipient = payable(msg.sender);
            value = bids[msg.sender];
        }else {
            if(msg.sender == owner && ownerFinalized == false){
                recipient = owner;
                value = highestBindingBid;
                ownerFinalized = true;
            } else if(msg.sender == highestBidder){
                recipient = highestBidder;
                value = bids[highestBidder] - highestBindingBid;
            } else {
                recipient = payable(msg.sender);
                value = bids[msg.sender];
            }
        }

        //resets the bid of the recipient
        bids[recipient] = 0;

        //send value to the recipient
        recipient.transfer(value);
    }

    function cancelAuction() public onlyOwner {
        auctionStatus = State.CANCELED;
    }
}