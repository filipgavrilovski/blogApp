# README

### Потребни верзии:

- Ruby 3.2.2
- Rails 7.0.8
- Postgres 14

### Postgres setup:

За да го стартувате "Postgres" серверот локално, извршете ја командата:



### Rails setup:


Во "root" директориумот, извршете ги слените команди:

    gem install bundler
    bundle install
    bundle exec rake db:create db:migrate

На крај, за да ја стартувате апликацијата локално, извршете ја командата:

bin/rails s

За да пристапите апликацијата локално, идете на http://localhost:3000
