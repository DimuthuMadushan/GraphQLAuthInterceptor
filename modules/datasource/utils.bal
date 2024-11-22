import ballerina/time;

public isolated function getBooks() returns BookRecord[]|error {
    lock {
        BookRecord[] bookRecords = from BookRecord book in books select book;
        return bookRecords.cloneReadOnly();
    }
}

public isolated function getBook(int bookId) returns BookRecord|error {
    lock {
        BookRecord[] bookRecords = from BookRecord book in books where book.id == bookId select book;
        if bookRecords.length() == 1 {
            return bookRecords[0].cloneReadOnly();
        }
        return error("Book not found");
    }
}

public isolated function addBook(string title, string author) returns BookRecord {
    lock {
        int key = books.length() + 1;
        while books.hasKey(key) {
            key = key + 1;
        }
        BookRecord newBook = {id: key, title, author, available: true};
        books.add(newBook);
        return newBook;
    }
}

public isolated function viewBorrowHistory(int userId) returns BorrowRecord[]|error {
    lock {
        BorrowRecord[] borrowRecords = from BorrowRecord rec in borrowTable where rec.userId == userId select rec;
        return borrowRecords.cloneReadOnly();
    }
}

public isolated function updateBorrowRecord(int userId, int bookId, boolean isReturn) returns BorrowRecord|error {
    lock {
        if isReturn {
            BorrowRecord[] borrow = from BorrowRecord rec in borrowTable
                where rec.userId == userId && rec.bookId == bookId
                select rec;
            if borrow.length() == 1 {
                borrow[0].returnedDate = time:utcToString(time:utcNow()).substring(0, 10);
                BorrowRecord bRec = borrow[0];
                return bRec.cloneReadOnly();
            }
            return error("Borrow record not found");
        }
        BorrowRecord br = {
            userId,
            bookId,
            borrowedDate: time:utcToString(time:utcNow()).substring(0, 10),
            returnedDate: ()
        };
        borrowTable.add(br);
        return br.cloneReadOnly();
    }
}

public isolated function removeBook(int bookId) returns BookRecord|error {
    lock {
        if !books.hasKey(bookId) {
            return error("Book not found");
        }
        BookRecord removed = books.remove(bookId);
        return removed.cloneReadOnly();
    }
}

public isolated function getUser(int userId) returns UserRecord|error {
    lock {
        UserRecord[] userRecords = from UserRecord user in users where user.id == userId select user;
        if (userRecords.length() == 1) {
            return userRecords[0].cloneReadOnly();
        }
        return error("User not found");
    }
}

public isolated function addUser(string name, Role role) returns UserRecord {
    lock {
        int key = users.length() + 1;
        while users.hasKey(key) {
            key = key + 1;
        }
        UserRecord newUser = {id: key, name, role};
        users.add(newUser);
        return newUser;
    }
}