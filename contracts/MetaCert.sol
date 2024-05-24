//SPDX-License-Identifier: MIT
//contracts/MetaCert.sol

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MetaCert is Ownable, ERC721URIStorage {

    constructor() Ownable(msg.sender) ERC721("MetaCert certs", "MCC") {
        _nextTokenId = 0;
        _nextIssuerUid = 0;
    }

    //events
    event certMinted(uint256 _tokenUid);

    //state vars
    struct Issuer {
        address account_address;
        string name;
        string issuer_address;
        uint256 issuer_uid_govt;
    }

    uint256 private _nextTokenId;
    uint256 private _nextIssuerUid;

    mapping(uint256 => Issuer) public IssuerMapping;

    //modifiers
    modifier registerIssuerMod(string memory _name, string memory _issuerAddress, uint256 _issuerUidGovt, uint256 _isVerified) {
        require(_isVerified == 1, "Issuer must be verified");
        require(bytes(_name).length > 0, "Issuer must have a name");
        require(bytes(_issuerAddress).length>0, "issuer physical address is required");
        _;
    }

    modifier mintCertMod(uint256 _issuerUid, address _to, string calldata _uri) {
        require(bytes(IssuerMapping[_issuerUid].name).length > 0, "Issuer not found");
        require(bytes(_uri).length > 0, "Must have a uri");
        _;
    }

    //functions
    function registerIssuer(string memory _name, string memory _issuerAddress, uint256 _issuerUidGovt, uint256 _isVerified) registerIssuerMod(_name, _issuerAddress, _issuerUidGovt, _isVerified) public returns(uint256) {

        Issuer memory i = Issuer(msg.sender, _name, _issuerAddress, _issuerUidGovt);
        IssuerMapping[_nextIssuerUid] = i;
        _nextIssuerUid = _nextIssuerUid+1;

        return _nextIssuerUid-1;
    }

    function mintCert(uint256 _issuerUid, address _to, string calldata _uri) mintCertMod(_issuerUid, _to, _uri) public returns(bool) {
        _mint(_to, _nextTokenId);
        _setTokenURI(_nextTokenId, _uri);
        emit certMinted(_nextTokenId);
        _nextTokenId = _nextTokenId+1;
        return true;
    }

    function verifyCert(address _addHolder, uint256 _tokenUid) public view returns(bool) {
        if (ownerOf(_tokenUid) == _addHolder) {
            return true;
        } else {
            return false;
        }
    }
}
