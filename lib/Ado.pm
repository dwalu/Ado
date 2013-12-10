package Ado;
use Mojo::Base 'Mojolicious';
use Ado::Control;
our $VERSION = '0.13';

# This method will run once at server start
sub startup {
    my $app = shift;
    $app->load_config()->load_plugins()->load_routes()->define_hooks();
    return;
}

#load ado.conf
sub load_config {
    my $app = shift;
    $app->plugin('Config', {file => $app->home->rel_file('etc/' . $app->moniker . '.conf')});

    return $app;
}

sub load_plugins {
    my $app = shift;

    # Documentation browser under "/perldoc"
    $app->plugin('PODRenderer', {no_perldoc => 1});

    #HACK!
    #TODO: Inherit PODRenderer and implement an Ado Default perldoc plugin.
    my $defaults = {module => 'Ado/Manual', format => 'html'};
    ##no critic (ProtectPrivateSubs,ProhibitUnusedPrivateSubroutines,ProtectPrivateVars)
    $app->routes->any('/perldoc/:module' => $defaults => [module => qr/[^.]+/] =>
          \&Mojolicious::Plugin::PODRenderer::_perldoc);

    my $plugins = $app->config('plugins') || [];
    foreach my $plugin (@$plugins) {
        if (ref $plugin eq 'HASH') {
            $app->plugin($plugin->{name} => $plugin->{config});
        }
        elsif ($plugin) {
            $app->plugin($plugin);
        }
    }
    return $app;
}

#load routes defined in ado.conf
sub load_routes {
    my ($app) = @_;
    my $routes = $app->routes;
    my $config_routes = $app->config('routes') || [];

    foreach my $route (@$config_routes) {
        my ($pattern) = keys %$route;    #$pattern is the only key
        my ($to, $via, $qrs) =
          ($route->{$pattern}{to}, $route->{$pattern}{via}, $route->{$pattern}{qrs} || {});

        next unless $to;
        my $r = keys %$qrs ? $routes->route($pattern, %$qrs) : $routes->route($pattern);

        #TODO: support other routes descriptions beside 'via'
        if ($via) {
            $r->via(@{$via});
        }
        $r->to(ref $to eq 'HASH' ? %$to : $to);
    }

    return $app;
}

sub define_hooks {
    my $app = shift;
    return $app;
}


1;


=pod

=encoding utf8

=head1 NAME

Ado - busy or delaying activity; bustle; fuss. 


=head1 SYNOPSIS

  require Mojolicious::Commands;
  Mojolicious::Commands->start_app('Ado');

=head1 ATTRIBUTES

Ado inherits all attributes from Mojolicious.


=head1 METHODS

Ado inherits all methods from Mojolicious and implements 
the following new ones.

=head2 startup

The startup method is where everything begins. Return $apps void.

=head2 load_config

Loads the configuration file C<$app-E<gt>home/etc/ado.conf>.
Returns $app.

=head2 load_plugins

Loads plugins listed in C<$config-E<gt>{plugins}>.
This is an C<ARRAYREF> in which each element is a C<HASHREF> with
keys C<name> and C<config>.
The name of the plugin is expected to be string that can be passed to
L<Mojolicious/plugin>.
The C<config> values is another C<HASHREF> containing the configuration for the plugin.
Plugins can be Mojolicious or Ado specific plugins.
Every L<Ado::Plugin>::Foo must inherit from L<Ado::Plugin> which C<ISA>
L<Mojolicious::Plugin>.
Of course Mojolicious plugins can be used - we count on this.
There are plenty of examples on CPAN.
Returns $app.

=head2 load_routes

Loads predefined routes in C<$config-E<gt>routes>
Returns $app.

=head2 define_hooks

Defines some hooks to intervene in the default workflow of the requests.
Returns $app.

=head1 SPONSORS

The original author

=head1 SEE ALSO

L<Mojolicious>, L<Ado::Manual>,
L<http://www.thefreedictionary.com/ado>, 


=head1 AUTHOR

Красимир Беров (Krasimir Berov)

=head1 COPYRIGHT AND LICENSE

Copyright 2013 Красимир Беров (Krasimir Berov).

This program is free software, you can redistribute it and/or
modify it under the terms of the 
GNU Lesser General Public License v3 (LGPL-3.0).
You may copy, distribute and modify the software provided that 
modifications are open source. However, software that includes 
the license may release under a different license.

See http://opensource.org/licenses/lgpl-3.0.html for more information.

=cut

