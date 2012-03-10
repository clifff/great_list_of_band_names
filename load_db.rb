if settings.environment = :production
  require 'uri'
  db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

  ActiveRecord::Base.establish_connection(
    :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
    :host     => db.host,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8'
  )
else
  dbconfig = YAML.load(File.read('config/database.yml'))
  ActiveRecord::Base.establish_connection dbconfig["#{settings.environment}"]
end

#ActiveRecord::Base.logger = Logger.new(STDOUT)
#ActiveRecord::Migration.verbose = true
ActiveRecord::Migrator.migrate("db/migrate")
