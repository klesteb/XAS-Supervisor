package XAS::Apps::Supervisor::Monitor;

our $VERSION = '0.01';

use XAS::Lib::Process;
use XAS::Supervisor::Controller;

use XAS::Class
  debug      => 0,
  version    => $VERSION,
  base       => 'XAS::Lib::App::Service',
  mixin      => 'XAS::Lib::Mixins::Configs',
  utils      => 'dotid trim',
  constants  => 'TRUE FALSE :jsonrpc',
  accessors  => 'cfg',
  filesystem => 'File Dir',
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

    my $processes = {};
    my @sections = $self->cfg->Sections();

    foreach my $section (@sections) {

        next if ($section !~ /^program:/);

        my ($alias)  = $section =~ /^program:(.*)/;

        $alias = trim($alias);

        my $process = XAS::Lib::Process->new(
            -alias          => $alias,
            -auto_start     => $self->cfg->val($section, 'auto-start', TRUE),
            -auto_restart   => $self->cfg->val($section, 'auto-restart', TRUE),
            -command        => $self->cfg->val($section, 'command'),
            -directory      => Dir($self->cfg->val($section, 'directory', "/")),
            -exit_codes     => $self->cfg->val($section, 'exit-codes', '0,1'),
            -exit_retries   => $self->cfg->val($section, 'exit-retires', -1),
            -group          => $self->cfg->val($section, 'group', 'xas'),
            -priority       => $self->cfg->val($section, 'priority', '0'),
            -pty            => 1,
            -umask          => $self->cfg->val($section, 'umask', '0022'),
            -user           => $self->cfg->val($section, 'user', 'xas'),
            -redirect       => $self->cfg->val($section, 'redirect', FALSE),
            -output_handler => sub {
                my $output = shift;
                $output = trim($output);
                if (my ($level, $line) = $output =~/\s+(\w+)\s+-\s+(.*)/ ) {
                    $level = lc(trim($level));
                    $line  = trim($line);
                    $self->log->$level(sprintf('%s: %s', $alias, $line));
                } else {
                    $self->log->info(sprintf('%s: -> %s', $alias, output));
                }
            }
        );

        $self->service->register($alias);

    }

    my $controller = XAS::Supervisor::Controller->new(
        -alias     => 'controller',
        -port      => $self->port,
        -host      => $self->host,
        -processes => $processes,
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
    $self->{'host'} = 'localhost';

    return {
        'port=s' => \$self->{'port'},
        'host=s' => \$self->{'host'},
    };

}

# ----------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------

sub init {
    my $class = shift;

    my $self = $class->SUPER::init(@_);

    $self->load_config();

    return $self;

}

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
