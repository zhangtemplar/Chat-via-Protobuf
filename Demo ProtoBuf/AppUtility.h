//
//  AppUtility.h
//  Demo ProtoBuf
//
//  Created by Qiang Zhang on 3/15/15.
//  Copyright (c) 2015 Qiang Zhang. All rights reserved.
//

#ifndef Demo_ProtoBuf_AppUtility_h
#define Demo_ProtoBuf_AppUtility_h
@class PBGeneratedMessage;
NSData* packMessage(PBGeneratedMessage *msg);

PBGeneratedMessage* unPackMessage(NSData *data);

/*
 * this function computes the number of bytes required to code the data x
 */
int getRawVariant32Length(int x);
#endif
