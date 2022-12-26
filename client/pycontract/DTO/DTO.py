from dataclasses import dataclass
import string


@dataclass
class UserDTO:
    address:str
    login:str
    password:str
    fio:str
    status:str

    def __iter__(self):
        return iter((self.address,self.login,self.password,self.fio,self.status))


@dataclass
class ShopDTO:
    number:str
    city:str

    def __iter__(self):
        return iter((self.number,self.city))

@dataclass
class ReviewDTO:
    autor_login:str
    message:str
    likes:int
    dislikes:int 
    mark:int

    def __iter__(self):
        return iter((self.autor_login,self.message,self.likes,self.dislikes,self.mark))

@dataclass
class RequestDTO:
    autor_login:str
    current_role:str
    desired_role:str
    checked:bool
    shopAddr:str = "0x0000000000000000000000000000000000000000"

    def __iter__(self):
        return iter((self.autor_login,self.current_role,self.desired_role,self.checked))


@dataclass
class ReviewSearch:
    shop_addr:str
    autor_login:str

    def __iter__(self):
        return iter((self.shop_addr,self.autor_login))

@dataclass
class LoginBody:
    login:str
    password:str

    def __iter__(self):
        return iter((self.login,self.password))


@dataclass
class BuyerInfoDTO:
    address:str
    fio:str
    shops:list[str]
    login:str
    balance:int
    

@dataclass
class AdminInfoDTO:
    admins:list[str]
    user_requests:list[str]
    shops:list[str]
    login:str


@dataclass
class SellerInfoDTO:
    login:str
    fio:str
    city:str
    shopAddr:str
    shops:list[str]

@dataclass
class MainShopDTO:
    number:str
    city:str
    balance:int