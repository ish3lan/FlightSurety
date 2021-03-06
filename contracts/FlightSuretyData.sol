pragma solidity ^0.4.25;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;
    using SafeMath for uint;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;                                      // Account used to deploy contract
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false

    mapping (address=>bool) private authorizedCallers;

    struct Airline{
        bool exists;
        bool registered;
        bool funded;
        bytes32[] flightKeys;
        Votes votes;
    }

    struct Votes{
        uint votersCount;
        mapping(address => bool) voters;
    }

    uint private airlinesCount = 0;
    uint private registeredAirlinesCount = 0;
    uint private fundedAirlinesCount = 0;
    
    mapping(address => Airline) private airlines;

    event AirlineExist(address airlineAddress, bool exist);
    event AirlineRegistered(address airlineAddress, bool exist, bool registered);
    event AirlineFunded(address airlineAddress, bool exist, bool registered, bool funded, uint fundedCount);

    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/


    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor
    (
        address airlineAddress
        ) 
    public 
    {
        contractOwner = msg.sender;
        airlines[airlineAddress] = Airline({
            exists:true,
            registered:true, 
            funded: false,
            flightKeys: new bytes32[](0),
            votes: Votes(0)
            });

        airlinesCount = airlinesCount.add(1);
        registeredAirlinesCount = registeredAirlinesCount.add(1);
        // fundedAirlinesCount = fundedAirlinesCount.add(1);
        emit AirlineExist(airlineAddress,  airlines[airlineAddress].exists);
        emit AirlineRegistered( airlineAddress,  airlines[airlineAddress].exists, airlines[airlineAddress].registered);
        // emit AirlineFunded( airlineAddress,  airlines[airlineAddress].exists, airlines[airlineAddress].registered, airlines[airlineAddress].funded);

    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in 
    *      the event there is an issue that needs to be fixed
    */
    modifier requireIsOperational() 
    {
        require(operational, "Contract is currently not operational");
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    /**
    * @dev Modifier that requires the airline address to be presend in airlines array
    */
    modifier requireAirLineExist(address airlineAddress) 
    {
        require(airlines[airlineAddress].exists, "Airline does not existed in requireAirLineExist");
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the airline address to be registered in airlines array
    */
    modifier requireAirLineRegistered(address airlineAddress) 
    {
        require(airlines[airlineAddress].exists, "Airline does not existed in requireAirLineRegistered");
        require(airlines[airlineAddress].registered, "Airline is not registered in requireAirLineRegistered");
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the airline address to be funded in airlines array
    */
    modifier requireAirLineFunded(address airlineAddress) 
    {
        require(airlines[airlineAddress].exists, "Airline does not existed in requireAirLineFunded");
        require(airlines[airlineAddress].registered, "Airline is not registered in requireAirLineFunded");
        require(airlines[airlineAddress].funded, "Airline is not funded in requireAirLineFunded");

        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */      
    function isOperational() 
    public 
    view 
    returns(bool) 
    {
        return operational;
    }


    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */ 
    function setOperatingStatus

    (
        bool mode
        ) 
    external
    requireContractOwner 

    {
        operational = mode;
    }


    function authorizeCaller(address contractAddress)
    external
    requireContractOwner
    {
        authorizedCallers[contractAddress] = true;
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

   /**
    * @dev Add an airline to the registration queue
    *      Can only be called from FlightSuretyApp contract
    *
    */   
    function registerAirline
    (
        address airlineAddress,
        bool registered
        )
    requireIsOperational
    external
    {
        airlines[airlineAddress] = Airline(
        {
            exists: true,
            registered:registered, 
            funded:false,
            flightKeys: new bytes32[](0),
            votes: Votes(0)
            });
        emit AirlineExist(airlineAddress,  airlines[airlineAddress].exists);

        airlinesCount = airlinesCount.add(1);
        if(registered){
            registeredAirlinesCount = registeredAirlinesCount.add(1);
            emit AirlineRegistered( airlineAddress,  airlines[airlineAddress].exists, airlines[airlineAddress].registered);
        }
    }


    function airlineExists(address airlineAddress)
    external
    view
    returns(bool)
    {
        return airlines[airlineAddress].exists;
    }


    function airlineRegistered(address airlineAddress)
    external
    view
    returns(bool)
    {
        if (airlines[airlineAddress].exists){
            return airlines[airlineAddress].registered;
        }
        return false;
    }
    function airlineFunded(address airlineAddress)
    external
    view
    returns(bool)
    {
        require(airlines[airlineAddress].funded, "Airline is not funded in airlineFunded");
        return airlines[airlineAddress].funded;
    }


   /**
    * @dev Buy insurance for a flight
    *
    */   
    function buy
    (                             
        )
    external
    payable
    {

    }

    /**
     *  @dev Credits payouts to insurees
     */
     function creditInsurees
     (
        )
     external
     pure
     {
     }


    /**
     *  @dev Transfers eligible payout funds to insuree
     *
     */
     function pay
     (
        )
     external
     pure
     {
     }

   /**
    * @dev Initial funding for the insurance. Unless there are too many delayed flights
    *      resulting in insurance payouts, the contract should be self-sustaining
    *
    */   
    function fund
    (address airlineAddress)
    public
    payable
    requireIsOperational
    requireAirLineRegistered(airlineAddress)
    {
        require(msg.value >= 1 ether, "No suffecient funds supplied");
        airlines[airlineAddress].funded = true;
        fundedAirlinesCount = fundedAirlinesCount.add(1);
        emit AirlineFunded( airlineAddress,  airlines[airlineAddress].exists, airlines[airlineAddress].registered,  airlines[airlineAddress].funded, fundedAirlinesCount );

    }

    function getFlightKey
    (
        address airline,
        string memory flight,
        uint256 timestamp
        )
    pure
    internal
    returns(bytes32) 
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
    function() 
    external 
    payable 
    {
        fund(msg.sender);
    }



    function getFundedAirlinesCount()
    requireIsOperational
    view
    returns(uint)
    {
        return fundedAirlinesCount;
    }
}

