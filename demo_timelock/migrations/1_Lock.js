const Lock = artifacts.require("Lock");

module.exports = function (deployer) {
  deployer.deploy(Lock);
};