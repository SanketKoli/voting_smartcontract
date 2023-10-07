// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Vote{
    address electionComision;
    address public winner;
    uint max;

    struct Voter{
        string name;
        uint age;
        uint voterId;
        string gender;
        uint voteCandidateId;
        address voterAddress;
    }

    struct Candidate{
        string name;
        string party;
        uint age;
        string gender;
        uint candidateId;
        address candidateAddress;
        uint votes;
    }

    uint nextVoterId =1;
    uint nextCandidateId = 1;

    uint startTime;
    uint endTime;

    mapping(uint => Voter) voterDetails;
    mapping(uint => Candidate) candidateDetails;
    bool stopVoting;

    constructor() {
         electionComision = msg.sender;
    }
    
    modifier isVotingOver(){
        require(block.timestamp > endTime || stopVoting == true, "Voting is not over");
        _;
    }

    modifier onlyComisioner(){
        require(electionComision == msg.sender , "Not from election commision");
        _;
    }

    function candidateRegister(
        string calldata _name,
        string calldata _party,
        uint _age,
        string calldata _gender
    ) public{
        require(msg.sender!=electionComision, "You are from election comision");
        require(CandidateVerification(msg.sender),"Alredy registered");
        candidateDetails[nextCandidateId]= Candidate(_name,_party,  _age, _gender, nextCandidateId, msg.sender,0);
        nextCandidateId++;
        
    }

    function CandidateVerification( address _person) internal view returns(bool){
        for (uint i =1; i< nextCandidateId; i++){
            if(candidateDetails[i].candidateAddress==_person){
                return false;
            }
        }
        return true;
    }

    function candidateList() public view returns ( Candidate[] memory) {
        Candidate[] memory  array = new Candidate[](nextCandidateId-1);
        for(uint i; i<=nextCandidateId; i++){
            array[i-1]= candidateDetails[i];
        }
        return array;

    }

    function voterRegister(string calldata _name, uint _age, string calldata _gender) external{
        require(msg.sender!=electionComision,"You are from elecsion comision");
        require(voterVerification(msg.sender),"Already registered");
        voterDetails[nextVoterId]= Voter(_name,_age,nextVoterId,_gender,0,msg.sender);
        nextVoterId++;
    }

    function voterVerification(address _person) internal view returns(bool){
        for(uint i=1; i<=nextVoterId ; i++){
            if(voterDetails[i].voterAddress == _person){
                return false;                
            }

        }
        return true;
    }

    function voteList() public view returns (Voter[] memory) {
        Voter[] memory Varray = new Voter[](nextVoterId-1);
        for(uint i=1; i<=nextVoterId; i++){
            Varray[i-1]= voterDetails[i];
        }
        return Varray;
    }

    function vote(uint _voterId, uint _id) external {
        require(voterDetails[_voterId].voteCandidateId==0,"Alredy voted");
        require(voterDetails[_voterId].voterAddress==msg.sender,"Not registered");
        require(startTime !=0,"Voting has not started");
        voterDetails[_voterId].voteCandidateId= _id;
        candidateDetails[_id].votes+=1;
    }

    function voteTime(uint _startTime, uint _endTime) external onlyComisioner(){
            startTime=_startTime+block.timestamp;
            endTime= startTime+_endTime;
    }

    function votingStatus() public view returns (string memory) {
            if(startTime==0){
                return "Voting not started yet";
            }else if((endTime>block.timestamp) && (stopVoting==false)){
                return "Voting is going on";

            }else{
                return "voting is over";
            }
    }
    function result() public onlyComisioner(){
        for(uint i=1;i< nextCandidateId ;i++){
              uint count= candidateDetails[i].votes;
              if(max<count){
                  max= count;
                  winner = candidateDetails[i].candidateAddress;
              }   
        }
        
    }

    function emergency() public onlyComisioner() {
            stopVoting=true;
    }
}   
