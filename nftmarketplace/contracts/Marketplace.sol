// SPDX-License-Identifier: MIT

// pragma - enforce compiler checks - like declaring compiler version.
pragma solidity ^0.8.20;

// what to import - search and then copy the suitable one.
// is library mai se smart contracts import kr rahe jinko extend kr rahe  
// wrna scratch se krna parta , yaha pai inke conventional , checked by ethereum. 
import "@openzeppelin/contracts/token/ERC721/ERC721.sol" ;

import "@openzeppelin/contracts/utils/Counters.sol" ; // Counter ka , will be managing overflow
// Although now not necessary , para tha kahi . Handle kaise kar rahe nahi pata

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// might be useful
//import "./node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";        

// It is standard code i found in the documentation to make the developer start
// for managing non-trivial tasks regarding subscription as per ERC5643 standard.  
contract SubscriptionModel {
    mapping(uint256 => uint64) internal _expirations; // NFT ke token IDs ka expiration time

    /// @notice Emitted when a subscription expiration changes
    /// @dev When a subscription is canceled, the expiration value should also be 0.
    event SubscriptionUpdate(uint256 indexed tokenId, uint64 expiration);

    /// @notice Renews the subscription to an NFT
    /// Throws if `tokenId` is not a valid NFT
    /// @param _tokenId The NFT to renew the subscription for
    /// @param duration The number of seconds to extend a subscription for
    function renewSubscription( 
        uint256 _tokenId,uint64 duration
    ) external payable {
        uint64 currentExpiration = _expirations[_tokenId];
        uint64 newExpiration;

        if (currentExpiration == 0) { // subscription creation
            //block.timestamp -> Current block timestamp as seconds since unix epoch [1 January , 1970]
            // Todo
            newExpiration = uint64(block.timestamp) + duration; 
        } else {
            require(isRenewable(_tokenId), "Subscription Not Renewable");
            newExpiration = currentExpiration + duration;
        }

        _expirations[_tokenId] = newExpiration; // local
        emit SubscriptionUpdate(_tokenId, newExpiration); // chain
    }

    /// @notice Cancels the subscription of an NFT
    /// @dev Throws if `tokenId` is not a valid NFT
    /// @param _tokenId The NFT to cancel the subscription for
    function cancelSubscription(uint256 _tokenId) external payable {
        // to Ig getOrDefault(_tokenId,0) hota hai , jo renew mai chalta hai.
        delete _expirations[_tokenId];
        emit SubscriptionUpdate(_tokenId, 0);
    }

    /// @notice Gets the expiration date of a subscription
    /// @dev Throws if `tokenId` is not a valid NFT
    /// @param _tokenId The NFT to get the expiration date of
    /// @return The expiration date of the subscription
    function expiresAt(uint256 _tokenId) external view returns (uint64) {
        return _expirations[_tokenId];
    }

    /// @notice Determines whether a subscription can be renewed
    /// @dev Throws if `tokenId` is not a valid NFT
    /// @param _tokenId The NFT to get the expiration date of
    /// @return The renewability of a the subscription - true or false
    function isRenewable(uint256 _tokenId) public pure returns (bool) {
        return true;
    }
}

// In sb ke sare function use bhi to krne hai jo yaha implement kiya hai 
// Hence hamare api.json file mai. Isliye sbke wrapper function in provider.

// is krke inherit. there is a limit to the lines of code in a contract , isliye modularity necessary
contract Marketplace is SubscriptionModel , ERC721URIStorage{
    // Initialising the name and symbol of project to define my NFTs. 
    constructor () ERC721("NFT Magazine and Marketplace" , "M") {
        tokenIds.increment();
        userIds.increment();
    } // The constructor is executed during the deployment of the smart contract. 

    // hota hai na jo module import kiya hai usmai se ye class use kro.
    using Counters for Counters.Counter;
    // al static kind of , fr the entire smart contract.
    Counters.Counter private tokenIds;
    Counters.Counter private nftsAvailableForSale;
    Counters.Counter private userIds;
    
    /// @dev design of how the state of created nft would be. UI being a function of state.
    struct nftStruct {
        uint256 tokenId;
        // payable means it can hold and transact in ether
        address payable seller; //- Initial
        address payable owner; // Phle seller owner - then Smart contract owner
        
        uint256 price;
        
        address[] subscribers;
        uint256 likes;

        string title;
        string description;
        string tokenUri; // Always better , File to impossible
    }

    struct profileStruct {
        address self;
        address[] followers;
        address[] following;
    }

    // same hi hoga na - ye to actually create logs on the blockchain networks
    event NftStructCreated(
        // usmai fields the , isliye semicolon.
        // yaha pai like parameter hai.
        uint256 indexed tokenId,
        address payable seller,
        address payable owner,
        uint256 price,
        address[] subscribers,
        uint256 likes,
        string title,
        string description
    );

    // read as --> HashMap<Integer,UserStruct> NFTs ;
    mapping(uint256 => nftStruct) private nfts ;
    //it is a temp storage , does not consumes gas.
    mapping(uint256 => profileStruct) public profiles;

    function getNumberOfUsers() public view returns(uint256){
        uint256 noOfUsers = userIds.current();
        return noOfUsers;
    }
    
    /// @dev this function mints received NFTs
    /// @param _tokenURI the new token URI for the magazine cover
    /// @param _title the name of the magazine cover
    /// @param _description detailed information on the magazine NFT
    // /// @return tokenId of the created NFT
    function createNFT(string memory _tokenURI , string memory _title , string memory _description) public {
        //tokenIds.increment();
        uint256 newTokenId = tokenIds.current();
        
        // for linking token to the user.
        _mint(msg.sender, newTokenId);
        // for linking token to the NFT
        _setTokenURI(newTokenId, _tokenURI); 

        setNft(newTokenId, _title, _description,_tokenURI);
        tokenIds.increment();
        // no return here as of now
    }

    function setNft(uint256 _tokenId,string memory _title,string memory _description,string memory _tokenURI) 
    private {
        // set krne ke liye hai , isse baar baar data change kr skte hai.
        nfts[_tokenId].tokenId = _tokenId;
        nfts[_tokenId].seller = payable(msg.sender);
        nfts[_tokenId].owner = payable(msg.sender);
        nfts[_tokenId].price = 0;
        nfts[_tokenId].likes = 1;
        nfts[_tokenId].title = _title;
        nfts[_tokenId].description = _description;
        nfts[_tokenId].tokenUri = _tokenURI;
        //nfts[_tokenId].subscribers = [msg.sender] ;
        // if we would have fetched every time from blockchain
        // it would cost gas , therefore storing in state variable
        // with whom we can interact whenever possible.

        emit NftStructCreated(_tokenId,payable(msg.sender),payable(msg.sender),
            0,nfts[_tokenId].subscribers,nfts[_tokenId].likes,
            _title,_description
        );
    }

    /// @dev sell a magazine subscription to the public so that's visible to the nft marketplace
    /// @param _tokenId the TokenID of the Nft Magazine
    /// @return total number of available nft subscriptions

    // when some one buys subscription , they can access the magazine.
    function sellSubscription(uint256 _tokenId, uint64 duration) 
    public payable returns (uint256) {
        /// Requirement mai function recognise nhi ho raha tha ,
        // waise bhi jyada need nahi iski to rhne diya hai abhi ke liye
        require(
            _isAuthorized(ownerOf(_tokenId),msg.sender,_tokenId),
            "Only NFT owner can perform this"
        );

        // ye msg.sender global variable hota hai that we can access
        // this represents tha smart contract, ye parent contract jo sb regulate , sare functions.
        _transfer(msg.sender, address(this), _tokenId); // smart contract mai chala jata hai na
        // yahi karan tha ki seller aur owner alag rakhne pre variables.
        // Ye by ether to convert to ether
        nfts[_tokenId].price = msg.value / (1 ether) ;
        nfts[_tokenId].owner = payable(address(this)); // apne local mai bhi to karna
        _expirations[_tokenId] = duration;
        nftsAvailableForSale.increment();
        return nftsAvailableForSale.current();
    }

    /// @dev buy a magazine subscription from the marketplace
    /// @param _tokenId the Token ID of the NFT Magazine
    /// @return true
    // ispai lagega payabale modifier
    function buySubscription(uint256 _tokenId) public payable returns (bool) {
        // ye msg jo function invoker - usko represent
        //uint256 price = nfts[_tokenId].price;
        //require( // heart of smart contracts , automated checking and then subsequent transaction too
        //    msg.value == price,"Please send the asking price in order to complete the purchase"
        //);
        // Todo - yaha pai khali transfer ho raha hai seller ko, 
        // real transaction
        payable(nfts[_tokenId].seller).transfer(msg.value);
        // changes locally
        nfts[_tokenId].subscribers.push(msg.sender);

        // these functions are essentially transaction
        // so they hold property of atomicity.
        return true;
    }

    /// @dev fetch available NFTs on sale that will be displayed on the marketplace
    /// @return nftStruct[] list of nfts with their metadata
    
    // ismai view modifier to - phle hi declare ki no mutability
    // for optimisation (like const) ki ye to gas nahi hi lega
    function getSubscriptions() public view returns (nftStruct[] memory) {
        uint256 nftCount = tokenIds.current();
        nftStruct[] memory nftSubs = new nftStruct[](nftCount);
        for (uint256 i = 1; i < nftCount; i++) {
            // all those nfts jo smart contract mai dal gaye hai
            // sale pai , else seller ke pass hi oownership hogi
            // mtlb usnai abhi sale pai nahi lagaya hai
            if (nfts[i].owner == address(this)) {
                nftSubs[i] = nfts[i]; // ye al.add() jaisa hi hai.
            }
        }
        return nftSubs;
    }
      
    /// @dev fetches NFT magazines that a specific user is already subscribed to
    /// @return nftStruct[] list of the nfts collected by a user with their metadata
    function getCollectables() public view returns (nftStruct[] memory) {
        uint256 nftCount = tokenIds.current(); 
        /// Ye yaar kahi pai naam clash kar raha tha , isliye
        nftStruct[] memory nftSubs = new nftStruct[](nftCount);

        for (uint256 i = 1; i < nftCount; i++) { // going to each nft(irrespective of whether on sale or not - 
        // kya pata ab sale close ya available subscription khatam)
            uint256 subscribers = nfts[i].subscribers.length;
            for (uint256 j = 0; j < subscribers; j++) { 
                // us nft ki subscriber list mai mera naam.
                if ( nfts[i].subscribers[j] == msg.sender ) {
                    nftSubs[i] = nfts[i]; // phle workable then optimisation :)
                }
            }
        }
        return nftSubs;
    } 

    // Ye sb system design se hi , user(s) ke view se socha kya kya requirement par skti hai
    // Wo Wo function banaye

    /// @dev fetches NFT magazines that a specific user has created
    /// @return nftStruct[] list of nfts created by a user with their metadata
    function getNfts() public view returns (nftStruct[] memory) {
        uint256 nftCount = tokenIds.current();
        nftStruct[] memory nftSubs = new nftStruct[](nftCount);
        for (uint256 i = 1; i < nftCount; i++) {
            if (nfts[i].seller == payable(msg.sender) ) {// yaha pai seller se
                nftSubs[i] = nfts[i];
            }
        } 
        return nftSubs;
    } 

    /// @dev fetches details of a particular NFT magazine subscription
    /// @param _tokenId The token ID of the NFT Magazine
    /// @return nftStruct NFT data of the specific token ID
    function getIndividualNFT(uint256 _tokenId) public view returns (nftStruct memory) {
        return nfts[_tokenId]; // Ek NFT item (object) return krega
    }   
 
    /// @notice Yaha se profile kr karunga baad mai
    ///@notice this respresents user onboarding
    /// @dev adds msg.sender as the profile
    function addProfile() public {
        
        uint256 newUserId = userIds.current();
        
        bool checkIfExists = false;
        for (uint256 i = 1; i < newUserId; i++) {
            if (profiles[i].self == msg.sender)
            checkIfExists = true;
        }

        if(!checkIfExists){
            profiles[newUserId].self = msg.sender;
        }
    
        userIds.increment();
        // declaration upar and unki filling idhar , aisa chalta hai.
        // phle return kr rahe the ab need nahi lagi.
    }

    /// @dev increment the following tag of the profile performing the action, and the follower tag of the profile that user wants to follow
    /// @param _account The account the user wants to follow
    function followProfile(address _account) public {
        //console.log(_account);
        //console.log(msg.sender);
        uint256 totalCount = userIds.current();
        //console.log(totalCount);
        for (uint256 i = 1; i < totalCount; i++) {
            //console.log(profiles[i].self);

            if (profiles[i].self == msg.sender) {
                //console.log("yes");
                profiles[i].following.push(_account);
                
                //console.log(profiles[i].following.length);
            }
            else if (profiles[i].self == _account) {
                profiles[i].followers.push(msg.sender);
            }
            //console.log(profiles[i].self);
            //console.log(profiles[i].following.length);
        }
    }

    /// @dev decrement the following tag of the profile performing the action, and the follower tag of the profile that the user to unfollow
    /// @param _account The account the user wants to unfollow
    function unfollowProfile(address _account) public view {
        uint256 totalCount = userIds.current();
        for (uint256 i = 1; i < totalCount; i++) {
            removeFollowing(profiles[i].self, profiles[i].followers, _account);
            removeFollower(
                profiles[i].self,
                profiles[i].following,
                payable(msg.sender)
            );
        }
    }

    function removeFollowing(
        address _owner,
        address[] memory _followers,
        address _account
    ) private view {
        if (_owner == _account) {
            address[] memory currentFollowing = _followers;
            for (uint256 j = 0; j < currentFollowing.length; j++) {
                if (currentFollowing[j] == payable(msg.sender)) {
                    delete currentFollowing[j];
                }
            }
        }
    }

    function removeFollower(
        address _owner,
        address[] memory _following,
        address _account
    ) private pure {
        if (_owner == _account) {
            address[] memory currentFollowers = _following;
            for (uint256 j = 0; j < currentFollowers.length; j++) {
                if (currentFollowers[j] == _account) {
                    delete currentFollowers[j];
                }
            }
        }
    }

    /// @notice postScript 

    /// @dev increments number of likes for a NFT Magazine by 1
    /// @param _tokenId the Token ID of the NFT Magazine
    function likeSubscription(uint256 _tokenId) public {
        nfts[_tokenId].likes += 1;
    }

    /// @dev decrement number of likes for a NFT Magazine by 1
    /// @param _tokenId the Token ID of the NFT Magazine
    function unlikeSubscription(uint256 _tokenId) public {
        nfts[_tokenId].likes -= 1;
    }

}
