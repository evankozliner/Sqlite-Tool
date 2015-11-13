require 'sqlite3'
require 'optparse'
require 'csv'

class DatabaseInteractor
	# Generic constructor, creates a database connection on initialization.
	# Input:
	# 	file: The file to open a database connection to. Non-existing files are
	# 	created automatically.
	def initialize file
		@db_file = file
		@db = intialize()
	end
	
	# Inserts a row into the database.
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
	
	# Establishes a database connection.
	def intialize
		begin
			return SQLite3::Database.open @db_file
		rescue => e
			raise "Database connection failed. "
		end
	end
end

def get_options
	options = {}
	options[:schema] = false

	OptionParser.new do |opts|
		opts.banner = "Usage: ruby interactions.rb [options]"
		# Handles verbose mode
		opts.on("-v", "--[no] verbose", "Run verbosely") do |v|
			options[:verbose] = v
		end
		# Specifies the databse file
		opts.on("-db", "--db=DB", "Use a database file other than 'database.db'") do |db|
			options[:db] = db
		end
		# Handles the assigned CSV
		opts.on("-d", "--[no] data", "Takes assigned class CSV and loads it into the db") do |csv|
			options[:csv] = csv
		end
		# Handles help
		opts.on("-h", "--help", "Prints this help screen") do
			puts opts
		end
	end.parse!
	return options
end

# Script starts here
options = get_options()
db = options[:db] || 'database.db'

interactor = DatabaseInteractor.new db









