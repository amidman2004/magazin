from client.pycontract.DTO.DTO import AdminInfoDTO, SellerInfoDTO, ShopDTO, UserDTO,LoginBody,RequestDTO,ReviewDTO, BuyerInfoDTO,ReviewSearch
from client.pycontract.basic.AmidModule import Database,Roles
from client.pycontract.basic.BaseUser import BaseUser


class Seller(BaseUser):

    @classmethod
    def add_new_seller(cls,shop_addr,user_dto:UserDTO,ether=0):
        user_dto.address = Database.create_account(user_dto.password,ether=ether)
        user_dto.status = Roles.SELLER
        data = Database.transact(*user_dto,shop_addr,fun_name="register_seller")
        return data

    def create_request(self):
        data = Database.transact(self.login,fun_name="create_request_seller")
        return data
    
    def get_seller_info(self) -> SellerInfoDTO | None:
        data = Database.call(self.login,fun_name="seller_info")
        if not data[0]:
            return data[1]
        seller_dto = SellerInfoDTO(self.login,*data[1])
        if seller_dto.city and seller_dto.fio:
            return seller_dto
        return None

    @classmethod
    def create_review(cls,shopAddr,review_dto:ReviewDTO):
        review_dto.likes = 0
        review_dto.dislikes = 0
        review_dto.mark = 0
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

