use BBS;
use Test::More;

use_ok 'BBS::Controller';

subtest 'param' => sub {
  ok(my $param = BBS::Controller->new);
};

done_testing;
