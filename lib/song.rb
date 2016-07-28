require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song

  # Returns the name of a table, given the name of a class
  # #pluralize is provided from active_support/inflector
  def self.table_name
    self.to_s.downcase.pluralize
  end


  # Return value of this method will look something like this:
  #=> ["id", "name", "album"]
  # Which we use to create the attr_accessors of our class
  def self.column_names
    DB[:conn].results_as_hash = true

    # Queries the table for the names of its columns
    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end


  # Metaprogramming our attr_accessors
  # Allows us to avoid having to explicitly name reader/writer methods for each column name
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end


  # We expect .new to be called with a hash, so when referring to options, we
  # expect to be operating on a hash
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end
