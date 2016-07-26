//
//  BLPathViewController.m
//  Hele
//
//  Created by Naufal Aros El Morabet on 10/07/16.
//  Copyright © 2016 Naufal Aros. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "BLPathViewController.h"

@import Mapbox;
@import MapboxDirections;

@interface BLPathViewController ()

@property (weak, nonatomic) IBOutlet MGLMapView *mapView;
@property (strong, nonatomic) MBDirections *directions;

@end

@implementation BLPathViewController

- (void)viewDidLoad {
    _directions = [MBDirections sharedDirections];
    for (BLPinMO *pin in _adventure.pins) {
        NSLog(@"%f - %f", pin.latitude.floatValue, pin.longitude.floatValue);
    }
    
    NSLog(@"====================================================");
    NSLog(@"====================================================");
    
    [self mapRequest];
    
}


# pragma mark - Supporting methods

- (void)mapRequest {
   /* NSArray<MBWaypoint *> *waypoints = @[
                                         [[MBWaypoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(38.9131752, -77.03240447) coordinateAccuracy:-1 name:@"Mapbox"],
                                         [[MBWaypoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(38.8977, -77.0365) coordinateAccuracy:-1 name:@"White House"]
                                         ];
    */

    MBRouteOptions *options = [[MBRouteOptions alloc] initWithWaypoints:[self waypointsArray] profileIdentifier:@"mapbox/driving"];
    options.includesSteps = YES;
    
    NSURLSessionDataTask *task = [self.directions calculateDirectionsWithOptions:options completionHandler:^(NSArray<MBWaypoint *> * _Nullable waypoints, NSArray<MBRoute *> * _Nullable routes, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error calculating directions: %@", error);
            return;
        }
        
        MBRoute *route = routes.firstObject;
        MBRouteLeg *leg = route.legs.firstObject;
        if (leg) {
            NSLog(@"Route via %@:", leg);
            
            NSLengthFormatter *distanceFormatter = [[NSLengthFormatter alloc] init];
            NSString *formattedDistance = [distanceFormatter stringFromMeters:leg.distance];
            
            NSDateComponentsFormatter *travelTimeFormatter = [[NSDateComponentsFormatter alloc] init];
            travelTimeFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleShort;
            NSString *formattedTravelTime = [travelTimeFormatter stringFromTimeInterval:route.expectedTravelTime];
            
            NSLog(@"Distance: %@; ETA: %@", formattedDistance, formattedTravelTime);
            
            for (MBRouteStep *step in leg.steps) {
                NSLog(@"%@", step.instructions);
                NSString *formattedDistance = [distanceFormatter stringFromMeters:step.distance];
                NSLog(@"- %@ -", formattedDistance);
            }
            
        }
        
        if (route.coordinateCount) {
            // Convert the route's coordinates into a polyline.
            CLLocationCoordinate2D *routeCoordinates = malloc(route.coordinateCount * sizeof(CLLocationCoordinate2D));
            [route getCoordinates:routeCoordinates];
            MGLPolyline *routeline = [MGLPolyline polylineWithCoordinates:routeCoordinates count:route.coordinateCount];
            
            // Add the polyline to the map and fit the viewport to the polyline.
            [self.mapView addAnnotation:routeline];
            [self.mapView setVisibleCoordinates:routeCoordinates count:route.coordinateCount edgePadding:UIEdgeInsetsZero animated:YES];
            
            // Make sure to free this arary to avoid leaking memory.
            free(routeCoordinates);
        }
    }];
    
    [task resume];
}

- (NSArray<MBWaypoint *> *)waypointsArray {
    NSMutableArray *waypointsArray = [NSMutableArray array];
    for (BLPinMO *pin in self.adventure.pins) {
        CLLocationDegrees lat = pin.latitude.doubleValue;
        CLLocationDegrees lon = pin.longitude.doubleValue;
        [waypointsArray addObject:[[MBWaypoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat, lon) coordinateAccuracy:-1 name:@""]];
    }
    
    return [waypointsArray copy];
}

@end
