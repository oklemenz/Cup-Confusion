//
//  StoreClient.h
//  CupConfusion
//
//  Created by Oliver on 18.03.12.
//  Copyright (c) 2012 Oliver Klemenz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface StoreClient : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    NSArray *storeProducts;
}

@property BOOL storeAvailable;

+ (StoreClient *)instance;

- (BOOL)isStoreAvailable;
- (void)requestProductData;
- (void)provideProduct:(NSString *)product;
- (void)purchaseProduct:(NSString *)product;

- (NSArray *)getStoreProducts;
- (void)purchaseProductAtIndex:(int)index;

@end
