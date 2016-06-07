// TODO
// createPotatokenProxy
// contracts: Potatokens, PotatokenCreation
// PotatoAdded
// is transferFrom needed?
// approve() needed? Limited to curators I believe.
// allowance() doesn't seem to be used for anything.

// REMOVED:
// splitting
// extraBalance
// minimum tokens, limited creation period
// curators, Approved Recipients
// ManagedAccount ( ~= extraBalance I think)
// minQuorumDivisor, lastTimeMinQuorumMet

// Figure out
// what does `indexed` do?
// what do the random `_` do?
// there seem to be two transfer() functions: here and in Potatoken.sol
// does the constructor in PotatokenCreation need to be uncommented or not?
// ...what is meant with "overloading"?
// what goes into transactionData? Is that the tx metadata?
// potatoes.length


import "./PotatokenCreation.sol";
import "./ManagedAccount.sol";

contract DPSInterface {

  // is a deposit needed to prevent proposal spam? Or do we only allow one proposal at a time, or three or?

  mapping (string => uint) public recipe; // needs to be called when proposal passes

  Potato[] public potatoes;

  uint constant potatoDebatePeriod = 2 days;

  uint constant executePotatoPeriod = 10 days;

  mapping (address => uint) public blocked;

  function () returns (bool success);

  modifier onlyPotatoholders {}

  struct Potato {
    string ingredient;
    uint quantity;
    bool open;
    bool potatoPassed;
    bytes32 potatoHash;
    uint yea;
    uint nay;
    mapping (address => bool) votedYes;
    mapping (address => bool) votedNo;
    address creator;
  }

  function newPotato(
    string _ingredient,
    uint _quantity,
    bytes _transactionData,
  ) onlyPotatoholders returns (uint _potatoID);

  function checkPotatoCode(
    uint _potatoID,
    bytes _transactionData
    ) constant returns (bool _codeChecksOut);

  function vote(
    uint _potatoID,
    bool _supportsPotato
    ) onlyPotatoholders returns (uint _voteID);

  function executePotato(
    uint _potatoID,
    bytes _transactionData
    ) returns (bool _success);

  function changePotatoDeposit(uint _potatoDeposit) external;

  function numberOfPotatoes() constant returns (uint _numberOfPotatoes);

  function isBlocked(address _account) internal returns (bool);

  function unblockMe() returns (bool);

  event PotatoAdded(
    uint indexed potatoID,
    string ingredient,
    uint quantity
  );
  event Voted(uint indexed potatoID, bool position, address indexed voter);
  event PotatoTallied(uint indexed potatoID, bool result, uint quorum);
}

contract DPS is DPSInterface, Potatokens, PotatokenCreation {

  modifier onlyPotatoholders {
    if (balanceOf(msg.sender) == 0) throw;
      _
  }

  function DPS(
    DPS_Creator _DPSCreator,
  ) PotatokenCreation() {

    DPSCreator = _DPSCreator,
    potatoes.length = 1; //needed?


  }

  function () returns (bool success) {
    return createPotatokenProxy(msg.sender);
  }

  function receiveEther() returns (bool) {
    return true;
  }

  function newPotato(
    string _ingredient,
    uint _quantity,
    bytes _transactionData
    ) onlyPotatokenholders returns (uint _potatoID) {
      // Sanity Checks

      _potatoID = potatoes.length++;
      Potato p = potatoes[_potatoID];
      p.ingredient = _ingredient;
      p.quantity = _quantity;
      p.potatoHash = sha3(_transactionData);
      p.open = true;
      p.creator = msg.sender;

      PotatoAdded(
        _potatoID,
        _ingredients
      );
    }

    // function checkPotatoCode()

    function vote(
      uint _potatoID,
      bool _supportsPotato
    ) onlyPotatokenholders noEther returns (uint _voteID){

      Potato p = potatoes[_potatoID];
      if (p.votedYes[msg.sender]
        || p.votedNo[msg.sender]
        || now >= p.votingDeadline) {
          throw;
        }

      if (_supportPotato) {
        p.yea += balances[msg.sender];
        p.votedYes[msg.sender] = true;
      } else {
        p.nay += balances[msg.sender];
        p.votedNo[msg.sender] = true;
      }

      if (blocked[msg.sender] == 0) {
        blocked[msg.sender] = _potatoID;
      } else if (p.votingDeadline > potatoes[blocked[msg.sender]].votingDeadline) {
        blocked[msg.sender] = _potatoID;
      }

      Voted(_potatoID, _supportsPotato, msg.sender);

    }

    function executePotato(
      uint _potatoID,
      bytes _transactionData
    ) noEther returns (bool _success) {

      Potato p = potatoes[_potatoID];

      if ( p.open && now > p.votingDeadline + executePotatoPeriod ) {
        closePotato(_potatoID);
        return;
      }

      if ( now < p.votingDeadline
        || !p.open
        || p.potatoHash != sha3(_transactionData)) {

        throw;
      }

      uint quorum = p.yea + p.nay;

      if ( quorum >= minQuorum(p.amount) && p.yea > p.nay ) {
        p.potatoPassed = true;
        _success = true;
        recipe[p.ingredient] = p.quantity;
      }

      closePotato(_potatoID);

      PotatoTallied(_potatoID, _success, quorum);

    }

    function closePotato(uint _potatoID) internal {
      Potato p = potatoes[_potatoID];
      if (p.open)
        sumOfPotatoDeposits -= p.potatoDeposit;
      p.open = false;
    }

    //function transfer?

    function minQuorum(uint _value) internal constant returns (uint _minQuorum) {
      //!TODO balances.length == 0
      if ( balances.length  == 1 || balances.length == 2 ) {
        return 1;
      } else if ( balances.length < 100 ) {
        return 0.5;
      } else {
        return 0.2;
      }
    }

    function numberOfPotatoes() constant returns (uint _numberOfPotatoes) {
      return potatoes.length - 1;
    }

    function isBlocked(address _account) internal returns (bool) {
        if (blocked[_account] == 0)
            return false;
        Potato p = potatoes[blocked[_account]];
        if (now > p.votingDeadline) {
            blocked[_account] = 0;
            return false;
        } else {
            return true;
        }
    }

    function unblockMe() returns (bool) {
        return isBlocked(msg.sender);
    }

}

contract DPS_Creator {
    function createDPS() returns (DPS _newDPS) {

        return new DPS(
            DPS_Creator(this),
        );
    }
}
