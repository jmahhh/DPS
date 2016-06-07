/*
This file is part of the DPS.

The DPS is free software: you can redistribute it and/or modify
it under the terms of the GNU lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The DPS is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the DPS.  If not, see <http://www.gnu.org/licenses/>.
*/

// ~J: I deleted functions of which I was certain we didn't need them
// ~J: I commented out functions that I didn't think we'd need

import "./Potatoken.sol";
import "./ManagedAccount.sol";

contract PotatokenCreationInterface {

    // needed? do we do permanent creation?
    uint public closingTime;
    // Minimum fueling goal of the Potatoken creation, denominated in Potatokens to
    // be created
    uint public minPotatokensToCreate;
    // True if the DPS reached its minimum fueling goal, false otherwise
    bool public isFueled;
    // tracks the amount of wei given from each contributor (used for refund)
    mapping (address => uint256) weiGiven;

    /// @dev Constructor setting the minimum fueling goal and the
    /// end of the Potatoken Creation
    /// @param _minPotatokensToCreate Minimum fueling goal in number of
    ///        Potatokens to be created
    /// @param _closingTime Date (in Unix time) of the end of the Potatoken Creation
    /// @param _privateCreation Zero means that the creation is public.  A
    /// non-zero address represents the only address that can create Potatokens
    /// (the address can also create Potatokens on behalf of other accounts)
    // This is the constructor: it can not be overloaded so it is commented out
    //  function PotatokenCreation(
        //  uint _minPotatokensTocreate,
        //  uint _closingTime,
        //  address _privateCreation
    //  );

    /// @notice Create Potatoken with `_PotatokenHolder` as the initial owner of the Potatoken
    /// @param _PotatokenHolder The address of the Potatokens's recipient
    /// @return Whether the Potatoken creation was successful
    function createPotatokenProxy(address _PotatokenHolder) returns (bool success);

    /// @notice Refund `msg.sender` in the case the Potatoken Creation did
    /// not reach its minimum fueling goal
    // function refund();

    /// @return The divisor used to calculate the Potatoken creation rate during
    /// the creation phase
    // function divisor() constant returns (uint divisor);

    event FuelingToDate(uint value);
    event CreatedPotatoken(address indexed to, uint amount);
    event Refund(address indexed to, uint value);
}


contract PotatokenCreation is PotatokenCreationInterface, Potatoken {
    // can an eponymous function be deleted without consequences? 
    /*function PotatokenCreation(
        uint _closingTime,
        address _privateCreation) {

        closingTime = _closingTime; // ?
        minPotatokensToCreate = _minPotatokensToCreate; // ?
    }*/

    function createPotatokenProxy(address _PotatokenHolder) returns (bool success) {
        if ( now < closingTime && msg.value > 0 ) {

            uint Potatoken = 1; // changed this to one
            balances[_PotatokenHolder] += Potatoken;
            totalSupply += Potatoken;
            weiGiven[_PotatokenHolder] += msg.value;
            CreatedPotatoken(_PotatokenHolder, Potatoken);
            if (totalSupply >= minPotatokensToCreate && !isFueled) {
                isFueled = true;
                FuelingToDate(totalSupply);
            }
            return true;
        }
        throw;
    }

    /*function refund() noEther {
        if (now > closingTime && !isFueled) {
            // Get extraBalance - will only succeed when called for the first time
            if (extraBalance.balance >= extraBalance.accumulatedInput())
                extraBalance.payOut(address(this), extraBalance.accumulatedInput());

            // Execute refund
            if (msg.sender.call.value(weiGiven[msg.sender])()) {
                Refund(msg.sender, weiGiven[msg.sender]);
                totalSupply -= balances[msg.sender];
                balances[msg.sender] = 0;
                weiGiven[msg.sender] = 0;
            }
        }
    }*/

    /*function divisor() constant returns (uint divisor) {
        // The number of (base unit) Potatokens per wei is calculated
        // as `msg.value` * 20 / `divisor`
        // The fueling period starts with a 1:1 ratio
        if (closingTime - 2 weeks > now) {
            return 20;
        // Followed by 10 days with a daily creation rate increase of 5%
        } else if (closingTime - 4 days > now) {
            return (20 + (now - (closingTime - 2 weeks)) / (1 days));
        // The last 4 days there is a constant creation rate ratio of 1:1.5
        } else {
            return 30;
        }
    }*/
}
