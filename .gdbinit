set breakpoint pending on

b my_ck_aassign
r

# stack dump, sp or PL_sp or my_perl->Istack_sp?
define sp_dump
  if my_perl
    p/x **my_perl->Istack_sp
    call Perl_sv_dump(my_perl, *my_perl->Istack_sp)
  else
    p/x **PL_sp
    Perl_sv_dump(*PL_sp)
  end
end
document sp_dump
 => Perl_sv_dump(PL_sp)
end

define op_dump
  if my_perl
    p/x *my_perl->Iop
    call Perl_op_dump(my_perl, my_perl->Iop)
  else
    p/x *PL_op
    call Perl_op_dump(PL_op)
  end
end
document op_dump
 => Perl_op_dump(PL_op)
see `odump op`
end

define sv_dump
  p/x *sv
  if my_perl
    call Perl_sv_dump(my_perl, sv)
  else
    call Perl_sv_dump(sv)
  end
end
document sv_dump
 => Perl_sv_dump(sv)
see `sdump sv`
end

define odump
  p/x *$arg0
  #if my_perl
  #  call Perl_op_dump(my_perl, $arg0)
  #else
    call Perl_op_dump($arg0)
  #end
end
document odump
odump op => p/x *op; Perl_op_dump(op)
see `help op_dump` for PL_op
end

define sdump
  p/x *$arg0
  #if my_perl
  #  call Perl_sv_dump(my_perl, $arg0)
  #else
    call Perl_sv_dump($arg0)
  #end
end
document sdump
sdump sv => p/x *sv; Perl_sv_dump(sv)
see `help sv_dump`
end


r
