{
  package BBS::Model::Thread;
  
  use BBS;
  use Carp qw/croak/;
  use BBS::Util qw/date_time remove_indention config_file_path get_log save_log/;
  use List::Util qw/max/;

  use constant DEFAULT_THREAD_NUM => 5;

  my $config = do(config_file_path() . 'app.conf');

  sub get {
    my ($class, $page, $num) = @_;
    $page ||= 0;
    $num  ||= DEFAULT_THREAD_NUM;

    my @lines = get_log($config->{app}{thread_file});
    @lines = map {
      my @thread_data = split /<>/, $_;
      my %thread;
      @thread{qw/id name mail title message time/} = @thread_data;
      \%thread;
    } @lines;
    return @lines[$page * $num .. ++$page * $num - 1];
  }

  sub max_page {
    my ($class, $num) = @_;
    $num ||= DEFAULT_THREAD_NUM;
    my $max_num = scalar(my @lines = get_log($config->{app}{thread_file}));
    return int(($max_num / $num) + 0.9) - 1;
  }

  sub add {
    my ($class, $args) = @_;
    for (qw/name mail title message/) {
      croak "$_ を指定してください" unless exists $args->{$_};
    }
    
    my @lines = get_log($config->{app}{thread_file});
    $args->{message} = remove_indention $args->{message};
    my $t = date_time();
    my $id = $class->max_id() + 1;
    unshift(@lines, "$id<>$args->{name}<>$args->{mail}<>$args->{title}<>$args->{message}<>$t\n");
    save_log($config->{app}{thread_file}, \@lines);
  }

  sub max_id {
    my ($class) = @_;
    max map { $_->{id} } $class->get();
  }

}

1;
