//
//  SKNode+SKNode_Extensions.h
//  Secret Chest Slots V2.7
//
//  Created by Eddy Fan on 1/20/16.
//  Copyright © 2016 Fantapstic Studio. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKNode (SKNode_Extensions)

-(instancetype) nodeFromTouches:(NSSet<UITouch *> *) touches;
+(instancetype) nodeFromTouches:(NSSet<UITouch *> *) touches inParentNode:(SKNode*) parentNode;
-(void) addChild:(SKNode*) child atZPosition:(CGFloat) zPosition;
-(void) addChildToTopZ:(SKNode*) child;

-(CGFloat) right;
-(CGFloat) top;
-(CGFloat) left;
-(CGFloat) bottom;

@end
