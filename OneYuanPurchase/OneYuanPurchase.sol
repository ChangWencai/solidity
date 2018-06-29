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
    
    
    mapping(uint32 => address) internal luckyIdOwner;
    
    //mapping(address => uint256) internal ownedluckIdCount;
    
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
    function ownerOf(uint32 _luckyId) public view returns (address) {
        address owner = luckyIdOwner[_luckyId];
        require(owner != address(0));
        return owner;
    }
    
    function exists(uint32 _luckyId) public view returns (bool) {
        address owner = luckyIdOwner[_luckyId];
        return owner != address(0);
    }
    
    function _mint(address _to, uint32 _luckyId) internal {
        require(_to != address(0));
        addLuckyIdTo(_to, _luckyId);
        emit createNewLuckyId(_to,_luckyId);
    }
    function addLuckyIdTo(address _to, uint32 _luckyId) internal {
        require(luckyIdOwner[_luckyId] == address(0));
        luckyIdOwner[_luckyId] =_to;
        //ownedluckIdCount[_to] = ownedluckIdCount[_to].add(1);
    }
    
    function _burn(address _owner, uint32 _luckyId) internal {
        removeLuckyIdFrom(_owner, _luckyId);
        emit destroyOldLuckyId(_owner, _luckyId);
    }
    
    function removeLuckyIdFrom(address _from, uint32 _luckyId) internal {
        require(ownerOf(_luckyId) == _from);
        //ownedluckIdCount[_from] = ownedluckIdCount[_from].sub(1);
        delete luckyIdOwner[_luckyId];
    }
}


contract luckyInfo is BasicGamble {
    using SafeMath32 for uint32;
    using SafeMath for uint256;
    
    mapping(address => uint32[]) internal ownedLuckyIds;
    
    mapping(uint32 => uint32) internal ownedLuckysIndex;
    
    uint32[] internal allLuckyIds;
    
    mapping(uint32 => uint32) internal allLuckysIndex;
    
    /*
    function luckyOfOwnerByIndex(address _owner, uint256 _index) public view returns(uint256) {
        require(_index < balanceOf(_owner));
        return ownedLuckyIds[_owner][_index];
    }
    */
    
    function totalSupply() public view returns (uint256) {
        return allLuckyIds.length;
    }
    
    function luckyIdByIndex(uint256 _index) public view returns (uint32) {
        require(_index < totalSupply());
        return allLuckyIds[_index];
    }
    
    function addLuckyIdTo(address _to, uint32 _luckyId) internal {
        super.addLuckyIdTo(_to, _luckyId);
        uint32 length = uint32(ownedLuckyIds[_to].length);
        ownedLuckyIds[_to].push(_luckyId);
        ownedLuckysIndex[_luckyId] = length;
    }
    
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
    
    function _mint(address _to, uint32 _luckyId) internal {
        super._mint(_to, _luckyId);
        
        allLuckysIndex[_luckyId] = uint32(allLuckyIds.length);
        allLuckyIds.push(uint32(_luckyId));
    }
    
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


contract LcukyGamble is luckyInfo, Ownable {
    using SafeMath32 for uint32;
    using SafeMath for uint256;
    uint32[] internal luckyIdsPool;
    uint256 internal currPoolSize;
    
    struct winerInfo{
        address userAddr;
        uint256 luckyIds;
    }
    winerInfo[] private historyWinerArr;
    event transfer(address indexed _owner, uint256 _luckyId);
    
    function disposeAll() external onlyOwner {
        //require(totalSupply() > 0);
        //require(pooloverplus() == 0);
        uint256 length = totalSupply();
        for (uint256 i = length.sub(1); i >= 0; i--) {
            uint32 _luckyid = allLuckyIds[i];
            
            address _owner = luckyIdOwner[_luckyid];
            
            delete luckyIdOwner[_luckyid];
            
            uint32 luckyIdIndex = ownedLuckysIndex[_luckyid];
            uint256 lastLuckyIdIndex = ownedLuckyIds[_owner].length.sub(1);
            uint32 lastLuckyId = ownedLuckyIds[_owner][lastLuckyIdIndex];
            
            ownedLuckyIds[_owner][luckyIdIndex] = lastLuckyId;
            delete ownedLuckyIds[_owner][lastLuckyIdIndex];
            ownedLuckyIds[_owner].length--;
            delete ownedLuckysIndex[_luckyid];
            ownedLuckysIndex[uint32(lastLuckyId)] = luckyIdIndex;
            
            uint32 AllLuckyIdIndex = allLuckysIndex[_luckyid];
            uint256 lastAllLuckyIdIndex = allLuckyIds.length.sub(1);
            uint32 lastAllLuckyId = allLuckyIds[lastAllLuckyIdIndex];
            
            allLuckyIds[AllLuckyIdIndex] = lastAllLuckyId;
            delete allLuckyIds[lastAllLuckyIdIndex];
            
            allLuckyIds.length--;
            delete allLuckysIndex[_luckyid];
            allLuckysIndex[lastAllLuckyId] = AllLuckyIdIndex;
            
        }
    }
    function disposeById(uint32 _luckyId,address _from) external onlyOwner {
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
    
    
    
    function removeLuckyIdFrom(uint32 _luckyId, address _owner) external onlyOwner{
        super.removeLuckyIdFrom(_owner, _luckyId);
    }
    function burn(uint32 _luckyId, address _owner) external onlyOwner{
        super._burn(_owner, _luckyId);
    }
    
    
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
            emit createNewLuckyId(msg.sender, i.add(10000).add(total));
        }
    }
    
    
    
    function poolOverplus() public view returns(uint256) {
        return luckyIdsPool.length;
    }
    
    
    
    function randomAlgorithm() internal returns(uint32 luckyId,bool ok) {
        if(luckyIdsPool.length > 0){
            ok = true;
            uint256 length = luckyIdsPool.length;
            uint256 index = uint256(keccak256(msg.sender,historyWinerArr.length)) % length;
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
    
    function buyLuckyId() checkDataOk() public payable {
        uint32 luckyid;
        bool ok;
        
        (luckyid, ok) = randomAlgorithm();
        if (ok) {
            _createLuckyId(msg.sender,luckyid);
            
            if(poolOverplus() == 0) {
                uint32 drawId = lotteryDraw();
                address winer = ownerOf(drawId);
                historyWinerArr.push(winerInfo(winer,drawId));
            }
        } else {
            revert();
        }
        
    }
    
    function getWinerLuckyId(uint256 _curva) public view returns(uint256){
        return historyWinerArr[_curva].luckyIds;
    }
    function getWiner(uint256 _curva)public view returns(address){
        return historyWinerArr[_curva].userAddr;
    }
    
    function lotteryDraw() internal view returns(uint32) {
        
        uint256 number = totalSupply() - currPoolSize;
        uint256 whatNumber = whatNumberOfAllAddress();
        uint256 winerId = (uint256(keccak256(whatNumber)));
        
        return uint32((winerId % currPoolSize).add(10000).add(number));
        
    }
    
    function whatNumberOfAllAddress() internal view returns(uint256) {
        uint256 length = allLuckyIds.length;
        uint256 temp = 0;
        for(uint256 i = 0; i < length; i++){
            uint32 luckyId = allLuckyIds[i];
            temp = temp.add(uint256(luckyIdOwner[luckyId]));
        }
        return temp;
    }
    
    function _createLuckyId(address _owner, uint32 _luckyId) internal{
        super._mint(_owner,_luckyId);
    }
    
    function LcukyGamble() public{
        owner = msg.sender;
        //totalOfOnePool = 100;
    }
    
    modifier checkDataOk() {
        uint256 temp = 0.01 ether;
        require(msg.value == temp);
        //require(msg.value % temp == 0);
        _;
    }
    function() internal payable {
        revert();
    }
    
    function kill() external onlyOwner{
       if (owner == msg.sender) { // 检查谁在调用
          selfdestruct(owner); // 销毁合约
       }
    }
}

