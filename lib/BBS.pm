{
  package BBS;
  
  use strict;
  use warnings;
  use utf8;

  sub import {
    $_->import() for qw/strict warnings utf8/;
  }

}

1;
