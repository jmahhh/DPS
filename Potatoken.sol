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


/*
Basic, standardized Potatoken contract with no "premine". Defines the functions to
check Potatoken balances, send Potatokens, send Potatokens on behalf of a 3rd party and the
corresponding approval process. Potatokens need to be created by a derived
contract (e.g. PotatokenCreation.sol).

Thank you ConsenSys, this contract originated from:
https://github.com/ConsenSys/Potatokens/blob/master/Potatoken_Contracts/contracts/Standard_Potatoken.sol
Which is itself based on the Ethereum standardized contract APIs:
https://github.com/ethereum/wiki/wiki/Standardized_Contract_APIs
*/

/// @title Standard Potatoken Contract.

contract PotaPotatokenInterface {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    /// Total amount of Potatokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance);

    /// @notice Send `_amount` Potatokens to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _amount The amount of Potatokens to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _amount) returns (bool success);

    /// @notice Send `_amount` Potatokens to `_to` from `_from` on the condition it
    /// is approved by `_from`
    /// @param _from The address of the origin of the transfer
    /// @param _to The address of the recipient
    /// @param _amount The amount of Potatokens to be transferred
    /// @return Whether the transfer was successful or not
    // function transferFrom(address _from, address _to, uint256 _amount) returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_amount` Potatokens on
    /// its behalf
    /// @param _spender The address of the account able to transfer the Potatokens
    /// @param _amount The amount of Potatokens to be approved for transfer
    /// @return Whether the approval was successful or not
    // function approve(address _spender, uint256 _amount) returns (bool success);

    /// @param _owner The address of the account owning Potatokens
    /// @param _spender The address of the account able to transfer the Potatokens
    /// @return Amount of remaining Potatokens of _owner that _spender is allowed
    /// to spend
    /*function allowance(
        address _owner,
        address _spender
    ) constant returns (uint256 remaining);*/

    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    /*event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
    );*/
}


contract Potatoken is PotatokenInterface {
    // Protects users by preventing the execution of method calls that
    // inadvertently also transferred ether
    modifier noEther() {if (msg.value > 0) throw; _}

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _amount) noEther returns (bool success) {
        if (balances[msg.sender] >= _amount && _amount > 0) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
           return false;
        }
    }

    /*function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) noEther returns (bool success) {

        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0) {

            balances[_to] += _amount;
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function approve(address _spender, uint256 _amount) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }*/

    /*function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }*/
}
