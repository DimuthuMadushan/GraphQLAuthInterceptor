import ballerina/graphql;

import AuthInterceptor.datasource as ds;

public enum Role {
    ADMIN,
    LIBRARIAN,
    MEMBER
}

public isolated distinct service class Book {
    private final readonly & ds:BookRecord br;
    isolated function init(ds:BookRecord br) {
        self.br = br;
    }
    isolated resource function get id() returns @graphql:ID int {
        return self.br.id;
    }

    isolated resource function get title() returns string {
        return self.br.title;
    }

    isolated resource function get author() returns string {
        return self.br.author;
    }

    isolated resource function get available() returns boolean {
        return self.br.available;
    }
}

public isolated distinct service class BorrowRecord {

    private final ds:BorrowRecord br;

    isolated function init(ds:BorrowRecord br) {
        self.br = br.cloneReadOnly();
    }

    isolated resource function get book() returns Book?|error {
        lock {
            ds:BookRecord book = check ds:getBook(self.br.bookId);
            return new Book(book);
        }
    }

    isolated resource function get borrowedDate() returns string {
        lock {
            return self.br.borrowedDate;
        }
    }

    isolated resource function get returnedDate() returns string? {
        lock {
            return self.br.returnedDate;
        }
    }
}

public isolated distinct service class User {
    private final ds:UserRecord user;

    isolated function init(ds:UserRecord user) {
        self.user = user;
    }

    isolated resource function get id() returns @graphql:ID int {
        return self.user.id;
    }

    isolated resource function get name() returns string {
        return self.user.name;
    }

    isolated resource function get role() returns Role {
        return self.user.role;
    }
}
