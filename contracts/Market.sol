// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IERC721.sol";

contract Market {
    enum ListingStatus {
        Active,
        Sold,
        Cancelled
    }
    struct Listing {
        ListingStatus status;
        address seller;
        address token;
        uint tokenID;
        uint price;
    }
    event Listed (
        uint listingID,
        address seller,
        address token,
        uint tokenID,
        uint price
    );
    event Sale (
        uint listingID,
        address seller,
        address buyer,
        address token,
        uint tokenID,
        uint price
    );
    event Cancel (
        uint listingID,
        address seller
    );

    uint private _listingID = 0;
    mapping(uint => Listing) private _listings;

    function listToken(address token, uint tokenID, uint price) external {
        IERC721(token).transferFrom(msg.sender, address(this), tokenID);
        Listing memory listing = Listing(
            ListingStatus.Active,
            msg.sender,
            token,
            tokenID,
            price
        );

        _listings[++_listingID] = listing;

        emit Listed(_listingID, msg.sender, token, tokenID, price);
    }
    function getListing(uint listingID) external view returns (Listing memory) {
        return _listings[listingID];
    }

    function buyToken(uint listingID) external payable {
        Listing storage listing = _listings[listingID];
        
        require(msg.sender != listing.seller, "Seller cannot buy own token");
        require(listing.status == ListingStatus.Active, "Listing is not active");

        require(msg.value >= listing.price, "Insufficient funds");

        listing.status = ListingStatus.Sold;

        IERC721(listing.token).transferFrom(address(this), msg.sender, listing.tokenID);
        payable(listing.seller).transfer(listing.price);

        emit Sale(listingID, listing.seller, msg.sender, listing.token, listing.tokenID, listing.price);
    }

    function cancel(uint listingID) public {
        Listing storage listing = _listings[listingID];

        require(msg.sender == listing.seller, "Only seller can cancel listing");
        require(listing.status == ListingStatus.Active, "Listing is not active");

        listing.status = ListingStatus.Cancelled;

        IERC721(listing.token).transferFrom(address(this), listing.seller, listing.tokenID);

        emit Cancel(listingID, listing.seller);
    }

}
