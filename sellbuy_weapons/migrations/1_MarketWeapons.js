const MarketWeapons = artifacts.require("MarketWeapons");

module.exports = function (deployer) {
  deployer.deploy(MarketWeapons);
};