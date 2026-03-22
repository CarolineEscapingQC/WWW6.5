// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AchievementsPlugin {
    mapping (address => string) public latestAchievement;

    function setAchievement(address user, string memory achievement) public {
        latestAchievement[user] = achievement;
    }

    function getAchievement(address user) public view returns (string memory){
        return latestAchievement[user];
    }
}

contract WeaponStorePlugin{
    mapping(address => string) public equippedWeapon;

    function setWeapon(address user, string memory weapon) public{
        equippedWeapon[user] = weapon;
    }

    function getWeapon (address user) public view returns (string memory){
        return equippedWeapon[user];
    }
}

