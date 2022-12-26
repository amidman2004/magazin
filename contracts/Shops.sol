//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;


import "./AuthService.sol";


struct Shop{
    string number;
    string city;
    int debt;
}

struct Request{
    address userAddr;
    uint currentRole;
    uint desiredRole;
    bool checked;
}


contract ShopsSystem is AuthService{
    mapping(address => bool) likeCountCheck;


    address provider;

    address admin;

    string[] admins;
 
    address payable bank;

    address[] sellers;

    string[] requests;

    mapping(address => Shop) ShopsList; // shop address

    mapping(address => address) salesmanShop; // seller address => shop address

    mapping(address => address[]) salesmen; // shop address to salesman addresses list 

    mapping(address => string[]) shopReviews; // shop address to shop review struct

    mapping(string => Review) reviewId;

    mapping(string => Request) requestId;

    mapping(string => mapping(address => bool)) reviewCom;


    
    
    constructor(){
        admin = msg.sender;
    }

    modifier isAdmin(){
        require(msg.sender == admin,"You not admin");
        _;
    }

    //регистрация админа при старте сети используется один раз
    function registerAdmin(string memory fio,string memory userLogin) isAdmin public {
        uint status = uint(UserRoles.admin);
        registerFromAdmin(fio,userLogin,status,msg.sender);
        admins.push(userLogin);
    }

    //регистрация нового админа главным админом
    function regAdmin(address adminAddr,string memory fio,string memory userLogin) public isUserStatus(UserRoles.admin){
        uint status = uint(UserRoles.admin);
        registerFromAdmin(fio,userLogin,status,adminAddr);
        admins.push(userLogin);
    }

    //создание магазина админом
    function registerShop(address shopAddr,string memory number,string memory city) public isUserStatus(UserRoles.admin){
        Shop memory shop = Shop({number:number,city:city,debt:0});
        ShopsList[shopAddr] = shop;
    }

    //регистрация поставщика админом при старте сети
    function registerProvider(string memory providerLogin,address providerAddr) public isAdmin {
        uint status = uint(UserRoles.provider);
        registerFromAdmin("",providerLogin,status,providerAddr);
        provider = providerAddr;
    }

    //регистрация банка при старте сети
    function registerBank(string memory bankLogin,address bankAddr) public isAdmin {
        uint status = uint(UserRoles.bank);
        registerFromAdmin("",bankLogin,status,bankAddr);
    }

    //регистрация продавца самим
    function registerSeller(string memory fio,string memory userLogin,address userAddress,address shopAddr) public {
        uint status = uint(UserRoles.seller);
        registerFromAdmin(fio,userLogin,status,userAddress);
        sellers.push(userAddress);
        salesmen[shopAddr].push(userAddress);
    }

    //регистрация покупателя самим
    function registerBuyer(string memory fio,string memory userLogin,address userAddr) public{
        uint status = uint(UserRoles.buyer);
        registerFromAdmin(fio,userLogin,status,userAddr);
    }

    //банк делает заём магазину по адресу магазина
    function doShopDebt(address payable shopAddr) public isUserStatus(UserRoles.bank) {
        require(payable(msg.sender).balance >= 1000 ether,"Low balance");
        shopAddr.transfer(1000 ether); 
    }  

    //получить информацию для продавца
    function getSellerInfo() public view isUserStatus(UserRoles.seller) returns(
        string memory sellerLogin,
        string memory fio,
        string memory city,
        string memory shopNumber,
        string[] memory reviews
    ){
        User memory sellUser = users[msg.sender];
        address sellShopAddr = salesmanShop[msg.sender];
        Shop memory sellShop = ShopsList[sellShopAddr];
        
        sellerLogin = sellUser.userLogin;
        fio = sellUser.fio;
        city = sellShop.city;
        shopNumber = sellShop.number;
        reviews = sellUser.reviews;
    }

    //получить информацию для покупателя покупателю
    function getBuyerInfo() public view isUser returns(
        string memory userLogin,
        string memory fio,
        uint balance,
        string[] memory reviews
    ){
        User memory user = users[msg.sender];

        userLogin = user.userLogin;
        fio = user.fio;
        balance = payable(msg.sender).balance;
        reviews = user.reviews;
    }

    //получить информацию для админа
    function getAdminInfo() public view isUserStatus(UserRoles.admin) returns(
        string memory login,
        string[] memory userRequests,
        string[] memory adminList,
        address[] memory sellersAddr
    ) {
        User memory user = users[msg.sender];

        login = user.userLogin;
        userRequests = requests;
        adminList = admins;
        sellersAddr = sellers;
    }

    //получить информацию по продавцу по его адресу
    function getSellerInfoByAddr(address sellerAddr) public view isUserStatus(UserRoles.admin)returns(
        string memory sellerLogin,
        string memory fio,
        string memory city,
        string memory shopNumber,
        string[] memory reviews
    ){
        User memory sellUser = users[sellerAddr];
        address sellShopAddr = salesmanShop[sellerAddr];
        Shop memory sellShop = ShopsList[sellShopAddr];
        
        sellerLogin = sellUser.userLogin;
        fio = sellUser.fio;
        city = sellShop.city;
        shopNumber = sellShop.number;
        reviews = sellUser.reviews;
    }

    function createReview(
        address shopAddr,
        string memory userMessage,
        string memory id,
        int grade
    ) public isUser {
        address[] memory likeCount;
        address[] memory disLikeCount;
        Review memory userReview = Review(msg.sender,shopAddr,userMessage,likeCount,disLikeCount,grade);
        shopReviews[shopAddr].push(id);
        users[msg.sender].reviews.push(id);
        reviewId[id] = userReview;
    }

    function likeReview(string memory id) public isUser {
        require(reviewCom[id][msg.sender] == false,"You already check this case");
        reviewId[id].likeCount.push(msg.sender);
        reviewCom[id][msg.sender] = true;
    }

    function disLikeReview(string memory id) public isUser {
        require(reviewCom[id][msg.sender] == false,"You already check this case");
        reviewId[id].disLikeCount.push(msg.sender);
        reviewCom[id][msg.sender] = true;
    }

    function getReviewById(string memory id) public view returns(
        address autorAddr,
        address shopAddr,
        string memory reviewMessage,
        uint likeCount,
        uint disLikeCount,
        int grade
    ){
        Review memory r = reviewId[id];
        autorAddr = r.autorAddress;
        shopAddr = r.shopAddr;
        reviewMessage = r.message;
        likeCount = r.likeCount.length;
        disLikeCount = r.disLikeCount.length;
        grade = r.grade;
    }

    function requestToSeller(string memory id) public isUserStatus(UserRoles.buyer){
        Request memory rq = Request(
            msg.sender,
            uint(UserRoles.buyer),
            uint(UserRoles.seller),
            false
        );
        requestId[id] = rq;
        requests.push(id);
    }

    function downRequestToByer(string memory id) public isUserStatus(UserRoles.seller){
        Request memory rq = Request(
            msg.sender,
            uint(UserRoles.seller),
            uint(UserRoles.buyer),
            false
        );
        requestId[id] = rq;
        requests.push(id);
    }

    function checkRequest(string memory id,bool isAccept) public isUserStatus(UserRoles.admin) {
        Request memory rq = requestId[id];
        uint userRole = rq.desiredRole;
        if (isAccept){
            users[rq.userAddr].status = userRole;
        }
        requestId[id].checked = true;
    }

    function getAllRequests() public view isUserStatus(UserRoles.admin) returns(string[] memory requestsId){
        return requests;
    }

    function deleteShop(address shopAddr) public isUserStatus(UserRoles.admin) {
        address[] memory shopSellers = salesmen[shopAddr];
        for(uint i;i<shopSellers.length;i++){
            address sellerAddr = shopSellers[i];
            users[sellerAddr].status = 0;
        }
        delete ShopsList[shopAddr];
        delete salesmen[shopAddr];
    }

    function getRequestById(string memory id) public view returns(
        address userAddr,
        string memory currentRole,
        string memory desiredRole
    ){
        Request memory rq = requestId[id];
        userAddr = rq.userAddr;
        currentRole = userStatus[rq.currentRole];
        desiredRole = userStatus[rq.desiredRole];
    }





    
    
    
    



    




    


    

    


    
}