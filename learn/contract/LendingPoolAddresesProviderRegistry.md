### LendingPoolAddressesProviderRegistry.sol

该合约依赖了 `contracts/interfaces/ILendingPollAddressesProvidersRegistry.sol` 的接口定义

```solidity
 /**
 * @title LendingPoolAddressesProviderRegistry contract
 * @dev 多个 Aave 协议市场的 LendingPoolAddressesProvider 的主要注册表
  * - 作为Aave协议池子索引
  * - 分配给 LendingPoolAddressesProvider 的 ID关联池子，
  * 例如，Aave 主要市场为“0”，下一个创建的市场为“1”
 * @author Aave
 **/
interface ILendingPoolAddressesProviderRegistry {
  // 地址加入池子的事件
  event AddressesProviderRegistered(address indexed newAddress);
  // 地址从池子撤走的事件
  event AddressesProviderUnregistered(address indexed newAddress);

  // 获取池子中的供应者地址列表
  function getAddressesProvidersList() external view returns (address[] memory);

  // 根据地址，获取供应者的id
  function getAddressesProviderIdByAddress(address addressesProvider)
    external
    view
    returns (uint256);

  // 注册
  function registerAddressesProvider(address provider, uint256 id) external;
  // 注销
  function unregisterAddressesProvider(address provider) external;
}
```

#### 读合约
第一步，已经读过了`interface`了,所以从接口定义来看，业务的发起是从`registerAddressesProvider` 开始的，顺着这个思路往下看

##### 1. registerAddressesProvider方法
```solidity
  /**
    * @dev 注册地址提供者，没有想到这个id是传入的...
    * @param provider 新的 LendingPoolAddressesProvider 的地址
    * @param id 新的LendingPoolAddressesProvider的id，指的是它所属的市场
   **/
  function registerAddressesProvider(address provider, uint256 id) external override onlyOwner {
    // 校验，id如果为零，报错
    require(id != 0, Errors.LPAPR_INVALID_ADDRESSES_PROVIDER_ID);
    // 记录映射
    _addressesProviders[provider] = id;
    // 添加到列表
    _addToAddressesProvidersList(provider);
    // 提交事件
    emit AddressesProviderRegistered(provider);
  }
```
牵扯到的额外的方法和成员变量
```solidity
  //  provider-id映射表
  mapping(address => uint256) private _addressesProviders;
  // provider地址列表
  address[] private _addressesProvidersList;
  function _addToAddressesProvidersList(address provider) internal {
    // 就是检查一下 _addressesProvidersList 中是否有 provider，如果没有就push进去
  }
```

##### 2. unregisterAddressesProvider 方法

与 `registerAddressesProvider`对应的，需要有注销
```solidity
/**
   * @dev Removes a LendingPoolAddressesProvider from the list of registered addresses provider
   * @param provider The LendingPoolAddressesProvider address
   **/
  function unregisterAddressesProvider(address provider) external override onlyOwner {
    // 检查map中是否有 key = provider
    require(_addressesProviders[provider] > 0, Errors.LPAPR_PROVIDER_NOT_REGISTERED);
    // 设为0，0标志着无效
    _addressesProviders[provider] = 0;
    // 发布事件
    emit AddressesProviderUnregistered(provider);
  }
```
这里需要注意的是，注销并没有将map中的k-v删掉，而是单纯地将 map[k]=0,通过0值来标记一个address失效

##### 3. getAddressesProvidersList 方法

这里作为一个view类型的方法，并没有传递原始的变量内容，而是做了一些调整

```solidity
/**
   * @dev Returns the list of registered addresses provider
   * @return The list of addresses provider, potentially containing address(0) elements
   **/
  function getAddressesProvidersList() external view override returns (address[] memory) {
    // 先copy一份数据
    address[] memory addressesProvidersList = _addressesProvidersList;
    
    uint256 maxLength = addressesProvidersList.length;
    // 申请指定长度的数组
    address[] memory activeProviders = new address[](maxLength);
    // 遍历copy的数据
    for (uint256 i = 0; i < maxLength; i++) {
      // 如果 map[address] 非0 即有效，则记录对应的address
      if (_addressesProviders[addressesProvidersList[i]] > 0) {
        activeProviders[i] = addressesProvidersList[i];
      }
      // 相当于其他情况下未填充地址应该是address(0) 空地址
    }

    return activeProviders;
  }
```