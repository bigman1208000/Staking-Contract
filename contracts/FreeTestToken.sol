//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

/// @title FreeTestToken
/// @dev Do not deploy this contract. This is used for the unit tests.
contract FreeTestToken is ERC20PresetMinterPauser {
    constructor() ERC20PresetMinterPauser("FTT", "FreeTestToken") {
        mint(msg.sender, 1000000 ether);
    }
}
