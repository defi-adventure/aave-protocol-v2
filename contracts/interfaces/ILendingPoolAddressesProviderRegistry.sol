// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;

/**
 * @title LendingPoolAddressesProviderRegistry contract
 * @dev Main registry of LendingPoolAddressesProvider of multiple Aave protocol's markets
 * - Used for indexing purposes of Aave protocol's markets
 * - The id assigned to a LendingPoolAddressesProvider refers to the market it is connected with,
 *   for example with `0` for the Aave main market and `1` for the next created
 * @author Aave
 **/
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
