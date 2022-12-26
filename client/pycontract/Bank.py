from client.pycontract.DTO.DTO import AdminInfoDTO, ShopDTO, UserDTO,LoginBody,RequestDTO,ReviewDTO, BuyerInfoDTO,ReviewSearch
from client.pycontract.basic.AmidModule import Database,Roles
from client.pycontract.basic.BaseUser import BaseUser


class Bank(BaseUser):
    


    # get list of shop add which ask bank to give money 
    @classmethod
    def get_requests(cls)->list[str]:
        data = Database.call(fun_name="give_shop_requests")
        return data[1]

    # from list of shopAddr which ask bank to give money we accept/decline this request
    def check_request(self,shopAddr):
        data = Database.transact(shopAddr,fun_name="give_shop_money",sender=self.address)
        return data
    