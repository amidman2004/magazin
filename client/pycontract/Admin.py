from client.pycontract.DTO.DTO import AdminInfoDTO, ShopDTO, UserDTO,LoginBody,RequestDTO,ReviewDTO, BuyerInfoDTO,ReviewSearch
from client.pycontract.basic.AmidModule import Database,Roles
from client.pycontract.basic.BaseUser import BaseUser


class Admin(BaseUser):

    def get_admin_info(self) -> AdminInfoDTO:
        data = Database.call(fun_name="admin_info")
        admin_info = AdminInfoDTO(*data[1],login=self.login)
        return admin_info

    # we have list of shopAddresses
    # in info screen we can see list of sellerlogins 
    @classmethod
    def get_shop_sellers(cls,shopAddr) -> list[str]:
        data = Database.call(shopAddr,fun_name="shopSellers")
        return data[1]

    # we have list of user_logins which send request
    # and in info screen we get RequestDTO which provide this method
    @classmethod
    def get_request_dto(cls,user_login) -> RequestDTO | None:
        request_dto = RequestDTO(*Database.call(user_login,fun_name="userRequest")[1])
        if (request_dto.autor_login and not request_dto.checked):
            return request_dto
        return None
    # get of list user logins which send requests
    @classmethod
    def get_request_user(cls) -> set[str]:
        users = set(Database.call(fun_name="userRequestList")[1])
        return users

    @classmethod
    def register_exist_shop(cls,shop_address,shop_dto:ShopDTO):
        data = Database.transact(shop_address,*shop_dto,fun_name="add_shop")
        return data

    @classmethod
    def register_new_shop(cls,shop_dto:ShopDTO,ether:int):
        shop_address = Database.create_account(shop_dto.city,ether=ether)
        data = Database.transact(shop_address,*shop_dto,fun_name="add_shop")
        return data

    @classmethod
    def add_exist_admin(cls,user_dto:UserDTO):
        user_dto.status = Roles.ADMIN
        data = Database.transact(*user_dto,fun_name="register_admin")
        return data

    @classmethod
    def add_new_admin(cls,user_dto:UserDTO,ether=0):
        user_dto.status = Roles.ADMIN
        user_dto.address = Database.create_account(user_dto.password,ether=0)
        data = Database.transact(*user_dto,fun_name="register_admin")
        return data

    @classmethod
    def add_provider(cls,user_dto:UserDTO):
        user_dto.status = Roles.PROVIDER
        data = Database.transact(*user_dto,fun_name="register_buyer")
        return data

    @classmethod
    def check_request(cls,user_login,is_accept):
        data = Database.transact(user_login,is_accept,fun_name="check_request")
        return data

    @classmethod
    def delete_shop(cls,shop_addr):
        data = Database.transact(shop_addr,fun_name="delete_shop")
        return data


