// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import { EIP3009 } from "./interfaces/EIP3009.sol";
import { IERC20Internal } from "./interfaces/IERC20Internal.sol";
import { EIP712Domain } from "./interfaces/EIP712Domain.sol";
import { EIP712 } from "./interfaces/EIP712.sol";

abstract contract EIP3009Expanded is IERC20Internal, EIP712Domain, EIP3009 {
    // keccak256("ApproveWithAuthorization(address owner,address spender,uint256 value,uint256 validAfter,uint256 validBefore,bytes32 nonce)")
    bytes32
        public constant APPROVE_WITH_AUTHORIZATION_TYPEHASH = 0x808c10407a796f3ef2c7ea38c0638ea9d2b8a1c63e3ca9e1f56ce84ae59df73c;

    // keccak256("IncreaseAllowanceWithAuthorization(address owner,address spender,uint256 increment,uint256 validAfter,uint256 validBefore,bytes32 nonce)")
    bytes32
        public constant INCREASE_ALLOWANCE_WITH_AUTHORIZATION_TYPEHASH = 0x424222bb050a1f7f14017232a5671f2680a2d3420f504bd565cf03035c53198a;

    // keccak256("DecreaseAllowanceWithAuthorization(address owner,address spender,uint256 decrement,uint256 validAfter,uint256 validBefore,bytes32 nonce)")
    bytes32
        public constant DECREASE_ALLOWANCE_WITH_AUTHORIZATION_TYPEHASH = 0xb70559e94cbda91958ebec07f9b65b3b490097c8d25c8dacd71105df1015b6d8;

    /**
     * @notice Update allowance with a signed authorization
     * @param owner         Token owner's address (Authorizer)
     * @param spender       Spender's address
     * @param value         Amount of allowance
     * @param validAfter    The time after which this is valid (unix time)
     * @param validBefore   The time before which this is valid (unix time)
     * @param nonce         Unique nonce
     * @param v             v of the signature
     * @param r             r of the signature
     * @param s             s of the signature
     */
    function approveWithAuthorization(
        address owner,
        address spender,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        _requireValidAuthorization(owner, nonce, validAfter, validBefore);

        bytes memory data = abi.encode(
            APPROVE_WITH_AUTHORIZATION_TYPEHASH,
            owner,
            spender,
            value,
            validAfter,
            validBefore,
            nonce
        );
        require(
            EIP712.recover(DOMAIN_SEPARATOR, v, r, s, data) == owner,
            _INVALID_SIGNATURE_ERROR
        );

        _markAuthorizationAsUsed(owner, nonce);
        _approve(owner, spender, value);
    }

    /**
     * @notice Increase allowance with a signed authorization
     * @param owner         Token owner's address (Authorizer)
     * @param spender       Spender's address
     * @param increment     Amount of increase in allowance
     * @param validAfter    The time after which this is valid (unix time)
     * @param validBefore   The time before which this is valid (unix time)
     * @param nonce         Unique nonce
     * @param v             v of the signature
     * @param r             r of the signature
     * @param s             s of the signature
     */
    function increaseAllowanceWithAuthorization(
        address owner,
        address spender,
        uint256 increment,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        _requireValidAuthorization(owner, nonce, validAfter, validBefore);

        bytes memory data = abi.encode(
            INCREASE_ALLOWANCE_WITH_AUTHORIZATION_TYPEHASH,
            owner,
            spender,
            increment,
            validAfter,
            validBefore,
            nonce
        );
        require(
            EIP712.recover(DOMAIN_SEPARATOR, v, r, s, data) == owner,
            _INVALID_SIGNATURE_ERROR
        );

        _markAuthorizationAsUsed(owner, nonce);
        _increaseAllowance(owner, spender, increment);
    }

    /**
     * @notice Decrease allowance with a signed authorization
     * @param owner         Token owner's address (Authorizer)
     * @param spender       Spender's address
     * @param decrement     Amount of decrease in allowance
     * @param validAfter    The time after which this is valid (unix time)
     * @param validBefore   The time before which this is valid (unix time)
     * @param nonce         Unique nonce
     * @param v             v of the signature
     * @param r             r of the signature
     * @param s             s of the signature
     */
    function decreaseAllowanceWithAuthorization(
        address owner,
        address spender,
        uint256 decrement,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        _requireValidAuthorization(owner, nonce, validAfter, validBefore);

        bytes memory data = abi.encode(
            DECREASE_ALLOWANCE_WITH_AUTHORIZATION_TYPEHASH,
            owner,
            spender,
            decrement,
            validAfter,
            validBefore,
            nonce
        );
        require(
            EIP712.recover(DOMAIN_SEPARATOR, v, r, s, data) == owner,
            _INVALID_SIGNATURE_ERROR
        );

        _markAuthorizationAsUsed(owner, nonce);
        _decreaseAllowance(owner, spender, decrement);
    }
}