# TodoServer - a combined demo of Overture and Ix

* get a recent Perl — v5.24.0 minimum
* install [Dist::Zilla::PluginBundle::RJBS](https://metacpan.org/pod/Dist::Zilla::PluginBundle::RJBS)
* install PostgreSQL — on macOS, this is easy: get [PostgreSQL.app](https://postgresapp.com/)
* clone, then use dzil to install [Test::PgMonger](https://github.com/fastmail/Test-PgMonger)
* clone, then use dzil to install [Ix](https://github.com/fastmail/Ix)
* clone the [TodoServer](https://github.com/fastmail/TodoServer) repo
* build Overture: `cd overture; npm install`
* from it, run: `plackup -I lib -MTodoServer::App -e 'TodoServer::App->oneoff'`


