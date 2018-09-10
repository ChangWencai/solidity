pragma solidity ^0.4.24;
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
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
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }

    /**
     * @dev gives square root of given x.
     */
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y)
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y)
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }

    /**
     * @dev gives square. multiplies x by x
     */
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }

    /**
     * @dev x to the power of y
     */
    function pwr(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}
contract onypay{
    
    using SafeMath for * ;
    
    struct gameInfo{
        uint256 maxSize;
        uint256 winId;
        address winPlyer;
        uint256 curr;
    }

    uint256 round_ = 1;

    uint256 pot_;
    
    uint256 constant min_ = 0.01 ether;
    
    mapping(uint256 => mapping(address => uint256[])) plyrRnds_; // round => plyr => ownTokens
    
    mapping(uint256 => uint256[]) rndTokenIds_;    // round => tokens
    mapping(uint256 => mapping(uint256 => uint256)) rndTokensIndex; // rount => tokenid => index

    mapping(uint256 => mapping(uint256 => address)) ronTokenAddr_;  // rount => tokenid => address

    address owner;
    
    uint256 private beginNumber_ = 10000;
    
    modifier checkLimit(uint256 _eth){
        require(_eth >= min_);
        _;
    }
    
     constructor() public{
         owner = msg.sender;
     }
     
     event buyToken(address _from, uint256 _tokenid);

     function core(address _account) private  {
         beginNumber_ = beginNumber_.add(1);
         uint256 _seed = beginNumber_;
         plyrRnds_[round_][_account].push(_seed);
         rndTokenIds_[round_].push(_seed);
         ronTokenAddr_[round_][_seed] = _account;
         uint256 _length = rndTokenIds_[round_].length;
         rndTokensIndex[round_][_length] = _seed;
         emit buyToken(_account,_seed);
     } 

    event BuyCore(uint256 _rnd, uint256 _tokenid, address _winer);
     function buyCore() public payable checkLimit(msg.value) {
        address _account = msg.sender;
        uint256 _eth = msg.value;
        uint256 num = _eth.div(min_);
        // if(_eth % min_ > 0){
        //     uint256 _surplus = _eth.sub(num.mul(min_));
        //     _account.transfer(_surplus);
        // }

        // pot_.add(num.mul(min_));
        pot_.add(_eth);

        for(uint256 i = 0; i < num; i++){
            core(_account);
        }
        if(pot_ >= 0.1 ether){
            uint256 _luckyTokenId = withdraw();
            address _luckyAddr = ronTokenAddr_[round_][_luckyTokenId];
            _luckyAddr.transfer(pot_.mul(8).div(10));
            emit BuyCore(round_,_luckyTokenId,_luckyAddr);
            endRound();
        }

     }
     event Withdraw(uint256 _length,uint256 _index, uint256 _tokenid);
     
     function withdraw() private returns(uint256) {
        uint256 _length = rndTokenIds_[round_].length;
        uint256 _luckyIndex = uint256(keccak256(abi.encodePacked((block.timestamp).add(block.difficulty).add((uint256(keccak256(abi.encodePacked(block.gaslimit)))))))) % _length;

        uint256 _tokenid = rndTokensIndex[round_][_luckyIndex];
        emit Withdraw(_length,_luckyIndex,_tokenid);
        return _tokenid;
     }
     
     function endRound() private{
        round_ = round_.add(1);
        pot_ = 0;
     }

     /*
     @dev 返回当前游戏信息
     @return 当前游戏round id
     @return 当前游戏进度
     @return 当前游戏奖金池
     */
     function getCurrentRoundInfo()public view returns(uint256,uint256,uint256){
        uint256 _rnd = round_;
        uint256 _curLength = rndTokenIds_[_rnd].length;

        return (_rnd,_curLength,pot_);
     }
     
}