package XAS::Supervisor::Client;

our $VERSION = '0.01';

use XAS::Class
  debug   => 0,
  version => $VERSION,
  base    => 'XAS::Lib::RPC::JSON::Client',
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub start {
    my ($self, $name) = @_;

    my $params = {
        name => $name
    };

    my $result = $self->call(
        -method => 'start_process',
        -id     => $self->id,
        -params => $params
    );

    return $result;

}

sub stop {
    my ($self, $name) = @_;

    my $params = {
        name => $name
    };

    my $result = $self->call(
        -method => 'stop_process',
        -id     => $self->id,
        -params => $params
    );

    return $result;

}

sub pause {
    my ($self, $name) = @_;

    my $params = {
        name => $name
    };

    my $result = $self->call(
        -method => 'pause_process',
        -id     => $self->id,
        -params => $params
    );

    return $result;

}

sub resume {
    my ($self, $name) = @_;

    my $params = {
        name => $name
    };

    my $result = $self->call(
        -method => 'resume_process',
        -id     => $self->id,
        -params => $params
    );

    return $result;

}

sub status {
    my ($self, $name) = @_;

    my $params = {
        name => $name
    };

    my $result = $self->call(
        -method => 'stat_process',
        -id     => $self->id,
        -params => $params
    );

    return $result;

}

sub list {
    my ($self, $name) = @_;

    my $params = {};

    my $result = $self->call(
        -method => 'list_processes',
        -id     => $self->id,
        -params => $params
    );

    return $result;

}

sub id {
    my $self = shift;

    $self->{'id'}++;

    return $self->{'id'};

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

sub init {
    my $class = shift;

    my $self = $class->SUPER::init(@_);

    $self->{'id'} = 0;

    return $self;

}

1;

__END__

=head1 NAME

XAS::Supervisor::Client - The RPC interface to the Supervisor

=head1 SYNOPSIS

 use XAS::Supervisor::Client;

 my $rpc = XAS::Supervisor::Client->new()
 my $result = $rpc->start('sleeper');

=head1 DESCRIPTION

This is the client module for external access to the XAS Supervisor. 

=head1 METHODS

=head2 new

This initilaize the module and can take these parameters. This module
inherits from L<XAS::Lib::Net::Client|XAS::Lib::Net::Client> and uses
the same parameters.

 Example:

     my $rpc = XAS::Supervisor::Client->new(
        -port => 9505,
        -host => 'localhost'
     };

=head2 start($name)

This method will start a managed process. It takes one parameter, the name
of the process, and returns "started" if successful.

 Example:

     my $result = $rpc->start('sleeper');

=head2 stop($name)

This method will stop a managed process. It takes one parameter, the name of
the process, and returns "stopped" if successful.

 Example:

     my $result = $rpc->stop('sleeper');

=head2 status($name)

This method will do a "stat" on a managed process. It takes one parameter,
the name of the process, and returns "alive" if the process is running or
"dead" if the process is not.

=head2 list

This method will list the known process on the target supervisor.

 Example:

     my $result = $rpc->list();

=head1 SEE ALSO

=over 4

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
