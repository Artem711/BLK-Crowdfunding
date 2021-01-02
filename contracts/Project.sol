// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Project {
    using SafeMath for uint256;

    // Data structures
    enum State {
        Fundarising, 
        Expired,
        Succesful
    }

    // State variables
    address payable public creator;
    uint public amountGoal;  // required to reach at least this much, else everyone gets refund
    uint public completedAt;
    uint256 public currentBalance;
    uint public raiseBy;
    string public title;
    string public description;
    State public state = State.Fundarising;
    mapping(address => uint) public contributions;
    
    // Event that will be emitted whenever funding will be received
    event FundingRecieved(address contributor, uint amount, uint currentTotal);
    // Event that will be emitted whenever the project starter has received the funds
    event CreatorRecieved(address recipient);
    
    // Modifier to check current state
    modifier inState(State _state) {
        require(state == _state);
        _;
    }
    
    // Modifier to check if the function caller is the project creator
    modifier isCreator() {
        require(msg.sender == creator);
        _;
    }

    constructor() public {}
}