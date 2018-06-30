pragma solidity ^0.4.18;


library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
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

library SafeMath32 {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint32 a, uint32 b) internal pure returns (uint32) {
    if (a == 0) {
      return 0;
    }
    uint32 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint32 a, uint32 b) internal pure returns (uint32) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint32 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint32 a, uint32 b) internal pure returns (uint32) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint32 a, uint32 b) internal pure returns (uint32) {
    uint32 c = a + b;
    assert(c >= a);
    return c;
  }
}
  
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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


contract BasicGamble {
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    
    // 抽奖id与地址的映射
    mapping(uint32 => address) internal luckyIdOwner;
    
    //mapping(address => uint256) internal ownedluckIdCount;
    // 限制抽奖id为拥有者才能调用的函数修饰符
    modifier onlyOwnerOf(uint32 _luckyId) {
        require(ownerOf(_luckyId) == msg.sender);
        _;
    }
    
    event createNewLuckyId(address indexed _to, uint256 _luckyId);
    event destroyOldLuckyId(address indexed _from, uint256 _luckyId);
    
    /*
    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0));
        return ownedluckIdCount[_owner];
    }
    */

    // 返回抽奖id的拥有者地址
    function ownerOf(uint32 _luckyId) public view  returns (address) {
        address owner = luckyIdOwner[_luckyId];
        require(owner != address(0));
        return owner;
    }
    // 返回抽奖id是否存在
    function exists(uint32 _luckyId) public view returns (bool) {
        address owner = luckyIdOwner[_luckyId];
        return owner != address(0);
    }
    // 绑定抽奖id与拥有者地址之间的映射关系，并发送createNewLuckyId事件
    function _mint(address _to, uint32 _luckyId) internal {
        require(_to != address(0));
        addLuckyIdTo(_to, _luckyId);
        emit createNewLuckyId(_to,_luckyId);
    }
    // 将抽奖id与地址的绑定关系添加到关系映射
    function addLuckyIdTo(address _to, uint32 _luckyId) internal {
        require(luckyIdOwner[_luckyId] == address(0));
        luckyIdOwner[_luckyId] =_to;
        //ownedluckIdCount[_to] = ownedluckIdCount[_to].add(1);
    }
    // 取消抽奖id与拥有者地址之间的绑定关系，并发送destroyOldLuckyId事件
    function _burn(address _owner, uint32 _luckyId) internal {
        removeLuckyIdFrom(_owner, _luckyId);
        emit destroyOldLuckyId(_owner, _luckyId);
    }
    // 取消抽奖id与拥有者地址之间的绑定关系
    function removeLuckyIdFrom(address _from, uint32 _luckyId) internal {
        require(ownerOf(_luckyId) == _from);
        //ownedluckIdCount[_from] = ownedluckIdCount[_from].sub(1);
        delete luckyIdOwner[_luckyId];
    }
}


contract GambleInfo is BasicGamble {
    using SafeMath32 for uint32;
    using SafeMath for uint256;

    // 单一地址所购买的所有id映射
    mapping(address => uint32[]) internal ownedLuckyIds;
    // 每个抽奖id所对应ownedLuckyIds的下标
    mapping(uint32 => uint32) internal ownedLuckysIndex;
    // 数组,存储所有的抽奖id
    uint32[] internal allLuckyIds;
    // 没有抽奖id对应allLuckyIds的下标
    mapping(uint32 => uint32) internal allLuckysIndex;
    
    // 通过下标返回玩家买过的抽奖id
    function luckyOfOwnerByIndex(address _owner, uint256 _index) public view returns(uint256) {
        require(_index < ownedLuckyIds[_owner].length);
        return ownedLuckyIds[_owner][_index];
    }
    // 返回总共出售抽奖id的数量
    function totalSupply() public view returns (uint256) {
        return allLuckyIds.length;
    }
    // 返回allLuckyIds下标对应的抽奖id
    function luckyIdByIndex(uint256 _index) public view returns (uint32) {
        require(_index < totalSupply());
        return allLuckyIds[_index];
    }
    // 将抽奖id与购买者地址添加到ownedLuckyIds对应关系
    function addLuckyIdTo(address _to, uint32 _luckyId) internal {
        super.addLuckyIdTo(_to, _luckyId);
        uint32 length = uint32(ownedLuckyIds[_to].length);
        ownedLuckyIds[_to].push(_luckyId);
        ownedLuckysIndex[_luckyId] = length;
    }
    // 将抽奖id与购买者地址从ownedLuckyIds对应关系上删除
    function removeLuckyIdFrom(address _from, uint32 _luckyId) internal {
        super.removeLuckyIdFrom(_from, _luckyId);
        
        uint32 luckyIdIndex = ownedLuckysIndex[_luckyId];
        uint256 lastLuckyIdIndex = ownedLuckyIds[_from].length.sub(1);
        uint32 lastLuckyId = ownedLuckyIds[_from][lastLuckyIdIndex];
        
        ownedLuckyIds[_from][luckyIdIndex] = lastLuckyId;
        delete ownedLuckyIds[_from][lastLuckyIdIndex];
        
        ownedLuckyIds[_from].length--;
        delete ownedLuckysIndex[_luckyId];
        ownedLuckysIndex[uint32(lastLuckyId)] = luckyIdIndex;
    }
    // 将抽奖id与购买者建立绑定关系
    function _mint(address _to, uint32 _luckyId) internal {
        super._mint(_to, _luckyId);
        
        allLuckysIndex[_luckyId] = uint32(allLuckyIds.length);
        allLuckyIds.push(uint32(_luckyId));
    }
    // 删除抽奖id与拥有者之间的关系
    function _burn(address _owner, uint32 _luckyId) internal {
        super._burn(_owner, _luckyId);
        
        uint32 luckyIdIndex = allLuckysIndex[_luckyId];
        uint256 lastLuckyIdIndex = allLuckyIds.length.sub(1);
        uint32 lastLuckyId = allLuckyIds[lastLuckyIdIndex];
        
        allLuckyIds[luckyIdIndex] = lastLuckyId;
        delete allLuckyIds[lastLuckyIdIndex];
        
        allLuckyIds.length--;
        delete allLuckysIndex[_luckyId];
        allLuckysIndex[lastLuckyId] = luckyIdIndex;
    }
    
}


contract LcukyGamble is GambleInfo, Ownable {
    using SafeMath32 for uint32;
    using SafeMath for uint256;
    // 抽奖id池，每一期抽奖都会刷新
    uint32[] internal luckyIdsPool;
    // 记录当前抽奖池中id的数量
    uint256 internal currPoolSize;
    // 中奖者的address与中奖id
    
    // 记录中奖者信息
    uint32[] private historyWinerId;
    event transfer(address indexed _owner, uint256 _luckyId);
    // 一次性删除所有抽奖id与拥有者address数据
    function disposeAll(uint32 _begin, uint32 _end) public onlyOwner {
        
        //uint32 length = uint32(totalSupply());
        
        uint32 beginId = _begin;
        uint32 endId = _end;
        
        for(uint32 i = beginId; i < endId; i++){
            if ( exists(i)){
                address owner = ownerOf(i);
                disposeById(i,owner);
            }
        }
        delete historyWinerId;
    }
    // 单次删除单个抽奖id与拥有者的信息
    function disposeById(uint32 _luckyId,address _from) public onlyOwner {
        require(ownerOf(_luckyId) == _from);
        delete luckyIdOwner[_luckyId];
        
        uint32 luckyIdIndex = ownedLuckysIndex[_luckyId];
        uint256 lastLuckyIdIndex = ownedLuckyIds[_from].length.sub(1);
        uint32 lastLuckyId = ownedLuckyIds[_from][lastLuckyIdIndex];
        
        ownedLuckyIds[_from][luckyIdIndex] = lastLuckyId;
        delete ownedLuckyIds[_from][lastLuckyIdIndex];
        
        ownedLuckyIds[_from].length--;
        delete ownedLuckysIndex[_luckyId];
        ownedLuckysIndex[uint32(lastLuckyId)] = luckyIdIndex;
        
        uint32 aluckyIdIndex = allLuckysIndex[_luckyId];
        uint256 alastLuckyIdIndex = allLuckyIds.length.sub(1);
        uint32 alastLuckyId = allLuckyIds[alastLuckyIdIndex];
        
        allLuckyIds[aluckyIdIndex] = alastLuckyId;
        delete allLuckyIds[alastLuckyIdIndex];
        
        allLuckyIds.length--;
        delete allLuckysIndex[_luckyId];
        allLuckysIndex[alastLuckyId] = aluckyIdIndex;
        
    }
    
    // 初始化id池事件
    event initPoolPushId(uint256 _id);

    // 创建抽奖id池，_num一次性创建的数量
    function fillLuckyPool(uint256 _num) public onlyOwner {
        //uint256 numberhistory = historyWinerArr.length;
        require(poolOverplus() == 0);
        luckyIdsPool = new uint32[](_num);
        currPoolSize = _num;
        luckyIdsPool.length = _num;
        uint256 total = totalSupply();
        for(uint256 i = 0; i < _num; i++) {
            //luckyIdsPool.push(i.add(10000).add(numberhistory.mul(totalOfOnePool)));
            luckyIdsPool[i] = uint32(i.add(10000).add(total));
            emit initPoolPushId( i.add(10000).add(total));
        }
    }
    
    
    // 返回当前抽奖池中还剩余的id数量
    function poolOverplus() public view returns(uint256) {
        return luckyIdsPool.length;
    }
    
    
    // 当玩家购买抽奖id时，随机从抽奖池中获取一个id
    function randomAlgorithm() internal returns(uint32 luckyId,bool ok) {
        if(luckyIdsPool.length > 0){
            ok = true;
            uint256 length = luckyIdsPool.length;
            uint256 index = uint256(keccak256(msg.sender,historyWinerId.length)) % length;
            if (index != length.sub(1)) {
                uint32 lastLuckyId = luckyIdsPool[length.sub(1)];
                luckyId = luckyIdsPool[index];
                luckyIdsPool[index] = lastLuckyId;
                
            } else {
                luckyId = luckyIdsPool[length.sub(1)];
            }
            luckyIdsPool.length--;
            
        } else {
            ok = false;
            luckyId = 0;
        }
    }
    
    // 购买抽奖id
    function buyLuckyId() checkDataOk() public payable {
        uint32 luckyid;
        bool ok;
        
        (luckyid, ok) = randomAlgorithm();
        if (ok) {
            _createLuckyId(msg.sender,luckyid);
            
            if(poolOverplus() == 0) {
                uint32 drawId = lotteryDraw();
                //address winer = ownerOf(drawId);
                historyWinerId.push(drawId);
            }
        } else {
            revert();
        }
        
    }
    // 获取每期的中奖id
    function getWinerLuckyId(uint256 _curva) public view returns(uint256){
        return historyWinerId[_curva];
    }
    
    // 返回随机的中奖id
    function lotteryDraw() internal view returns(uint32) {
        
        uint256 number = totalSupply() - currPoolSize;
        uint256 whatNumber = whatNumberOfAllAddress();
        uint256 winerId = (uint256(keccak256(whatNumber)));
        
        return uint32((winerId % currPoolSize).add(10000).add(number));
        
    }
    // hash种子
    function whatNumberOfAllAddress() internal view returns(uint256) {
        uint256 length = allLuckyIds.length;
        uint256 temp = 0;
        for(uint256 i = 0; i < length; i++){
            uint32 luckyId = allLuckyIds[i];
            temp = temp.add(uint256(luckyIdOwner[luckyId]));
        }
        return temp;
    }
    // 将创建id函数在子类私有化
    function _createLuckyId(address _to, uint32 _luckyId) private{
        super._mint(_to,_luckyId);
        
        uint32 length = uint32(ownedLuckyIds[_to].length);
        ownedLuckyIds[_to].push(_luckyId);
        ownedLuckysIndex[_luckyId] = length;
    }
    // 构造函数
    function LcukyGamble() public{
        owner = msg.sender;
        //totalOfOnePool = 100;
    }
    // 检查玩家发送过来的ether
    modifier checkDataOk() {
        uint256 temp = 0.01 ether;
        require(msg.value == temp);
        //require(msg.value % temp == 0);
        _;
    }
    // fallback函数
    function() internal payable {
        revert();
    }
    // 销毁合约
    function kill() external onlyOwner{
       if (owner == msg.sender) { // 检查谁在调用
          selfdestruct(owner); // 销毁合约
       }
    }
}


