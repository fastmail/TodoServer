package TodoServer::Context {;
  use Moose;

  use experimental qw(lexical_subs signatures postderef);

  use Data::GUID qw(guid_string);

  use namespace::autoclean;

  sub is_system { 0 }

  sub file_exception_report {
    warn "EXCEPTION!!";
    return guid_string();
  }

  sub with_account ($self, $t, $i) {
    $self->internal_error("unknown account type: $t")->throw
      unless $t eq 'generic';

    $i //= $self->processor->sole_accountId;

    $self->error("invalidArgument" => {})->throw
      unless $i eq $self->processor->sole_accountId;

    return TodoServer::Context::WithAccount->new({
      root_context => $self,
      account_type => $t,
      accountId    => $i,
    });
  }

  with 'Ix::Context';
}

package TodoServer::Context::WithAccount {
  use Moose;

  use experimental qw(lexical_subs signatures postderef);
  use namespace::autoclean;

  sub account_type { 'generic' }
  has accountId => (is => 'ro', isa => 'Str', required => 1);

  with 'Ix::Context::WithAccount';
}

1;
