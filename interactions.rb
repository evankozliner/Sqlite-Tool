require 'sqlite3'
require 'optparse'

class DatabaseInteractor
	def initialize file
		@db_file = file
		@db = intialize()
	end
	
	# Inserts a row into the database
	# Input: 
	# 	table: A string fort the table to insert into (must already exist)
	#		value_map: A hash with keys as column rows and values as values to insert
	def insert table, value_map
		column_string, value_string = "", ""
		value_map.each do |key, value|
			column_string += key.to_s + ", "
			value_string += "'" +  value.to_s + "', "
		end
		column_string = column_string[0..(column_string.length - 3)] # Lose trailing ','
		value_string = value_string[0..(value_string.length - 3)] 
		
		statement = "INSERT INTO " + table
		statement += " (" + column_string.to_s + ")"
		statement += " VALUES (" + value_string.to_s + ")"
		puts "Executing SQLite3 statement: " + statement
		begin 
			@db.execute statement
		rescue => e # Eat exception so later queries are executed
			puts e
		end
	end
	
	# Establishes a database connection
	def intialize
		begin
			return SQLite3::Database.open @db_file
		rescue => e
			raise "Database connection failed. "
		end
	end
end

def get_options
	return 0
end

`sqlite3 database.db < schema.sql`

tests = {"one" => "Kozliner", "two" => 5}
db = DatabaseInteractor.new "database.db"
db.insert("test", tests)
