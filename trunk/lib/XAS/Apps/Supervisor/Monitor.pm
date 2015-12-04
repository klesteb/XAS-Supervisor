package XAS::Apps::Supervisor::Monitor;

our $VERSION = '0.01';

use XAS::Supervisor::Monitor;
use XAS::Supervisor::Controller;

use XAS::Class
  debug   => 0,
  version => $VERSION,
  base    => 'XAS::Lib::App::Service',
  vars => {
    SERVICE_NAME         => 'XAS_Supervisor',
    SERVICE_DISPLAY_NAME => 'XAS Supervisor',
    SERVICE_DESCRIPTION  => 'Supervise proccesses'
  }
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub setup {
    my $self = shift;

    my $controller = XAS::Supervisor::Controller->new(
        -alias => 'controller',
        -port  => $self->port,
        -host  => $self->host,
        -processes => XAS::Supervisor::Monitor->load(
            -service = $self->service
        )
    );

    $self->service->register('controller');

}

sub main {
    my $self = shift;

    $self->log->info_msg('startup');

    $self->setup();
    $self->service->run();

    $self->log->info_msg('shutdown');

}

sub options {
    my $self = shift;

    $self->{'port'} = RPC_DEFAULT_PORT;
    $self->{'host'} = RPC_DEFAULT_HOST;

    return {
        'port=s' => \$self->{'port'},
        'host=s' => \$self->{'host'},
    };

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

1;

__END__

=head1 NAME

XAS::Apps::Supervisor::Monitor - A class for the XAS environment

=head1 SYNOPSIS

 use XAS::Apps::Supervisor::Monitor;

 my $app = XAS::Apps::Supervisor::Montior->new(
     -throws = 'xas-supervisor',
 );

 exit $app->run;

=head1 DESCRIPTION

This module will spawn multiple processes. It will keep track
of them and restart them if they should stop.

=head1 METHODS

=head2 setup

This method will process the config file and spawn log processes.

=head2 main

This method will start the processing.

=head2 options

This method defines the command line options.

=head1 SEE ALSO

=over 4

=item L<XAS::Supervisor>

=item L<XAS|XAS>

=back

=head1 AUTHOR

Kevin L. Esteb, E<lt>kevin@kesteb.usE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2012-2015 Kevin L. Esteb

This is free software; you can redistribute it and/or modify it under
the terms of the Artistic License 2.0. For details, see the full text
of the license at http://www.perlfoundation.org/artistic_license_2_0.

=cut
