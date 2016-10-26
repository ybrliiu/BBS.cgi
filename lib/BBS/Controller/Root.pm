{
  package BBS::Controller::Root;

  use BBS;
  use base qw/BBS::Controller/;

  use BBS::Model::Thread;
  use BBS::Model::Reply;

  sub root {
    my ($self) = @_;

    my $page = $self->param('page');

    my @threads = map {
      my $thread = $_;
      if (defined $thread) {
        my @replys = BBS::Model::Reply->new($thread->{id})->get();
        $thread->{replys} = \@replys;
        $thread;
      } else {
        ()
      }
    } BBS::Model::Thread->get($page);

    my $vars = {
      threads      => \@threads,
      current_page => $page,
      max_page     => BBS::Model::Thread->max_page(),
    };
    $self->render('root/root.html.ep', $vars);
  }

  sub add_thread {
    my ($self) = @_;

    my %error;
    my %conf = %{ $self->config->{app} };
    $error{name} = "名前は$conf{name_len_min}文字以上$conf{name_len_max}文字以下で入力してください"
      if $self->length('name') < $conf{name_len_min} || $self->length('name') > $conf{name_len_max};
    $error{mail} = "メールは$conf{mail_len_max}文字以下で入力してください"
      if $self->length('mail') > $conf{mail_len_max};
    $error{title} = "タイトルは$conf{title_len_min}文字以上$conf{title_len_max}文字以下で入力してください"
      if $self->length('title') < $conf{title_len_min} || $self->length('title') > $conf{title_len_max};
    $error{message} = "本文は1文字以上$conf{message_len_max}文字以下で入力してください" 
      if $self->length('message') < 1 || $self->length('message') > $conf{message_len_max};

    return $self->render_error(\%error) if %error;

    eval {
      BBS::Model::Thread->add($self->param);
    };

    if (my $e = $@) {
      return $self->render_error($e);
    } else {
      $self->redirect_to('/');
      # $self->render('root/add_thread.html.ep');
    }

  }

}

1;

