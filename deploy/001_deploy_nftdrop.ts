import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  await deploy('ERC20TokenContract', {
    from: deployer,
    log: true,
    args: ['ERC20TokenContract', 'CGT', 100],
  }); 

/*   await deploy('DAO', {
    from: deployer,
    log: true,
  });  */
};

export default func;

func.tags = ['ERC20TokenContract']; 
/* func.tags = ['DAO']; */
