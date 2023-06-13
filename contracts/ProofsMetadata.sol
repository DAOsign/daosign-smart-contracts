// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

// import "hardhat/console.sol";

import { Strings } from './libs/Strings.sol';
import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';

contract ProofsMetadata is Ownable {
    using Strings for string;

    event MetadataAdded(string indexed name, string indexed version, string metadata);
    event MetadataUpdated(string indexed name, string indexed version, string metadata);

    // proof name -> version -> metadata itself
    mapping(string => mapping(string => string)) public proofsMetadata;
    // proof name -> history of versions
    mapping(string => string[]) public metadataVersions;

    /**
     * Get number of versions that exist for metadata by its name
     * @param name Name of metadata. As for now, it's Proof-of-Authority, Proof-of-Signature, and
     *             Proof-of-Agreement.
     * @return numVersions Number of versions.
     */
    function getMetadataNumOfVersions(string memory name) public view returns (uint256) {
        return metadataVersions[name].length;
    }

    /**
     * Add metadata by the contract administrator.
     * @param name Name of metadata. As for now, it's Proof-of-Authority, Proof-of-Signature, and
     *             Proof-of-Agreement.
     * @param version Protocol version of the metadata. The version should be increased every time
     *                there is a change in the metadata.
     * @param metadata Metadata in JSON format.
     */
    function addMetadata(
        string memory name,
        string memory version,
        string memory metadata
    ) public onlyOwner {
        require(
            name.length() > 0 && version.length() > 0 && metadata.length() > 0,
            'Input params cannot be empty'
        );
        require(proofsMetadata[name][version].length() == 0, 'Metadata already exists');

        proofsMetadata[name][version] = metadata;
        metadataVersions[name].push(version);

        emit MetadataAdded(name, version, metadata);
    }

    /**
     * Update metadata by the contract administrator.
     * Note: This has to be done ONLY in the event of incorrect data entry in `addMetadata`
     *       function. Update of metadata on the protocol level should be done by adding another
     *       metadata with newer version.
     * @param name Name of metadata. As for now, it's Proof-of-Authority, Proof-of-Signature, and
     *             Proof-of-Agreement.
     * @param version Protocol version of the metadata. The version should be increased every time
     *                there is a change in the metadata. This function is only to adjusting the
     *                inconsistency of metadata in smart contract and the one, used on the website.
     * @param metadata Metadata in JSON format.
     */
    function forceUpdateMetadata(
        string memory name,
        string memory version,
        string memory metadata
    ) public onlyOwner {
        require(
            name.length() > 0 && version.length() > 0 && metadata.length() > 0,
            'Input params cannot be empty'
        );
        require(proofsMetadata[name][version].length() > 0, 'Metadata does not exist');

        proofsMetadata[name][version] = metadata;

        emit MetadataUpdated(name, version, metadata);
    }
}
