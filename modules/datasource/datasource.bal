isolated table<BookRecord> key(id) books = table [
    {id: 1, title: "The Great Gatsby", author: "F. Scott Fitzgerald", available: true},
    {id: 2, title: "1984", author: "George Orwell", available: false}
];

isolated table<BorrowRecord> key(userId, bookId) borrowTable = table [
    {userId: 1, bookId: 1, borrowedDate: "2024-11-12", returnedDate: ()},
    {userId: 2, bookId: 2, borrowedDate: "2024-11-12", returnedDate: "2024-11-12"}
];

isolated table<UserRecord> key(id) users = table [
    {id: 1, name: "Alice", role: ADMIN},
    {id: 2, name: "Bob", role: LIBRARIAN},
    {id: 3, name: "Charlie", role: MEMBER}
];
