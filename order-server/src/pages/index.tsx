import React, { useEffect, useState } from 'react';
import { SignTypedDataVersion, TypedDataUtils, TypedMessage } from "@metamask/eth-sig-util";
 


const Index = () => {
  const [accounts, setAccounts] = useState<string[]>([]);
  const [signature, setSignature] = useState<string[]>([]);


  const order = {
    orderType: 1,  // Ask
    isFulfilled: false,
    globalNonce: 1,
    subsetNonce: 2,
    orderNonce: 3,
    collectionType: 0,  // ERC721
    collection: '0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2',
    currency: '0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c',
    signer: '0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db',
    startTime: '1672444800', //20230101
    endTime: '1703980800', // 20231231
    price: '1000000000000000000', //1 ETH
    itemIds: [1, 2, 3],
    amounts: [1, 1, 1]
  };  
  
  const typeDataMaker =  {EIP712Domain: [
    { name: "name", type: "string" },
    { name: "version", type: "string" },
    { name: "chainId", type: "uint256" },
    { name: "verifyingContract", type: "address" }
  ],
  Maker: [
    { name: "orderType", type: "uint8" },
    { name: "isFulfilled", type: "bool" },
    { name: "globalNonce", type: "uint256" },
    { name: "subsetNonce", type: "uint256" },
    { name: "orderNonce", type: "uint256" },
    { name: "collectionType", type: "uint8" },
    { name: "collection", type: "address" },
    { name: "currency", type: "address" },
    { name: "signer", type: "address" },
    { name: "startTime", type: "uint256" },
    { name: "endTime", type: "uint256" },
    { name: "price", type: "uint256" },
    { name: "itemIds", type: "uint256[]" },
    { name: "amounts", type: "uint256[]" }
  ]}


  const orderTypedData:TypedMessage<typeof typeDataMaker> = {
    types: typeDataMaker,
    primaryType: "Maker",
    domain: {
      name: "Orderbook-v1",
      version: "4",
      chainId: 11155111, // Sepolia
      verifyingContract: "0x8865d9736Ad52c6cdBbEA9bCd376108284CFd0e4"
    },
    message: {
      ...order
    }
  };

  console.log('encodeData',TypedDataUtils.encodeData(orderTypedData.primaryType,orderTypedData.message,orderTypedData.types,SignTypedDataVersion.V4).toString('hex'));
  console.log('hashStruct',TypedDataUtils.hashStruct(orderTypedData.primaryType,orderTypedData.message,orderTypedData.types,SignTypedDataVersion.V4).toString('hex'));
  console.log('encodeType', TypedDataUtils.encodeType(orderTypedData.primaryType,orderTypedData.types));
  console.log('eip712DomainHash', TypedDataUtils.eip712DomainHash(orderTypedData,SignTypedDataVersion.V4).toString('hex'));
  console.log('eip712DomainHash', TypedDataUtils.eip712Hash(orderTypedData,SignTypedDataVersion.V4).toString('hex'));

  useEffect(() => {
    if ((window as any).ethereum) {
      (window as any).ethereum.request({ method: 'eth_requestAccounts' })
        .then((accounts: string[]) => {
          console.log('accounts', accounts)
          setAccounts(accounts);
        })
        .catch((err: any) => {
          console.error(err);
        });
    }
  }, []);

  const signMessage = async () => {
    const signature = await (window as any).ethereum.request({ method: 'eth_signTypedData_v4', params: [accounts[0], JSON.stringify(orderTypedData)] })
    console.log('signature :', signature);
    setSignature(signature)

  }

  return (
    <div>
      <h2>Account</h2>
      <p>{accounts[0]}</p>
      <h2>Message:</h2>
      <p>{''}</p>
      <button onClick={signMessage}>Sign Message</button>
      <h2>Signature:</h2>
      <p>{signature}</p>
    </div>
  );
}

export default Index;