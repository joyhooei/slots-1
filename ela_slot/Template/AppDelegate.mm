//
//  AppDelegate.mm
//  Template
//
//  Created by Slavian on 2013-08-17.
//  Copyright bsixlux 2013. All rights reserved.
//

//
#import "cocos2d.h"
#import "AnalyticsManager.h"
//#import <FSAnalytics/FSAnalytics.h>
#import "AppDelegate.h"
#import "IntroLayer.h"
#import "HelloWorldLayer.h"
#import "Menu.h"
#import "BBXBeeblex.h"
#import "ALSdk.h"
#import "cfg.h"

#import "b6luxLoadingView.h"
#import <Chartboost/Chartboost.h>
#import <CommonCrypto/CommonDigest.h>
#import <AdSupport/AdSupport.h>

#import "IDSTOREPLACE.h"



@implementation MyNavigationController 
    


// The available orientations should be defined in the Info.plist file.
// And in iOS 6+ only, you can override it in the Root View controller in the "supportedInterfaceOrientations" method.
// Only valid for iOS 6+. NOT VALID for iOS 4 / 5.
-(NSUInteger)supportedInterfaceOrientations {
	
	// iPhone only
	if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
		return UIInterfaceOrientationMaskLandscape;
	
	// iPad only
	return UIInterfaceOrientationMaskLandscape;
}

// Supported orientations. Customize it for your own needs
// Only valid on iOS 4 / 5. NOT VALID for iOS 6.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// iPhone only
	if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
		return UIInterfaceOrientationIsLandscape(interfaceOrientation);
	
	// iPad only
	// iPhone only
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

// This is needed for iOS4 and iOS5 in order to ensure
// that the 1st scene has the correct dimensions
// This is not needed on iOS6 and could be added to the application:didFinish...
-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil) {
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
		[director runWithScene: [HelloWorldLayer scene]];
	}
}
@end


@implementation AppController

@synthesize window=window_, navController=navController_, director=director_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    NSString* uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    // Setup Analytics with tracking ID and device ID.
    [[AnalyticsManager sharedManager] setupWithTrackingID:@"UA-65793508-6" dispatchInterval:20 sampleRate:50.0 userID: uuid];
    
    
    // Setup Chartboost
    [Chartboost startWithAppId:chartBoostAppID
                  appSignature:chartBoostAppSignature
                      delegate:self];
    [ALSdk initializeSdk];
    [Chartboost cacheInterstitial:CBLocationHomeScreen];
    [Chartboost cacheInterstitial:CBLocationGameOver];
    [Chartboost cacheRewardedVideo:CBLocationMainMenu];
    [Chartboost cacheMoreApps:CBLocationHomeScreen];
	
    //lots of your initialization code
    
    if ([shoudlStartPushWoosh  isEqual: @YES]) {
        NSLog(@"STARTING PUSHWOOSH!");
        //-----------PUSHWOOSH PART-----------
        // set custom delegate for push handling, in our case - view controller
        PushNotificationManager * pushManager = [PushNotificationManager pushManager];
        pushManager.delegate = self;
        
        // handling push on app start
        [[PushNotificationManager pushManager] handlePushReceived:launchOptions];
        
        // make sure we count app open in Pushwoosh stats
        [[PushNotificationManager pushManager] sendAppOpen];
        
        // register for push notifications!
        [[PushNotificationManager pushManager] registerForPushNotifications];
        

    }
    
    
	// CCGLView creation
	// viewWithFrame: size of the OpenGL view. For full screen use [_window bounds]
	//  - Possible values: any CGRect
	// pixelFormat: Format of the render buffer. Use RGBA8 for better color precision (eg: gradients). But it takes more memory and it is slower
	//	- Possible values: kEAGLColorFormatRGBA8, kEAGLColorFormatRGB565
	// depthFormat: Use stencil if you plan to use CCClippingNode. Use Depth if you plan to use 3D effects, like CCCamera or CCNode#vertexZ
	//  - Possible values: 0, GL_DEPTH_COMPONENT24_OES, GL_DEPTH24_STENCIL8_OES
	// sharegroup: OpenGL sharegroup. Useful if you want to share the same OpenGL context between different threads
	//  - Possible values: nil, or any valid EAGLSharegroup group
	// multiSampling: Whether or not to enable multisampling
	//  - Possible values: YES, NO
	// numberOfSamples: Only valid if multisampling is enabled
	//  - Possible values: 0 to glGetIntegerv(GL_MAX_SAMPLES_APPLE)
    
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565
								   depthFormat:0
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];

	// Enable multiple touches
	[glView setMultipleTouchEnabled:NO];

	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
	
	director_.wantsFullScreenLayout = YES;
	
	// Display FSP and SPF
	[director_ setDisplayStats:NO];
	
	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];
	
	// attach the openglView to the director
	[director_ setView:glView];
	
	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
	//	[director setProjection:kCCDirectorProjection3D];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	
	// Create a Navigation Controller with the Director
	navController_ = [[MyNavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
	
	// for rotation and other messages
	[director_ setDelegate:navController_];
	
	// set the Navigation Controller as the root view controller
	[window_ setRootViewController:navController_];
	
	// make main window visible
	[window_ makeKeyAndVisible];
    
    //local pushes
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    application.applicationIconBadgeNumber = 0;
	
	// Handle launching from a notification
	UILocalNotification *localNotif =
	[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    
    if (localNotif) {
        /*
		NSLog(@"[ didFinishLaunchingWithOptions ] : Recieved Notification %@",localNotif);
        NSDictionary *info = localNotif.userInfo;
        NSLog(@"DICT IN PUSH %@",info);
        NSString *key = [[info allKeys] objectAtIndex:0];
        NSLog(@"KEY %@",key);
         */
  
	}


//    [BBXBeeblex initializeWithAPIKey:@"NWQyMmI0YTdlZmM2MDMwNTg2MjUwNmM4NzJkYjJmZWIyMWIxNzU4NDUxMGE1ZjQ4NTIyNWRiNWJiYmIzZTYxZWExNGZmZDE1MTI5MzU4ODNiNjllNjI4NzkzZjlmZTE2ZGU0ODZlNjllZDVjZjQ5NzQwMTBlOTBlNzVkNTYzNTcsLS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUEyTzdjbFhwQUZuL1NOTmpydHUxdwpOdWJWWGdpT1gxck5jRkMwampCVGhuVkVmY1RpV1FFa3ArWldFOVdveHdtc2FMNW5MNnZGYnIrUlpxbG9hdm16ClBueGRvVVlLamYvYnY0cStxQ0ZZd1NMQ25aQ0Flb2ppditKOUdaL0N2YlB6aUFIQ3ArN1AyTGhEUWw4Vk1qZVQKQndVZkt6NTRHWGZQTG5VZ05mNkFtS3AvNlNHT0hnTFlDb2IrSEJBRklJQnQvY2NweXRDenlPKzVtb1d0N2FrWQo3WG1JRmR6b2NkTnh3YkdJK3Y3cnpGLzJtbUk3TDFqbmVXWGw2MUJKcmIyT1dmSFVPcTBmUDBHWmRTdXZ5YUxICjZuNjdKaE9meURoZW5RaUd4cHBLcU5wRkQvZ3BtWVNadGpYN3drZE5RM3hOd0x5Rjd1YjBMV3JORnFUWXA5ZlEKYlFJREFRQUIKLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0t"];
	
	return YES;
}
// system push notification registration success callback, delegate to pushManager
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[PushNotificationManager pushManager] handlePushRegistration:deviceToken];
}

// system push notification registration error callback, delegate to pushManager
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[PushNotificationManager pushManager] handlePushRegistrationFailure:error];
}

// system push notifications callback, delegate to pushManager
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[PushNotificationManager pushManager] handlePushReceived:userInfo];
}
- (void)didCompleteRewardedVideo:(CBLocation)location withReward:(int)reward {
    [SB reedemCoinReward];
}
-(void)didCacheRewardedVideo:(CBLocation)location{
    NSLog(@"****************CHARTBOOST VIDEO CACHED**********************");
}
-(void)didCacheInterstitial:(CBLocation)location{
       NSLog(@"***************CHARTBOOST INTERSTITIAL CACHED**********************");
}
-(void)didFailToLoadRewardedVideo:(CBLocation)location withError:(CBLoadError)error{
    if (error==CBLoadErrorNoAdFound) {
        NSLog(@"****************CHARTBOOST VIDEO FAILED TO CACHE, ERROR: NO AD FOUND**********************");
    }else{
        NSLog(@"****************CHARTBOOST VIDEO FAILED TO CACHE, unknow error**********************");

    }
    
}


- (void)didCloseMoreApps:(CBLocation)location{
    [[AnalyticsManager sharedManager] trackPopoverPresenter];
}


// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
    
    
}

-(BOOL)inMenu{
    
    CCScene *scene = [director_ runningScene];
    
    for (CCNode *n in scene.children)
    {
        if (n.tag == 999 && [n isKindOfClass:[HelloWorldLayer class]]){
            return YES;
        }
    }
    return NO;
}

-(SpecialBonus*)getSpecialBonus{
    
    return SB;
    
}

-(void)setSPECIALBONUS:(SpecialBonus*)sb_{
    
    SB = sb_;
    
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
    
    
  //  NSLog(@"running scene is %@. children %@",[director_ runningScene],[[director_ runningScene]children]);

        CCScene *scene = [director_ runningScene];
    
    for (CCNode *n in scene.children)
    {
        if (n.tag == 999 && [n isKindOfClass:[HelloWorldLayer class]]){
            //[(HelloWorldLayer*)n UPDATE_SPECIAL_BONUS];
            [SB UPDATE_ME];
            //[SB updateBonusLabel];
        }
    }
    
    [GC_ authenticateLocalPlayer];
    
    application.applicationIconBadgeNumber = 0;
    
    //check animation
    
    [self animationLoadingCheck];
    
    //[self performSelector:@selector(startPlayMusic) withObject:nil afterDelay:1.f];
    
}

-(void)animationLoadingCheck{
    
    BOOL wasRunning = NO;
    
    for (UIView *a in [[[CCDirector sharedDirector] openGLView]subviews]) {
        if ([a viewWithTag:kLOADINGTAG]) {
            [[a viewWithTag:kLOADINGTAG]removeFromSuperview];
            wasRunning = YES;
        }
    }
    
    if (wasRunning) {
        UIView *view__ = [[[b6luxLoadingView alloc]initWithFrame:CGRectMake(0, 0, 0, 0) loading:kLOADING_PURCHASE]autorelease];
        view__.tag = kLOADINGTAG;
        [[[CCDirector sharedDirector] openGLView]addSubview:view__];
    }
    
}

-(void)startPlayMusic{
    
//    if ([self inMenu]) {
//        [SOUND_ playMusic:@"menu.mp3" looping:YES fadeIn:YES];
//        SOUND_.musicVolume = 0.5f;
//    }

   
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window_ release];
	[navController_ release];
	
	[super dealloc];
}
@end

