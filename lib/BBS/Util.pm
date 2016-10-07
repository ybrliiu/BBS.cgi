{
  package BBS::Util ;
  
  use BBS;
  use Carp qw/croak/;
  use Cwd 'getcwd';
  use Encode qw/encode_utf8 decode_utf8/;
  use Exporter 'import';
  our @EXPORT_OK = qw/project_root_dir config_file_path get_log save_log date_time remove_indention print_utf8 request_uri url_for/;

  sub project_root_dir {
    return getcwd() . '/';
  }

  sub config_file_path {
    return project_root_dir() . 'etc/config/';
  }

  sub get_log {
    my ($file_name) = @_;
    open(my $fh, '<', project_root_dir() . $file_name) || croak qq{$file_name を開けませんでした:$!};
    my @lines = map { decode_utf8 $_ } <$fh>;
    close($fh);
    return @lines;
  }

  sub save_log {
    my ($file_name, $lines) = @_;
    open(my $fh, '+<', project_root_dir() . $file_name) || croak qq{$file_name を開けませんでした:$!};
    flock($fh, 2);
    truncate($fh, 0);
    seek($fh, 0, 0);
    print $fh map { encode_utf8 $_ } @$lines;
    close($fh);
  }

  sub date_time {
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdat) = localtime();
    return "@{[ $year + 1900 ]}年@{[ ++$mon ]}月${mday}日${hour}時${min}分";
  }

  sub remove_indention {
    my ($str) = @_;
    $str =~ s/(\n|\r\n|\r)/<br>/g;
    return $str;
  }

  sub print_utf8 { print encode_utf8($_[0]) }

  sub request_uri {
    (my $request_uri = $ENV{REQUEST_URI}) =~ s!$ENV{SCRIPT_NAME}!!g;
    return $request_uri;
  }

  sub url_for {
    my ($path) = @_;
    my $request_uri = request_uri();
    my $depath = scalar(my @depath = ($request_uri =~ m!/!g));

    if ($path =~ /public/) {
      return '../' x $depath . $path;
    } else {
      return $ENV{SCRIPT_NAME} . $path;
    }
  }

}

1;
