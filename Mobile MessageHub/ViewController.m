//
//  ViewController.m
//  Mobile MessageHub
//
//  Created by Ben Leiken on 11/6/13.
//  Copyright (c) 2013 BKL. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITextFieldDelegate, NSURLConnectionDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *messageField;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;

@property (strong, nonatomic) IBOutlet UITableView *messagesTable;
@property (strong, nonatomic) IBOutlet UIButton *viewAll;
@property (strong, nonatomic) IBOutlet UIButton *hideAll;

@property (nonatomic, strong) UIRefreshControl * refresher;

@property (strong, nonatomic) NSArray * returnedMessages;
@property (strong, nonatomic) NSMutableArray * messages;

@property (assign ,nonatomic) int offset;
@property (assign, nonatomic) int total;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
   
   self.usernameField.delegate = self;
   self.messageField.delegate = self;
   self.offset = 0;
   
   self.messages = [[NSMutableArray alloc] init];
   
   self.messagesTable.hidden = YES;
   self.messagesTable.delegate = self;
   self.messagesTable.dataSource = self;
   
   self.hideAll.hidden = YES;
   
   UITableViewController *tableViewController = [[UITableViewController alloc] init];
   tableViewController.tableView = self.messagesTable;
   
   /*
   self.refresher = [[UIRefreshControl alloc] init];
   self.refresher.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
   [self.refresher addTarget:self action:@selector(getMessages) forControlEvents:UIControlEventValueChanged];
   */
   
   tableViewController.refreshControl = self.refresher;
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) getCount
{
   NSURL *url = [NSURL URLWithString:@"http://0.0.0.0:3000/messages.json"];
   
   NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
   
   
   [request setHTTPMethod:@"GET"];
   
   [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
   
   NSOperationQueue *queue = [[NSOperationQueue alloc] init];
   [NSURLConnection sendAsynchronousRequest:request
                                      queue:queue
                          completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                             if (error == nil) {
                                
                                NSString * jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                
                                NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                                NSArray * msg = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                                self.total = [msg count];
                             }
                             else {
                                UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle: @"Failure" message: @"Something went terribly wrong..."delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                
                                [alert1 performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                             }
                          }];

}

- (void) endRefresh
{
   [self.refresher endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (IBAction)done:(id)sender {
   
   [self.usernameField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   [textField resignFirstResponder];
   return YES;
}
- (IBAction)submit:(id)sender {
   
   
   //Note: 17 is the app_id for ios on my messagehub
   NSArray *objects = [NSArray arrayWithObjects:self.usernameField.text, self.messageField.text, @"17" , nil];
   NSArray *keys = [NSArray arrayWithObjects:@"username", @"content", @"app_id", nil];
   NSDictionary *messageDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
   
   NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:messageDict forKey:@"message"];
   
   NSData *jsonRequest = [NSJSONSerialization
                            dataWithJSONObject:jsonDict
                            options:NSJSONWritingPrettyPrinted
                            error:nil];
   
   
   NSURL *url = [NSURL URLWithString:@"http://0.0.0.0:3000/messages"];
   
   NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
   NSData *requestData = jsonRequest;
   
   [request setHTTPMethod:@"POST"];

   [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
   [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
   [request setHTTPBody: requestData];
   
   NSOperationQueue *queue = [[NSOperationQueue alloc] init];
   [NSURLConnection sendAsynchronousRequest:request
                                      queue:queue
                          completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                             if (error == nil) {
                                UIAlertView *alert3 = [[UIAlertView alloc] initWithTitle: @"Success!" message: @"Message Submitted" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                
                                [alert3 performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                                
                                self.total ++;
                             }
                             else {
                                UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle: @"Failure" message: @"Something went terribly wrong..."delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                      
                                 [alert1 performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                             }
                          }];
}

- (void) getMessages
{
   if(self.total == 0)
   {
      [self getCount];
   }
   
   NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"http://0.0.0.0:3000/messages/%d.json", self.offset]];
   
   NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
   
   
   [request setHTTPMethod:@"GET"];
   
   [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
   
   NSOperationQueue *queue = [[NSOperationQueue alloc] init];
   [NSURLConnection sendAsynchronousRequest:request
                                      queue:queue
                          completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                             if (error == nil) {
                                
                                NSString * jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                
                                NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                                self.returnedMessages = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                                
                                NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self.returnedMessages count]];
                                NSEnumerator *enumerator = [self.returnedMessages reverseObjectEnumerator];
                                for (id element in enumerator) {
                                   [array addObject:element];
                                }
                                
                                [self.messages addObjectsFromArray:array];
                              
                                self.offset = [self.messages count];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                   [self.messagesTable reloadData];
                                });
                             }
                             else {
                                UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle: @"Failure" message: @"Something went terribly wrong..."delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                
                                [alert1 performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                             }
                          }];
   
}

- (IBAction)show:(id)sender {
   self.messagesTable.hidden = NO;
   self.hideAll.hidden = NO;
   self.viewAll.hidden = YES;
}


- (IBAction)hide:(id)sender {
   self.messagesTable.hidden =YES;
   self.hideAll.hidden = YES;
   self.viewAll.hidden = NO;
}


#pragma TableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
   if (self.offset == 0) {
      return 1;
   }
   if([self.messages count] <= self.total)
      return [self.messages count] +1;
   else
      return self.total;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   NSString* cellID = @"CellID";
   NSUInteger indexRow = [indexPath row];
   UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
   
   
   if (cell == nil)
   {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
   }
   
   if (indexPath.row < [self.messages count]) {
      NSDictionary * dict = self.messages[indexRow];
   
      cell.textLabel.text = [dict objectForKey:@"content"] ;
      cell.detailTextLabel.text = [dict objectForKey:@"username"];
      cell.textLabel.numberOfLines = 0;
      
      cell.tag = 2;
   }
   else{
      return [self loadingCell];
   }
   return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return 50;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
   return NO;
}

- (UITableViewCell *)loadingCell {
   UITableViewCell *cell = [[UITableViewCell alloc]
                             initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:nil];
   
   UIActivityIndicatorView *activityIndicator =
   [[UIActivityIndicatorView alloc]
    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
   activityIndicator.center = cell.center;
   [cell addSubview:activityIndicator];
   
   [activityIndicator startAnimating];
   
   cell.tag = 0;
   
   return cell;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
   if (cell.tag == 0 && self.offset < self.total) {
      [self getMessages];
   }
   if(self.offset == 0 && cell.tag == 0)
   {
      [self getMessages];
   }
}
@end
