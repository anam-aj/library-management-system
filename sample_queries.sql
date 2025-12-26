-- List all available books
SELECT * FROM available_books;

-- List all borrowed books:
SELECT * FROM borrowed_books;

-- Get borrowing history of a user by email
CALL user_borrowing_history('user@example.com');

-- Get all books by a specific author
CALL book_by_author('J.K. Rowling');

-- Get all books by a specific publisher
CALL book_by_publisher('Penguin Books');

-- List all members
SELECT * FROM members;

-- List all staff
SELECT * FROM staff;

-- Add a new book transaction (Borrowed)
INSERT INTO borrowing_transactions (user_id, book_id, action)
VALUES (1, 101, 'Borrowed');

-- Add a new book transaction (Returned)
INSERT INTO borrowing_transactions (user_id, book_id, action)
VALUES (1, 101, 'Returned');
