#!/usr/bin/perl
package FTN::Addr;
our $VERSION = '20090704';

use strict;
use warnings;
#use base = qw(Exporter);
#our @EXPORT = ();
#our @EXPORT_OK = ();

use Carp qw(croak);

use overload
  "eq" => \&eq_,
  "cmp" => \&cmp_,
  fallback => 1;

my $default_domain = "fidonet";

sub set_results($) {
  my $t = shift;
  $t -> {full4d} = "$t->{zone}:$t->{net}/$t->{node}.$t->{point}";
  $t -> {full5d} = $t -> {full4d} . "\@$t->{domain}";
  $t -> {short4d} = "$t->{zone}:$t->{net}/$t->{node}" . ($t -> {point}? ".$t->{point}" : '');
  $t -> {short5d} = $t -> {short4d} . "\@$t->{domain}";
  $t -> {fqfa} = "$t->{domain}#$t->{zone}:$t->{net}/$t->{node}.$t->{point}";
  $t -> {brake_style} = "$t->{domain}.$t->{zone}.$t->{net}.$t->{node}.$t->{point}";
}

sub new($$;$) {
  my $either = shift;
  my $class = ref($either) || $either;
  my $addr = shift;
  my $base_addr = shift;
  $base_addr = undef unless defined($base_addr) && ref($base_addr) && $base_addr -> isa('FTN::Addr');

  if (ref $either) {
    %$either = ();
  } else {
    $either = {};
  }

  # let's figure domain
  if ($addr =~ m!(\w+)#([\d:/.]+)!) { # fidonet#2:451/31.0
    $either -> {domain} = $1;
    $addr = $2;
  } elsif ($addr =~ m!([\d:/.]+)@(\w+)!) { # 2:451/31.0@fidonet
    $either -> {domain} = $2;
    $addr = $1;
  } elsif ($addr =~ m!(\w+)\.(\d+\.\d+\.\d+\.\d+)!) { # fidonet.2.451.31.0
    $either -> {domain} = $1;
    $addr = $2;
  } else {
    $either -> {domain} = $base_addr? $base_addr -> {domain} : $default_domain;
  }

  # and the rest of the address
  if ($addr =~ m!^(\d+):(\d+)/(\d+)\.?(\d*)$!) { # 2:451/31.0 or 2:451/31
    $either -> {zone} = $1;
    $either -> {net} = $2;
    $either -> {node} = $3;
    $either -> {point} = $4 || 0;
  } elsif ($addr =~ m!^\.(\d+)$!) { # addr as .4
    if ($base_addr) {
      $either -> {zone} = $base_addr -> zone;
      $either -> {net} = $base_addr -> net;
      $either -> {node} = $base_addr -> node;
      $either -> {point} = $1;
    } else {			# no base addr - no way to get full addr...
      return undef;
    }
  } elsif ($addr =~ m!^(\d+)\.?(\d*)$!) { # addr as 31 or 31.6
    if ($base_addr) {
      $either -> {zone} = $base_addr -> zone;
      $either -> {net} = $base_addr -> net;
      $either -> {node} = $1;
      $either -> {point} = $2 || 0;
    } else {			# no base addr - no way to get full addr...
      return undef;
    }
  } elsif ($addr =~ m!^(\d+)/(\d+)\.?(\d*)$!) { # addr as 451/31 or 451/31.6
    if ($base_addr) {
      $either -> {zone} = $base_addr -> zone;
      $either -> {net} = $1;
      $either -> {node} = $2;
      $either -> {point} = $3 || 0;
    } else {			# no base addr - no way to get full addr...
      return undef;
    }
  } elsif ($addr =~ m!^(\d+)\.(\d+)\.(\d+)\.(\d+)$!) { # addr as 2.451.31.0 - brake style
    $either -> {zone} = $1;
    $either -> {net} = $2;
    $either -> {node} = $3;
    $either -> {point} = $4;
  } else {
    return undef;
  }

  # some checking for correctness...
  unless (1 <= $either -> {zone} && $either -> {zone} <= 32767 # FRL-1002.001
	  && 1 <= $either -> {net} && $either -> {net} <= 32767 # FRL-1002.001
	  && -1 <= $either -> {node} && $either -> {node} <= 32767 # FRL-1002.001
	  && 0 <= $either -> {point} && $either -> {point} <= 32767 # FRL-1002.001
	  && length($either -> {domain}) <= 8 # FRL-1002.001
	  && index($either -> {domain}, '.') == -1) { # FRL-1002.001
    %$either = ();
    return undef;
  }

  set_results($either);
  bless $either, $class;
}

sub domain($) {
  ref(my $inst = shift) or croak "I'm only instance method!";
  $inst -> {domain};
}

sub set_domain($$) {
  ref(my $inst = shift) or croak "I'm only instance method!";
  my $d = shift;
  $inst -> {domain} = $d || $default_domain;
  set_results($inst);
}

sub zone($) {
  ref(my $inst = shift) or croak "I'm only instance method!";
  $inst -> {zone};
}

sub set_zone($$) {
  ref(my $inst = shift) or croak "I'm only instance method!";
  $inst -> {zone} = shift;
  set_results($inst);
}

sub net($) {
  ref(my $inst = shift) or croak "I'm only instance method!";
  $inst -> {net};
}

sub set_net($$) {
  ref(my $inst = shift) or croak "I'm only instance method!";
  $inst -> {net} = shift;
  set_results($inst);
}

sub node($) {
  ref(my $inst = shift) or croak "I'm only instance method!";
  $inst -> {node};
}

sub set_node($$) {
  ref(my $inst = shift) or croak "I'm only instance method!";
  $inst -> {node} = shift;
  set_results($inst);
}

sub point($) {
  ref(my $inst = shift) or croak "I'm only instance method!";
  $inst -> {point};
}

sub set_point($$) {
  ref(my $inst = shift) or croak "I'm only instance method!";
  $inst -> {point} = shift;
  set_results($inst);
}

sub f4 {
  ref(my $inst = shift) or croak "I'm only instance method!";
  $inst -> {full4d};
}

sub s4 {
  ref(my $inst = shift) or croak "I'm only instance method!";
  $inst -> {short4d};
}

sub f5 {
  ref(my $inst = shift) or croak "I'm only instance method!";
  $inst -> {full5d};
}

sub s5 {
  ref(my $inst = shift) or croak "I'm only instance method!";
  $inst -> {short5d};
}

sub fqfa {
  ref(my $inst = shift) or croak "I'm only instance method!";
  $inst -> {fqfa};
}

sub bs {
  ref(my $inst = shift) or croak "I'm only instance method!";
  $inst -> {brake_style};
}

sub eq_ {			# eq operator
  return undef unless $_[1] -> isa('FTN::Addr');
  return lc($_[0] -> domain) eq lc($_[1] -> domain)
    && $_[0] -> zone == $_[1] -> zone && $_[0] -> net == $_[1] -> net
    && $_[0] -> node == $_[1] -> node && $_[0] -> point == $_[1] -> point;
}

sub cmp_ {			# cmp operator
  return undef unless $_[1] -> isa('FTN::Addr');
  if ($_[2]) {			# arguments were swapped
    lc($_[1] -> domain) cmp lc($_[0] -> domain) || $_[1] -> zone <=> $_[0] -> zone
      || $_[1] -> net <=> $_[0] -> net || $_[1] -> node <=> $_[0] -> node || $_[1] -> point <=> $_[0] -> point;
  } else {
    lc($_[0] -> domain) cmp lc($_[1] -> domain) || $_[0] -> zone <=> $_[1] -> zone
      || $_[0] -> net <=> $_[1] -> net || $_[0] -> node <=> $_[1] -> node || $_[0] -> point <=> $_[1] -> point;
  }
}

sub equal($$$) {
  ref(my $class = shift) and croak "I'm only class method!";
  return undef unless $_[0] -> isa('FTN::Addr');
  eq_(@_);
}

1;
__END__

=head1 NAME

FTN::Addr - Object-oriented module for creation and work with the ftn addresses.

=head1 VERSION

Version 20090704

=head1 SYNOPSIS

  use FTN::Addr;

  my $a = FTN::Addr -> new('1:23/45') or die "this is not a correct address";

  my $b = FTN::Addr -> new('1:23/45@fidonet') or die 'cannot create address';

  print "Hey! They are the same!\n" if $a eq $b; # should print, because default domain is 'fidonet'

  $b -> set_domain('othernet');

  print "Hey! They are the same!\n" if $a eq $b; # no output. we changed domain

  $b -> new('44.22', $a) or die "cannot create address"; # takes the rest of information from optional $a

  print $a -> f4 . "\n"; # 1:23/45.0

  print $a -> s4 . "\n"; # 1:23/45

  print $a -> f5 . "\n"; # 1:23/45.0@fidonet

  print $a -> s5 . "\n"; # 1:23/45@fidonet

=head1 DESCRIPTION

FTN::Addr module for creation and work with the ftn addresses. Supports domains, different representations and comparison operators.

=head1 OBJECT CREATION

=head2 new

Can be called as class or instance method:

  my $t = FTN::Addr -> new('1:23/45') or die 'something wrong!';

  $t -> new('1:22/33.44@fidonet') or die 'something wrong!';

Default domain is 'fidonet'. If point isn't specified, it's taken as 0. Address can be:

  3d/4d       (1:23/45 or 1:23/45.0)
  5d          (1:23/45@fidonet or 1:23/45.0@fidonet)
  fqfa        (fidonet#1:23/45.0)
  brake style (fidonet.1.23.45.0)

Can have optional second parameter, which is an already created FTN::Addr object. If first parameter doesn't have
some fields, they'll be fetched from second parameter.

  my $an = FTN::Addr -> new('99', $t); # address in $an is 1:22/99.0@fidonet

Performs some checking of field correctness.

=head1 REPRESENTATION

=head2 print $an -> f4;   # 1:22/99.0

=head2 print $an -> s4;   # 1:22/99

=head2 print $an -> f5;   # 1:22/99.0@fidonet

=head2 print $an -> s5;   # 1:22/99@fidonet

=head2 print $an -> fqfa; # fidonet#1:22/99.0

=head2 print $an -> bs;   # fidonet.1.22.99.0

Above presented all available forms.

=head1 FIELD ACCESS

Direct access to object fields.

=head2 $an -> set_domain('mynet');

=head2 $an -> domain;

=head2 $an -> set_zone(2);

=head2 $an -> zone;

=head2 $an -> set_net(456);

=head2 $an -> net;

=head2 $an -> set_node(33);

=head2 $an -> node;

=head2 $an -> set_point(6);

=head2 $an -> point;

No checking is performed.

=head1 COMPARISON

=head2 equal, eq, cmp

Two addresses could be compared. Domain is case-insensetive.

  my $first = FTN::Addr -> new('1:23/45.66@fidonet') or die "cannot create";

  my $second = FTN::Addr -> new('1:23/45.66@FidoNet') or die "cannot create";

  print "the same address!\n" if FTN::Addr -> equal($first, $second); # should print

  print "the same address!\n" if $first eq $second;                   # the same result

  print "but objects are different\n" if $first != $second;           # should print

The same way as 'eq' works 'cmp' operator.

=head1 AUTHOR

Valery Kalesnik, C<< <valkoles at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-ftn-addr at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=FTN-Addr>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

  perldoc FTN::Addr
