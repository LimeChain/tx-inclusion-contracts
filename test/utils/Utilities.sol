// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import "forge-std/Test.sol";

contract Utilities is Test {
    bytes32 internal nextUser = keccak256(abi.encodePacked("user address"));
    address private currentPrank;

    function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory) {
        bytes memory bytesArray = new bytes(32);
        for (uint256 i = 0; i < 32; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    function getNextUserAddress() external returns (address payable, uint256) {
        (address user, uint256 userPk) = makeAddrAndKey(bytes32ToString(nextUser));
        nextUser = keccak256(abi.encodePacked(nextUser));
        return (payable(user), userPk);
    }

    function label(string memory str, uint256 num) internal pure returns (string memory) {
        if (num == 0) {
            return "0";
        }
        uint256 j = num;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = num;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + (j % 10)));
            j /= 10;
        }
        // return string(bstr);
        //concatenate str and bstr
        bytes memory strBytes = bytes(str);
        return string(abi.encodePacked(strBytes, bstr));
    }

    /// @notice create users with 100 ether balance
    function createUsers(uint256 userNum) external returns (address payable[] memory, uint256[] memory) {
        address payable[] memory users = new address payable[](userNum);
        uint256[] memory pks = new uint256[](userNum);
        for (uint256 i = 0; i < userNum; i++) {
            (address payable user, uint256 pk) = this.getNextUserAddress();
            vm.deal(user, 100 ether);
            vm.label(user, i == 0 ? "owner" : label("user", i));
            users[i] = user;
            pks[i] = pk;
        }
        return (users, pks);
    }

    function convertUsersToUnpayable(address payable[] memory users) external pure returns (address[] memory) {
        address[] memory unpayableUsers = new address[](users.length);
        for (uint256 i = 0; i < users.length; i++) {
            unpayableUsers[i] = address(users[i]);
        }
        return unpayableUsers;
    }

    /// @notice move block.number forward by a given number of blocks
    function mineBlocks(uint256 numBlocks) external {
        uint256 targetBlock = block.number + numBlocks;
        vm.roll(targetBlock);
    }

    function signMessage(uint256 privateKey, bytes32 hash) external pure returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, hash);
        return makeSignatureFromVRS(v, r, s);
    }

    // Useful if you have signature (for example from web2 JS call) string (135 in length) and want to convert it to bytes
    function bytesSignatureFromString(string memory s) public pure returns (bytes memory) {
        bytes memory ss = bytes(s);
        require(ss.length % 2 == 0);
        bytes memory r = new bytes(ss.length / 2 - 1);
        for (uint256 i = 0; i < (ss.length / 2 - 1); ++i) {
            uint256 sI = i + 1;
            r[i] = bytes1(fromHexChar(uint8(ss[2 * sI])) * 16 + fromHexChar(uint8(ss[2 * sI + 1])));
        }
        return r;
    }

    function makeSignatureFromVRS(uint8 v, bytes32 r, bytes32 s) public pure returns (bytes memory) {
        bytes memory sig = new bytes(65);
        assembly {
            mstore(add(sig, 65), v)
            mstore(add(sig, 32), r)
            mstore(add(sig, 64), s)
        }
        return sig;
    }

    // Helper for bytesSignatureFromString
    function fromHexChar(uint8 c) private pure returns (uint8) {
        if (bytes1(c) >= bytes1("0") && bytes1(c) <= bytes1("9")) {
            return c - uint8(bytes1("0"));
        }
        if (bytes1(c) >= bytes1("a") && bytes1(c) <= bytes1("f")) {
            return 10 + c - uint8(bytes1("a"));
        }
        if (bytes1(c) >= bytes1("A") && bytes1(c) <= bytes1("F")) {
            return 10 + c - uint8(bytes1("A"));
        }
        revert("fail");
    }

    function epsilon(uint256 _a, uint256 _b, uint256 _epsilon) public pure returns (bool) {
        if (_a > _b) {
            return _a - _b <= _epsilon;
        } else {
            return _b - _a <= _epsilon;
        }
    }

    function assertSemiEq(uint256 a, uint256 b) external {
        uint256 epsilonVal = 50;
        assertEq(epsilon(a, b, epsilonVal), true);
    }
}
