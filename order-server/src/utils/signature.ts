import Web3 from 'web3';
const web3 = new Web3();
// import { Maker } from '../types';

// function getMessageHash(order:Maker) {
//     return web3.utils.soliditySha3(
//         { t: 'uint8', v: order.orderType },
//         { t: 'bool', v: order.isFulfilled },
//         { t: 'uint256', v: order.globalNonce },
//         { t: 'uint256', v: order.subsetNonce },
//         { t: 'uint256', v: order.orderNonce },
//         { t: 'uint8', v: order.collectionType },
//         { t: 'address', v: order.collection },
//         { t: 'address', v: order.currency },
//         { t: 'address', v: order.signer },
//         { t: 'uint256', v: order.startTime },
//         { t: 'uint256', v: order.endTime },
//         { t: 'uint256', v: order.price },
//         { t: 'uint256[]', v: order.itemIds },
//         { t: 'uint256[]', v: order.amounts }
//     );
// }


export function getEncodedStructData(order: any) {
    console.log('order raw hash...', web3.eth.abi.encodeParameters(
        [
            'uint8', 'bool',
            'uint256', 'uint256',
            'uint256', 'uint8',
            'address', 'address',
            'address', 'uint256',
            'uint256', 'uint256',
            'uint256[]', 'uint256[]'
        ],
        [
            order.orderType, order.isFulfilled,
            order.globalNonce, order.subsetNonce,
            order.orderNonce, order.collectionType,
            order.collection, order.currency, order.signer,
            order.startTime, order.endTime, order.price,
            order.itemIds, order.amounts
        ]
    ));
    return web3.utils.keccak256(
        web3.eth.abi.encodeParameters(
            [
                'uint8', 'bool',
                'uint256', 'uint256',
                'uint256', 'uint8',
                'address', 'address',
                'address', 'uint256',
                'uint256', 'uint256',
                'uint256[]', 'uint256[]'
            ],
            [
                order.orderType, order.isFulfilled,
                order.globalNonce, order.subsetNonce,
                order.orderNonce, order.collectionType,
                order.collection, order.currency, order.signer,
                order.startTime, order.endTime, order.price,
                order.itemIds, order.amounts
            ]
        )
    )
}

