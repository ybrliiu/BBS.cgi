{
  package BBS::Model::Reply;

  use BBS;
  use Class::Accessor::Lite (new => 0);
  use Carp qw/croak/;
  use BBS::Util qw/date_time remove_indention config_file_path get_log save_log/;
  use List::Util qw/max/;

  Class::Accessor::Lite->mk_ro_accessors(qw/id/);

  my $config = do(config_file_path() . 'app.conf');

  sub new {
    my ($class, $id) = @_;
    croak "idを指定してください" unless defined $id;

    return bless {id => $id}, $class;
  }

  sub get {
    my ($self) = @_;
    my @lines = get_log($config->{app}{reply_file});
    @lines = map {
      my @reply_data = split /<>/, $_;
      my %reply;
      @reply{qw/id name mail message time/} = @reply_data;
      $reply{id} eq $self->id ? \%reply : ();
    } @lines;
    return @lines;
  }

  sub add {
    my ($self, $args) = @_;
    for (qw/name mail message/) {
      croak "$_ を指定してください" unless exists $args->{$_};
    }
    
    my @lines = get_log($config->{app}{reply_file});
    $args->{message} = remove_indention $args->{message};
    my $t = date_time();
    unshift(@lines, "$self->{id}<>$args->{name}<>$args->{mail}<>$args->{message}<>$t\n");
    save_log($config->{app}{reply_file}, \@lines);
  }

  sub max_id {
    my ($self) = @_;
    max map { $_->{id} } $self->get();
  }

}

1;
