/*
 * Copyright (c) 2017 Mindaugas Rasiukevicius <rmind at noxt eu>
 * All rights reserved.
 *
 * Use is subject to license terms, as specified in the LICENSE file.
 */

#ifndef _RHASHMAP_H_
#define _RHASHMAP_H_

#define	RHM_NOCOPY		0x01
#define	RHM_NONCRYPTO		0x02

#define KEYTYPE __KEYTYPE__
#define VALTYPE  __VALTYPE__
#define KV __KV__
#define PASTER(x,y) x ## _ ## y
#define EVALUATOR(x,y)  PASTER(x,y)
#define NAME(fun) EVALUATOR(fun, KV)

typedef struct {
	KEYTYPE  key; 
	VALTYPE val;
	uint64_t	hash	: 32;
	uint64_t	psl	: 16;
} NAME(rh_bucket_);

typedef struct {
	unsigned	size;
	unsigned	nitems;
	unsigned	flags;
	uint64_t	divinfo;
	NAME(rh_bucket_) *	buckets;
	uint64_t	hashkey;
	unsigned	minsize;
} NAME(rhashmap_);

extern NAME(rhashmap_) *	
NAME(q_rhashmap_create)(
    size_t initial_size
    );
extern void		
NAME(q_rhashmap_destroy)(
    NAME(rhashmap_) *
    );

extern VALTYPE
NAME(q_rhashmap_get)(
    NAME(rhashmap_) *, 
    KEYTYPE key
    );
extern VALTYPE
NAME(q_rhashmap_put)(
    NAME(rhashmap_) *, 
    KEYTYPE key,
    VALTYPE val
    );
extern VALTYPE
NAME(q_rhashmap_del)(
    NAME(rhashmap_) *, 
    KEYTYPE key
    );

#endif
