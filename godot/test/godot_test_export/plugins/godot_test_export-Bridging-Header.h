//
//  GodotBridge.h
//  godot_test_export
//
//  Created by Ayah Harper on 2/7/25.
//  Copyright © 2025 GodotEngine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "godot_ios.h"

@interface GodotBridge : NSObject
+ (void)sendSignalToGodot:(NSString *)signalName withData:(NSDictionary *)data;
@end


