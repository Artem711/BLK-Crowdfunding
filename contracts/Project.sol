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
    uint public goalAmount;  // required to reach at least this much, else everyone gets refund
    uint public completedAt;
    uint256 public currentBalance;
    uint public timeDeadline;
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

    constructor(
        address payable _creator,
        string memory _title,
        string memory _description,
        uint _timeDeadline,
        uint _goalAmount
    ) {
        creator = _creator;
        title = _title;
        description = _description;
        goalAmount = _goalAmount;
        timeDeadline = _timeDeadline;
        currentBalance = 0;
    }

    // @dev Function to fund a certain project.
    function contribute() external inState(State.Fundarising) payable {
        require(msg.sender != creator);
        contributions[msg.sender] = contributions[msg.sender].add(msg.value);
        currentBalance = currentBalance.add(msg.value);
        emit FundingRecieved(msg.sender, msg.value, currentBalance);
        checkIfFundingCompleteOrExpired();
    }

    function checkIfFundingCompleteOrExpired() public {
        if (currentBalance >= goalAmount) {
            state = State.Succesful;
            payOut();
        }
    } 

    function payOut() internal inState(State.Succesful) returns(bool) {

    }
}