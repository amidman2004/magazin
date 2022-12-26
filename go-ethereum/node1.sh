#!/bin/bash
geth --datadir node1 --bootnodes enode://0d89ab9d15e0032834d0c7dd66e9f25e77e28fddd205620ed376616a509444029dd34ae0b855b7a4a22c391d9acb81af9d90c5745c27f1cfbcf0d6eca7baddc9@127.0.0.1:0?discport=1111 --http --http.addr "0.0.0.0" --allow-insecure-unlock --http.api "debug,admin,txpool,personal,net,miner,web3,eth" --unlock 0x18732227F6254af748ae00Fb3F6498400EF4dE46 --password coinbase.txt
