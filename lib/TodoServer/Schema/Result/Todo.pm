use strict;
use warnings;
use experimental qw(postderef signatures);
package TodoServer::Schema::Result::Todo;
use base qw/DBIx::Class::Core/;

use Ix::Validators qw(enum);

__PACKAGE__->load_components(qw/+Ix::DBIC::Result/);

__PACKAGE__->table('todos');

__PACKAGE__->ix_add_columns;

__PACKAGE__->ix_add_properties(
  listId      => { data_type => 'idstr', xref_to => 'TodoList' },
  precedence  => { data_type => 'integer' },
  isComplete  => { data_type => 'boolean' },
  summary     => { data_type => 'string' },
);

sub ix_default_properties {
  return {
    precedence => 0,
    isComplete => JSON::MaybeXS::false,
    summary    => q{},
  };
}

__PACKAGE__->set_primary_key('id');

sub ix_account_type { 'generic' }

sub ix_type_key { 'Todo' }

1;
