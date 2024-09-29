#[derive(Copy, Drop, Serde, starknet::Store)]
struct Book {
    name: felt252,
    book_author: felt252,
    book_pub: u16
}

#[starknet::interface]
pub trait IBookStore<TContractState> {
    fn register_book(ref self: TContractState, name: felt252, book_author: felt252, book_pub: u16, book_id: u8);
    fn delete_book(ref self: TContractState, book_id: u8);
    fn update_book(ref self: TContractState, name: felt252, book_author: felt252, book_pub: u16, book_id: u8);
    fn access_book(self: @TContractState, book_id: u8) -> Book;
}

#[starknet::contract]
pub mod BookStore {
    use starknet::event::EventEmitter;
    use super::{IBookStore, Book}; // import interface BookStore and struct Book
    use core::starknet::{
        get_caller_address, ContractAddress,
        storage::{Map, StorageMapReadAccess, StorageMapWriteAccess} // import map
    };

    #[storage]
    struct Storage {
       books : Map<u8, Book>, // map book id to struct Book
       admin_address: ContractAddress
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        BookAdded: BookAdded,
        BookUpdated: BookUpdated,
    }

    #[derive(Drop, starknet::Event)]
    struct BookAdded {
        name: felt252,
        book_author: felt252,
        book_pub: u16,
        book_id: u8
    }

    #[derive(Drop, starknet::Event)]
    struct BookUpdated {
      name: felt252,
      book_author: felt252,
      book_pub: u16
    }

    #[constructor]
    fn constructor(ref self: ContractState, admin_address: ContractAddress) {
        self.admin_address.write(admin_address)
    }

    #[abi(embed_v0)]
    impl BookStoreImpl of IBookStore <ContractState>{
        fn register_book(ref self: ContractState, name: felt252, book_author: felt252, book_pub: u16, book_id: u8) {
            let admin_address = self.admin_address.read();
            assert(get_caller_address() == admin_address, 'Only Admin has access');
            let book = Book {name: name, book_author: book_author, book_pub: book_pub};
            self.books.write(book_id, book);
            self.emit(BookAdded { name, book_author, book_pub, book_id});
        }

        fn update_book(ref self: ContractState, name: felt252, book_author: felt252, book_pub: u16, book_id: u8){
            let admin_address = self.admin_address.read();
            assert(get_caller_address() == admin_address, 'Only admin has access');
            let mut book = self.books.read(book_id);
            book = Book {name: name, book_author: book_author, book_pub: book_pub};
            self.books.write(book_id, book);
            self.emit(BookUpdated { name, book_author, book_pub});
        }

        fn access_book(self: @ContractState, book_id: u8) -> Book {
            return self.books.read(book_id);
        }

        // Working on the delete function...
        fn delete_book(ref self: ContractState, book_id: u8){
            let admin_address = self.admin_address.read();
            assert(get_caller_address() == admin_address, 'Only Admin has access');
            let mut book = self.books.read(book_id);
            
        }
    }
}


