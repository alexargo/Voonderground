//
//  DataViewController.m
//  Voonderground
//
//  Created by Alex Argo on 10/29/14.
//  Copyright (c) 2014 Alex Argo. All rights reserved.
//

#import "DataViewController.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@interface DataViewController ()

@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSDictionary *currentObservationData;
@property (nonatomic, copy) NSDictionary *forcaseData;
@property (weak, nonatomic) IBOutlet UILabel *temperature;
@property (weak, nonatomic) IBOutlet UILabel *humidity;
@property (weak, nonatomic) IBOutlet UILabel *highLow;
@property (weak, nonatomic) IBOutlet UILabel *wind;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdate;
@property (weak, nonatomic) IBOutlet UIImageView *iconURL;

@end

@implementation DataViewController
- (IBAction)refresh:(id)sender {
    [self findTheData];
}

- (void)findTheData {
    NSError *error;
    NSString *filePath = [[[NSBundle mainBundle] URLForResource:@"wunderground-key" withExtension:@"txt"] path];
    NSString * APIKEY = [[NSString alloc]
                               initWithContentsOfFile:filePath
                               encoding:NSUTF8StringEncoding
                               error:&error];
    if(!error) {
        // Do any additional setup after loading the view, typically from a nib.
        NSString *currentObservationURL = [[NSString stringWithFormat:@"http://api.wunderground.com/api/%@/conditions/q/%@.json",APIKEY,self.location] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:currentObservationURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            self.currentObservationData = responseObject;
            [self configureCurrentObservationData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    
        NSString *forecastURL = [[NSString stringWithFormat:@"http://api.wunderground.com/api/%@/forecast/q/%@.json",APIKEY,self.location] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [manager GET:forecastURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            self.forcaseData = responseObject;
            [self configureForecastData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.location = self.dataObject;
    
    [self findTheData];

}

- (void) configureCurrentObservationData {
    self.temperature.text = [NSString stringWithFormat:@"Current Temp: %@°F",self.currentObservationData[@"current_observation"][@"temp_f"]];
    self.humidity.text = [NSString stringWithFormat:@"Current Humidity: %@",self.currentObservationData[@"current_observation"][@"relative_humidity"]];
    self.lastUpdate.text = [NSString stringWithFormat:@"%@", self.currentObservationData[@"current_observation"][@"observation_time"]];
    [self.iconURL setImageWithURL:[NSURL URLWithString:self.currentObservationData[@"current_observation"][@"icon_url"]]];
    self.wind.text = [NSString stringWithFormat:@"Wind: %@mph %@",self.currentObservationData[@"current_observation"][@"wind_mph"],self.currentObservationData[@"current_observation"][@"wind_dir"]];
    
}

- (void) configureForecastData {
    self.highLow.text = [NSString stringWithFormat:@"High: %@°F Low: %@°F",
                          self.forcaseData[@"forecast"][@"simpleforecast"][@"forecastday"][0][@"high"][@"fahrenheit"],
                          self.forcaseData[@"forecast"][@"simpleforecast"][@"forecastday"][0][@"low"][@"fahrenheit"]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dataLabel.text = [self.dataObject description];
}

@end
