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
  isFulfilled: boolean;
  globalNonce: number;
  subsetNonce: number;
  orderNonce: number;
  collectionType: CollectionType;
  collection: string;
  currency: string;
  signer: string;
  startTime: number;
  endTime: number;
  price: BN;
  itemIds: number[];
  amounts: number[];
};
