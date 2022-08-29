// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// import "hardhat/console.sol";

contract Proofable {
    event SetDifficulty(
        uint8 oldDifficulty, 
        uint8 newDifficulty
    );

    event UpdateAccountIndex(
        address account,
        uint256 index
    );

    mapping(address => uint256) public indexes;
    uint8 public difficulty = 10;

    modifier verifiedProof(bytes32 proof) {
        require(
            _verifyProof(msg.sender, indexes[msg.sender]++, proof, _getDifficulty()), 
            "PoWProofable: Proof not verified"
        );
        emit UpdateAccountIndex(msg.sender, indexes[msg.sender]);
        _;
    }

    function getProofHash(address caller, uint256 index, bytes32 proof) public pure returns (bytes32 hash) {
        hash = keccak256(abi.encode(uint160(caller), index, proof));
    }

    function _byteDiff(bytes1 b) private pure returns (uint8) {
        uint8 curDiff = 0;
        for (uint8 j = 0; j < 8; j++) {
            if((uint8(b) & 1 << j) == 0) {
                curDiff += 1;
            } else {
                break;
            }
        }
        return curDiff;
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function _check(bytes32 h, uint8 diff) private pure returns (bool) {
        uint8 curDiff = 0;
        for (uint8 i = 0; i <= h.length; i++) {
            uint8 currByteDiff = _byteDiff(h[i]);
            curDiff += currByteDiff;
            if(currByteDiff != 8) break;
        }
        return curDiff >= diff;
    }

    function _verifyProof(address caller, uint256 index, bytes32 proof, uint8 diff) internal pure returns (bool) {
        bytes32 hash = getProofHash(caller, index, proof);
        require(diff <= hash.length, "PoWProofable: Invalid difficulty");
        
        return _check(hash, diff);
    }

    function _getDifficulty() internal view virtual returns (uint8) {
        return difficulty;
    }

    function _setDifficulty(uint8 newDifficulty) internal {
        emit SetDifficulty(difficulty, newDifficulty);
        difficulty = newDifficulty;
    }
}