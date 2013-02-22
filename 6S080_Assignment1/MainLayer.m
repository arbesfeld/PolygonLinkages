//
//  HelloWorldLayer.m
//  6S080_Assignment1
//
//  Created by Matthew Arbesfeld on 2/20/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "MainLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "CCTouchDispatcher.h"

NSMutableArray *polygonLocs;
NSMutableArray *sets;

CGFloat const THRESHOLD = 20.0;
float const thickness = 12.0;
BOOL polygonCompleted, segmentsCompleted, firstRun;
int fadeCounter;
float angle, oldDist, segmentAngle;

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation MainLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainLayer *layer = [MainLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(CGFloat) distanceBetweenP1:(CGPoint)p1 P2:(CGPoint)p2
{
    return sqrt( pow((p2.x - p1.x), 2) + pow((p2.y - p1.y), 2) );
}

-(void) tracePathFromP1:(CGPoint)p1 P2:(CGPoint)p2
{
    glLineWidth(thickness);
    ccDrawColor4F(255.0f/255.0f, 255.0f/255.0f, 255.0f/255.0f, 255.0f/255.0f);
    ccDrawLine(p1, p2);
    
    float theta = atan( (p2.y - p1.y) / (p2.x - p1.x) ) + M_PI/2;
    float offsetX = thickness / 4 * cos(theta);
    float offsetY = thickness / 4 * sin(theta);
    
    ccDrawFilledCircle( p1, thickness/5, CC_DEGREES_TO_RADIANS(360), 60, NO);
    ccDrawFilledCircle( p2, thickness/5, CC_DEGREES_TO_RADIANS(360), 60, NO);
    
    glLineWidth(1.5f);
    ccDrawColor4F(0.0f/255.0f, 0.0f/255.0f, 0.0f/255.0f, 255.0f/255.0f);
    ccDrawLine(CGPointMake(p1.x + offsetX, p1.y + offsetY),
               CGPointMake(p2.x + offsetX, p2.y + offsetY));
    ccDrawLine(CGPointMake(p1.x - offsetX, p1.y - offsetY),
               CGPointMake(p2.x - offsetX, p2.y - offsetY));
    
//    glLineWidth(6.0f);
//    ccDrawColor4F(0.0f/255.0f, 0.0f/255.0f, 0.0f/255.0f, 255.0f/255.0f);
//    ccDrawCircle( p1, thickness/4, CC_DEGREES_TO_RADIANS(360), 60, NO);
    
    
}
-(void) draw
{
    [super draw];
    
    if([polygonLocs count] == 0) {
        return;
    }
    if(segmentsCompleted && sets.count != 0) {
        for (int i = 0; i < sets.count; i++) {
            int mult = 1;
            if(i % 2 == 1)
                mult = -1;
            CGPoint p1 = [sets[i][0] CGPointValue];
            CGPoint ctr = [sets[i][1] CGPointValue];
            CGPoint p2 = [sets[i][2] CGPointValue];
            
            float angle1 = atan2( (ctr.y - p1.y), (ctr.x - p1.x) ) + mult*segmentAngle + M_PI;
            float angle2 = atan2( (ctr.y - p2.y), (ctr.x - p2.x) ) + mult*segmentAngle + M_PI;
            
            //NSLog(@"Segment angle: %f", segmentAngle);
            float dist1 = [self distanceBetweenP1:p1 P2:ctr];
            float dist2 = [self distanceBetweenP1:p2 P2:ctr];
            
            float offsetX = 0.0, offsetY = 0.0;
            
            CGPoint pPreOffset = CGPointMake(dist1*cos(angle1)+ctr.x, dist1*sin(angle1)+ctr.y);
            if(i == sets.count - 2) {
                pPreOffset = CGPointMake(dist2*cos(angle2)+ctr.x, dist2*sin(angle2)+ctr.y);
                
                offsetX = pPreOffset.x - [sets[1][0] CGPointValue].x;
                offsetY = pPreOffset.y - [sets[1][0] CGPointValue].y;
            }
            else if(i == sets.count - 1) {
                pPreOffset = CGPointMake(dist2*cos(angle2)+ctr.x, dist2*sin(angle2)+ctr.y);
                
                offsetX = pPreOffset.x - [sets[0][0] CGPointValue].x;
                offsetY = pPreOffset.y - [sets[0][0] CGPointValue].y;
            }
            else if(i >= 2 && i % 2 == 1) {
                offsetX = pPreOffset.x - [sets[i-3][2] CGPointValue].x;
                offsetY = pPreOffset.y - [sets[i-3][2] CGPointValue].y;
                
               // NSLog(@"Offset for i: %d: %f", i, offsetY);
//                if(firstRun && (offsetX > 0 || offsetY > 0)) {
//                    NSMutableArray *tmp = [sets[i] copy];
//                    sets[i] = [sets[i-1] copy];
//                    sets[i-1] = [tmp copy];
//                    continue;
//                }
            }
            
            else if(i >= 2 && i % 2 == 0) {
                offsetX = pPreOffset.x - [sets[i-1][2] CGPointValue].x;
                offsetY = pPreOffset.y - [sets[i-1][2] CGPointValue].y;
                //NSLog(@"Offset for i: %d: %f", i, offsetY);
//                if(firstRun && (offsetX > 0 || offsetY > 0)) {
//                    NSMutableArray *tmp = [sets[i] copy];
//                    sets[i] = [sets[i+1] copy];
//                    sets[i+1] = [tmp copy];
//                    continue;
//                }
            }
            NSLog(@"OffsetX: %f OffsetY: %f", offsetX, offsetY);
            if(offsetX != offsetX) {
                NSLog(@"ERROROROROROR");
                offsetX = 0.0;
                offsetY = 0.0;
            }
            CGPoint p1Disp = CGPointMake(dist1*cos(angle1)+ctr.x-offsetX, dist1*sin(angle1)+ctr.y-offsetY);
            CGPoint p2Disp = CGPointMake(dist2*cos(angle2)+ctr.x-offsetX, dist2*sin(angle2)+ctr.y-offsetY);
            CGPoint ctrDisp = CGPointMake(ctr.x-offsetX, ctr.y-offsetY);
            sets[i] = [[NSMutableArray alloc] initWithObjects:[NSValue valueWithCGPoint:p1Disp],
                       [NSValue valueWithCGPoint:ctrDisp],
                       [NSValue valueWithCGPoint:p2Disp], nil];
            [self tracePathFromP1:p1Disp P2:ctrDisp];
            
            [self tracePathFromP1:ctrDisp P2:p2Disp];
            
            glLineWidth(2.0f);
            ccDrawColor4F(0.0f/0.0f, 0.0f/255.0f, 0.0f/255.0f, 255.0f/255.0f);
            
            ccDrawCircle( p1Disp, thickness/6, CC_DEGREES_TO_RADIANS(360), 60, NO);
            ccDrawCircle( p2Disp, thickness/6, CC_DEGREES_TO_RADIANS(360), 60, NO);
            ccDrawFilledCircle( ctrDisp, thickness/6, CC_DEGREES_TO_RADIANS(360), 60, NO);
        }
        
        segmentAngle = 0.0;
        firstRun = NO;
    }
    else if(polygonCompleted) {
        
        ccDrawColor4F(171/255.0f, 217/255.0f, 140/255.0f, 255.0f*(fadeCounter/90.0)/255.0f);
        
        //ccDrawColor4F(171/255.0f, 217/255.0f, 140/255.0f, 255.0f/255.0f);
        glLineWidth(6.0f);
        float xCtr = 0.0, yCtr = 0.0;
        for (int i = 0; i < polygonLocs.count; i++) {
            xCtr += [polygonLocs[i] CGPointValue].x;
            yCtr += [polygonLocs[i] CGPointValue].y;
        }
        xCtr /= polygonLocs.count;
        yCtr /= polygonLocs.count;
        CGPoint avg = CGPointMake(xCtr, yCtr);
        
        for (int i = 0; i < [polygonLocs count]; i++) {
            CGPoint p1 = [polygonLocs[i] CGPointValue];
            CGPoint p2 = [polygonLocs[(i+1)%[polygonLocs count]] CGPointValue];
            CGPoint p3 = [polygonLocs[(i+2)%[polygonLocs count]] CGPointValue];
            CGPoint avgFirst = CGPointMake((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
            CGPoint avgSecond = CGPointMake((p2.x + p3.x) / 2, (p2.y + p3.y) / 2);
            
            float angleFirst = atan( (p2.y - p1.y) / (p2.x - p1.x) ) + M_PI/2;
            float angleSecond = atan( (p3.y - p2.y) / (p3.x - p2.x) ) + M_PI/2;
            
            float distanceFromPolygonFirst = [self distanceBetweenP1:p1 P2:p2] / (2 * tan(angle/2) );
            float distanceFromPolygonSecond = [self distanceBetweenP1:p2 P2:p3] / (2 * tan(angle/2) );
            
            float offsetXFirst = distanceFromPolygonFirst * cos(angleFirst);
            float offsetYFirst = distanceFromPolygonFirst * sin(angleFirst);
            CGPoint pointFirstP1 = CGPointMake(avgFirst.x + offsetXFirst, avgFirst.y + offsetYFirst);
            CGPoint pointFirstP2 = CGPointMake(avgFirst.x - offsetXFirst, avgFirst.y - offsetYFirst);
            
            if([self distanceBetweenP1:pointFirstP1 P2:avg] < [self distanceBetweenP1:pointFirstP2 P2:avg]) {
                CGPoint tmp = pointFirstP1;
                pointFirstP1 = pointFirstP2;
                pointFirstP2 = tmp;
            }
            float offsetXSecond = distanceFromPolygonSecond * cos(angleSecond);
            float offsetYSecond = distanceFromPolygonSecond * sin(angleSecond);
            CGPoint pointSecondP1 = CGPointMake(avgSecond.x + offsetXSecond, avgSecond.y + offsetYSecond);
            CGPoint pointSecondP2 = CGPointMake(avgSecond.x - offsetXSecond, avgSecond.y - offsetYSecond);
            if([self distanceBetweenP1:pointSecondP1 P2:avg] < [self distanceBetweenP1:pointSecondP2 P2:avg]) {
                CGPoint tmp = pointSecondP1;
                pointSecondP1 = pointSecondP2;
                pointSecondP2 = tmp;
            }
            [self tracePathFromP1:pointFirstP1 P2:p2];
            [self tracePathFromP1:p2 P2:pointSecondP2];
            
            
            [self tracePathFromP1:pointFirstP2 P2:p2];
            [self tracePathFromP1:p2 P2:pointSecondP1];
            
            glLineWidth(2.0f);
            ccDrawColor4F(0.0f/0.0f, 0.0f/255.0f, 0.0f/255.0f, 255.0f/255.0f);
            
            ccDrawCircle( pointFirstP1, thickness/6, CC_DEGREES_TO_RADIANS(360), 60, NO);
            ccDrawCircle( pointFirstP2, thickness/6, CC_DEGREES_TO_RADIANS(360), 60, NO);
            ccDrawCircle( pointSecondP1, thickness/6, CC_DEGREES_TO_RADIANS(360), 60, NO);
            ccDrawCircle( pointSecondP2, thickness/6, CC_DEGREES_TO_RADIANS(360), 60, NO);
            ccDrawFilledCircle( p2, thickness/6, CC_DEGREES_TO_RADIANS(360), 60, NO);
            
            if(segmentsCompleted) {
                NSArray *set = [[NSMutableArray alloc] initWithObjects:[NSValue valueWithCGPoint:pointFirstP1],
                                                [NSValue valueWithCGPoint:p2],
                                                [NSValue valueWithCGPoint:pointSecondP2], nil];
                
                NSArray *set2 = [[NSMutableArray alloc] initWithObjects:[NSValue valueWithCGPoint:pointFirstP2],
                                                 [NSValue valueWithCGPoint:p2],
                                                 [NSValue valueWithCGPoint:pointSecondP1], nil];
                
                [sets addObject:set];
                [sets addObject:set2];

                firstRun = YES;
            }
            
        }
    }
    
    ccDrawColor4F(171/255.0f, 217/255.0f, 140/255.0f, 255.0f*(1.0 - fadeCounter/90.0)/255.0f);
    glLineWidth(6.0f);
    for (int i = 0; i < [polygonLocs count] - 1; i++) {
        ccDrawLine( [polygonLocs[i] CGPointValue], [polygonLocs[i+1] CGPointValue]);
        ccDrawFilledCircle( [polygonLocs[i] CGPointValue], 7, CC_DEGREES_TO_RADIANS(360), 60, NO);
        
    }
    fadeCounter += 1;
    
    if(!polygonCompleted) {
        fadeCounter = 0;
        
        glLineWidth(1.0f);
        ccDrawFilledCircle( [polygonLocs.lastObject CGPointValue], 10, CC_DEGREES_TO_RADIANS(360), 60, NO);
        ccDrawColor4F(0.15, 0.45, 0.55, 1);
        ccDrawCircle( [polygonLocs.lastObject CGPointValue], 10, CC_DEGREES_TO_RADIANS(360), 60, NO);
    }
    
}
-(id) init
{
	if( (self=[super init]) ) {
        
        // Standard method to create a button
//        CCMenuItem *menuItem = [CCMenuItemImage
//                                itemWithNormalImage:@"checkmarkRed" selectedImage:@"checkmarkGrey.png"
//                                target:self selector:@selector(checkButtonTapped:)];
        
        CCLayerColor *blueSky = [[CCLayerColor alloc] initWithColor:ccc4(54, 161, 141, 255)];
        [self addChild:blueSky z:-1];
		polygonLocs = [[NSMutableArray alloc] init];
        polygonCompleted = NO;
        fadeCounter = 0;
        angle = 2.0;
        self.isTouchEnabled = YES;
        segmentsCompleted = NO;
        
        CCMenuItem *menuItem = [CCMenuItemFont
                                itemWithString:@"Continue"
                                target:self selector:@selector(continueButtonTapped:)];
        
        CCMenuItem *menuItem2 = [CCMenuItemFont
                                 itemWithString:@"Restart"
                                 target:self selector:@selector(returnButtonTapped:)];
        menuItem.position = ccp(100, 90);
        menuItem2.position = ccp(100, 40);
        CCMenu *menu = [CCMenu menuWithItems:menuItem, menuItem2, nil];
        menu.position = CGPointZero;
        [self addChild:menu z:0.2];
        
	}
	return self;
}

- (void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
    [[[CCDirector sharedDirector] touchDispatcher] addStandardDelegate:self priority:0];
}

- (void)ccTouchesBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(!polygonCompleted)
        return;
    
    NSSet *allUserTouches=[event allTouches];
    
    if(allUserTouches.count==2)
    {
        UITouch* touch1=[[allUserTouches allObjects] objectAtIndex:0];
        UITouch* touch2=[[allUserTouches allObjects] objectAtIndex:1];
        
        CGPoint touch1location=[touch1 locationInView:[touch1 view]];
        CGPoint touch2location=[touch2 locationInView:[touch2 view]];
        
        
        float currentDist=ccpDistance(touch1location, touch2location);
        oldDist = currentDist;
        
        NSLog(@"Pinching started, distance: %f", oldDist);
    }
    
}

-(void)ccTouchesMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(!polygonCompleted)
        return;
    NSSet *allUserTouches=[event allTouches];
    
    if(allUserTouches.count==2)
    {
        UITouch* touch1=[[allUserTouches allObjects] objectAtIndex:0];
        UITouch* touch2=[[allUserTouches allObjects] objectAtIndex:1];
        
        CGPoint touch1location=[touch1 locationInView:[touch1 view]];
        CGPoint touch2location=[touch2 locationInView:[touch2 view]];
        
        float currentDist=ccpDistance(touch1location, touch2location);
        NSLog(@"Pinching ended, distance: %f", currentDist);
        if(abs(currentDist - oldDist) > 25.0) {
            oldDist = currentDist;
        }
        
        if(segmentsCompleted) {
            segmentAngle += (currentDist - oldDist) / 100.0;
        }
        else if(polygonCompleted) {
            angle *= currentDist / oldDist;
        }
        NSLog(@"Angle change: %f", (currentDist / oldDist));
        oldDist = currentDist;
        
        angle = min(max(angle, -M_PI/2), 3.1);
    }
}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touches ended");
}
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(polygonCompleted) {
        return;
    }
    
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    // if the point is far from the first point (or the first point) continue the polygon
    if([polygonLocs count] == 0 || [ self distanceBetweenP1:[[polygonLocs objectAtIndex:0] CGPointValue] P2:location ] > THRESHOLD  ) {
        [polygonLocs addObject:[NSValue valueWithCGPoint:location]];
        NSLog(@"Point added: %d", [polygonLocs count]);
    }
    // else, complete the polygon
    else {
        polygonCompleted = YES;
        
       
        [polygonLocs addObject:polygonLocs[0]];
        NSLog(@"Polygon completed!");
    }
}
- (void)continueButtonTapped:(id)sender {
    NSLog(@"Continue button tapped!");
    if(!polygonCompleted) {
        polygonCompleted = YES;
    }
    else if(polygonCompleted && !segmentsCompleted) {
        segmentsCompleted = YES;
        sets = [[NSMutableArray alloc] init];
        segmentAngle = 0.0;
    }
    else {
        return;
    }
}
- (void)returnButtonTapped:(id)sender {
    NSLog(@"Return button tapped!");
    polygonCompleted = NO;
    segmentsCompleted = NO;
    polygonLocs = [[NSMutableArray alloc] init];
}
// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
