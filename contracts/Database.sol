// SPDX-License-Identifier: Unlicense


pragma solidity ^0.8.0;


struct User{
    address userAddr;
    string login;
    string password;
    string fio;
    string status;
}

struct Shop{
    string number;
    string city;
}

struct Review{
    string autorLogin;
    string message;
    uint likes;
    uint dislikes;
    uint mark;
}

struct Request{
    string autor;
    string currentRole;
    string desiredRole;
    bool checked;
    address shopAddr;
}

contract Database{

    string[] admins;
    address[] shopsAddr;

    address public bank;

    mapping(string => User) public users; // login to UserDTO


    mapping(string => Request) public userRequest; //login to Request
    string[] userRequestList; // list of user logins which wait admin check


    mapping(address => uint) public shopDebts;
    address[] shopRequests;

    mapping(address => string[]) public shopSellers; // shop addr to login list
    mapping(string => address) public sellerToShop;

    mapping(address => Shop) public shops; // shop addr to ShopDTO

    mapping(address => string[]) public shopsReviews; // shop addr to user logins list

    mapping(string => mapping(address => Review)) public userReviews; // user login to mapping shop address to Request dto

    mapping(address => mapping(string => mapping(string => bool))) public userActions;


    constructor(address _bank){
        bank = _bank;
        users["bank"] = User(_bank,"bank","bank","bank","bank");
    }
    
    modifier isLoginUnique(string memory login) {
        require(users[login].userAddr == address(0),"Login already exist");
        _;
    }

    function compare(string memory a,string memory b) private pure returns(bool){
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    modifier isUserStatus(string memory userLogin,string memory userStatus){
        require(compare(users[userLogin].status,userStatus),"Wrong Role");_;
    }
    
    function get_admins() public view returns(string[] memory){
        return admins;
    }
    function get_shops() public view returns(address[] memory){
        return shopsAddr;
    }

    function register_admin(
        address userAddr,
        string memory login,
        string memory password,
        string memory fio,
        string memory status
    ) isLoginUnique(login) public {
        admins.push(login);
        User memory newUser = User(userAddr,login,password,fio,status);
        users[login] = newUser;
    }

    function admin_info() public view returns(
        string[] memory adminLogin,
        string[] memory requests,
        address[] memory shopAddrList
    ){
        adminLogin = admins;
        requests = userRequestList;
        shopAddrList = shopsAddr;
    }


    function register_seller(
        address userAddr,
        string memory login,
        string memory password,
        string memory fio,
        string memory status,
        address shopAddr
    ) public isLoginUnique(login){
        User memory newUser = User(userAddr,login,password,fio,status);
        users[login] = newUser;
        shopSellers[shopAddr].push(login);
        sellerToShop[login] = shopAddr;
    }

    function seller_info(string memory seller_login) public view returns(
        string memory fio,
        string memory city,
        address shopAddr,
        address[] memory shopAddrList
    ){
        fio = users[seller_login].fio;
        city = shops[sellerToShop[seller_login]].city;
        shopAddr = sellerToShop[seller_login];
        shopAddrList = shopsAddr;
    }

    function register_buyer(
        address userAddr,
        string memory login,
        string memory password,
        string memory fio,
        string memory status
    ) public isLoginUnique(login) {
        User memory newUser = User(userAddr,login,password,fio,status);
        users[login] = newUser;
    }

    function buyer_info(string memory user_login) public view returns(
        address userAddress,
        string memory fio,
        address[] memory shopAddressList
    ){
        userAddress = users[user_login].userAddr;
        fio = users[user_login].fio;
        shopAddressList = shopsAddr;
    }

    function add_shop(
        address shopAddr,

        string memory number,
        string memory city
    ) public isLoginUnique(city){
        shopsAddr.push(shopAddr);
        shops[shopAddr] = Shop(number,city);
        users[city] = User(shopAddr,city,city,city,"shop");
    }

    function delete_shop(address shopAddr) public {
        require(!compare(shops[shopAddr].number,""),"Shop doesnt exist");
        uint index;
        for (uint i; i<shopsAddr.length;i++){
            if (shopsAddr[i] == shopAddr){
                index = i;
            }
        }
        shopsAddr[index] = shopsAddr[shopsAddr.length - 1];
        shopsAddr.pop();
        for (uint i; i<shopSellers[shopAddr].length; i++){
            string memory sellerLogin = shopSellers[shopAddr][i];
            users[sellerLogin].status = "buyer";
            delete sellerToShop[sellerLogin]; 
        }
    }

    function ask_money(address shopAddr) public {
        shopRequests.push(shopAddr);
    }

    function get_shop_requests() public view returns(address[] memory){
        return shopRequests;
    }

    function give_shop_money(
        address shopAddr
    ) public {
        require(msg.sender == bank,"You not bank");
        payable(shopAddr).transfer(1000 ether);
        shopDebts[shopAddr] += 1000 ether;
        for (uint i;i<shopRequests.length;i++){
            if(shopAddr == shopRequests[i]){
                shopRequests[i] = shopRequests[shopRequests.length -1];
                shopRequests.pop();
            }
        }
    }

    function auth(
        string memory login,
        string memory password
    ) public view returns(User memory){
        User memory u = users[login];
        require(u.userAddr != address(0),"User doesnt exist");
        require(compare(u.password,password),"Wrong password");
        return u;
    }

    function create_request_buyer(
        string memory autor,
        address shopAddr
    ) public {
        Request memory req = Request(autor,"buyer","seller",false,shopAddr);
        userRequest[autor] = req;
        userRequestList.push(autor);
    }
    function create_request_seller(
        string memory autor
    ) public {
        Request memory req = Request(autor,"seller","buyer",false,address(0));
        userRequest[autor] = req;
        userRequestList.push(autor);
    }

    function get_requests() public view returns(string[] memory){
        return userRequestList;
    }

    function check_request(
        string memory userLogin,
        bool isAccept
    ) public {
        Request memory req = userRequest[userLogin];
        if (isAccept){
            users[userLogin].status = req.desiredRole;
        }
        
        if (req.shopAddr != address(0)){
            shopSellers[req.shopAddr].push(userLogin);
            sellerToShop[userLogin] = req.shopAddr;
        }else{
            for (uint i; i<shopSellers[req.shopAddr].length; i++){
                if (compare(shopSellers[req.shopAddr][i],userLogin)){
                    shopSellers[req.shopAddr][i] = shopSellers[req.shopAddr][shopSellers[req.shopAddr].length - 1];
                    shopSellers[req.shopAddr].pop();
                    delete sellerToShop[userLogin];
                }
            }
        }
        userRequest[userLogin].checked = true;
        
    }

    function create_review(
        address shopAddr,

        string memory autorLogin,
        string memory message,
        uint likes,
        uint dislikes,
        uint mark
    ) public {
        Review memory rev = Review(autorLogin,message,likes,dislikes,mark);
        shopsReviews[shopAddr].push(autorLogin); 
        userReviews[autorLogin][shopAddr] = rev;
        userActions[shopAddr][autorLogin][autorLogin] = true;
    }

    function get_user_review(
        address shopAddr,
        string memory userLogin
    ) public view returns(Review memory){
        return userReviews[userLogin][shopAddr];
    }

    function like_review(
        string memory user_login,
        address shopAddr,
        string memory autorLogin
    ) public {
        require(!userActions[shopAddr][autorLogin][user_login],"You already do action");
        userReviews[autorLogin][shopAddr].likes++;
        userActions[shopAddr][autorLogin][user_login] = true;
    }

    function dislike_review(
        string memory user_login,
        address shopAddr,
        string memory autorLogin
    ) public {
        require(!userActions[shopAddr][autorLogin][user_login],"You already do action");
        userReviews[autorLogin][shopAddr].dislikes++;
        userActions[shopAddr][autorLogin][user_login] = true;
    }

    
    
}