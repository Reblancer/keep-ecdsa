pragma solidity ^0.5.4;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "@keep-network/keep-core/contracts/Rewards.sol";

contract ECDSAKeepRewards is Rewards {
    uint256 constant MAX_UINT20 = 1 << 20 - 1;
    IBondedECDSAKeepFactory factory;

    constructor (
        uint256 _termLength,
        address _token,
        uint256 _minimumKeepsPerInterval,
        address factoryAddress,
        uint256 _firstIntervalStart,
        uint256[] memory _intervalWeights
    ) public Rewards(
        _termLength,
        _token,
        _minimumKeepsPerInterval,
        _firstIntervalStart,
        _intervalWeights
    ) {
       factory = IBondedECDSAKeepFactory(factoryAddress);
    }

   function _getKeepCount() internal view returns (uint256) {
       return factory.getKeepCount();
   }

   function _getKeepAtIndex(uint256 index) internal view returns (bytes32) {
       return fromAddress(factory.getKeepAtIndex(index));
   }

   function _getCreationTime(bytes32 _keep) isAddress(_keep) internal view returns (uint256) {
       return factory.getCreationTime(toAddress(_keep));
   }

   function _isClosed(bytes32 _keep) isAddress(_keep) internal view returns (bool) {
       return IBondedECDSAKeep(toAddress(_keep)).isClosed();
   }

   function _isTerminated(bytes32 _keep) isAddress(_keep) internal view returns (bool) {
       return IBondedECDSAKeep(toAddress(_keep)).isTerminated();
   }

   function _recognizedByFactory(bytes32 _keep) isAddress(_keep) internal view returns (bool) {
       return factory.getCreationTime(toAddress(_keep)) != 0;
   }

   function _distributeReward(bytes32 _keep, uint256 amount) isAddress(_keep) internal {
       token.approve(toAddress(_keep), amount);
       IBondedECDSAKeep(toAddress(_keep)).distributeERC20Reward(
           address(token),
           amount
       );
   }

   function toAddress(bytes32 keepBytes) internal pure returns (address) {
       return address(bytes20(keepBytes));
   }

   function fromAddress(address keepAddress) internal pure returns (bytes32) {
       return bytes32(bytes20(keepAddress));
   }

   function validAddressBytes(bytes32 keepBytes) internal pure returns (bool) {
       return fromAddress(toAddress(keepBytes)) == keepBytes;
   }

   modifier isAddress(bytes32 _keep) {
       require(
           validAddressBytes(_keep),
           "Invalid keep address"
       );
       _;
   }
}

interface IBondedECDSAKeep {
    function getOwner() external view returns (address);
    function getTimestamp() external view returns (uint256);
    function isClosed() external view returns (bool);
    function isTerminated() external view returns (bool);
    function isActive() external view returns (bool);
    function distributeERC20Reward(address _erc20, uint256 amount) external;
}

interface IBondedECDSAKeepFactory {
    function getKeepCount() external view returns (uint256);
    function getKeepAtIndex(uint256 index) external view returns (address);
    function getCreationTime(address _keep) external view returns (uint256);
}