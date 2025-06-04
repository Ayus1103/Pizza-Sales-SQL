CREATE DATABASE pizzahut;

USE pizzahut;

CREATE TABLE orders(
	order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY(order_id)
);

SELECT * FROM orders;

CREATE TABLE order_details(
	order_detail_id INT NOT NULL,
	order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY(order_detail_id)
);

SELECT * FROM order_details;