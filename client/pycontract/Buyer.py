from lib2to3.pytree import Base
from client.pycontract.DTO.DTO import UserDTO,LoginBody,RequestDTO,ReviewDTO, BuyerInfoDTO,ReviewSearch
from client.pycontract.basic.AmidModule import Database,Roles
from client.pycontract.basic.BaseUser import BaseUser


class Buyer(BaseUser):

    @classmethod
    def register_exist_account(cls,user_dto:UserDTO):
        user_dto.status = Roles.BUYER
        Database.unlock(user_dto)
        data = Database.transact(*user_dto,fun_name="register_buyer")
        return data
    
    @classmethod
    def register_new_account(cls,user_dto:UserDTO,ether:int = 0):
        user_dto.status = Roles.BUYER
        user_dto.address = Database.create_account(user_dto.password,ether)
        Database.unlock(user_dto)
        data = Database.transact(*user_dto,fun_name="register_buyer")
        return data

    # get info by userlogin
    # return userdto, balance and list of shopsaddr
    # by list of shops we can get list of userlogins which send review in same shop
    # by userlogin we can get review dto 
    def get_buyer_info(self) -> BuyerInfoDTO | None:
        data = Database.call(self.login,fun_name="buyer_info")
        address = data[1][0]
        balance = int(Database.balance(address))
        buyer_info = BuyerInfoDTO(*data[1],login=self.login,balance=balance)
        if buyer_info.fio and buyer_info.shops:
            return buyer_info
        return None

    # we list of shops addr
    # every shop addr have list of userlogins which send review to this shop
    # with shop addr and user login we can get ReviewDTO
    @classmethod
    def get_review(cls,review_search:ReviewSearch) -> ReviewDTO | None:
        data = Database.call(*review_search,fun_name="get_user_review")
        review_dto = ReviewDTO(*data[1])
        if review_dto.autor_login != "":
            return review_dto
        return None

    # we want levelup to seller of shop
    # we have list of shop addresses
    # by shop address we create request
    def create_request(self,shopAddr):
        data = Database.transact(self.login,shopAddr,fun_name="create_request_buyer")
        return data

    # we have list of shops
    @classmethod
    def create_review(cls,shopAddr,review_dto:ReviewDTO):
        review_dto.likes = 0
        review_dto.dislikes = 0
        data = Database.transact(shopAddr,*review_dto,fun_name="create_review")
        return data
    
    # by shop addr and autor login we find needed review and like it
    def like_review(self,review_search:ReviewSearch):
        data = Database.transact(self.login,*review_search,fun_name="like_review")
        return data

    # by shop addr and autor login we find needed review and dislike it
    def dislike_review(self,review_search:ReviewSearch):
        data = Database.transact(self.login,*review_search,fun_name="dislike_review")
        return data

    
