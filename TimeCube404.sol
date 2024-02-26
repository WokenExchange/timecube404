// Time Cube 404 by Woken Exchange (@wokenExchange)
//
// About:
// Time Cube 404 is an experimental collection of 1000 NFTs (DN404) launched by Woken Exchange on Arbitrum chain
// Time Cube NFTs have implemented the WokenFactory interface to listen to its pair on Woken Exchange (First Custom Trading Hours DEX) 
// and display a different image for the NFTs regarding its market status on the DEX.
//
// Read more:
// https://woken.exchange/timecube404 
//
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IWokenFactory {
    function isTradingOpen(address token) external view returns (bool);
}

import {DN404} from "./DN404.sol";
import {DN404Mirror} from "./DN404Mirror.sol";
import {Ownable} from "./Ownable.sol";
import {LibString} from "./LibString.sol";
import {SafeTransferLib} from "./SafeTransferLib.sol";


contract TimeCube404 is DN404, Ownable {
    string private _name;
    string private _symbol;
    string public dataURI;
    string public baseTokenURI;
    IWokenFactory public wokenFactory;
    address public pairAddress;


    constructor(
        string memory name_,
        string memory symbol_,
        uint96 initialTokenSupply,
        address initialSupplyOwner
    ) {
        _initializeOwner(msg.sender);

        _name = name_;
        _symbol = symbol_;

        address mirror = address(new DN404Mirror(msg.sender));
        _initializeDN404(initialTokenSupply, initialSupplyOwner, mirror);
    }


    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }
   

    function withdraw() public onlyOwner {
        SafeTransferLib.safeTransferAllETH(msg.sender);
    }

    function setWokenFactory(address _wokenFactory) public onlyOwner {
        wokenFactory = IWokenFactory(_wokenFactory);
    }

    // Listen to a pair on Woken Exchange and display a different image for the NFT depending on the LP's trading status.
    // owner can edit the pairaddress to listen any Pair on the DEX
    function setPairAddress(address _pairAddress) external onlyOwner {
        pairAddress = _pairAddress;
    }

    function isLpTradingOpen() public view returns (bool) {
        return wokenFactory.isTradingOpen(pairAddress);
    }    

    function setDataURI(string memory _dataURI) public onlyOwner {
        dataURI = _dataURI;
    }

    function setTokenURI(string memory _tokenURI) public onlyOwner {
        baseTokenURI = _tokenURI;
    }

   
    function tokenURI(uint256 id) public view override returns (string memory) {
        if (bytes(baseTokenURI).length > 0) {
            return string.concat(baseTokenURI, LibString.toString(id));
        } else {
        bool tradingOpen = wokenFactory.isTradingOpen(pairAddress);
        uint8 seed = uint8(bytes1(keccak256(abi.encodePacked(id))));
        string memory image;
        string memory value;
        string memory color;
        string memory background;
        string memory rarity;
      
        if (seed >= 0 && seed <= 45) {
            image = "1";
            value = "Status Cube";
            color = "white";
            background = "white";
            rarity = "Common";
        } else if (seed >= 46 && seed <= 89) {
            image = "2";
            value = "Status Cube";
            color = "white";
            background = "gradient";
            rarity = "Common";
        } else if (seed >= 90 && seed <= 127) {
            image = "3";
            value = "Status Cube";
            color = "white";
            background = "carbon";
            rarity = "Common";
        } else if (seed >= 128 && seed <= 163) {
            image = "4";
            value = "Timekeeper";
            color = "gradient";
            background = "white";
            rarity = "Uncommon";
        } else if (seed >= 164 && seed <= 194) {
            image = "5";
            value = "Timekeeper";
            color = "gradient";
            background = "gradient";
            rarity = "Uncommon";
        } else if (seed >= 195 && seed <= 220) {
            image = "6";
            value = "Timekeeper";
            color = "gradient";
            background = "carbon";
            rarity = "Uncommon";
        } else if (seed >= 221 && seed <= 235) {
            image = "7";
            value = "Timekeeper";
            color = "blue";
            background = "carbon";
            rarity = "Rare";
        } else if (seed >= 236 && seed <= 248) {
            image = "8";
            value = "Timekeeper";
            color = "purple";
            background = "carbon";
            rarity = "Rare";
        } else if (seed >= 249 && seed <= 251) {
            image = "9";
            value = "Wagmi";
            color = "outline gradient";
            background = "gradient";
            rarity = "Ultra Rare";
        } else if (seed >= 252 && seed <= 254) {
            image = "10";
            value = "Partner";
            color = "outline gradient";
            background = "carbon";
            rarity = "Ultra Rare";
        } else if (seed == 255) {
            image = "11";
            value = "Genesis";
            color = "yellow";
            background = "carbon";
            rarity = "Legendary";
        } 

        image = string.concat(image, tradingOpen ? "a.png" : "b.png");

        string memory fullImageURI = string.concat(dataURI, image);
        string memory metadata = string.concat(
        '{"name": "Time Cube 404 #', LibString.toString(id),
        '","description":"TimeCube404, experimental DN404 NFT collection by Woken Exchange, on Arbitrum chain","external_url":"https://woken.exchange/timecube404","image":"', fullImageURI,
        '","attributes":[',
            '{"trait_type":"Cube Type","value":"', value, '"},',
            '{"trait_type":"Color","value":"', color, '"},',
            '{"trait_type":"Background","value":"', background, '"},',
            '{"trait_type":"Rarity","value":"', rarity, '"},',
            '{"trait_type":"LP Trading Status","value":"', tradingOpen ? "Open" : "Closed", '"}', 
        ']}'
    );

        return string.concat("data:application/json;utf8,", metadata);
        }
    }
}