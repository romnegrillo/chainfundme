// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract ChainFundMe {
    struct Campaign {
        address owner;  
        string title;  
        string description;  
        string image;  
        uint256 targetAmount;  
        uint256 targetDate;  
        uint256 currentAmount;  
        address[] donatorAddresses;  
        uint256[] donations;  
    }
 
    mapping(uint256 => Campaign) public campaigns; 
    uint256 numCampaigns = 0;
 
    function createCampaign(string memory _title, string memory _description, string memory _image, uint256 _targetAmount, uint256 _targetDate) public returns (uint256) {
        require(block.timestamp < _targetDate, "The campaign deadline should be in the future.");

        Campaign storage newCampaign = campaigns[numCampaigns];

        newCampaign.owner = msg.sender;
        newCampaign.title = _title;
        newCampaign.description = _description;
        newCampaign.image = _image;
        newCampaign.targetAmount = _targetAmount;
        newCampaign.targetDate = _targetDate;
        newCampaign.currentAmount = 0;

        numCampaigns++;
        
        return numCampaigns - 1;
    }

    function donateToCampaign(uint256 _campaignId) public payable {
        uint256 amount = msg.value;
        Campaign storage campaign = campaigns[_campaignId];

        (bool sent,) = payable(campaign.owner).call{value: amount}("");

        if(sent) {
            campaign.donatorAddresses.push(msg.sender);
            campaign.donations.push(amount);
            campaign.currentAmount += amount;
        }
    }

    function getDonators(uint256 _campaignId) public view returns (address[] memory, uint256[] memory) {
        Campaign storage campaign = campaigns[_campaignId];
        return (campaign.donatorAddresses, campaign.donations);
    }
    
    function getAllCampaigns() public view returns(Campaign[] memory) {
       Campaign[] memory allCampaigns = new Campaign[](numCampaigns);

        for(uint256 i = 0; i < numCampaigns; i++) {
            Campaign storage campaign = campaigns[i];
            allCampaigns[i] = campaign;
        }

        return allCampaigns;
    }

}