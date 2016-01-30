
#import "cocos2d.h"
#import <StoreKit/StoreKit.h>
#import <SpriteKit/SpriteKit.h>
UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

enum validationStates{
    
    stateValidation_None    = 1,
    stateValidation_Passed  = 2,
    stateValidation_Hacked  = 3,
    
};

@interface IAPHelper : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver,UIAlertViewDelegate>
{
    SKProductsRequest * _productsRequest;
    SKNode *parent__;
    NSString *identifier_;
    BOOL isPurchasedNow;
    BOOL isRestoringNow;
}
@property (assign) BOOL isPurchasedNow;
@property (assign) BOOL isRestoringNow;

- (id)init;
- (void)requestProductsWithIndetifier:(NSString *)_indetifier parent:(SKNode *)sender;
- (void)buyProduct:(SKProduct *)product;
- (void)restoreCompletedTransactionsWithparent:(SKNode *)sender;


- (void)calculatePoits:(NSString *)indetifier;

@end