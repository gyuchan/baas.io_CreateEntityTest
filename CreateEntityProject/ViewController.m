//
//  ViewController.m
//  CreateEntityProject
//
//  Created by gyuchan jeon on 13. 1. 25..
//  Copyright (c) 2013년 gyuchan jeon. All rights reserved.
//

#import "ViewController.h"

//baas.io SDK 추가하기
#import "BaasClient.h"

@interface ViewController (){
    UITableView *_tableView ;
}
@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Create Entity";
        
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        _tableView.scrollEnabled = NO;
        _tableView.allowsSelection = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return self;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 300;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    footerView.backgroundColor = [UIColor clearColor];
    
    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    postButton.frame = CGRectMake(10, 10, 300, 44);
    [postButton setTitle:@"POST" forState:UIControlStateNormal];
    [postButton addTarget:self action:@selector(postButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    postButton.enabled = false;
    postButton.tag = 3;
    [footerView addSubview:postButton];
    return footerView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellName = @"entityCell";
    
    UITableViewCell *entityCell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (entityCell == nil) {
        entityCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, 44)];
        label.backgroundColor = [UIColor clearColor];
        label.tag = 1;
        [entityCell addSubview:label];
        
        UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(120, 10, 200, 44)];
        field.delegate = self;
        field.backgroundColor = [UIColor clearColor];
        field.tag = 20 + indexPath.row;
        switch (indexPath.row) {
            case 0:
                field.text = @"foo";
                field.placeholder = @"Collection이름 입력";
                break;
            case 1:
                field.text = @"";
                field.placeholder = @"key값 입력";
                break;
            case 2:
                field.text = @"";
                field.placeholder = @"Value값 입력";
                break;
            default:
                break;
        }
        [entityCell addSubview:field];
    }
    
    UILabel *label = (UILabel*)[entityCell viewWithTag:1];
    UITextField *field = (UITextField*)[entityCell viewWithTag:2 + indexPath.row];
    field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    switch (indexPath.row){
        case 0:
            label.text = @"Collection";
            break;
        case 1:
            label.text = @"Key";
            break;
        case 2:
            label.text = @"Value";
            break;
    }
    return entityCell;
}


#pragma mark - event
- (void)postButtonPressed
{
    UITextField *collectionField = (UITextField *)[self.view viewWithTag:20];
    UITextField *keyField = (UITextField *)[self.view viewWithTag:21];
    UITextField *valueField = (UITextField *)[self.view viewWithTag:22];
    
    //post보내기
    NSDictionary *entity = @{keyField.text: valueField.text};
    BaasClient *baasClient = [BaasClient createInstance];
    [baasClient setDelegate:self];
    [baasClient setLogging:YES];
    UGClientResponse *response = [baasClient createEntity:collectionField.text entity:entity];
    NSLog(@"response.transactionID : %i", response.transactionID);
}

#pragma mark - UGClient delegate
- (void)ugClientResponse:(UGClientResponse *)response
{
    NSDictionary *resp = (NSDictionary *)response.rawResponse;
    if (response.transactionState == kUGClientResponseFailure) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"로그인에 실패하였습니다.\n다시 시도해주세요."
                                                            message:[resp objectForKey:@"error_description"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"POST가 성공하였습니다.\n데이터 브라우저에서 확인해보세요!"
                                                            message:[resp objectForKey:@"error_description"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}
#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self checkButtonEnable];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self checkButtonEnable];
}

- (void)checkButtonEnable
{
    UITextField *collectionField = (UITextField *)[self.view viewWithTag:20];
    UITextField *keyField = (UITextField *)[self.view viewWithTag:21];
    UITextField *valueField = (UITextField *)[self.view viewWithTag:22];
    collectionField.text = [collectionField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    keyField.text = [keyField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    valueField.text = [valueField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    UIButton *button = (UIButton*)[self.view viewWithTag:3];
    if (![collectionField.text isEqualToString:@""] && ![keyField.text isEqualToString:@""] && ![valueField.text isEqualToString:@""]){
        button.enabled = YES;
    } else{
        button.enabled = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
