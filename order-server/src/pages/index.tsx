import React, { useEffect, useState } from 'react';
import Web3 from 'web3';
import BN from 'bn.js';
const web3 = new Web3();
import  '../utils/signature'

 

const MyComponent = () => {
    const [accounts, setAccounts] = useState<string[]>([]);
    const [signature, setSignature] = useState<string>('');

    const order = {
        orderType: 1,
        isFulfilled: false,
        globalNonce: 1,
        subsetNonce: 2,
        orderNonce: 3,
        collectionType: 0,
        collection: '0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2',
        currency: '0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c',
        signer: '0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db',
        startTime: 1672444800,
        endTime: 1703980800,
        price: new BN('1000000000000000000'),
        itemIds: [1, 2, 3],
        amounts: [1, 1, 1]
    };
    const message = JSON.stringify(order);

    useEffect(() => {
        if ((window as any).ethereum) {
            (window as any).ethereum.request({ method: 'eth_requestAccounts' })
            .then((accounts: string[]) => {
              console.log('accounts',accounts)
                setAccounts(accounts);
            })
            .catch((err: any) => {
                console.error(err);
            });
        }
    }, []);

    const signMessage = async () => {
        if (accounts.length > 0 && (window as any).ethereum) {
            const signer = accounts[0];
            const signature = await (window as any).ethereum.request({
                method: 'personal_sign',
                params: [message, signer]
            });
            setSignature(signature);
        }
    }

    return (
        <div>
            <h2>Message:</h2>
            <p>{message}</p>
            <button onClick={signMessage}>Sign Message</button>
            <h2>Signature:</h2>
            <p>{signature}</p>
        </div>
    );
}

export default MyComponent;