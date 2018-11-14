//
//  StoreClient.m
//  CupConfusion
//
//  Created by Oliver on 18.03.12.
//  Copyright (c) 2012 Oliver Klemenz. All rights reserved.
//

#import "StoreClient.h"
#import "AppDelegate.h"
#import "GameView.h"
#import "GameData.h"

@implementation StoreClient

@synthesize storeAvailable;

+ (StoreClient *)instance {
	static StoreClient *_instance;
	@synchronized(self) {
		if (!_instance) {
			_instance = [[StoreClient alloc] init];
		}
	}
	return _instance;
}

- (id)init {
	if ((self = [super init])) {
        storeAvailable = [self isStoreAvailable];
        if (storeAvailable) {
            [self requestProductData];
            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        }
	}
	return self;
}

- (BOOL)isStoreAvailable {
    return [SKPaymentQueue canMakePayments];
}

- (void)requestProductData {
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:
                                  [NSSet setWithObjects: @"de.oklemenz.CupConfusion.Pool_1000000", 
                                                         @"de.oklemenz.CupConfusion.Pool_10000000",
                                                         @"de.oklemenz.CupConfusion.Pool_100000000", nil]];
    request.delegate = self;
    [request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    storeProducts = response.products;
    storeProducts = [storeProducts sortedArrayUsingComparator:^(id a, id b) {
        int index;
        SKProduct *p1 = (SKProduct *)a;
        index = (int)([p1.productIdentifier rangeOfString :@"_" options:NSBackwardsSearch].location);
        int points1 = [[p1.productIdentifier substringFromIndex:index+1] intValue];
        SKProduct *p2 = (SKProduct *)b;
        index = (int)([p2.productIdentifier rangeOfString :@"_" options:NSBackwardsSearch].location);
        int points2 = [[p2.productIdentifier substringFromIndex:index+1] intValue];
        return [[NSNumber numberWithInt:points1] compare:[NSNumber numberWithInt:points2]];
    }];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    GameView *gameView = (GameView *)[[AppDelegate instance].viewController view];
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self provideProduct:transaction.payment.productIdentifier];
                [gameView stopRotatingCoin];
                break;
            case SKPaymentTransactionStateFailed:
                if (transaction.error.code != SKErrorPaymentCancelled) {                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PURCHASE_FAILED", nil) message:NSLocalizedString(@"PURCHASE_FAILED_MSG", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK_BTN", nil) otherButtonTitles:nil];
                    [alert show];
                }
                [gameView stopRotatingCoin];
                break;
            case SKPaymentTransactionStateRestored:
                [self provideProduct:transaction.originalTransaction.payment.productIdentifier];
                [gameView stopRotatingCoin];
                break;
            default:
                break;
        }
        if (transaction.transactionState != SKPaymentTransactionStatePurchasing) {
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
    }
}

- (void)purchaseProduct:(NSString *)product {
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)provideProduct:(NSString *)product {
    GameView *gameView = (GameView *)[[AppDelegate instance].viewController view];
    int index = (int)([product rangeOfString:@"_" options:NSBackwardsSearch].location);
    int points = [[product substringFromIndex:index+1] intValue];
    [[GameData instance] updateBoughtPoolWith:points];  
    [gameView notifyPoolBought:points];
}

- (NSArray *)getStoreProducts {
    return storeProducts;
}

- (void)purchaseProductAtIndex:(int)index {
    SKProduct *storeProduct = [storeProducts objectAtIndex:index];
    [self purchaseProduct:storeProduct.productIdentifier];
}

@end
