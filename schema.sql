create table if not exists item(item_id integer primary key not null, price integer, name text, year integer, inventory boolean, publisher_id integer, foreign key(publisher_id) references publisher(pub_id));

create table if not exists book(isbn primary key not null, item_id integer not null, foreign key(item_id) references item(item_id));

create table if not exists author(person_id integer primary key not null, foreign key(person_id) references person(person_id));

create table if not exists publisher(pub_id integer primary key not null, name text, city_id integer, foreign key(city_id) references city(city_id));

create table if not exists person(person_id integer primary key not null, first_name text, last_name text, city_id integer, foreign key(city_id) references city(city_id));

create table if not exists city(city_id integer primary key autoincrement not null, name text, country text);

create table if not exists employee(person_id integer primary key not null, access_level integer, foreign key(person_id) references person(person_id));

create table if not exists author(person_id integer primary key not null, foreign key(person_id) references person(person_id));

create table if not exists c_order(order_number integer primary key not null);

create table if not exists customer(person_id integer primary key not null, email text, address text, phone_number text, credit_card integer, order_id integer, foreign key(order_id) references c_order(order_number), foreign key(person_id) references person(person_id));

create table if not exists purchased_by(date_of_purchase date, customer_id integer, item_id integer, primary key(customer_id,item_id), foreign key(customer_id) references customer(person_id), foreign key(item_id) references item(item_id));

create table if not exists written_by(author_id integer, book_id integer, primary key(author_id,book_id), foreign key(author_id) references author(person_id), foreign key(book_id) references book(isbn));

create table if not exists magazine(issn integer, pub_date date, item_id integer, primary key(issn,pub_date), foreign key(item_id) references item(item_id));

create table if not exists contains(order_id integer, item_id integer, primary key(order_id,item_id), foreign key(order_id) references c_order(order_number), foreign key(item_id) references item(item_id));

create table if not exists review(review_id integer primary key autoincrement not null, rating integer, body text, item_id integer, reviewer_id integer, foreign key(item_id) references item(item_id), foreign key(reviewer_id) references customer(person_id));

