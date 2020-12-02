import { task } from 'hardhat/config';

import { UniswapRepayAdapterFactory } from '../../types';
import { verifyContract } from '../../helpers/etherscan-verification';
import { getFirstSigner } from '../../helpers/contracts-getters';

const CONTRACT_NAME = 'UniswapRepayAdapter';

task(`deploy-${CONTRACT_NAME}`, `Deploys the ${CONTRACT_NAME} contract`)
  .addFlag('verify', `Verify ${CONTRACT_NAME} contract via Etherscan API.`)
  .setAction(async ({ verify }, localBRE) => {
    await localBRE.run('set-DRE');

    if (!localBRE.network.config.chainId) {
      throw new Error('INVALID_CHAIN_ID');
    }

    console.log(`\n- ${CONTRACT_NAME} deployment`);
    const args = [
      '0x88757f2f99175387aB4C6a4b3067c77A695b0349', // lending  provider kovan address
      '0xfcd87315f0e4067070ade8682fcdbc3006631441', // uniswap router address
    ];
    const uniswapRepayAdapter = await new UniswapRepayAdapterFactory(await getFirstSigner()).deploy(
      args[0],
      args[1]
    );
    await uniswapRepayAdapter.deployTransaction.wait();
    console.log(`${CONTRACT_NAME}.address`, uniswapRepayAdapter.address);
    await verifyContract(uniswapRepayAdapter.address, args);

    console.log(
      `\tFinished ${CONTRACT_NAME}${CONTRACT_NAME}lDataProvider proxy and implementation deployment`
    );
  });