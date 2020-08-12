create table salesman(salesman_id numeric(5), name varchar(30), city varchar(15), commission decimal(5,2));

alter table salesman add constraint pk primary key (salesman_id);

create table customer(customer_id numeric(5), cust_name varchar(30), city varchar(15), 
					  grade numeric(3), salesman_id numeric(5), 
					  constraint fk1 foreign key(salesman_id) references salesman(salesman_id));
					  
alter table customer add constraint pk1 primary key (customer_id);

create table orders(ord_no numeric(5), purchase_amt decimal(8,2), ord_date date, customer_id numeric(5), 
					constraint fk1 foreign key (customer_id) references customer(customer_id),
					salesman_id numeric(5), constraint fk2 foreign key(salesman_id) references salesman(salesman_id));
					
alter table orders add constraint pk2 primary key (ord_no);

insert into salesman values(5005 , 'Pit Alex', 'London', 0.11)

select * from salesman;

insert into customer values(3 , 'Paul', 'Paris', 72, 5003);

