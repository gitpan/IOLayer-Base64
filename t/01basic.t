use Test::More tests => 11;

BEGIN { use_ok('IOLayer::Base64') }

my $file = 't/test.mime';

my $decoded = <<EOD;
This is a tést for MIME-encoded (base64) text that has hàrdly any speçial characters in it but which is nonetheless an indication of the real world.

With long lines and paragraphs and all that sort of things.

And so on and so on.
-- 
And a signature
EOD

my $encoded = <<EOD;
VGhpcyBpcyBhIHTpc3QgZm9yIE1JTUUtZW5jb2RlZCAoYmFzZTY0KSB0ZXh0IHRoYXQgaGFzIGjg
cmRseSBhbnkgc3Bl52lhbCBjaGFyYWN0ZXJzIGluIGl0IGJ1dCB3aGljaCBpcyBub25ldGhlbGVz
cyBhbiBpbmRpY2F0aW9uIG9mIHRoZSByZWFsIHdvcmxkLgoKV2l0aCBsb25nIGxpbmVzIGFuZCBw
YXJhZ3JhcGhzIGFuZCBhbGwgdGhhdCBzb3J0IG9mIHRoaW5ncy4KCkFuZCBzbyBvbiBhbmQgc28g
b24uCi0tIApBbmQgYSBzaWduYXR1cmUK
EOD

# Create the encoded test-file

ok(
 open( my $out,'>:Via(IOLayer::Base64)', $file ),
 "opening '$file' for writing"
);

ok( (print $out $decoded),		'print to file' );
ok( close( $out ),			'closing encoding handle' );

# Check encoding without layers

{
local $/ = undef;
ok( open( my $test,$file ),		'opening without layer' );
is( readline( $test ),$encoded,		'check encoded content' );
ok( close( $test ),			'close test handle' );
}

# Check decoding _with_ layers

ok(
 open( my $in,'<:Via(IOLayer::Base64)', $file ),
 "opening '$file' for reading"
);
is( join( '',<$in> ),$decoded,		'check decoding' );
ok( close( $in ),			'close decoding handle' );

# Remove whatever we created now

ok( unlink( $file ),			"remove test file '$file'" );
