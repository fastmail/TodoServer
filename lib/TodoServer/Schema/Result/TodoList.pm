use strict;
use warnings;
use experimental qw(postderef signatures);
package TodoServer::Schema::Result::TodoList;
use base qw/DBIx::Class::Core/;

use Ix::Validators qw(enum);

__PACKAGE__->load_components(qw/+Ix::DBIC::Result/);

__PACKAGE__->table('todo_lists');

__PACKAGE__->ix_add_columns;

__PACKAGE__->ix_add_properties(
  description => { data_type => 'string' },
);

__PACKAGE__->set_primary_key('id');

sub ix_account_type { 'generic' }

sub ix_type_key { 'TodoList' }

1;
