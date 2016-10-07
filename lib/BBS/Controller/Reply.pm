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
    $errors{'thread-id'} = "スレッドIDがありません"                        unless $self->param('thread-id');
    $errors{name}        = "名前は0文字以上10文字以下で入力してください"   if $self->length('name') < 1 || $self->length('name') > 10;
    $errors{mail}        = "メールは20文字以下で入力してください"          if $self->length('mail') > 20;
    $errors{message}     = "本文は0文字以上1000文字以下で入力してください" if $self->length('message') < 1 || $self->length('message') > 1000;

    return $self->render_error(\%errors) if %errors;

    eval {
      my $id = $self->param('thread-id');
      my $reply = BBS::Model::Reply->new($id);
      $reply->add($self->param);
    };

    if (my $e = $@) {
      $self->render_error($e);
    } else {
      $self->render('reply/add_reply.html.ep');
    }

  }

}

1;
