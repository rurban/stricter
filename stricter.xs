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
    return 1; /* dummy for testing */
}

STATIC OP *(*old_ck_aassign)(pTHX_ OP *) = NULL;

STATIC OP *
my_ck_aassign(pTHX_ OP *o) {
    dSP;
    o = CALL_FPTR(old_ck_aassign)(aTHX_ o); /* This is usually null */
    
    if (my_hint()) { /* check if we are lexically active */
        SV *msg = newSVpvs("");

        /* TODO check for violations */
        if (o->op_flags & OPf_KIDS) {
            OP *or = NULL;
            OP *ol_pushmark;
            OP *ol = cBINOPo->op_first;
            OP* or_pushmark = cUNOPx(ol)->op_first;
            char *lname = NULL;
            int nright;

            if (OpHAS_SIBLING(or_pushmark)) {
                or = OpSIBLING(or_pushmark);
                if (or->op_type == OP_SORT || or->op_type == OP_REVERSE)
                    return o;
            }
            if (!or) return o;
#if 0
            /* how many scalars on the right? */
            for (nright = 0; OpHAS_SIBLING(or); or = OpSIBLING(or)) {
                if (!or) break;
                if (PL_opargs[or->op_type] & OA_RETSCALAR)
                    nright++;
            }
#endif
            /* if there is a @ or % on the left, not at the end */
            ol_pushmark = cUNOPx(OpSIBLING(ol))->op_first;
            for (ol = OpSIBLING(ol_pushmark); OpHAS_SIBLING(ol); ol = OpSIBLING(ol)) {
                if (!ol) break;
                if (ol->op_type == OP_PADAV || ol->op_type == OP_PADHV)
                    lname = PadnamePV(PAD_COMPNAME(ol->op_targ));
                else if (ol->op_type == OP_RV2AV)
                    lname = "ARRAY";
                else if (ol->op_type == OP_RV2HV)
                    lname = "HASH";
            }

            if (lname && ol) {
                char *rname = "SCALAR on the right";
                if (ol->op_type == OP_PADSV)
                    rname = PadnamePV(PAD_COMPNAME(ol->op_targ));
                sv_catpvf(msg, "Possible wrong slurpy assignment with %s in LIST,"
                          " leaving %s as undef", lname, rname);
            }
        }
        
        /* warn if stricter is enabled. no warnings 'stricter',
           apply the FATAL or NONFATAL bit */
        if (SvCUR(msg)) {
            PUSHMARK(SP);
            XPUSHs(newSVpvs("stricter"));
            XPUSHs(msg);
            PUTBACK;
            call_pv("warnings::warnif", G_DISCARD);
            SPAGAIN;
        }
    }
    return o;
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

  wrap_op_checker(OP_AASSIGN, my_ck_aassign, &old_ck_aassign);
}
