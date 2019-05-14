/*
 * Copyright (c) 2017 Mindaugas Rasiukevicius <rmind at noxt eu>
 * All rights reserved.
 *
 * Use is subject to license terms, as specified in the LICENSE file.
 */


#define	RHM_NOCOPY		0x01
#define	RHM_NONCRYPTO		0x02

#ifndef _Q_RHASHMAP___KV__
#define _Q_RHASHMAP___KV__
// #define KV__KEYTYPE __KV__
#define PASTER(x,y) x ## _ ## y
#define EVALUATOR(x,y)  PASTER(x,y)
#define NAME__KV__(fun) EVALUATOR(fun, __KV__)

typedef struct {
	__KEYTYPE__  key; 
	__VALTYPE__ val;
	uint64_t	hash	: 32;
	uint64_t	psl	: 16;
} rh_bucket___KV___t;

typedef struct {
	unsigned	size;
	unsigned	nitems;
	unsigned	flags;
	uint64_t	divinfo;
	rh_bucket___KV___t *	buckets;
	uint64_t	hashkey;
	unsigned	minsize;
} q_rhashmap___KV___t; 

extern q_rhashmap___KV___t *
q_rhashmap_create___KV__(
    size_t initial_size
    );
extern void		
q_rhashmap_destroy___KV__(
    q_rhashmap___KV___t *
    );

extern __VALTYPE__
q_rhashmap_get___KV__(
    q_rhashmap___KV___t *,
    __KEYTYPE__ key
    );
extern __VALTYPE__
q_rhashmap_put___KV__(
q_rhashmap___KV___t *,
    __KEYTYPE__ key,
    __VALTYPE__ val
    );
extern __VALTYPE__
q_rhashmap_del___KV__(
    q_rhashmap___KV___t *,
    __KEYTYPE__ key
    );

#endif
