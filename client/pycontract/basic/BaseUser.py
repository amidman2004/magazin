from client.pycontract.DTO.DTO import AdminInfoDTO, ShopDTO, UserDTO,LoginBody,RequestDTO,ReviewDTO, BuyerInfoDTO,ReviewSearch
from client.pycontract.basic.AmidModule import Database,Roles



class BaseUser:
    def __init__(self,login:str,address:str):
        self.login = login
        self.address = address

    def auth(self,password)->UserDTO | None:
        login_body = LoginBody(self.login,password)
        data = Database.call(*login_body,fun_name="auth")
        if (data[0]):
            return UserDTO(*data[1])
        return None

    @classmethod
    def get_shops(cls) -> list[str]:
        return Database.call(fun_name="get_shops")[1]

    def get_user_balance(self):
        balance = Database.balance(self.address)
        return balance