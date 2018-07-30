pragma solidity ^0.4.24;

// File: node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: node_modules/openzeppelin-solidity/contracts/lifecycle/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

// File: node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: node_modules/openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

// File: node_modules/openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

// File: node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: node_modules/openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: contracts/DiscoverBlockchainToken.sol

/**
 * @title DiscoverBlockchainToken
 * @author Aleksandar Djordjevic
 * @dev DiscoverBlockchainToken is ERC20 Ownable, BurnableToken & StandardToken
 * It is meant to be used in a DiscoverBlockchain Crowdsale contract
 */
contract DiscoverBlockchainToken is Ownable, BurnableToken, StandardToken {
    string public constant name = 'DiscoverBlockchain Token'; // DSC name
    string public constant symbol = 'DSC'; // DSC symbol
    uint8 public constant decimals = 18; // DSC decimal number
    uint256 public constant TOTAL_SUPPLY = 500000000 * (10 ** uint256(decimals)); // total amount of all DSC tokens - 500 000 000 DSC

    /**
     * @dev DiscoverBlockchainToken constructor
     * Sets total supply and assigns total supply to the owner
     */
    constructor() public {
        totalSupply_ = TOTAL_SUPPLY; // set total amount of tokens
        balances[owner] = TOTAL_SUPPLY; // transfer all tokens to smart contract owner

        emit Transfer(address(0), owner, totalSupply_); // emit Transfer event and notify that transfer of tokens was made
    }
}

// File: contracts/DiscoverBlockchainCrowdsale.sol

/**
 * @title DiscoverBlockchainCrowdsale
 * @author Yosra Helal 
 * @dev DiscoverBlockchainCrowdsale is Crowdsale Smart Contract with a limit for total contributions, funding goal, and
 * the possibility of users getting a refund if goal is not met.
 */
contract DiscoverBlockchainCrowdsale is Pausable {
    // ICO Stage
    enum CrowdsaleStage {PrivatePreICO, PreICO, ICO}
    CrowdsaleStage public stage = CrowdsaleStage.PrivatePreICO; // By default it's Private Pre Sale

    // Token Distribution
    DiscoverBlockchainToken token;
    address public wallet; // wallet to save raised ether
    uint256 public maxTokens = 500000000000000000000000000; // There will be total 500 000 000 DiscoverBlockchain tokens
    uint256 public tokensForEcosystem = 100000000000000000000000000; // 100 000 000 DSC tokens are reserved for Ecosystem - Platform
    uint256 public tokensForBounty = 40000000000000000000000000; // 40 000 000 tokens are reserved for Bounties, Rewards & Bonuses
    uint256 public totalTokensForSale = 360000000000000000000000000; // 360 000 000 DSC tokens will be sold in Crowdsale
    uint256 public totalTokensForSaleDuringPrivatePreICO = 60000000000000000000000000; // 60 000 000 DSC tokens will be sold during Private PreICO
    uint256 public totalTokensForSaleDuringPreICO = 120000000000000000000000000; // 120 000 000 DSC tokens will be sold during Private PreICO
    // Dates
    // PrivatePreICO period
    uint256 public startingDatePrivatePreICO = 1538352000; // epoch timestamp for the starting date PrivatePreICO period Human time (GMT): Monday, October 1, 2018 12:00:00 AM
    uint256 public endDatePrivatePreICO = 1540944000; // timestamp for the ending date PrivatePreICO period Human time (GMT): Wednesday, October 31, 2018 12:00:00 AM

    uint256 public softCapPrivatePreICO = 10000 ether;
    // PreICO period
    uint256 public startingDatePreICO = 1541030400; // timestamp for the starting date PreICO period Human time (GMT): Thursday, November 1, 2018 12:00:00 AM
    uint256 public endDatePreICO = 1543536000; // timestamp for the ending date PreICO period Human time (GMT): Friday, November 30, 2018 12:00:00 AM
    // ICO period
    uint256 public startingDateICO = 1543622400; // timestamp for the starting date ICO period Human time (GMT): Saturday, December 1, 2018 12:00:00 AM

    // Amount raised in Private PreICO and PreICO
    uint256 public totalWeiRaisedDuringPrivatePreICO;
    uint256 public totalWeiRaisedDuringPreICO;
    uint256 public totalWeiRaised;
    uint256 public hardCap = 60000 ether;

    // Mapping contributions during the private PreICO
    mapping (address => uint256) contributions;
    mapping (uint => address) public contributorPositions;
    uint256 contributorsCount;

    // Events
    event EthTransferred(uint256 _value, address _from, address _to);
    event EthRefunded(uint256 _value, address _from, address _to);

    /**
     * @dev DiscoverBlockchainCrowdsale constructor
     * Creates DiscoverBlockchainCrowdsale Smart Contracts
     * Checks if the goal is less then hard cap and transfers tokens for bounty to bountyFund
     */
    constructor(ERC20 _token, uint256 _rate, address _wallet, address _bountyFund, address _ecosystemFund) public {
        require(_goal <= _cap);
        wallet = _wallet;
        token = DiscoverBlockchainToken(_token);
        token.transfer(_bountyFund, tokensForBounty); // to validate
        token.transfer(_ecosystemFund, tokensForEcosystem); // to validate
    }

    /**
     * @dev Token Purchase
     */
    function() external payable {
        uint256 tokensToTransfer = msg.value.mul(rate);
        require(totalWeiRaised.add(msg.value) <= hardCap));
        if (stage == CrowdsaleStage.PrivatePreICO) {
          require(_value <= totalTokensForSaleDuringPrivatePreICO);
          token.transfer(msg.sender, tokensToTransfer);
          totalWeiRaisedDuringPrivatePreICO = totalWeiRaisedDuringPrivatePreICO.add(msg.value);
          totalWeiRaised = totalWeiRaised.add(msg.value);
          contributions[msg.sender] = contributions[msg.sender].add(msg.value);
          contributorPositions[contributorsCount] = msg.sender;
          contributorsCount++;
          return;
        }
        else if (stage == CrowdsaleStage.PreICO) {
          require(_value <= totalTokensForSaleDuringPreICO);
          token.transfer(msg.sender, tokensToTransfer);
          totalWeiRaised = totalWeiRaised.add(msg.value);
          return;
        }
        else {
          require(_value <= totalTokensForSale);
          token.transfer(msg.sender, tokensToTransfer);
          totalWeiRaised = totalWeiRaised.add(msg.value);
          return;
        }
    }

    /**
     * @dev Change Crowdsale Stage
     * Available Options: PrivatePreICO, PreICO, ICO
     */
    function setCrowdsaleStage(uint value) public onlyOwner {
        require(value == CrowdsaleStage.PrivatePreICO || value == CrowdsaleStage.ICO);
        if (uint(CrowdsaleStage.PrivatePreICO) == value) {
            stage = CrowdsaleStage.PrivatePreICO;
            // Set price of DSC tokens per 1 ETH for each the PrivatePreICO
            setCurrentRate(10000);
        } else{
            stage = CrowdsaleStage.ICO;
            // Set price of DSC tokens per 1 ETH for each the ICO
            setCurrentRate(5000);
        }
    }
    /*
    * @dev Change the current rate by the owner,
    * if the ETH prices change a lot during our Crowdsale
    */
    function setCurrentRate(uint256 _rate) public onlyOwner {
        rate = _rate;
    }

    /**
     * @dev Change the current rate
     */
    function setCurrentRate(uint256 _rate) internal {
        rate = _rate;
    }

    /**
    * @dev Refund all the contributors in the private PreICO
    */
    function _refund() internal {
      for(uint i = 0; i < contributorsCount; i++){
        address contributor = contributorPositions[i];
        uint256 amountRefunded = contributions[contributor];
        require(contributor.transfer(amountRefunded));
        emit EthRefunded(address(this).balance, address(this), contributor);
      }
    }
    /**
     * @dev Finalize Crowdsale
     */
    function finish() public onlyOwner {
        require(totalWeiRaised >= hardCap);
        // transfer the raised ether
        wallet.transfer(address(this).balance);
        emit EthTransferred(address(this).balance, address(this), wallet);
    }

    /**
    * @dev Close the private ico period and switch to the pre sale period
    */
    function finishPrivatePreICO() public onlyOwner {
        require (now >= endDatePrivatePreICO);
        // check if the soft cap of the private PreICO period is reached
        if(totalWeiRaisedDuringPrivatePreICO >= softCapPrivatePreICO){
          // transfer the raised ether
          wallet.transfer(address(this).balance);
          emit EthTransferred(address(this).balance, address(this), wallet);
          // switch the next stage : PreICO period
          stage = CrowdsaleStage.PreICO;
          setCurrentRate(6667);
        }
      else{
         // refund all the funds
         _refund();
      }
    }
}