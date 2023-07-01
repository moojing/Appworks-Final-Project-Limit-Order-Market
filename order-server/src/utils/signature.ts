import  Web3 from 'web3';
import {Maker} from '../types';
import BN from 'bn.js';
const web3 = new Web3(); 

function getMessageHash(order:Maker) {
    return web3.utils.soliditySha3(
        { t: 'uint8', v: order.orderType },
        { t: 'bool', v: order.isFulfilled },
        { t: 'uint256', v: order.globalNonce },
        { t: 'uint256', v: order.subsetNonce },
        { t: 'uint256', v: order.orderNonce },
        { t: 'uint8', v: order.collectionType },
        { t: 'address', v: order.collection },
        { t: 'address', v: order.currency },
        { t: 'address', v: order.signer },
        { t: 'uint256', v: order.startTime },
        { t: 'uint256', v: order.endTime },
        { t: 'uint256', v: order.price },
        { t: 'uint256[]', v: order.itemIds },
        { t: 'uint256[]', v: order.amounts }
    );
}

function getEthSignedMessageHash(messageHash: string) {
    const prefix = "\x19Ethereum Signed Message:\n32";
    const prefixedHash = web3.utils.soliditySha3(prefix, messageHash);
    return prefixedHash;
}

// async function signHash(account, password, hash) {
//     let signature = await web3.eth.personal.sign(hash, account, password);
//     return signature;
// }

let account = "yourAccount";  // 要签名的账户地址
let password = "yourPassword";  // 账户的密码
let order:Maker = {
  orderType: 1,
  isFulfilled: false,
  globalNonce: 1,
  subsetNonce: 2,
  orderNonce: 3,
  collectionType: 0,
  collection: '0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2',
  currency: '0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c',
  signer: '0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db',
  startTime: 1672444800, //20230101
  endTime: 1703980800, // 20231231
  price: new BN('1000000000000000000'), //1 ETH
  itemIds: [1, 2, 3], // Assuming these are your itemIds
  amounts: [1, 1, 1] // Assuming these are your amounts
};

let messageHash = getMessageHash(order);
let ethSignedMessageHash = getEthSignedMessageHash(messageHash||'');
console.log('ethSignedMessageHash :', ethSignedMessageHash);

// signHash(account, password, ethSignedMessageHash).then(signature => {
//     console.log("Signature:", signature);
// }).catch(error => {
//     console.error("An error occurred:", error);
// });