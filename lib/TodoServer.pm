use 5.20.0;
use warnings;
use experimental qw(lexical_subs signatures postderef);

package TodoServer;

use Moose;
with 'Ix::Processor::JMAP';

use HTTP::Throwable::JSONFactory qw(http_throw);

use TodoServer::Context;
use Data::GUID qw(guid_string);
use Ix::Validators qw( enum integer record );

use experimental qw(signatures postderef);
use namespace::autoclean;

sub exceptions;
has exceptions => (
  lazy => 1,
  traits => [ 'Array' ],
  handles => {
    'exceptions'       => 'elements',
    'clear_exceptions' => 'clear',
    'add_exception'    => 'push',
   },
  default => sub { [] },
);

sub file_exception_report ($self, $ctx, $exception) {
  Carp::cluck( "EXCEPTION!! $exception" ) unless $ENV{QUIET_BAKESALE};
  $self->add_exception($exception);
  return guid_string();
}

sub connect_info;
has connect_info => (
  traits   => [ 'Array' ],
  handles  => { connect_info => 'elements' },
  required => 1,
);

sub database_defaults {
  return (
    "SET LOCK_TIMEOUT TO '2s'",
  );
}

has sole_accountId => (
  is      => 'ro',
  default => sub { lc guid_string() },
);

sub get_context ($self, $arg) {
  TodoServer::Context->new({
    schema    => $arg->{schema} // $self->schema_connection,
    processor => $self,
  });
}

sub context_from_plack_request ($self, $req, $arg = {}) {
  return $self->get_context({
    schema => $arg->{schema},
  });
}

sub schema_class { 'TodoServer::Schema' }

sub handler_for ($self, $method) {
  return 'echo'          if $method eq 'echo';
  return;
}

sub echo ($self, $ctx, $arg) {
  return Ix::Result::Generic->new({
    result_type       => 'echoEcho',
    result_arguments  => { args => $arg->{echo} },
  });
}

__PACKAGE__->meta->make_immutable;
1;
