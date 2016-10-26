{
  package BBS::Controller::Reply;

  use BBS;
  use base qw/BBS::Controller/;

  use BBS::Model::Thread;
  use BBS::Model::Reply;

  sub root {
    my ($self) = @_;
    my $thread_id = $self->param('thread-id');
    $self->render('reply/root.html.ep', {thread_id => $thread_id});
  }

  sub add_reply {
    my ($self) = @_;

    my %errors;
    my %conf = %{ $self->config->{app} };
    $errors{'thread-id'} = "スレッドIDがありません" unless $self->param('thread-id');
    $errors{name} = "名前は$conf{name_len_min}文字以上$conf{name_len_max}文字以下で入力してください"
      if $self->length('name') < $conf{name_len_min} || $self->length('name') > $conf{name_len_max};
    $errors{mail} = "メールは$conf{mail_len_max}文字以下で入力してください"
      if $self->length('mail') > $conf{mail_len_max};
    $errors{message} = "本文は1文字以上$conf{message_len_max}文字以下で入力してください"
      if $self->length('message') < 1 || $self->length('message') > $conf{message_len_max};

    return $self->render_error(\%errors) if %errors;

    eval {
      my $id = $self->param('thread-id');
      my $reply = BBS::Model::Reply->new($id);
      $reply->add($self->param);
    };

    if (my $e = $@) {
      $self->render_error($e);
    } else {
      $self->redirect_to('/');
      # $self->render('reply/add_reply.html.ep');
    }

  }

}

1;
