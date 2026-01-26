// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

/*
   OpenZeppelin Upgradeable Contracts
  Upgradeable variants are used to support proxy-based deployments.
  Constructors are replaced with initializer functions.
 */
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/*
  title ACTXToken 
  notice
  ACTXToken is a UUPS-upgradeable ERC20 token that implements:
  - Transfer tax (basis points)
  - On-chain reward pool funded by tax
  - Controlled reward distribution
  - Secure upgrade authorization
 
  dev
  - Uses UUPS proxy pattern (ERC1967)
  - Storage layout must never be reordered or removed in upgrades
  - Designed for auditability and production readiness
 */
contract ACTXToken is
    Initializable,
    ERC20Upgradeable,
    AccessControlUpgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable
{
    //                         ROLES

    /*
      @notice Role allowed to distribute rewards from the reward pool
      @dev Separate from ownership to allow operational flexibility
     */
    bytes32 public constant REWARD_MANAGER_ROLE =
        keccak256("REWARD_MANAGER_ROLE");

    //                  STATE VARIABLES

    /*
      notice Transfer tax expressed in basis points (e.g. 200 = 2%)
     */
    uint256 public taxRateBasisPoints;

    /*
     notice Accumulated reward pool funded by transfer tax
     */
    uint256 public rewardPool;

    //                             EVENTS

    event RewardDistributed(address indexed user, uint256 amount);
    event TaxUpdated(uint256 newTax);

    //                          INITIALIZER

    /*
      notice Initializes the token contract (replaces constructor)
     
      dev
      - Can only be called once
      - Sets up ERC20 metadata
      - Configures access control and ownership
      - Initializes UUPS upgrade mechanism
     
      param treasury Address receiving initial token supply
      param initialTax Initial transfer tax (basis points)
     */
    function initialize(
        address treasury,
        uint256 initialTax
    ) public initializer {
        require(treasury != address(0), "Invalid treasury");
        require(initialTax <= 500, "Max tax is 5%");

        // Initialize parent contracts
        __ERC20_init("ACT.XToken", "ACTX");    //  token name
        __AccessControl_init();
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        // Grant administrative roles to deployer
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(REWARD_MANAGER_ROLE, msg.sender);

        // Configure initial tax rate
        taxRateBasisPoints = initialTax;

        // Mint fixed initial supply to treasury
        _mint(treasury, 100_000_000 ether);
    }

    //                      REWARD MANAGEMENT

    /*
      notice Distributes rewards from the on-chain reward pool
     
      dev
      - Rewards originate exclusively from collected transfer tax
      - Protected against reentrancy
      - Callable only by authorized reward managers
     
      param user Address receiving the reward
      param amount Amount of tokens to distribute
     */
    function distributeReward(
        address user,
        uint256 amount
    )
        external
        onlyRole(REWARD_MANAGER_ROLE)
        nonReentrant
    {
        require(user != address(0), "Invalid user");
        require(amount <= rewardPool, "Insufficient reward pool");

        // Update accounting before transfer (checks-effects-interactions)
        rewardPool -= amount;

        // Transfer reward from contract balance
        _transfer(address(this), user, amount);

        emit RewardDistributed(user, amount);
    }

    //                      ADMINISTRATIVE LOGIC

    /*
      notice Updates the transfer tax rate
     
      dev
      - Restricted to contract owner
      - Upper bound prevents abusive taxation
     
      param newRate New tax rate in basis points
     */
    function setTaxRate(uint256 newRate) external onlyOwner {
        require(newRate <= 500, "Max tax is 5%");
        taxRateBasisPoints = newRate;

        emit TaxUpdated(newRate);
    }

    //                    ERC20 INTERNAL MECHANICS

    /*
      notice Internal token accounting hook (OpenZeppelin v5)
     
      dev
      - Executes on every mint, burn, and transfer
      - Applies tax only to regular transfers
      - Tax is retained by the contract and added to reward pool
     
      param from Sender address (zero on mint)
      param to Recipient address (zero on burn)
      param amount Token amount involved
     */
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override {
        // Skip taxation on minting, burning, or when tax is disabled
        if (from == address(0) || to == address(0) || taxRateBasisPoints == 0) {
            super._update(from, to, amount);
            return;
        }

        // Calculate tax and net transfer amount
        uint256 tax = (amount * taxRateBasisPoints) / 10_000;
        uint256 remaining = amount - tax;

        // Collect tax into contract and update reward pool
        if (tax > 0) {
            super._update(from, address(this), tax);
            rewardPool += tax;
        }

        // Transfer remaining tokens to recipient
        super._update(from, to, remaining);
    }

    //                    UPGRADE AUTHORIZATION
    /*
      notice Authorizes implementation upgrades (UUPS requirement)
     
      dev
      - Called internally by upgrade functions
      - Restricted to contract owner to prevent unauthorized upgrades
     */
    function _authorizeUpgrade(address)
        internal
        override
        onlyOwner
    {}
}
