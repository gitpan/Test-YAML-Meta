package Test::YAML::Meta;

use warnings;
use strict;

use vars qw($VERSION);
$VERSION = '0.16';

#----------------------------------------------------------------------------

=head1 NAME

Test::YAML::Meta - Validation of the META.yml file in a distribution.

=head1 SYNOPSIS

There are two forms this module can be used.

The first is a standalone test of your distribution's META.yml file:

  use Test::More;
  eval "use Test::YAML::Meta";
  plan skip_all => "Test::YAML::Meta required for testing META.yml" if $@;
  meta_yaml_ok();

Note that you may provide an optional label/comment/message/etc to the
function, or one will be created automatically.

The second form allows you to test other META.yml files, or specify a specific
version you wish to test against:

  use Test::More test => 6;
  use Test::YAML::Meta;

  # specify a file and specification version
  meta_spec_ok('META.yml','1.3',$msg);

  # specify the specification version to validate the local META.yml
  meta_spec_ok(undef,'1.3',$msg);

  # specify a file, where the specification version is deduced
  # from the file itself
  meta_spec_ok('META.yml',undef,$msg);

Note that this form requires you to specify the number of tests you will be
running in your test script. Also note that each 'meta_spec_ok' is actually 2
tests under the hood.

=head1 DESCRIPTION

This module was written to ensure that a META.yml file, provided with a
standard distribution uploaded to CPAN, meets the specifications that slowly
being introduced to module uploads, via the use of L<ExtUtils::MakeMaker>,
L<Module::Build> and L<Module::Install>.

=head1 ABSTRACT

A test module to validate a META.yml file.

=cut

#----------------------------------------------------------------------------

#############################################################################
#Library Modules															#
#############################################################################

use Test::Builder;
use Test::YAML::Valid           -Syck;
use Test::YAML::Meta::Version;

#----------------------------------------------------------------------------

my $Test = Test::Builder->new();

sub import {
    my $self = shift;
    my $caller = caller;
    no strict 'refs';
    *{$caller.'::meta_yaml_ok'}   = \&meta_yaml_ok;
    *{$caller.'::meta_spec_ok'}   = \&meta_spec_ok;

    $Test->exported_to($caller);
    $Test->plan(@_);
}

#############################################################################
#Interface Functions														#
#############################################################################

=head1 FUNCTIONS

=over

=item * meta_yaml_ok([$msg])

Basic META.yml wrapper around meta_spec_ok.

=cut

sub meta_yaml_ok {
    $Test->plan( tests => 2 );
    return meta_spec_ok(undef,undef,@_);
}

=item * meta_spec_ok($file, $version [,$msg])

Validates the named file against the given specification version. Both $file
and $version can be undefined.

=back

=cut

sub meta_spec_ok {
	my ($file, $vers, $msg) = @_;
    $file ||= 'META.yml';

    unless($msg) {
        $msg = "$file meets the designated specification";
        $msg .= " ($vers)"   if($vers);
    }

    if(my $yaml = yaml_file_ok($file)) {
        my %hash;
        $hash{spec} = $vers if($vers);
        $hash{yaml} = $yaml;

        my $spec = Test::YAML::Meta::Version->new(%hash);
        if(my $result = $spec->parse()) {
            $Test->ok(0,$msg);
            $Test->diag("  ERR: $_") for($spec->errors);
        } else {
            $Test->ok(1,$msg);
        }

        return $yaml;

    } else {
        print STDERR "\n#Failed\n";
    }
}

q( Currently Listening To: Blondie - "Screaming Skin" from 'No Exit');

__END__

#----------------------------------------------------------------------------

=head1 TESTING META FILES

There are currently 3 distributions to test META files:

  Test-CPAN-Meta
  Test-JSON-Meta
  Test-YAML-Meta

All three have slightly different requirements and are intended to be used in
slightly different environments. 

Test-YAML-Meta requires a YAML parser, and currently looks for the YAML or 
YAML::Syck modules. This is the original variant of the 3 and was intended to
provide a more complete YAML validation of a META.yml.

Test-CPAN-Meta requires the Parse::CPAN::Meta module, which is now part of Perl
Core as of perl-5.10.1. This version is intended to be used by those only 
wishing to rely on core modules to test their META.yml files.

Test-JSON-Meta is the most recent addition to the family, and is specifically
aimed at those distributions that use a META.json Meta file. The distribution
requires the JSON module to parse the Meta file.

=head1 BUGS, PATCHES & FIXES

There are no known bugs at the time of this release. However, if you spot a
bug or are experiencing difficulties that are not explained within the POD
documentation, please send an email to barbie@cpan.org or submit a bug to the
RT system (http://rt.cpan.org/Public/Dist/Display.html?Name=Test-YAML-Meta).
However, it would help greatly if you are able to pinpoint problems or even
supply a patch.

Fixes are dependant upon their severity and my availablity. Should a fix not
be forthcoming, please feel free to (politely) remind me.

=head1 SEE ALSO

  Test::YAML::Valid

=head1 DSLIP

  b - Beta testing
  d - Developer
  p - Perl-only
  O - Object oriented
  p - Standard-Perl: user may choose between GPL and Artistic

=head1 AUTHOR

Barbie, <barbie@cpan.org>
for Miss Barbell Productions, L<http://www.missbarbell.co.uk>

=head1 COPYRIGHT AND LICENSE

  Copyright (C) 2007-2010 Barbie for Miss Barbell Productions

  This module is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.

=cut
