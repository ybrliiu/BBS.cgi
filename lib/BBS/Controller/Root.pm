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
    $error{name}    = "名前は0文字以上10文字以下で入力してください"     if $self->length('name') < 1 || $self->length('name') > 10;
    $error{mail}    = "メールは20文字以下で入力してください"            if $self->length('mail') > 20;
    $error{title}   = "タイトルは0文字以上10文字以下で入力してください" if $self->length('title') < 1 || $self->length('title') > 10;
    $error{message} = "本文は0文字以上1000文字以下で入力してください"   if $self->length('message') < 1 || $self->length('message') > 1000;

    return $self->render_error(\%error) if %error;

    eval {
      BBS::Model::Thread->add($self->param);
    };

    if (my $e = $@) {
      return $self->render_error($e);
    } else {
      $self->render('root/add_thread.html.ep');
    }

  }

}

1;

