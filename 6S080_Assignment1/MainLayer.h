//
//  MainLayer.h
//  6S080_Assignment1
//
//  Created by Matthew Arbesfeld on 2/20/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "WebSocket.h"
#import "SBJson.h"

// HelloWorldLayer
@interface MainLayer : CCLayer <WebSocketDelegate>
{
}

@property (nonatomic, readonly) WebSocket* ws;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
-(CGFloat) distanceBetweenP1:(CGPoint)p1 P2:(CGPoint)p2;
@end
