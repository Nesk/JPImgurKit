//
//  ImgurClient.m
//  ImgurKit
//
//  Created by Johann Pardanaud on 29/06/13.
//  Distributed under the MIT license.
//

#import "ImgurClient.h"

static NSString * const JPBaseURL = @"https://api.imgur.com/3/";
static NSString * const JPOAuthBaseURL = @"https://api.imgur.com/oauth2/";

@implementation ImgurClient;

#pragma mark - Get/Set

@synthesize oauthClient=_oauthClient;

- (AFOAuth2Client *)oauthClient
{
    if(!_oauthClient)
        _oauthClient = [[AFOAuth2Client alloc] initWithBaseURL:[NSURL URLWithString:JPOAuthBaseURL] clientID:_clientID secret:_secret];
    
    return _oauthClient;
}

#pragma mark - Initialize

+ (instancetype)sharedInstance
{
    return [self sharedInstanceWithBaseURL:nil clientID:nil secret:nil];
}

+(instancetype)sharedInstanceWithClientID:(NSString *)clientID secret:(NSString *)secret
{
    return [self sharedInstanceWithBaseURL:nil clientID:clientID secret:secret];
}

+ (instancetype)sharedInstanceWithBaseURL:(NSURL *)url clientID:(NSString *)clientID secret:(NSString *)secret
{
    static dispatch_once_t onceToken;
    static ImgurClient *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ImgurClient alloc] initWithBaseURL:url clientID:clientID secret:secret];
    });
    return sharedInstance;
}

- (instancetype)initWithBaseURL:(NSURL *)url clientID:(NSString *)clientID secret:(NSString *)secret
{
    url = (url == nil) ? [NSURL URLWithString:JPBaseURL] : url;
    self = [self initWithBaseURL:url];
    
    _retryCountOnImgurError = 3;
    
    _clientID = clientID;
    _secret = secret;
    
    return self;
}

#pragma mark - Authenticate

- (NSURL *)authorizationURLUsing:(ImgurAuthType)authType
{
    NSString *responseType;

    switch (authType) {
        case ImgurAuthTypeToken:
            responseType = @"token";
            break;

        case ImgurAuthTypePIN:
            responseType = @"pin";
            break;

        case ImgurAuthTypeCode:
            responseType = @"code";
            break;
    }

    NSString *path = [NSString stringWithFormat:@"authorize?response_type=%@&client_id=%@", responseType, self.oauthClient.clientID];
    return [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:JPOAuthBaseURL]];
}

- (void)authenticateUsingOAuthWithPIN:(NSString *)pin success:(void (^)(AFOAuthCredential *credentials))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"pin", pin, nil]
                                                           forKeys:[NSArray arrayWithObjects:@"grant_type", @"pin", nil]];
    
    [self.oauthClient authenticateUsingOAuthWithPath:@"token" parameters:parameters success:^(AFOAuthCredential *credential) {
        // Here we specify the authorization header for the API client and call afterwards the success block
        [self setAuthorizationHeaderWithToken:[credential accessToken]];
        success(credential);
    } failure:failure];
}

- (void)setAuthorizationHeaderWithToken:(NSString *)token
{
    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", token]];
}

#pragma mark - Manage the requests

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(void (^)(AFHTTPRequestOperation *, id))success
                                                    failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    return [super HTTPRequestOperationWithRequest:urlRequest success:success failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(operation.response.statusCode >= 500)
            [self HTTPRequestOperationWithRequest:urlRequest success:success failure:failure andRetry:_retryCountOnImgurError];
        else
            failure(operation, error);
    }];
}

- (void)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(void (^)(AFHTTPRequestOperation *, id))success
                                                    failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
                                                   andRetry:(NSInteger)retryCount
{
    AFHTTPRequestOperation *operation;
    
    if(retryCount > 1)
    {
        operation = [super HTTPRequestOperationWithRequest:urlRequest success:success failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if(operation.response.statusCode >= 500)
                [self HTTPRequestOperationWithRequest:urlRequest success:success failure:failure andRetry:retryCount - 1];
            else
                failure(operation, error);
        }];
    }
    
    else // Last retry
        operation = [super HTTPRequestOperationWithRequest:urlRequest success:success failure:failure];
    
    [self enqueueHTTPRequestOperation:operation];
}

@end