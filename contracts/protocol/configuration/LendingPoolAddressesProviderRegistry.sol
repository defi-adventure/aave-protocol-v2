// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;

import {Ownable} from '../../dependencies/openzeppelin/contracts/Ownable.sol';
import {ILendingPoolAddressesProviderRegistry} from '../../interfaces/ILendingPoolAddressesProviderRegistry.sol';
import {Errors} from '../libraries/helpers/Errors.sol';

/**
 * @title LendingPoolAddressesProviderRegistry contract
 * @dev Main registry of LendingPoolAddressesProvider of multiple Aave protocol's markets
 * - Used for indexing purposes of Aave protocol's markets
 * - The id assigned to a LendingPoolAddressesProvider refers to the market it is connected with,
 *   for example with `0` for the Aave main market and `1` for the next created
 * @author Aave
 **/
contract LendingPoolAddressesProviderRegistry is Ownable, ILendingPoolAddressesProviderRegistry {
  //  provider-id映射表
  mapping(address => uint256) private _addressesProviders;
  // provider地址列表
  address[] private _addressesProvidersList;

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

  /**
   * @dev Registers an addresses provider
   * @param provider The address of the new LendingPoolAddressesProvider
   * @param id The id for the new LendingPoolAddressesProvider, referring to the market it belongs to
   **/
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

  /**
   * @dev Returns the id on a registered LendingPoolAddressesProvider
   * @return The id or 0 if the LendingPoolAddressesProvider is not registered
   */
  function getAddressesProviderIdByAddress(address addressesProvider)
    external
    view
    override
    returns (uint256)
  {
    return _addressesProviders[addressesProvider];
  }

  // 将地址加入地址列表中
  function _addToAddressesProvidersList(address provider) internal {
    // 遍历列表，如果有相同的地址，则不添加.. 就这么简单
    uint256 providersCount = _addressesProvidersList.length;

    for (uint256 i = 0; i < providersCount; i++) {
      if (_addressesProvidersList[i] == provider) {
        return;
      }
    }

    _addressesProvidersList.push(provider);
  }
}
