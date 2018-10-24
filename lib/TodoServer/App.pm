use 5.20.0;
package TodoServer::App;
use Moose;
use experimental qw(signatures postderef);

use TodoServer;

use JSON::MaybeXS;

use namespace::autoclean;

has transaction_log => (
  init_arg => undef,
  default  => sub {  []  },
  traits   => [ 'Array' ],
  handles  => {
    clear_transaction_log => 'clear',
    logged_transactions   => 'elements',
    emit_transaction_log  => 'push',
  },
);

with 'Ix::App::JMAP';

sub drain_transaction_log ($self) {
  my @log = $self->logged_transactions;
  $self->clear_transaction_log;
  return @log;
}

sub oneoff ($class) {
  require Test::PgMonger;
  my $db = Test::PgMonger->new->create_database({
    extra_sql_statements => [
      "CREATE EXTENSION IF NOT EXISTS citext;",
    ],
  });

  my $schema = TestServer->new({
    connect_info => [ $db->connect_info ],
  })->schema_connection;

  $schema->deploy;

  my $processor = TodoServer->new({
    connect_info => $db->connect_info,
  });

  return $class->new({ processor => $processor })->to_app;
}

1;
