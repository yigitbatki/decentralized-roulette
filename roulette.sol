//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract DecenteralizedRoulette {

    //announces the new recruitment
    event newMember(
        string name,
        uint entranceDate,
        address memberAddress
    );

    address[] membersList;

    //defines the structure of a member
    struct Member {
        string name;
        uint entranceDate;
        address memberAddress;
        uint memberNr;
    }

    //makes sure that only authorized personel can call such functions
    modifier onlyOwner{
        require(msg.sender==owner);
        _;
    }

    modifier onlyMember{
        require(members[msg.sender].memberAddress!=address(0));
        _;
    }

    //stores the address of the owner of the contract
    address owner;

    //stores total count of members
    uint count;

    //stores members
    mapping(address=>Member) members;

    //adds a new member to the crew
    function addMember(string memory _name, address _memberAddress) public onlyOwner {

        require(members[_memberAddress].entranceDate==0,"you have already joined");

        members[_memberAddress] = Member({
            name: _name,
            entranceDate: block.timestamp,
            memberAddress: _memberAddress,
            memberNr: count
        });

        membersList.push(_memberAddress);
        //announces the newcomer
        emit newMember(_name, block.timestamp, _memberAddress);
    }

    //declares the owner of the contract as well as adds them to the members mapping
    constructor(string memory _name){
        owner = msg.sender;
        addMember(_name, msg.sender);
    }


    
    //removes a random member from the list
    function russianRoulette() public onlyMember {
        require(membersList.length>1);
        uint luckyNumber = uint(keccak256(abi.encodePacked(msg.sender,block.timestamp))) % membersList.length;
        address luckyMember = membersList[luckyNumber];
        delete members[luckyMember];

        if (luckyNumber >= membersList.length) return;
        else{
        membersList[luckyNumber] = membersList[membersList.length - 1];
        membersList.pop();
        }

        if(luckyMember==owner){
            uint nextOwner = uint(keccak256(abi.encodePacked(msg.sender,block.timestamp+1))) % membersList.length;
            owner = membersList[nextOwner];
        }
    }
}