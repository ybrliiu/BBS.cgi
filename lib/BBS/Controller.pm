{
  package BBS::Controller;

  use BBS;
  use base qw/CGI/;

  use HTML::Escape;
  use Mojo::Template;
  use BBS::Util qw/project_root_dir load_config print_utf8 url_for/;
  use Encode qw/encode_utf8 decode_utf8/;

  sub new {
    my ($class, %args) = @_;
    # SUPER::newから呼ぶと * なぜか * パラメータ取得できない
    my $self = CGI->new(%args);
    $self->{_params} = +{
      map { $_ => escape_html(decode_utf8 $self->param($_)) } $self->param,
    };
    return bless $self, $class;
  }

  {
    my $config = {};
    sub config {
      return $config if %$config;
      $config = load_config('app.conf');
    }
  }

  sub param {
    my ($self, $key) = @_;
    my $params = $self->{_params};
    return do {
      if (defined $key) {
        exists $params->{$key} ? $params->{$key} : ();
      } else {
        $params;
      }
    };
  }

  sub length {
    my ($self, $key) = @_;
    return length $self->{_params}->{$key};
  }

  sub render {
    my ($self, $filename, $vars) = @_;
    my $mt = Mojo::Template->new(vars => 1);
    
    # export to namespace of template
    {
      no strict 'refs';
      *{Mojo::Template::SandBox::url_for} = \&url_for;
    }

    print_header();
    print $mt->render_file(project_root_dir . 'templates/' . $filename, $vars);
    print_footer();
  }

  sub render_error {
    my ($self, $err) = @_;
    my $before_uri = $self->before_uri;
    print_error($err, $before_uri);
  }

  sub before_uri {
    my ($self) = @_;
    return do {
      my $base_uri = './';
      # if error ocurred when add reply ...
      # もっと汎用化できる方にした方がいいよね
      my $thread_id = $self->param('thread-id');
      defined $thread_id ? "$base_uri?thread-id=$thread_id" : $base_uri;
    };
  }

  sub redirect_to {
    my ($self, $uri) = @_;
    print_utf8 $self->redirect(url_for $uri);
    exit;
  }

  sub print_header {
    print_utf8 <<"EOS";
Cache-Control: no-cache
Pragma: no-cache
Content-type: text/html

<!DOCTYPE html>
<html>
<head>
  <meta HTTP-EQUIV="Content-type" CONTENT="text/html; charset=UTF-8">
  <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, width=device-width">
  <link href="@{[ url_for('/public/css/skyblue.min.css') ]}" rel="stylesheet">
  <link href="@{[ url_for('/public/css/bbs.css') ]}" rel="stylesheet">
  <title>BBS</title>
</head>
<body>
EOS
  }

  sub print_footer {
    print_utf8 <<"EOS";
</body>
</html>
EOS
  }

  sub print_error {
    my ($message, $before_uri) = @_;
    $before_uri ||= '';

    print_header();
    print_utf8 '<h1>ERROR!!</h1>';

    if (ref $message eq 'HASH') {
      print_utf8 '<ul>';
      print_utf8 qq{<li class="error">$message->{$_}</li>\n} for keys %$message;
      print_utf8 '</ul>';
    } else {
      print_utf8 qq{<p class="error">$message</p>};
    }


    print_utf8 qq{<a href="$before_uri">戻る</a>};
    print_footer();
  }

}

1;
