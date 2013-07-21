//
//  JPImgurClient.m
//  JPImgurKit
//
//  Created by Johann Pardanaud on 29/06/13.
//  Distributed under the MIT license.
//

#import "JPImgurClient.h"
#import "AFOAuth2Client.h"
#import "AFJSONRequestOperation.h"

NSString * const JPBaseURL = @"https://api.imgur.com/3/";
NSString * const JPOAuthBaseURL = @"https://api.imgur.com/oauth2/";

@implementation JPImgurClient

+ (instancetype)sharedInstance
{
    return [self sharedInstanceWithBaseURL:nil clientID:nil secret:nil];
}

+(instancetype)sharedInstanceWithBaseURL:(NSURL *)url
{
    return [self sharedInstanceWithBaseURL:url clientID:nil secret:nil];
}

+(instancetype)sharedInstanceWithClientID:(NSString *)clientID secret:(NSString *)secret
{
    return [self sharedInstanceWithBaseURL:nil clientID:clientID secret:secret];
}

+ (instancetype)sharedInstanceWithBaseURL:(NSURL *)url clientID:(NSString *)clientID secret:(NSString *)secret
{
    static dispatch_once_t onceToken;
    static JPImgurClient *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JPImgurClient alloc] initWithBaseURL:url clientID:clientID secret:secret];
    });
    return sharedInstance;
}

#pragma mark -

- (instancetype)initWithBaseURL:(NSURL *)url clientID:(NSString *)clientID secret:(NSString *)secret
{
    url = (url == nil) ? [NSURL URLWithString:JPBaseURL] : url;
    self = [self initWithBaseURL:url];
    
    if(clientID != nil || secret != nil)
        [self initializeOAuthWithClientID:clientID secret:secret];
    
    return self;
}

#pragma mark -

- (void)initializeOAuthWithClientID:(NSString *)clientID secret:(NSString *)secret
{
    if(!oauthClient)
        oauthClient = [[AFOAuth2Client alloc] initWithBaseURL:[NSURL URLWithString:JPOAuthBaseURL] clientID:clientID secret:secret];
}

#pragma mark -

- (NSURL *)getAuthorizationURLUsingPIN
{
    if(!oauthClient)
        @throw [NSException exceptionWithName:@"MissingResourceException" reason:@"The OAuth Client must be initialized to use this method" userInfo:nil];
    
    NSString *path = [NSString stringWithFormat:@"authorize?response_type=pin&client_id=%@", oauthClient.clientID];
    return [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:JPOAuthBaseURL]];
}

- (void)authenticateUsingOAuthWithPIN:(NSString *)pin success:(void (^)(AFOAuthCredential *))success failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    [mutableParameters setObject:@"pin" forKey:@"grant_type"];
    [mutableParameters setValue:pin forKey:@"pin"];
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    [oauthClient authenticateUsingOAuthWithPath:@"token" parameters:parameters success:^(AFOAuthCredential *credential) {
        // Here we specify the authorization header for the API client and call afterwards the success block
        [self setAuthorizationHeaderWithToken:[credential accessToken]];
        success(credential);
    } failure:failure];
}

- (void)setAuthorizationHeaderWithToken:(NSString *)token
{
    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", token]];
}

@end