// SPDX-FileCopyrightText: © 2022 Dai Foundation <www.daifoundation.org>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
pragma solidity ^0.6.12;

import {SolidityTypeConversions as stc} from "./SolidityTypeConversions.sol";

library JsonFormatter {
    function toPair(string memory key, string memory value) internal pure returns (string memory) {
        // solhint-disable-next-line quotes
        return string(abi.encodePacked('["', key, '","', value, '"]'));
    }

    function toPair(string memory key, uint256 value) internal pure returns (string memory) {
        // solhint-disable-next-line quotes
        return string(abi.encodePacked('["', key, '","', stc.toString(value), '"]'));
    }

    function toPair(string memory key, address value) internal pure returns (string memory) {
        // solhint-disable-next-line quotes
        return string(abi.encodePacked('["', key, '","', stc.toString(value), '"]'));
    }

    function toPair(string memory key, bytes memory value) internal pure returns (string memory) {
        // solhint-disable-next-line quotes
        return string(abi.encodePacked('["', key, '","', value, '"]'));
    }

    function toPair(string memory key, bytes32 value) internal pure returns (string memory) {
        // solhint-disable-next-line quotes
        return string(abi.encodePacked('["', key, '","', stc.toString(value), '"]'));
    }
}
