use 5.20.0;
use warnings;
package TodoServer::Schema;
use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_components(qw/+Ix::DBIC::Schema/);

__PACKAGE__->load_namespaces(
  default_resultset_class => '+Ix::DBIC::ResultSet',
);

__PACKAGE__->ix_finalize;

1;
