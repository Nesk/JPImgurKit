//
//  JPImgurImage.h
//  JPImgurKit
//
//  Created by Johann Pardanaud on 10/07/13.
//  Distributed under the MIT license.
//

#import "JPImgurBasicImage.h"

@interface JPImgurImage : JPImgurBasicImage

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *description;
@property (nonatomic, readonly) NSDate *datetime;

@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) BOOL animated;

@property (nonatomic, readonly) NSInteger width;
@property (nonatomic, readonly) NSInteger height;
@property (nonatomic, readonly) NSInteger size;

@property (nonatomic, readonly) NSInteger views;
@property (nonatomic, readonly) NSInteger bandwidth;

#pragma mark - Uploading an image

+ (void)uploadImageWithFileURL:(NSURL *)fileURL success:(void (^)(JPImgurBasicImage *))success failure:(void (^)(NSError *))failure;
+ (void)uploadImageWithFileURL:(NSURL *)fileURL title:(NSString *)title description:(NSString *)description andLinkToAlbumWithID:(NSString *)albumID success:(void (^)(JPImgurBasicImage *))success failure:(void (^)(NSError *))failure;

+ (void)uploadImageWithURL:(NSURL *)url success:(void (^)(JPImgurBasicImage *))success failure:(void (^)(NSError *))failure;
+ (void)uploadImageWithURL:(NSURL *)url title:(NSString *)title description:(NSString *)description filename:(NSString *)filename andLinkToAlbumWithID:(NSString *)albumID success:(void (^)(JPImgurBasicImage *))success failure:(void (^)(NSError *))failure;

#pragma mark - Loading the image properties

+ (void)imageWithID:(NSString *)imageID success:(void (^)(JPImgurImage *))success failure:(void (^)(NSError *))failure;
- (void)loadImageWithID:(NSString *)imageID success:(void (^)(JPImgurImage *))success failure:(void (^)(NSError *))failure;
- (void)setImagePropertiesWithJSONObject:(NSData *)object;

@end
