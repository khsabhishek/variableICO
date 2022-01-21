// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


/*************************************SafeMath library*********************************/
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

/***************************************Context*******************************************/
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
/********************************************IERC20 interface******************************/
interface IERC20 {


    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */

    function buyTokens(address _receiver, uint256 _amount) external;

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


/**********************************************main contract***********************/

contract Crowdsale  {
    using SafeMath for uint256;

     AggregatorV3Interface internal priceFeed;

    bool public icoCompleted;
    uint256 public icoStartTime;
    uint256 public a = 1;
    uint256 public icoEndTime;
  //  uint256 public tokenRate;
    uint256 public PriceOfETHinUSD;
    IERC20 public token;
    uint256 public fundingGoal;
    address public owner;
    uint256 public tokensRaised;
    // uint256 public rateOne = PriceOfETHinUSD.div(1e8).mul(100);
    // uint256 public rateTwo = PriceOfETHinUSD.div(1e8).mul(50);
    // uint256 public limitTierOne;
    // uint256 public limitTierTwo;

    modifier whenIcoCompleted {
        require(icoCompleted);
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    fallback () external payable {
        buy();
    }

    constructor(uint256 _icoStart, uint256 _icoEnd, /*uint256 _tokenRate,*/ address _tokenAddress, uint256 _fundingGoal) public {
        require(_icoStart != 0 &&
            _icoEnd != 0 &&
            _icoStart < _icoEnd &&
           // _tokenRate != 0 &&
            _tokenAddress != address(0) &&
            _fundingGoal != 0);

        priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        icoStartTime = _icoStart;
        icoEndTime = _icoEnd;
     //   tokenRate = _tokenRate;
        token = IERC20(_tokenAddress);
        fundingGoal = _fundingGoal;
        owner = msg.sender;
    }


     function getLatestPrice() public returns (uint256) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        PriceOfETHinUSD = uint(price);
        return PriceOfETHinUSD;
    }

    function limitTierOne() public view returns(uint256) {
        return 30e6 * (10 ** token.decimals());
    }

    function limitTierTwo() public view returns(uint256) {
        return 50e6 * (10 ** token.decimals());
    }

    function rateOne() public view returns(uint256) {
        return PriceOfETHinUSD.div(1e8).mul(100);
    }

    function rateTwo() public view returns(uint256) {
        return PriceOfETHinUSD.div(1e8).mul(50);
    }

    
    function calculateExcessTokens(
      uint256 amount,
      uint256 tokensThisTier,
      uint256 tierSelected,
      uint256 _rate
    ) public returns(uint256 totalTokens) {
        require(amount > 0 && tokensThisTier > 0 && _rate > 0);
        require(tierSelected >= 1 && tierSelected <= 2);

        uint weiThisTier = tokensThisTier.sub(tokensRaised).div(_rate);
        uint weiNextTier = amount.sub(weiThisTier);
        uint tokensNextTier = 0;
        bool returnTokens = false;

        // If there's excessive wei for the last tier, refund those
        if(tierSelected != 2)
            tokensNextTier = calculateTokensTier(weiNextTier, tierSelected.add(1));
        else
            returnTokens = true;

        totalTokens = tokensThisTier.sub(tokensRaised).add(tokensNextTier);

        // Do the transfer at the end
        if(returnTokens) payable(msg.sender).transfer(weiNextTier);
   }

    function calculateTokensTier(uint256 weiPaid, uint256 tierSelected)
        internal returns(uint256 calculatedTokens)
    {
        require(weiPaid > 0);
        require(tierSelected >= 1 && tierSelected <= 2);

        if(tierSelected == 1)
            calculatedTokens = weiPaid.mul(rateOne());
        else if(tierSelected == 2)
            calculatedTokens = weiPaid.mul(rateTwo());
   }

    function buy() public payable {
    	require(tokensRaised < fundingGoal);
    	require(block.timestamp < icoEndTime && block.timestamp > icoStartTime);

        uint256 tokensToBuy;
    	uint256 etherUsed = msg.value;

    	// If the tokens raised are less than 25 million with decimals, apply the first rate
    	if(tokensRaised < limitTierOne()) {
    	    // Tier 1
    		tokensToBuy = etherUsed * (10 ** token.decimals()) / 1 ether * rateOne();

    		// If the amount of tokens that you want to buy gets out of this tier
    		if(tokensRaised + tokensToBuy > limitTierOne()) {
    			tokensToBuy = calculateExcessTokens(etherUsed, limitTierOne(), 1, rateOne());
    		}
    	} else if(tokensRaised >= limitTierOne() && tokensRaised < limitTierTwo()) {
    	    // Tier 2
            tokensToBuy = etherUsed * (10 ** token.decimals()) / 1 ether * rateTwo();

            // If the amount of tokens that you want to buy gets out of this tier
       		if(tokensRaised + tokensToBuy > limitTierTwo()) {
    			tokensToBuy = calculateExcessTokens(etherUsed, limitTierTwo(), 2, rateTwo());
    		}


    	// Send the tokens to the buyer
    	token.buyTokens(msg.sender, tokensToBuy);

    	// Increase the tokens raised and ether raised state variables
    	tokensRaised += tokensToBuy;
    }
}
}
