// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;
import "@openzeppelin/contracts/math/SafeMath.sol";
 

contract Project {
    using SafeMath for uint256;

    // Data structures
    enum State {
        Fundarising, 
        Expired,
        Successful
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
    event CreatorRecievedFunds(address recipient);
    
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
            state = State.Successful;
            payOut();
        } else if (block.timestamp > timeDeadline) {
            state  = State.Expired;
        }
        completedAt = block.timestamp;
    } 

    // Function to give the received funds to project starter.
    function payOut() internal inState(State.Successful) returns(bool) {
        uint256 totalRaised = currentBalance;
        currentBalance = 0;

        if (creator.send(totalRaised)) {
            emit CreatorRecievedFunds(creator);
            return true;
        } else {
            currentBalance = totalRaised;
            state = State.Successful;
        }

        return false;
    }

    // Function to retrieve donated amount when a project expires.
    function getRefund() public inState(State.Expired) returns (bool) {
        uint refundAmount = contributions[msg.sender];
        require(refundAmount > 0);

        contributions[msg.sender] = 0;
        if (!msg.sender.send(refundAmount)) {
            contributions[msg.sender] = refundAmount;
            return false;
        } else {
            currentBalance = currentBalance.sub(refundAmount);
        }

        return true;
    }

 
    /** Function to get specific information about the project.
    * Returns all the project's details */
    function getDetails() public view returns  (
        address payable _creator,
        string memory _title,
        string memory _description,
        uint256 _timeDeadline,
        State _state,
        uint256 _currentBalance,
        uint256 _goalAmount
    ) {
        _creator = creator;
        _title = title;
        _description = description;
        _timeDeadline = timeDeadline;
        _state = state;
        _currentBalance = currentBalance;
        _goalAmount = goalAmount;
    }
}