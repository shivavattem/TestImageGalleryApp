//
//  ViewController.m
//  TestApp
//
//  Created by shiva on 15/06/2017.
//  Copyright © 2017 ACUMEN. All rights reserved.
//

#import "ViewController.h"
#import "ImageDetailsCell.h"

@interface ViewController () <NSURLSessionDelegate> {
    NSArray* latestLoans;
}

@property(nonatomic,strong)NSMutableArray *imageURLPath;
//@property(nonatomic,strong) NSMutableData *responseData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self getTheResponseFromAPI];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)parseResponse:(NSData *)responseData{
    
    //The below lines removes ‘jsonFlickrFeed’ from Flickr json response****Below lines copied from stackoverflow 🙂
    NSString *dataAsString = [NSString stringWithUTF8String:[responseData bytes]];
    //remove the leading ‘jsonFlickrFeed(‘ and trailing ‘)’ from the response data so we are left with a dictionary root object
    NSString *correctedJSONString = [NSString stringWithString:[dataAsString substringWithRange:NSMakeRange (15, dataAsString.length-15-1)]];
    //Flickr incorrectly tries to escape single quotes – this is invalid JSON (see http://stackoverflow.com/a/2275428/423565)
    //correct by removing escape slash (note NSString also uses \ as escape character – thus we need to use \\)
    correctedJSONString = [correctedJSONString stringByReplacingOccurrencesOfString:@"\\'" withString:@"‘"];
    //re-encode the now correct string representation of JSON back to a NSData object which can be parsed by NSJSONSerialization
    NSData *correctedData = [correctedJSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;

    //Store the json response in NSDictionary
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:correctedData options:NSJSONReadingAllowFragments error:&error];
    if (error) {
       
    } else {
       
       latestLoans = [json objectForKey:@"items"];
       
       NSMutableArray *areas = [latestLoans mutableArrayValueForKey:@"media"];
       
       self.imageURLPath = [areas mutableArrayValueForKey:@"m"];
        [_collectionView reloadData];
    }
    
}
- (void)getTheResponseFromAPI {
    
    NSString *url = [NSString stringWithFormat:@"https://api.flickr.com/services/feeds/photos_public.gne?format=json"];
    NSURLSessionConfiguration *sessionConfig =
            [NSURLSessionConfiguration defaultSessionConfiguration];
    
            NSURLSession *session =
            [NSURLSession sessionWithConfiguration:sessionConfig delegate:self
                                     delegateQueue:nil];
            NSURLSessionTask *task = [session dataTaskWithURL:[NSURL URLWithString:url]
                                                                 completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          if (data) {
                                              
                                              [self parseResponse:data];
                                          } else {
                                              NSLog(@"Failed to fetch %@: %@", url, error);
                                          }
                                      }];
            [task resume];

}
#pragma mark - Collection view delegate methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return latestLoans.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"imageCell";
    ImageDetailsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [cell updateWellnessContent:[latestLoans objectAtIndex:indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag) {
        CGFloat cellWidth = (self.view.bounds.size.width - 40)/3;
        return CGSizeMake(cellWidth, cellWidth);
    }
    else {
        //        CGFloat height = (_categoryCollectionView.frame.size.height-20);
        
        CGSize size;
        if ([UIScreen mainScreen].bounds.size.width == 375) {
            size = CGSizeMake(260, 320);
            
        } else if ([UIScreen mainScreen].bounds.size.width == 414) {
            size = CGSizeMake(289, 270);
        }
        else {
            size = [(UICollectionViewFlowLayout*)collectionViewLayout itemSize];
        }
        return size;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"the selected cell is: %ld",indexPath.row);
    
    //   Need to show view for Non Vodafone Users
    /*nonVodafoneSubscribe = [NonVodaSubscribeView view];
     nonVodafoneSubscribe.delegate = self;
     nonVodafoneSubscribe.frame = self.view.bounds;
     [self.view addSubview:nonVodafoneSubscribe];*/
    //    return;

}

@end
