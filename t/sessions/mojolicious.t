#t/sessions/mojolicious.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Ado');

#default configuration from etc/ado.conf(Mojolicious::Sessions)
my $cookie_name = $t->app->config('session')->{options}{cookie_name};

# Create new SID
$t->get_ok("/добре/ок?$cookie_name=123456789");
my $sid = $t->tx->res->cookie($cookie_name)->value;
ok $sid, "new sid $sid ok";

$t->get_ok("/?$cookie_name=$sid");
is $sid, $t->tx->res->cookie($cookie_name)->value, 'Param $sid ok';

#$t->get_ok("/");
#is $sid, $t->tx->res->cookie('adosessionid')->value, 'Cookie $sid ok';

#$t->get_ok("/?adosessionid=wrong");
#isnt $sid, $t->tx->res->cookie('adosessionid')->value, 'Param wrong sid ok';

#$t->tx->req->cookie('adosessionid', 'WRONG!');
#$t->get_ok("/");
#isnt $sid, $t->tx->res->cookie('adosessionid')->value, 'Bad SID ok';

done_testing();

