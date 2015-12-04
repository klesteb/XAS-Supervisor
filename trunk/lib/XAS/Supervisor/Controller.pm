package XAS::Supervisor::Controller ;

our $VERSION = '0.01';

use POE;
use XAS::Class
  debug     => 0,
  version   => $VERSION,
  base      => 'XAS::Lib::Net::Server',
  mixin     => 'XAS::Lib::Mixins::JSON::Server',
  constants => ':process :jsonrpc HASHREF',
  vars => {
    PARAMS => {
      -processes => 1,
      -retires   => { optional => 1, default => 5 },
    }
  }
;

# ----------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------

sub session_initialize {
    my $self = shift;

    my $alias = $self->alias;

    $self->log->debug("$alias: entering session_initialize() - supervisor");

    # communications from RPC.

    $poe_kernel->state('stop_process',   '_stop_process',   $self);
    $poe_kernel->state('stat_process',   '_stat_process',   $self);
    $poe_kernel->state('start_process',  '_start_process',  $self);
    $poe_kernel->state('pause_process',  '_pause_process',  $self);
    $poe_kernel->state('resume_process', '_resume_process', $self);
    $poe_kernel->state('check_status',   '_check_status',   $self);

    # walk the chain

    $self->SUPER::session_initialize();

    $self->log->debug("$alias: leaving session_initialize() - supervisor");

}

sub check_status {
    my $self = shift;
    my ($params, $ctx, $status) = validate_params(\@_, [
        { type => HASHREF },
        { type => HASHREF },
        1
    ]);

    my $count = 0;
    my $alias = $self->alias;

    $poe_kernel->delay_add('check_status', 5, $params, $ctx, $status, $count);

}

# ----------------------------------------------------------------------
# Private Events
# ----------------------------------------------------------------------

sub _stop_process {
    my $self = $_[OBJECT];
    my ($params, $ctx) = validate_params(\@_[ARG0,ARG1], [
        { type => HASHREF },
        { type => HASHREF },
    ]);

    my $alias = $self->alias;
    my $name  = $params->{'name'};

    if (my $process = $self->processes->{$name}) {

        $process->stop_process();
        $self->check_status($params, $ctx, PROC_STOPPED);

    } else {

        my $error = {
            code    => RPC_ERR_APP,
            message => $self->message('supervisor_unable', 'stop_process', $name)
        };

        $self->process_errors($error, $ctx);

    }

}

sub _kill_process {
    my $self = $_[OBJECT];
    my ($params, $ctx) = validate_params(\@_[ARG0,ARG1], [
        { type => HASHREF },
        { type => HASHREF },
    ]);

    my $alias = $self->alias;
    my $name  = $params->{'name'};

    if (my $process = $self->processes->{$name}) {

        $process->kill_process();
        $self->check_status($params, $ctx, PROC_KILLED);

    } else {

        my $error = {
            code    => RPC_ERR_APP,
            message => $self->message('supervisor_unable', 'kill_process', $name)
        };

        $self->process_errors($error, $ctx);

    }

}

sub _stat_process {
    my $self = $_[OBJECT];
    my ($params, $ctx) = validate_params(\@_[ARG0,ARG1], [
        { type => HASHREF },
        { type => HASHREF },
    ]);

    my $alias = $self->alias;
    my $name  = $params->{'name'};

    if (my $process = $self->processes->{$name}) {

        my $stat     = $process->stat_process();
        my $status   = $self->_convert_stat($stat);
        my $response = $self->message('supervisor_status', $name, $status);

        $self->process_response($response, $ctx);

    } else {

        my $error = {
            code    => RPC_ERR_APP,
            message => $self->message('supervisor_unable', 'stat_process', $name)
        };

        $self->process_errors($error, $ctx);

    }

}

sub _start_process {
    my $self = $_[OBJECT];
    my ($params, $ctx) = validate_params(\@_[ARG0,ARG1], [
        { type => HASHREF },
        { type => HASHREF },
    ]);

    my $alias = $self->alias;
    my $name  = $params->{'name'};

    if (my $process = $self->processes->{$name}) {

        $process->start_process();
        $self->check_status($params, $ctx, PROC_RUNNING);

    } else {

        my $error = {
            code    => RPC_ERR_APP,
            message => $self->message('supervisor_unable', 'start_process', $name)
        };

        $self->process_errors($error, $ctx);

    }

}

sub _pause_process {
    my $self = $_[OBJECT];
    my ($params, $ctx) = validate_params(\@_[ARG0,ARG1], [
        { type => HASHREF },
        { type => HASHREF },
    ]);

    my $alias = $self->alias;
    my $name  = $params->{'name'};

    if (my $process = $self->processes->{$name}) {

        $process->pause_process();
        $self->check_status($params, $ctx, PROC_PAUSED);

    } else {

        my $error = {
            code    => RPC_ERR_APP,
            message => $self->message('supervisor_unable', 'pause_process', $name)
        };

        $self->process_errors($error, $ctx);

    }

}

sub _resume_process {
    my $self = $_[OBJECT];
    my ($params, $ctx) = validate_params(\@_[ARG0,ARG1], [
        { type => HASHREF },
        { type => HASHREF },
    ]);

    my $alias = $self->alias;
    my $name  = $params->{'name'};

    if (my $process = $self->processes->{$name}) {

        $process->resume_process();
        $self->check_status($params, $ctx, PROC_RUNNING);

    } else {

        my $error = {
            code    => RPC_ERR_APP,
            message => $self->message('supervisor_unable', 'resume_process', $name)
        };

        $self->process_errors($error, $ctx);

    }

}

sub _check_status {
    my $self = $_[OBJECT];
    my ($params, $ctx, $status, $count) = validate_params(\@_[ARG0...ARG3], [
        { type => HASHREF },
        { type => HASHREF },
        1,
        1,
    ]);

    my $alias = $self->alias;
    my $name  = $params->{'name'};

    if (my $process = $self->processes->{$name}) {

        my $stat = $process->status();

        if ($stat == $status) {

            my $response = $self->message('supervisor_status', $name, $stat);

            $self->process_response($response, $ctx);

        } else {

            $count += 1;

            if ($count < $self->retires) {

                $poe_kernel->delay_add('check_status', 5, $params, $ctx, $status, $count);

            } else {

                my $error = {
                    code    => RPC_ERR_APP,
                    message => $self->message('supervisor_nostatus', $name)
                };

                $self->process_errors($error, $ctx);

            }

        }

    } else {

        my $error = {
            code    => RPC_ERR_APP,
            message => $self->message('supervisor_unable', 'check_status', $name)
        };

        $self->process_errors($error, $ctx);

    }

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

sub _convert_stat {
    my $self = shift;
    my $stat = shift;

    my $status = 'unknown';

    $status = 'suspended ready'   if ($stat == 6);
    $status = 'suspended blocked' if ($stat == 5);
    $status = 'blocked'           if ($stat == 4);
    $status = 'running'           if ($stat == 3);
    $status = 'ready'             if ($stat == 2);
    $status = 'other'             if ($stat == 1);

    return $status;

}

sub init {
    my $class = shift;

    my $self = $class->SUPER::init(@_);

    my @methods = [
        'stop_process',
        'start_process',
        'stat_process',
        'kill_process',
        'pause_process',
        'resume_process'
    ];

    $self->init_json_server(\@methods);

    return $self;

}

1;

__END__

=head1 NAME

XAS::xxx - A class for the XAS environment

=head1 SYNOPSIS

 use XAS::XXX;

=head1 DESCRIPTION

=head1 METHODS

=head2 method1

=head1 SEE ALSO

=over 4

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
