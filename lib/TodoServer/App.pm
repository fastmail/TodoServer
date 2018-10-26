use 5.20.0;
package TodoServer::App;
use Moose;
use experimental qw(signatures postderef);

use TodoServer;
use TodoServer::Schema;

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
  our $db = Test::PgMonger->new->create_database({
    extra_sql_statements => [
      "CREATE EXTENSION IF NOT EXISTS citext;",
    ],
  });

  my $processor = TodoServer->new({
    connect_info => [ $db->connect_info ],
  });

  $processor->schema_connection->deploy;

  my $res = $processor->get_context({})->process_request([
    [ 'TodoList/set'  => { create => { 'first' => { description => 'Todo' } } }, 'a' ],
    [ 'Todo/set'      => {
        create => {
          1 => { listId => "#first", summary => "Arrive in Gaul", precedence => 1 },
          2 => { listId => "#first", summary => "Observe the state of Gaul", precedence => 2 },
          3 => { listId => "#first", summary => "Conquer Gaul", precedence => 3,
                 dueBy  => Ix::DateTime->now->add(months => 1) },
        },
      },
    ],
  ]);

  printf "First Todo at: http://localhost:5000/examples/Todo/%s/\n",
    $res->[0][1]{created}{first}{id};

  return $class->new({ processor => $processor })->to_app;
}

around _core_request => sub ($orig, $self, $ctx, $req) {
  my $path = $req->path_info;

  my $accountId = $self->processor->sole_accountId;

  if ($path eq '/.well-known/jmap') {
    return [
      200,
      [ "Content-Type" => 'application/json' ],
      [
        JSON->new->encode({
          username => "",
          accounts => {
            $accountId => {
              name       => "",
              isPersonal => JSON::MaybeXS::false,
              isReadOnly => JSON::MaybeXS::false,
              hasDataFor => [ "http://overturejs.com/examples/Todo" ]
            }
          },
          "primaryAccounts" => {
            "https://overturejs.com/examples/Todo" => $accountId,
          },
          "capabilities" => {
            "https://overturejs.com/examples/Todo" => {},
            "urn:ietf:params:jmap:core" => {
              "maxSizeUpload"         => 0,
              "maxConcurrentUpload"   => 10,
              "maxSizeRequest"        => 10000000,
              "maxConcurrentRequests" => 10,
              "maxCallsInRequest"     => 64,
              "maxObjectsInGet"       => 1000,
              "maxObjectsInSet"       => 1000,
              "collationAlgorithms"   => [
                "i;ascii-numeric",
                "i;ascii-casemap",
                "i;octet"
              ]
            }
          },
          "apiUrl" => "/jmap/api/",
          "downloadUrl" => "/jmap/download/{accountId}/{blobId}/{name}?accept={type}",
          "uploadUrl" => "/jmap/upload/{accountId}/",
          "eventSourceUrl" => "/jmap/event/",
          "state" => ""
        })
      ],
    ];
  }

  if ($path =~ m{^/(examples|build)/}n) {
    my $disk_path = "./overture/$path";
    if (-f $disk_path) {
      my $type  = $path =~ /\.css$/ ? 'text/css'
                : $path =~ /\.js$/  ? 'text/javascript'
                : $path =~ /\.png$/ ? 'image/png'
                :                     'application/octet-stream';

      open my $fh, '<', $disk_path or die "can't read $path: $!";
      return [
        200,
        [ 'Content-Type' => $type ],
        $fh,
      ];
    }

    open my $fh, '<', './overture/examples/Todo/index.html'
      or die "can't read index: $!";

    return [
      200,
      [ "Content-Type" => 'text/html' ],
      $fh,
    ];
  }

  return $self->$orig($ctx, $req);
};

1;
