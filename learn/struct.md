# AAVE 合约学习

## 从部署脚本看起合约的入口

### 1. tasks/full/0_address_provider_registry.ts

第一个部署的合约：

```typescript
// 方法：
// deployLendingPoolAddressesProviderRegistry
// 部署的合约内容
export const deployLendingPoolAddressesProviderRegistry = async (verify?: boolean) =>
  withSaveAndVerify(
    await new LendingPoolAddressesProviderRegistryFactory(await getFirstSigner()).deploy(),
    eContractid.LendingPoolAddressesProviderRegistry,
    [],
    verify
);


```

其中 `getFirstSigner` 方法指向了一个重要的配置文件 `contracts-getter`
这个方法目前作用暂且布标

`eContractid.LendingPoolAddressesProviderRegistry` 这个才是核心的合约
指向 `LendingPoolAddressesProviderRegistry` 合约

合约内容在
`contracts/protocol/configuration/LendingPoolAddressesProviderRegistry`中

我们可以看一下这个合约在干什么

合约解析：
[./contract/LendingPoolAddressesProviderRegistry.md](./contract/LendingPoolAddresesProviderRegistry.md)