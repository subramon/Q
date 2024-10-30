#ifndef __GET_REQ_TYPE_H
#define __GET_REQ_TYPE_H


#define  WebUndefined 0 // By convention, this must always be there 

#define  Disk        1
#define  Halt        2 
#define  HaltMaster  3 
#define  Ignore      4
#define  Lua         5
#define  Memory      6
#define  Favicon     7
  //-- only for out of band server 
#define  SetDisk     8
#define  SetMaster   9
#define  SetMemory   10

extern int
get_req_type(
    const char *api
    );
#endif // __GET_REQ_TYPE_H
