use BBS;
use Test::More;

my $TEST_CLASS = 'BBS::Model::Thread';
use_ok $TEST_CLASS;

my $max_page = $TEST_CLASS->max_page();
for my $page (0 .. $max_page) {
  # diag "-------------------";
  my $show_threads = [$TEST_CLASS->get($page)];
  # diag explain $show_threads;
  is @$show_threads, 5;
}

done_testing();
