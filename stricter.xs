/* -*- mode:C c-basic-offset:4 -*- */
#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#define __PACKAGE__     "stricter"
#define __PACKAGE_LEN__ (sizeof(__PACKAGE__)-1)

#ifdef USE_ITHREADS
# define MY_CXT_KEY __PACKAGE__ "::_guts" XS_VERSION
# ifndef MY_CXT_CLONE
#  define MY_CXT_CLONE \
    dMY_CXT_SV;                                                      \
    my_cxt_t *my_cxtp = (my_cxt_t*)SvPVX(newSV(sizeof(my_cxt_t)-1)); \
    Copy(INT2PTR(my_cxt_t*, SvUV(my_cxt_sv)), my_cxtp, 1, my_cxt_t); \
    sv_setuv(my_cxt_sv, PTR2UV(my_cxtp))
# endif

typedef struct {
 peep_t  old_peep; /* This is actually the rpeep past 5.13.5 */
 tTHX    owner;
} my_cxt_t;

START_MY_CXT

#endif

typedef OP *(*my_ck_t)(pTHX_ OP *);

/* added with 5.18 */
#ifndef wrap_op_checker
STATIC void
wrap_op_checker(pTHX_ OPCODE type, my_ck_t new_ck, my_ck_t *old_ck_p)
{
    OP_CHECK_MUTEX_LOCK;
    if (!*old_ck_p) {
        *old_ck_p      = PL_check[type];
        PL_check[type] = new_ck;
    }
    OP_CHECK_MUTEX_UNLOCK;
}
#endif

STATIC int
my_hint() {
    return 1;
}

STATIC OP *(*old_ck_aassign)(pTHX_ OP *) = NULL;

STATIC OP *
my_ck_aassign(pTHX_ OP *o) {
    o = CALL_FPTR(old_ck_aassign)(aTHX_ o);
    if (my_hint()) {
        OP *kid    = o;
        OP *prev   = NULL;
        OP *parent = NULL;

        while (kid->op_flags & OPf_KIDS) {
            parent = kid;
            kid    = cUNOPx(kid)->op_first;
        }
    }
}

  
MODULE = stricter		PACKAGE = stricter

PROTOTYPES: DISABLE

#ifdef USE_ITHREADS

void
CLONE(...)
PROTOTYPE: DISABLE
PREINIT:
  ISET *old_s;
PPCODE:
 {
  dMY_CXT;
  old_s = MY_CXT.s;
 }
 {
  MY_CXT_CLONE;
  MY_CXT.s = old_s;
 }
 XSRETURN(0);

#endif

BOOT:
{
#ifdef USE_ITHREADS
  MY_CXT_INIT;
  MY_CXT.map         = newHV();
  MY_CXT.placeholder = NULL;
  MY_CXT.owner       = aTHX;
#endif

  my_ck_replace(OP_AASSIGN, my_ck_aassign, &old_ck_aassign);
}
