//
//  AppUtility.m
//  Demo ProtoBuf
//
//  Created by Qiang Zhang on 3/15/15.
//  Copyright (c) 2015 Qiang Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "App.pb.h"
#import "AppUtility.h"

NSData* packMessage(Message *msg)
{
    int msg_length=(int)[[msg data] length];
    int msg_header_length=sizeof(int32_t);
    
    NSMutableData *data=[NSMutableData dataWithLength:msg_length+msg_header_length];
    PBCodedOutputStream *output_stream=[PBCodedOutputStream streamWithData:data];
    [output_stream writeRawVarint32:msg_length];
//    [output_stream flush];
    [msg writeToCodedOutputStream:output_stream];
//    [output_stream flush];
    
    return data;
}

Message* unPackMessage(NSData *data)
{
    // first scan the header for the length of the data
    char buf[5];
    for (int i=0; i<5 && i<data.length; i++)
    {
        buf[i]=(((char *)data.bytes)[i]);
        if (buf[i]>=0)
        {
            int length=[[PBCodedInputStream streamWithData:[NSMutableData dataWithBytes:buf length:i+1]] readRawVarint32];
            if (length<0)
            {
                // some error here
                NSLog(@"Parse message error in length: %d\n", length);
                return nil;
            }
            else
            {
                // pass the message
                if (data.length<length+i+1)
                {
                    // message doesn't match the length
                    NSLog(@"The length of the message doesn't match: %d\n", length);
                    return nil;
                }
                else
                {
                    // finally we can parse the message
                    Message *msg=[Message parseFromCodedInputStream:[PBCodedInputStream streamWithData:[NSMutableData dataWithBytesNoCopy:(char *)data.bytes+(i+1) length:length]]];
                    return msg;
                }
            }
        }
    }
    return nil;
}