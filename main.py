from audioop import add
from dataclasses import dataclass
from time import sleep
from web3.auto import w3
from client.pycontract.Admin import Admin
from client.pycontract.Bank import Bank
from client.pycontract.Shop import Shop
from client.pycontract.Seller import Seller
from client.pycontract.basic.AmidModule import Database
from client.pycontract.DTO.DTO import ShopDTO, UserDTO,MainShopDTO
from client.pycontract.Buyer import Buyer
from web3.middleware import geth_poa



w3.middleware_onion.inject(geth_poa.geth_poa_middleware, layer=0)

# bank = "0x6bDD6631816fFE844a92dA7cC7edEd62ed1BcdC3"#Database.create_account("bank")
# provider = "0x9902F47450FE66b049C894FCbF8F88E97Ba1F321"#Database.create_account("gold_fish")
bank = Database.create_account("bank")
provider = Database.create_account("gold_fish")

Database.deploy(bank)

provider_dto = UserDTO(
    provider,"gold_fish","provider","gold_fish",""
)
admin_dto = UserDTO(
    "ivan","ivan","ivan","Ivanov","admin"
)

provider_data = Admin.add_provider(
    provider_dto
)
print("provider data is ",provider_data[1])

admin_data = Admin.add_new_admin(
    admin_dto,50
)

print("admin data is ",admin_data[1])

shops = [
    MainShopDTO("1","dimitrov",1000),
    MainShopDTO("2","kaluga",900),
    MainShopDTO("3","moscow",1050),
    MainShopDTO("4","razan",700),
    MainShopDTO("5","samara",2000),
    MainShopDTO("6","spb",2300),
    MainShopDTO("7","taganrog",0),
    MainShopDTO("8","tomsk",780),
    MainShopDTO("9","habarovsk",1500),
]

for shop in shops:
    shop_dto = ShopDTO(
        shop.number,
        shop.city
    )
    shop_data = Admin.register_new_shop(
        shop_dto,shop.balance
    )
    print(
        f"shop number {shop.number} data is ", shop_data[1]
    )

shop_addr = Buyer.get_shops()[0]
seller_dto = UserDTO(
    "pofig","semen","semen","Semenov","pofig"
)
seller_data = Seller.add_new_seller(shop_addr,seller_dto,70)
print("seller data is ",seller_data[1])

buyer_dto = UserDTO(
    "pofig","petr","petr","Petrov","pofig"
)
buyer_data = Buyer.register_new_account(buyer_dto,80)
print("buyer data is ", buyer_data[1])

login_data = Buyer(
    login="petr",
    address="pofig"
).auth("petr")
print("buyer ",login_data)

login_data = Buyer(
    login="semen",
    address="pofig"
).auth("semen")
print("seller ",login_data)

login_data = Buyer(
    login="ivan",
    address="pofig"
).auth("ivan")
print("admin ",login_data)

print("shops ",Buyer.get_shops())


login_data = Shop(
    login="samara",
    address="pofig"
).auth("samara")
print("shop ",login_data)

info = Buyer(login="petr",address="pofig").get_buyer_info()

print(info)
