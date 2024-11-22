import ballerina/graphql;
import ballerina/http;
import ballerina/lang.value;
import ballerina/log;

import AuthInterceptor.datasource as ds;

@graphql:InterceptorConfig {
    global: false
}
isolated readonly service class AuthInterceptor {
    *graphql:Interceptor;

    private map<Role[]> scopes = {
        addUser: [ADMIN],
        getUser: [ADMIN, LIBRARIAN],
        getBooks: [ADMIN, LIBRARIAN, MEMBER],
        viewBorrowHistory: [ADMIN, LIBRARIAN],
        addBook: [ADMIN],
        borrowBook: [LIBRARIAN, MEMBER],
        returnBook: [LIBRARIAN, ADMIN],
        removeBook: [ADMIN]
    };
    isolated remote function execute(graphql:Context context, graphql:Field 'field) returns anydata|error {
        value:Cloneable|isolated object {} role = check context.get("role");
        lock {
            if role is Role && self.scopes.hasKey('field.getName()) {
                Role[] scopes = <Role[]>self.scopes['field.getName()];
                if scopes.indexOf(role) is int {
                    return context.resolve('field);
                }
                return error("Unauthorized");
            }
            return error("Invalid user role");
        }
    }
}

@graphql:ServiceConfig {
    graphiql: {
        enabled: true
    },
    contextInit: contextInit,
    interceptors: new AuthInterceptor()
}
isolated service /graphql on new graphql:Listener(9000) {

    # Get a user
    # + userId - The user ID
    # + return - return the user
    resource function get getUser(@graphql:ID int userId) returns User?|error {
        ds:UserRecord user = check ds:getUser(userId);
        return new User(user);
    }

    # Get all books
    # + return - return the list of books
    resource function get getBooks() returns Book[]|error {
        ds:BookRecord[] books = check ds:getBooks();
        return books.'map(book => new Book(book));
    }

    # View borrow history
    # + userId - The user ID
    # + return - return the list of borrow history
    resource function get viewBorrowHistory(@graphql:ID int userId) returns BorrowRecord[]?|error {
        ds:BorrowRecord[] borrowRecords = check ds:viewBorrowHistory(userId);
        if borrowRecords.length() == 0 {
            return [];
        }
        return borrowRecords.'map(rec => new BorrowRecord(rec));
    }

    # Add a new user
    # + name - The name of the user
    # + role - The role of the user
    # + return - return the newly added user
    remote function addUser(string name, Role role) returns User? {
        ds:UserRecord user = ds:addUser(name, role);
        return new User(user);
    }

    # Add a new book
    # + title - The title of the book
    # + author - The author of the book
    # + return - return the newly added book
    remote function addBook(string title, string author) returns Book? {
        ds:BookRecord newBook = ds:addBook(title, author);
        return new Book(newBook);
    }

    # Remove a book
    # + bookId - The ID of the book
    # + return - return the removed book
    remote function removeBook(@graphql:ID int bookId) returns Book?|error {
        ds:BookRecord book = check ds:removeBook(bookId);
        return new Book(book);
    }

    # Borrow a book
    # + userId - The user ID
    # + bookId - The ID of the book
    # + return - return the borrowed book
    remote function borrowBook(@graphql:ID int userId, @graphql:ID int bookId) returns BorrowRecord?|error {
        ds:BorrowRecord book = check ds:updateBorrowRecord(userId, bookId, false);
        return new BorrowRecord(book);
    }

    # Return a book
    # + userId - The user ID
    # + bookId - The ID of the book
    # + return - return the returned book
    remote function returnBook(@graphql:ID int userId, @graphql:ID int bookId) returns BorrowRecord?|error {
        ds:BorrowRecord book = check ds:updateBorrowRecord(userId, bookId, true);
        return new BorrowRecord(book);
    }
}

isolated function contextInit(http:RequestContext requestContext, http:Request request) returns graphql:Context|error {
    graphql:Context context = new;
    string role = check request.getHeader("role");
    log:printInfo("Role: " + role);
    context.set("role", role);
    return context;
}