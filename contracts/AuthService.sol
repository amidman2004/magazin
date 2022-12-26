// SPDX-License-Identifier: UNLICENSED


pragma solidity ^0.8.0;

enum UserRoles{
    buyer,
    seller,
    shop,
    admin,
    provider,
    bank
}

struct Review{
    address autorAddress;
    address shopAddr;
    string message;
    address[] likeCount;
    address[] disLikeCount;
    int grade;
}

struct User{
    uint status;
    string userLogin;
    string fio;
    string[] reviews;
}

contract AuthService{

    
    mapping(uint => string) userStatus;

    mapping(string => address) userLogins;

    mapping(address => User) users;

    constructor(){
        userStatus[0] = "buyer";
        userStatus[1] = "seller";
        userStatus[2] = "shop";
        userStatus[3] = "admin";
        userStatus[4] = "provider";
        userStatus[5] = "bank";
    }

    function compare(string memory a,string memory b) internal pure returns (bool){
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    modifier isNotRegistered(address userAddress,string memory userLogin){
        require(compare(users[userAddress].fio,""),"You already registered");
        require(userLogins[userLogin] == address(0),"Your login already exist in system");
        _;
    }

    modifier isRegistered(string memory userLogin){
        // require(compare(users[userAddress].fio,""),"You not registered");
        require(userLogins[userLogin] != address(0),"Wrong Login");
        _;
    }

    modifier isUser(){
        require(!compare(users[msg.sender].userLogin,""),"You not user");
        _;
    }

    modifier isUserStatus(UserRoles status){
        require(uint(status) == users[msg.sender].status,"Forbidden");
        _;
    }
    modifier isUserStatusAdminOr(UserRoles status){
        uint uStatus = users[msg.sender].status;
        require(uint(status) == uStatus || uStatus == uint(UserRoles.admin));
        _;
    }


    function registerFromAdmin(string memory fio,string memory userLogin,uint status,address userAddress) internal isNotRegistered(userAddress,userLogin){
        string[] memory reviewList;
        User memory newUser = User({fio:fio,userLogin:userLogin,status:status,reviews:reviewList});
        userLogins[userLogin] = userAddress;
        users[userAddress] = newUser;
    }

    function login(string memory userLogin) public view isRegistered(userLogin) returns(address userAddress,string memory status){
        address userAddr = userLogins[userLogin];
        User memory user = users[userAddr];
        userAddress = userAddr;
        status = userStatus[user.status];
    }

}