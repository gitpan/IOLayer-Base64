
package IOLayer::Base64;

# Make sure we do things by the book
# Set the version info

use strict;
$IOLayer::Base64::VERSION = 0.01;

# Make sure the encoding/decoding stuff is available

use MIME::Base64 (); # no need to pollute this namespace

#-----------------------------------------------------------------------
#  IN: 1 class
#      2 mode string (ignored)
#      3 file handle of PerlIO layer below (ignored)
# OUT: 1 blessed object

sub PUSHED {

# Initialize the buffer to be used
# Bless it as the object we're gonna use and return that

    my $buffer = '';
    bless \$buffer,$_[0];
} #PUSHED

#-----------------------------------------------------------------------
#  IN: 1 instantiated object (ignored)
#      2 handle to read from
# OUT: 1 decoded string

sub FILL {

# Make sure we slurp everything we can in one go
# Read the line from the handle
# Decode if there is something decode and return result or signal eof

    local $/ = undef;
    my $line = readline( $_[1] );
    (defined $line) ? MIME::Base64::decode_base64( $line ) : undef;
} #FILL

#-----------------------------------------------------------------------
#  IN: 1 instantiated object (reference to buffer)
#      2 buffer to be written
#      3 handle to write to (ignored)
# OUT: 1 number of bytes "written"

sub WRITE {

# Add to the buffer (encoding will take place on FLUSH)
# Return indicating we read the entire buffer

    $$_[0] .= $_[1];
    length( $_[1] );
} #WRITE

#-----------------------------------------------------------------------
#  IN: 1 instantiated object (reference to buffer)
#      2 handle to write to
# OUT: 1 flag indicating error

sub FLUSH {

# If there is something in the buffer to be handled
#  Write out what we have in the buffer, encoding it on the fly
#  Reset the buffer
# Return indicating success

    if ($$_[0]) {
        print {$_[1]} MIME::Base64::encode_base64( $$_[0] ) or return -1;
        $$_[0] = '';
    }
    0;
} #FLUSH

# Satisfy -require-

1;

__END__

=head1 NAME

IOLayer::Base64 - PerlIO layer for base64 (MIME) encoded strings

=head1 SYNOPSIS

 use IOLayer::Base64;

 open( my $in,'<Via(IOLayer::Base64)','file.mime' )
  or die "Can't open file.mime for reading: $!\n";
 
 open( my $out,'>Via(IOLayer::Base64)','file.mime' )
  or die "Can't open file.mime for writing: $!\n";

=head1 DESCRIPTION

This module implements a PerlIO layer that works on files encoded in the
Base64 format (as described in RFC 2045).  It will decode from base64 format
while reading from a handle, and it will encode to base64 while writing to a
handle.

=head1 CAVEAT

The current implementation slurps the whole contents of a handle into memory
before doing any encoding or decoding.  This may change in the future when I
finally figured out how READ and WRITE are supposed to work on incompletely
processed buffers.

=head1 COPYRIGHT

Copyright 2002 Elizabeth Mattijsen.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
