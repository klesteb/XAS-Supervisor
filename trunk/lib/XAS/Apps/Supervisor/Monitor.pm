package XAS::Apps::Supervisor::Monitor;

our $VERSION = '0.01';

use XAS::Supervisor::Monitor;
use XAS::Supervisor::Controller;

use XAS::Class
  debug     => 0,
  version   => $VERSION,
  base      => 'XAS::Lib::App::Service',
  accessors => 'port address',
  constants => ':jsonrpc',
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
        -alias     => 'controller',
        -port      => $self->port,
        -address   => $self->address,
        -processes => XAS::Supervisor::Monitor->load($self->service)
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

    $self->{'port'}    = RPC_DEFAULT_PORT;
    $self->{'address'} = RPC_DEFAULT_ADDRESS;

    return {
        'port=s' => \$self->{'port'},
        'address=s' => \$self->{'host'},
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

=head1 CONFIGURATION

The configuration file is the familiar Windows .ini format. It has the
following stanzas.

 [supervisor: xas-logmon]
 auto-start = 1
 auto-restart = 1
 command = xas-logmon 
 directory = /
 environment = name1=value1;;name2=value2
 exit-codes = 0,1
 exit-retires = 5
 group = xas
 priority = 0
 umask = 0022
 user = xas
 redirect = 0

This stanza defines a process to manage. There can be multiple stanzas. The
"xas-logmon" in the stanza name must be unique and is associated with the
process. This name is used to control this process. Reasonable defaults
have been defined within the code. You really only need to use 'command' to
start a process. The following defaults are defined:

 auto-start = 1
 auto-restart = 1
 directory = /
 exit-codes = 0,1
 exit-retires = 5
 group = xas
 priority = 0
 umask = 0022
 user = xas
 redirect = 0

Please see L<XAS::Lib::Process|XAS::Lib::Process> for more details. If 
"redirect" is 1, all output from that process will be written to the
supervisors log file.

=head1 METHODS

=head2 setup

This method will process the config file and spawn log processes.

=head2 main

This method will start the processing.

=head2 options

These are the additional options.

=over 4

=item B<--port>

This defines the port to list on. Defaults to RPC_DEFAULT_PORT.

=item B<--address>

This defines the address to bind too. Defaults to RPC_DEFAULT_ADDRESS.

=back

=head1 SEE ALSO

=over 4

=item L<XAS::Supervisor::Controller|XAS::Supervisor::Controller>

=item L<XAS::Supervisor::Monitor|XAS::Supervisor::Monitor>

=item L<XAS::Supervisor|XAS::Supervisor>

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
