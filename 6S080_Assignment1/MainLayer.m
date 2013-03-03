//
//  MainLayer.m
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
float const thickness = 18.0;
BOOL polygonCompleted, segmentsCompleted, outlineCompleted;
int fadeCounter;
float angle, oldDist, segmentAngle, outlineScale;
float randColor[9];
CGPoint panOffset, interiorPolygonOffset;
CGPoint initialTouchPoint;
CGPoint * interiorPoli;


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

-(CGPoint) avg:(CGPoint)p1 P2:(CGPoint)p2 {
    return CGPointMake((p1.x+p2.x)/2, (p1.y+p2.y)/2);
}

-(void) tracePathFromP1:(CGPoint)p1 P2:(CGPoint)p2 color:(int)color second:(BOOL)second
{
    float theta = atan( (p2.y - p1.y) / (p2.x - p1.x) ) + M_PI/2;
    float offsetX = thickness / 4 * cos(theta);
    float offsetY = thickness / 4 * sin(theta);
    float changeX = (p1.x - p2.x) * 0.02;
    float changeY = (p1.y - p2.y) * 0.02;
    
    p1.x += panOffset.x;
    p1.y += panOffset.y;
    p2.x += panOffset.x;
    p2.y += panOffset.y;
    
    glLineWidth(3.0f);
    ccDrawColor4F(0.0f/255.0f, 0.0f/255.0f, 0.0f/255.0f, 255.0f/255.0f);
    ccDrawLine(CGPointMake(p1.x + offsetX, p1.y + offsetY),
               CGPointMake(p2.x + offsetX, p2.y + offsetY));
    ccDrawLine(CGPointMake(p1.x - offsetX, p1.y - offsetY),
               CGPointMake(p2.x - offsetX, p2.y - offsetY));
    
    p1.x += changeX;
    p1.y += changeY;
    p2.x -= changeX;
    p2.y -= changeY;
    
    //ccDrawFilledCircle( p1, thickness/4, CC_DEGREES_TO_RADIANS(360), 60, NO);
    //ccDrawFilledCircle( p2, thickness/4, CC_DEGREES_TO_RADIANS(360), 60, NO);
    ccDrawColor4F(0.0f/255.0f, 0.0f/255.0f, 0.0f/255.0f, 255.0f/255.0f);
    
    if(second) {
        ccDrawLine(CGPointMake(p2.x + offsetX, p2.y + offsetY),
                   CGPointMake(p2.x - offsetX, p2.y - offsetY));
    }
    else {
        ccDrawLine(CGPointMake(p1.x + offsetX, p1.y + offsetY),
                   CGPointMake(p1.x - offsetX, p1.y - offsetY));
    }
    glLineWidth(thickness);
    
    if(color == 0) {
        ccDrawColor4F(180.0f/255.0f, 180.0f/255.0f, 180.0f/255.0f, 255.0f/255.0f);
    }
    else if(color == 1) {
        ccDrawColor4F(randColor[0]/255.0f, randColor[1]/255.0f, randColor[2]/255.0f, 255.0f/255.0f);
    }
    else {
        ccDrawColor4F(randColor[3]/255.0f, randColor[4]/255.0f, randColor[5]/255.0f, 255.0f/255.0f);
    }
    ccDrawLine(p1, p2);
//    glLineWidth(6.0f);
//    ccDrawColor4F(0.0f/255.0f, 0.0f/255.0f, 0.0f/255.0f, 255.0f/255.0f);
//    ccDrawCircle( p1, thickness/4, CC_DEGREES_TO_RADIANS(360), 60, NO);
    
    glLineWidth(2.0f);
    ccDrawColor4F(0.0f/0.0f, 0.0f/255.0f, 0.0f/255.0f, 255.0f/255.0f);
    
    if(second) {
        ccDrawCircle( p2, thickness/6, CC_DEGREES_TO_RADIANS(360), 60, NO );
        ccDrawCircle( p2, thickness/8, CC_DEGREES_TO_RADIANS(360), 60, NO );
    }
    else {
        ccDrawCircle( p1, thickness/6, CC_DEGREES_TO_RADIANS(360), 60, NO );
        ccDrawCircle( p1, thickness/8, CC_DEGREES_TO_RADIANS(360), 60, NO );
        ccDrawFilledCircle( p2, thickness/6, CC_DEGREES_TO_RADIANS(360), 60, NO );
    }
}
-(void) draw
{
    [super draw];
    
    if([polygonLocs count] == 0) {
        return;
    }
    if(segmentsCompleted && sets.count != 0) {
        int currentPoliPoint = 0;
        ccDrawSolidPoly(interiorPoli, polygonLocs.count, ccc4f(randColor[6]/255.0f, randColor[7]/255.0f, randColor[8]/255.0f, 255/255.0f));
        
        glLineWidth(3.0f);
        ccDrawColor4F(0/255.0f, 0/255.0f, 0/255.0f, 255.0f/255.0f);
        ccDrawPoly(interiorPoli, polygonLocs.count, YES);
        
        //ccDrawSolidPoly(interiorPoli, polygonLocs.count, ccc4f(180.0f/255.0f, 180.0f/255.0f, 180.0f/255.0f, 155/255.0f));
        for (int i = 0; i < sets.count; i++) {
            BOOL bigArray = NO;
            int mult = 1;
            if(i % 2 == 1)
                mult = -1;
            
            CGPoint p1 = [sets[i][0] CGPointValue];
            CGPoint ctr = [sets[i][1] CGPointValue];
            CGPoint p2 = [sets[i][2] CGPointValue];
            CGPoint interior = CGPointMake(0, 0);
            
            if([sets[i] count] == 4) {
                bigArray = YES;
                interior = [sets[i][3] CGPointValue];
            }
            float angle1 = atan2( (ctr.y - p1.y), (ctr.x - p1.x) ) + mult*segmentAngle + M_PI;
            float angle2 = atan2( (ctr.y - p2.y), (ctr.x - p2.x) ) + mult*segmentAngle + M_PI;
            float angle3 = atan2( (ctr.y - interior.y), (ctr.x - interior.x) ) + mult*segmentAngle + M_PI;
            //NSLog(@"Segment angle: %f", segmentAngle);
            float dist1 = [self distanceBetweenP1:p1 P2:ctr];
            float dist2 = [self distanceBetweenP1:p2 P2:ctr];
            float dist3 = [self distanceBetweenP1:interior P2:ctr];
            
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
                
            }
            else if(i >= 2 && i % 2 == 0) {
                offsetX = pPreOffset.x - [sets[i-1][2] CGPointValue].x;
                offsetY = pPreOffset.y - [sets[i-1][2] CGPointValue].y;
            }
            
            //NSLog(@"OffsetX: %f OffsetY: %f", offsetX, offsetY);
            if(offsetX != offsetX) {
                NSLog(@"ERROROROROROR");
                offsetX = 0.0;
                offsetY = 0.0;
            }
            
            CGPoint p1Disp = CGPointMake(dist1*cos(angle1) + ctr.x - offsetX,
                                         dist1*sin(angle1) + ctr.y - offsetY);
            CGPoint p2Disp = CGPointMake(dist2*cos(angle2) + ctr.x - offsetX,
                                         dist2*sin(angle2) + ctr.y - offsetY);
            CGPoint ctrDisp = CGPointMake(ctr.x - offsetX, ctr.y - offsetY);
            
            CGPoint interiorDisp = CGPointMake(dist3*cos(angle3) + ctr.x - offsetX,
                                               dist3*sin(angle3) + ctr.y - offsetY);
            if(bigArray) {
                
                NSLog(@"Set: %d, PoliPoint: %d, interiorDisp: (%f, %f)", i, currentPoliPoint, interiorDisp.x, interiorDisp.y);
                interiorPoli[currentPoliPoint++] = interiorDisp;
            }
            sets[i] = [[NSMutableArray alloc] initWithObjects:[NSValue valueWithCGPoint:p1Disp],
                       [NSValue valueWithCGPoint:ctrDisp],
                       [NSValue valueWithCGPoint:p2Disp], nil];
            if(bigArray) {
                
                [self tracePathFromP1:ctrDisp P2:interiorDisp color:i%2+1 second:NO];
                [sets[i] addObject:[NSValue valueWithCGPoint:interiorDisp]];
            }
            [self tracePathFromP1:p1Disp P2:ctrDisp color:i%2+1 second:NO];
            
            [self tracePathFromP1:ctrDisp P2:p2Disp color:i%2+1 second:YES];
            
            
        }
        interiorPoli[polygonLocs.count - 1] = interiorPoli[0];
        segmentAngle = 0.0;
    }
    //stage 3: modify the physical linkages
    else if(polygonCompleted) {
        
        ccDrawSolidPoly(interiorPoli, polygonLocs.count, ccc4f(180.0f/255.0f, 180.0f/255.0f, 180.0f/255.0f, 255/255.0f));
        
        glLineWidth(3.0f);
        ccDrawColor4F(0/255.0f, 0/255.0f, 0/255.0f, 255.0f/255.0f);
        ccDrawPoly(interiorPoli, polygonLocs.count, YES);
        
        ccDrawColor4F(171/255.0f, 217/255.0f, 140/255.0f, 255.0f/255.0f);
        
        
        glLineWidth(6.0f);
        float xCtr = 0.0, yCtr = 0.0;
        for (int i = 0; i < polygonLocs.count; i++) {
            xCtr += [polygonLocs[i] CGPointValue].x;
            yCtr += [polygonLocs[i] CGPointValue].y;
        }
        xCtr /= polygonLocs.count;
        yCtr /= polygonLocs.count;
        CGPoint avg = CGPointMake(xCtr, yCtr);
        
        for (int i = 0; i < polygonLocs.count; i++) {
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
            
            if(i != polygonLocs.count - 1) {
                [self tracePathFromP1:p2 P2:interiorPoli[i+1] color:0 second:NO];
            }
            [self tracePathFromP1:pointFirstP1 P2:p2 color:0 second:NO];
            [self tracePathFromP1:p2 P2:pointSecondP2 color:0 second:YES];
            
            
            [self tracePathFromP1:pointFirstP2 P2:p2 color:0 second:NO];
            [self tracePathFromP1:p2 P2:pointSecondP1 color:0 second:YES];
            
            glLineWidth(2.0f);
            ccDrawColor4F(0.0f/0.0f, 0.0f/255.0f, 0.0f/255.0f, 255.0f/255.0f);
            
            ccDrawFilledCircle( p2, thickness/6, CC_DEGREES_TO_RADIANS(360), 60, NO );
            
            
            if(segmentsCompleted) {
                
                NSMutableArray *set = [[NSMutableArray alloc] initWithObjects:[NSValue valueWithCGPoint:pointFirstP1],
                                                [NSValue valueWithCGPoint:p2],
                                                [NSValue valueWithCGPoint:pointSecondP2], nil];
                if(i != polygonLocs.count - 1) {
                    [set addObject:[NSValue valueWithCGPoint:interiorPoli[i+1]]];
                }
                NSArray *set2 = [[NSMutableArray alloc] initWithObjects:[NSValue valueWithCGPoint:pointFirstP2],
                                                 [NSValue valueWithCGPoint:p2],
                                                 [NSValue valueWithCGPoint:pointSecondP1], nil];
                
                [sets addObject:set];
                [sets addObject:set2];
            }
            
        }
    }
    //stage 2 (placing the interior polygon)
    else if(outlineCompleted) {
        ccDrawColor4F(171/255.0f, 217/255.0f, 140/255.0f, 255.0f/255.0f);
        glLineWidth(6.0f);
        
        CGPoint avg = [polygonLocs[0] CGPointValue];
        for (int i = 0; i < polygonLocs.count - 1; i++) {
            ccDrawLine( [polygonLocs[i] CGPointValue], [polygonLocs[i+1] CGPointValue]);
            avg.x += [polygonLocs[i+1] CGPointValue].x;
            avg.y += [polygonLocs[i+1] CGPointValue].y;
        }
        avg.x /= polygonLocs.count;
        avg.y /= polygonLocs.count;
        
        interiorPoli = (CGPoint *) malloc(polygonLocs.count * sizeof(CGPoint));
        
        for (int i = 0; i < polygonLocs.count; i++) {
            CGPoint curPoint = [polygonLocs[i] CGPointValue];
            interiorPoli[i] = CGPointMake((avg.x * outlineScale + curPoint.x) / (1.0 + outlineScale), (avg.y * outlineScale + curPoint.y) / (1.0 + outlineScale));
            interiorPoli[i].x += interiorPolygonOffset.x;
            interiorPoli[i].y += interiorPolygonOffset.y;
        }
        
        ccDrawSolidPoly(interiorPoli, polygonLocs.count, ccc4f(171/255.0f, 217/255.0f, 140/255.0f, 155.0f/255.0f));
    }
    //stage 1 (drawing the outline)
    else {
        ccDrawColor4F(171/255.0f, 217/255.0f, 140/255.0f, 255.0f/255.0f);
        glLineWidth(6.0f);
        for (int i = 0; i < [polygonLocs count] - 1; i++) {
            ccDrawLine( [polygonLocs[i] CGPointValue], [polygonLocs[i+1] CGPointValue]);
            ccDrawFilledCircle( [polygonLocs[i] CGPointValue], 7, CC_DEGREES_TO_RADIANS(360), 60, NO);
            
        }
        
        if(!polygonCompleted) {
            glLineWidth(1.0f);
            ccDrawFilledCircle( [polygonLocs.lastObject CGPointValue], 10, CC_DEGREES_TO_RADIANS(360), 60, NO);
            ccDrawColor4F(0.15, 0.45, 0.55, 1);
            ccDrawCircle( [polygonLocs.lastObject CGPointValue], 10, CC_DEGREES_TO_RADIANS(360), 60, NO);
        }
    }
}
-(id) init
{
	if( (self=[super init]) ) {
        
        // Standard method to create a button
//        CCMenuItem *menuItem = [CCMenuItemImage
//                                itemWithNormalImage:@"checkmarkRed" selectedImage:@"checkmarkGrey.png"
//                                target:self selector:@selector(checkButtonTapped:)];
        
        CCLayerColor *background = [[CCLayerColor alloc] initWithColor:ccc4(54, 161, 141, 255)];
        [self addChild:background z:-1];
        
		polygonLocs = [[NSMutableArray alloc] init];
        
        polygonCompleted = NO;
        segmentsCompleted = NO;
        outlineCompleted = NO;
        
        fadeCounter = 0;
        angle = 2.0;
        outlineScale = 0.5;
        
        self.isTouchEnabled = YES;
        
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
        
        randColor[0] = arc4random() % 255;
        randColor[1] = arc4random() % 255;
        randColor[2] = arc4random() % 255;
        randColor[3] = 255 - randColor[1];
        randColor[4] = 255 - randColor[2];
        randColor[5] = 255 - randColor[0];
        randColor[6] = 255 - randColor[2];
        randColor[7] = 255 - randColor[0];
        randColor[8] = 255 - randColor[1];
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
    if(!outlineCompleted)
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
    if(!outlineCompleted)
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
        else if(outlineCompleted) {
            outlineScale *= oldDist / currentDist;
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
    NSLog(@"Touch began");
    
    initialTouchPoint = [self convertTouchToNodeSpace:touch];
    
    return YES;
}
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSSet *allUserTouches=[event allTouches];
    if(segmentsCompleted && allUserTouches.count == 1) {
        CGPoint currentPanPoint = [self convertTouchToNodeSpace:touch];
        panOffset.x += ( currentPanPoint.x - initialTouchPoint.x ) * 0.05;
        panOffset.y += ( currentPanPoint.y - initialTouchPoint.y ) * 0.05;
    }
    else if(outlineCompleted && allUserTouches.count == 1) {
        CGPoint currentPoint = [self convertTouchToNodeSpace:touch];
        interiorPolygonOffset.x += ( currentPoint.x - initialTouchPoint.x ) * 0.02;
        interiorPolygonOffset.y += ( currentPoint.y - initialTouchPoint.y ) * 0.02;
    }
}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(outlineCompleted) {
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
        outlineCompleted = YES;
       
        [polygonLocs addObject:polygonLocs[0]];
        NSLog(@"Polygon completed!");
    }
}
- (void)continueButtonTapped:(id)sender {
    NSLog(@"Continue button tapped!");
    
    if(!outlineCompleted) {
        outlineCompleted = YES;
    }
    else if(outlineCompleted && !polygonCompleted) {
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
    outlineCompleted = NO;
    interiorPolygonOffset = CGPointMake(0, 0);
    panOffset = CGPointMake(0, 0);
    
    angle = 2.0;
    outlineScale = 0.5;
    
    polygonLocs = [[NSMutableArray alloc] init];
    
    randColor[0] = arc4random() % 255;
    randColor[1] = arc4random() % 255;
    randColor[2] = arc4random() % 255;
    randColor[3] = 255 - randColor[1];
    randColor[4] = 255 - randColor[2];
    randColor[5] = 255 - randColor[0];
    randColor[6] = 255 - randColor[2];
    randColor[7] = 255 - randColor[0];
    randColor[8] = 255 - randColor[1];
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
