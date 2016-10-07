#!/usr/bin/perl

use FindBin;
use lib "$FindBin::Bin/lib";
use BBS;
use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
use BBS::Util qw/request_uri print_utf8/;

use BBS::Controller::Root;
use BBS::Controller::Reply;

my $request_uri = request_uri();

  $request_uri eq ''                   ? BBS::Controller->new->redirect_to('/')
: $request_uri =~ m!(^/\?(.*?))|(^/$)! ? BBS::Controller::Root->new->root()
: $request_uri eq '/add-thread'        ? BBS::Controller::Root->new->add_thread()
: $request_uri eq '/reply/add-reply'   ? BBS::Controller::Reply->new->add_reply()
: $request_uri =~ m!^/reply!           ? BBS::Controller::Reply->new->root()
: BBS::Controller->new->render_error('そのURIにはアクセスできません!!');

