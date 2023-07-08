import BN from 'bn.js';

enum OrderType {
  Ask = 0,
  Bid = 1
}

enum CollectionType {
  ERC721 = 0,
  ERC1155 = 1
}

export type Maker = {
  orderType: OrderType;
  globalNonce: number;
  subsetNonce: number;
  orderNonce: number;
  collectionType: CollectionType;
  collection: string;
  currency: string;
  signer: string;
  startTime: number;
  endTime: number;
  price: BN | number;
  itemIds: number[];
  amounts: number[];
};
