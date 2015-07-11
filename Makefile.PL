use 5.006; # PL_check added with v5.6
use strict;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'stricter',
    VERSION_FROM      => 'stricter.pm',
    PREREQ_PM         => {
        'multidimensional' => 0
    },
    ($] >= 5.005 ?
      (ABSTRACT_FROM  => 'stricter.pm',
       AUTHOR         => 'Reini Urban <rurban@cpan.org>') : ()),
   ($ExtUtils::MakeMaker::VERSION gt '6.46' ?
    ('META_MERGE'  => {
        resources => {
            repository  => 'http://github.com/rurban/stricter',
            license     => 'http://dev.perl.org/licenses/',
        },
     }
    ) : ()),
    SIGN => 1,
);

package MY;
#use Config;

sub depend {
  "
README.md : \$(VERSION_FROM)
	pod2markdown \$(VERSION_FROM) > \$@

release : README.md README dist
	git commit -am\"release \$(VERSION)\"
	echo -n continue?
	read y
	git tag \$(VERSION)
	cpan-upload \$(DISTVNAME).tar\$(SUFFIX)
	git push
	git push --tags

test_cover :: pure_all
	\$(RM_RF) cover_db
	\$(PERLRUNINST) -S cover -test
test_coveralls :: pure_all
	\$(PERLRUNINST) -S cover -test -report coveralls

gcov : \$(BASEEXT).c.gcov \$(BASEEXT).gcov cover_db/\$(BASEEXT)-xs.html

\$(BASEEXT).c.gcov \$(BASEEXT).xs.gcov : \$(BASEEXT).xs
	\$(MAKE) CCFLAGS=\"\$(CCFLAGS) -fprofile-arcs -ftest-coverage\" LDDLFLAGS=\"\$(LDDLFLAGS) -fprofile-arcs -ftest-coverage\"
	gcov \$(BASEEXT).c \$(BASEEXT).xs

cover_db/\$(BASEEXT)-xs.html : \$(BASEEXT).xs.gcov
	PERL5OPT=-MDevel::Cover make test
	-$^X -S gcov2perl \$(BASEEXT).c.gcov \$(BASEEXT).xs.gcov
	$^X -S cover

gprof :
	\$(MAKE) CCFLAGS=\"\$(CCFLAGS) -pg\" LDDLFLAGS=\"\$(LDDLFLAGS) -pg\"
"
}
