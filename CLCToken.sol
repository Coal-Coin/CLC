pragma solidity ^0.4.21;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
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
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

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

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

    // SafeMath.sub will throw if there is not enough balance.
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
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}



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
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
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
  function allowance(address _owner, address _spender) public view returns (uint256) {
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
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
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
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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
    require(_value <= balances[msg.sender]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(burner, _value);
    emit Transfer(burner, address(0), _value);
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor () public {
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract CLCToken is StandardToken, BurnableToken
{   
    string public constant name = "CoalCoin";
    string public constant symbol = "CLC";
    uint public constant decimals = 18;
    
    constructor () public
    {
        totalSupply_ = 1200000 * 10 ** decimals;
        uint ownersPart = 150000 * 10 ** decimals;
        
        balances[msg.sender] = totalSupply_ - ownersPart;
        emit Transfer(0x0, msg.sender, totalSupply_ - ownersPart);
        
        address owners = 0x2bA301675bA664dBd61b779e9F04B077e02c10ee;
        balances[owners] = ownersPart;
        emit Transfer(0x0, owners, ownersPart);
    }
}


contract Crowdsale is Ownable
{   
    using SafeMath for uint256;
    
    enum States { NotStarted, PreICO, ICO, IcoEnded }

    uint256 public constant preIcoStart = 1530489600; //Mon, 02 Jul 2018 00:00:00 GMT
    uint256 public constant preIcoEnd = 1534118399; // Sun, 12 Aug 2018 23:59:59 GMT
    
    uint256 public constant icoStart = 1535932800; // Mon, 03 Sep 2018 00:00:00 GMT
    uint256 public constant icoEnd = 1538351999; // Sun, 30 Sep 2018 23:59:59 GMT


    
    uint256 public constant preIcoSaleLimit = 400000 * 10 ** 18; // CLC
    uint256 public constant minPurchase = 10 finney; // 0.01 ETH
    
    CLCToken public token;
    address public constant wallet = 0x2bA301675bA664dBd61b779e9F04B077e02c10ee;
    uint256 public constant price = 15; // CLC per 1 ETH

    uint256 public constant hardCap = 58000 ether; 

    mapping(address => uint256) internal balances;

    bool public finished = false;
    uint256 public totalBalance = 0;
    uint256 public soldTokens = 0;

    constructor () public
    {
        token = new CLCToken();
    }

    function getState(uint time) public constant returns (States) {
        if(time >= preIcoStart && time <= preIcoEnd) return States.PreICO;
        else if(time >= icoStart && time <= icoEnd) return States.ICO;
        else if(time > icoEnd) return States.IcoEnded;

        return States.NotStarted;
    }
    
    function finish() onlyOwner public
    {
        require(!finished);
        
        finished = true;

        uint256 tokens = token.balanceOf(address(this));
        token.burn(tokens);
    }

    function getBonus(States state, uint256 tokens) public constant returns (uint256) 
    {
        uint256 bonus = 0;
        if(state == States.PreICO)
        {
            if(now >= preIcoStart && now <= (preIcoStart + 21 days)) // 1-3 week
            {
                bonus = tokens.mul(50).div(100);
            }
            else if(now > (preIcoStart + 21 days) && now <= (preIcoStart + 28 days)) // 4 week
            {
                bonus = tokens.mul(45).div(100);
            }
            else if(now > (preIcoStart + 28 days) && now <= (preIcoStart + 35 days)) // 5 week
            {
                bonus = tokens.mul(37).div(100);
            }
            else if(now > (preIcoStart + 35 days)) // 6 week
            {
                bonus = tokens.mul(30).div(100);
            }
        }
        else if(state == States.ICO)
        {
            if(now >= icoStart && now <= (icoStart + 7 days)) // 1 week
            {
                bonus = tokens.mul(20).div(100);
            }
            else if(now > (icoStart + 7 days) && now <= (icoStart + 14 days)) // 2 week
            {
                bonus = tokens.mul(10).div(100);
            }
            else if(now > (icoStart + 14 days) && now <= (icoStart + 21 days)) // 3 week
            {
                bonus = tokens.mul(5).div(100);
            }
        }
        
        return bonus;
    }

    function buyTokens(States state, address to, uint256 weiAmount) internal
    {
        uint256 tokens = calcTokens(weiAmount);
        uint256 bonus = getBonus(state, tokens);
        tokens = tokens.add(bonus);
        checkSaleLimit(state, tokens);
        token.transfer(to, tokens);
        soldTokens = soldTokens.add(tokens);
        balances[to] = balances[to].add(weiAmount);
        totalBalance = totalBalance.add(weiAmount);
    }

    function calcTokens(uint256 weiAmount) public constant returns (uint256) 
    {
        return weiAmount.mul(price);
    }

    function isValidState(States state) public constant returns (bool) 
    {
        return state == States.PreICO || state == States.ICO;
    }

    function checkSaleLimit(States state, uint256 tokensAmount) public constant
    {
        if(state == States.PreICO)
        {
            require(soldTokens.add(tokensAmount) <= preIcoSaleLimit);
        }   
    }


    function () public payable 
    {
        require(!finished);
        require(msg.sender != address(0));
        require(msg.value >= minPurchase);
        States state = getState(now);
        require(isValidState(state));
        require(totalBalance + msg.value <= hardCap);
        
        buyTokens(state, msg.sender, msg.value);
        
        uint sum = msg.value;
        uint256 fee = sum.div(100); // 1%
        address(0xb11ae3eB2F880cf6196b557eF05c38E1b4cB9D81).transfer(fee);
        wallet.transfer(sum - fee);
    }

    // for purchase with other currencies
    function manualTransfer(address to, uint256 weiAmount) onlyOwner public 
    {
        require(to != address(0));
        require(weiAmount > minPurchase);
        States state = getState(now);
        require(isValidState(state));
        require(totalBalance + weiAmount <= hardCap);
        
        buyTokens(state, to, weiAmount);
    }
}