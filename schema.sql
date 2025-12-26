-- Table for storing user data
CREATE TABLE users (
    `id` INT UNSIGNED AUTO_INCREMENT,
    `first_name` VARCHAR(64) NOT NULL,
    `last_name` VARCHAR(64) NOT NULL,
    `email` VARCHAR(128) NOT NULL UNIQUE,
    `phone_number` VARCHAR(16) NOT NULL,
    `address` VARCHAR(256),
    `role` ENUM('member', 'staff') NOT NULL,
    PRIMARY KEY(`id`)
);

-- Table for data about Authors
CREATE TABLE authors (
    `id` INT UNSIGNED AUTO_INCREMENT,
    `name` VARCHAR(64) NOT NULL,
    `birth_year` YEAR DEFAULT NULL,
    `bio` TEXT DEFAULT NULL,
    PRIMARY KEY(`id`)
);

-- Table for data about Publishers
CREATE TABLE publishers (
    `id` INT UNSIGNED AUTO_INCREMENT,
    `name` VARCHAR(64) NOT NULL,
    `bio` TEXT DEFAULT NULL,
    PRIMARY KEY(`id`)
);

-- Table containing data about books
CREATE TABLE books (
    `id` INT UNSIGNED AUTO_INCREMENT,
    `title` VARCHAR(128) NOT NULL,
    `author_id` INT UNSIGNED NOT NULL,
    `publisher_id` INT UNSIGNED NOT NULL,
    `publication_year` YEAR DEFAULT NULL,
    `genre` VARCHAR(32) DEFAULT NULL,
    `availability_status` ENUM('available', 'not_available') DEFAULT 'available',
    PRIMARY KEY(`id`),
    FOREIGN KEY(`author_id`) REFERENCES authors(`id`),
    FOREIGN KEY(`publisher_id`) REFERENCES publishers(`id`)
);

-- Table to record book transactions, borrow and returns
CREATE TABLE borrowing_transactions (
    `id` INT UNSIGNED AUTO_INCREMENT,
    `user_id` INT UNSIGNED NOT NULL,
    `book_id` INT UNSIGNED NOT NULL,
    `date_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `action` ENUM('Borrowed', 'Returned') NOT NULL,
    FOREIGN KEY(`user_id`) REFERENCES users(`id`),
    FOREIGN KEY(`book_id`) REFERENCES books(`id`)
);

-- Update book's availabilty status on transaction
DELIMITER //
CREATE TRIGGER book_status_update
AFTER INSERT ON borrowing_transactions
FOR EACH ROW
BEGIN
    IF NEW.action = 'Borrowed' THEN
        UPDATE books
        SET `availability_status` = 'not_available'
        WHERE id = NEW.book_id;
    ELSEIF NEW.action = 'Returned' THEN
        UPDATE books
        SET `availability_status` = 'available'
        WHERE id = NEW.book_id;
    END IF;
END //
DELIMITER ;

-- Indexes to speed-up queries
CREATE INDEX index_authors_name ON authors(name);
CREATE INDEX index_publishers_name ON publishers(name);
CREATE INDEX idx_books_author_id ON books(author_id);
CREATE INDEX idx_books_publisher_id ON books(publisher_id);
CREATE INDEX idx_books_availability_status ON books(availability_status);
CREATE INDEX idx_borrowing_transactions_user_id ON borrowing_transactions(user_id);
CREATE INDEX idx_borrowing_transactions_book_id ON borrowing_transactions(book_id);

-- List of books available at Library
CREATE VIEW available_books AS
    SELECT id, title
    FROM books
    WHERE availability_status = 'available';

-- List of books borrowed by users
CREATE VIEW borrowed_books AS
    SELECT id, title
    FROM books
    WHERE availability_status = 'not_available';

-- List of members
CREATE VIEW members AS
    SELECT id, first_name, last_name, email
    FROM users
    WHERE role = 'member';

-- List of staff
CREATE VIEW staff AS
    SELECT id, first_name, last_name, email
    FROM users
    WHERE role = 'staff';

-- Shows user's borrowing history
DELIMITER //
CREATE PROCEDURE user_borrowing_history(IN user_email VARCHAR(128))
BEGIN
    SELECT
        users.id,
        users.first_name,
        users.last_name,
        books.title,
        borrowing_transactions.date_time,
        borrowing_transactions.action
    FROM users
    JOIN borrowing_transactions ON users.id = borrowing_transactions.user_id
    JOIN books ON borrowing_transactions.book_id = books.id
    WHERE users.email = user_email;
END //
DELIMITER ;

-- Shows all books by a given author
DELIMITER //
CREATE PROCEDURE book_by_author(IN author_name VARCHAR(64))
BEGIN
    SELECT
        books.title AS Title,
        books.publication_year AS Year,
        books.genre AS Genre,
        publishers.name AS Publisher
    FROM books
    JOIN publishers ON books.publisher_id = publishers.id
    WHERE author_id = (
        SELECT id
        FROM authors
        WHERE name = author_name    
    );
END //
DELIMITER ;

-- Shows all books by a given Publisher
DELIMITER //
CREATE PROCEDURE book_by_publisher(IN publisher_name VARCHAR(64))
BEGIN
    SELECT
        books.title AS Title,
        books.publication_year AS Year,
        books.genre AS Genre
    FROM books
    JOIN publishers ON books.publisher_id = publishers.id
    WHERE publisher_id = (
        SELECT id
        FROM publishers
        WHERE name = publisher_name
    );
END //
DELIMITER ;
