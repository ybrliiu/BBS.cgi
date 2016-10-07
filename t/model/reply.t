use BBS;
use Test::More;

my $TEST_CLASS = 'BBS::Model::Reply';
use_ok $TEST_CLASS;
ok(my $reply_model = $TEST_CLASS->new(0));
ok $reply_model->add({
  name => 'liiu',
  message => '返信テスト',
  mail => '',
});

done_testing();
