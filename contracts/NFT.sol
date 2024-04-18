// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721 {
    constructor() ERC721("Varun NFT", "NFV") {}
    uint private _tokenID = 0;

    function mint() external returns (uint) {
        _mint(msg.sender, ++_tokenID);
        return _tokenID;
    }
}
