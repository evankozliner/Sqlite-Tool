create table if not exists item(item_id integer primary key not null, price integer, name text, year integer, inventory boolean);

create table if not exists book(isbn primary key not null, item_id integer not null, foreign key(item_id) references item(item_id));

create table if not exists author(person_id integer primary key not null, foreign key(person_id) references person(person_id));

create table if not exists publisher(pub_id integer primary key not null, name text, city_id integer, foreign key(city_id) references city(city_id));

create table if not exists person(person_id integer primary key not null, first_name text, last_name text, city_id integer, foreign key(city_id) references city(city_id));

create table if not exists city(city_id integer primary key not null, name text);
