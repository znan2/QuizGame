// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Quiz{
    struct Quiz_item {
      uint id;
      string question;
      string answer;
      uint min_bet;
      uint max_bet;
   }
    
    mapping(address => uint256)[] public bets;
    uint public vault_balance;
    address public owner;
    Quiz_item[] public quiz_list;
    mapping(address => uint256) public rewards;
    

    constructor () {
        owner = msg.sender;
        Quiz_item memory q;
        q.id = 1;
        q.question = "1+1=?";
        q.answer = "2";
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        addQuiz(q);
    }

    function addQuiz(Quiz_item memory q) public {
        if(msg.sender != owner) {
            revert("next call did not revert as expected");
        }
        quiz_list.push(q);
        bets.push();
    }

    function getAnswer(uint quizId) public view returns (string memory){
        return quiz_list[quizId - 1].answer;
    }

    function getQuiz(uint quizId) public view returns (Quiz_item memory) {
        Quiz_item memory qi = quiz_list[quizId - 1];
        qi.answer = "";
        return qi;
    }

    function getQuizNum() public view returns (uint){
        return quiz_list.length;
    }
    
    function betToPlay(uint quizId) public payable {
        // 퀴즈 정보 가져오기
        Quiz_item memory qi = quiz_list[quizId - 1];

        // 최소/최대 베팅 범위 검사
        require(msg.value >= qi.min_bet && msg.value <= qi.max_bet, "Bet out of range");

        // 누적 베팅
        bets[quizId - 1][msg.sender] += msg.value;
    }

    function solveQuiz(uint quizId, string memory ans) public returns (bool) {
        uint betAmount = bets[quizId - 1][msg.sender];
        require(betAmount > 0, "You have not bet on this quiz");

        if(keccak256(abi.encodePacked(ans)) == keccak256(abi.encodePacked(quiz_list[quizId - 1].answer))) {
            rewards[msg.sender] += betAmount * 2;
            bets[quizId - 1][msg.sender] = 0;
            return true;
        } else {
            vault_balance += betAmount;
            bets[quizId - 1][msg.sender] = 0;
            return false;
        }
    }

    function claim() public {
        uint amount = rewards[msg.sender];
        require(amount > 0, "No rewards to claim");
        rewards[msg.sender] = 0;

        // 실제 이더 송금
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
    receive() external payable {}
}
