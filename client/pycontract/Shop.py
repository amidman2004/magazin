from client.pycontract.DTO.DTO import AdminInfoDTO, ShopDTO, UserDTO,LoginBody,RequestDTO,ReviewDTO, BuyerInfoDTO,ReviewSearch
from client.pycontract.basic.AmidModule import Database,Roles
from client.pycontract.basic.BaseUser import BaseUser



class Shop(BaseUser):
    

    def ask_money(self):
        data = Database.transact(self.address,fun_name="ask_money")
        return data

    