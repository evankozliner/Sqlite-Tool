require 'sqlite3'
require 'optparse'
require 'csv'
require 'spreadsheet'

class DatabaseInteractor
	# Generic constructor, creates a database connection on initialization.
	# Input:
	# 	file: The file to open a database connection to. Non-existing files are
	# 	created automatically.
	def initialize file
		@db_file = file
		@db = intialize()
	end

	def get_first_name full_name
		return full_name.split(" ")[0]
	end

	def get_last_name full_name
		words = full_name.split(" ")
		if words[2].nil?
			return words[1] # There are always at least 2 words in row 2
		else
			return words[2] # Ignore middle names
		end
	end
	
	# Inserts an entry into the authors and books tables from the project data
	def insert_person name, person_id
		insert("person", {
			:person_id 	=> person_id,
			:first_name => get_first_name(name),
			:last_name 	=> get_last_name(name)
		})
		insert("author", {
			:person_id => person_id
		})
	end
	
	# Sees if the author has already been inserted in this script and 
	# If we hit an author and that author already exists we only add to the 
	# written by table
	def try_author_insertion row, existing_authors
		person_id = nil
		if existing_authors.keys.include? row[2].strip
			puts row[2]
			person_id = existing_authors[row[2]]
		else
			# New id is always one higher than the last entered id
			if existing_authors.count > 0 # Handle first entry
				person_id = existing_authors.values.max + 1
			else
				person_id = 0
			end
			existing_authors[row[2].strip] = person_id
			insert_person(row[2].strip, person_id)
		end
		insert("written_by", {
			:author_id 	=> person_id,
			:book_id		=> row[0]
		})
		return existing_authors
	end

	# Parses the entries file into a database containing authors and publishers
	def parse_class_file
		book = Spreadsheet.open("proj_data_xls.xls")
		sheet = book.worksheet(0)
		item_id = 0 # Probably a bad idea to rely on order in insertions (temporary)
		existing_authors = {} # author name => person id mapping
		sheet.each_with_index do |row, index|
			if index == 0 or index == 1 # Handle headers
				next
			end
			if row[0].nil? # If the first row is null we have additional authors
				existing_authors = try_author_insertion(row, existing_authors)
			else # Otherwise we're entering a new book
				insert("item", {
					:price 	=> row[5].to_s,
					:name 	=> row[1].to_s, 
					:year 	=> row[4].to_s
				})
				insert("book", {
					:isbn 	=> row[0].to_s,
					:item_id	=> item_id.to_s
				})
				existing_authors = try_author_insertion(row, existing_authors)
				item_id += 1
			end
		end
		puts existing_authors.to_s
	end
	# Inserts a row into the database.
	# Input: 
	# 	table: A string fort the table to insert into (must already exist)
	#		value_map: A hash with keys as column rows and values as values to insert
	def insert table, value_map
		column_string, value_string = "", ""
		value_map.each do |key, value|
			column_string += key.to_s + ", "
			value_string += '"' +  value.to_s + '", '
		end
		column_string = column_string[0..(column_string.length - 3)] # Lose trailing ','
		value_string = value_string[0..(value_string.length - 3)] 
		
		statement = "INSERT INTO " + table.strip
		statement += " (" + column_string.to_s.strip + ")"
		statement += " VALUES (" + value_string.to_s.strip + ")"
		begin 
			@db.execute statement
		rescue => e # Eat exception so later queries are executed
			puts "Failing SQL Statement: " + statement
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
		opts.on("-d", "--[no] data", "Takes assigned class CSV and loads it into the db") do
			options[:csv] = true
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
# Some stuff here for faster testing
puts "Removing old database file..."
`rm database.db`
puts "Making new database file..."
`touch database.db`
puts "Loading in schema..."
`sqlite3 database.db < schema.sql`
db = options[:db] || 'database.db'
puts "Options:"
p options

interactor = DatabaseInteractor.new db

if options[:csv] 
	puts "Parsing excel doc..."
	interactor.parse_class_file()
end


