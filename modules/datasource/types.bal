public type BookRecord readonly & record {|
    int id;
    string title;
    string author;
    boolean available;
|};

public type UserRecord readonly & record {|
    int id;
    string name;
    Role role;
|};

public type BorrowRecord record {|
    readonly int userId;
    readonly int bookId;
    string borrowedDate;
    string? returnedDate;
|};

public enum Role {
    ADMIN,
    LIBRARIAN,
    MEMBER
}
