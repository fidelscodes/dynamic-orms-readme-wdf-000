require 'sqlite3'


DB = {:conn => SQLite3::Database.new("db/songs.db")}

# Drop 'songs' to avoid an error
DB[:conn].execute("DROP TABLE IF EXISTS songs")

# Create the 'songs' table
sql = <<-SQL
  CREATE TABLE IF NOT EXISTS songs (
  id INTEGER PRIMARY KEY,
  name TEXT,
  album TEXT
  )
SQL

DB[:conn].execute(sql)

# When a SELECT statement is executed, don't return a row as an array.
# Return it as a hash with the column names as keys
DB[:conn].results_as_hash = true

# Instead of this:
#=> [[1, "Hello", "25"]]

# We get something like this:
#=> {"id"=>1, "name"=>"Hello", "album"=>"25", 0 => 1, 1 => "Hello", 2 => "25"}
