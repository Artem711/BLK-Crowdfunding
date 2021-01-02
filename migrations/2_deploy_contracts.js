const CrowdFunding = require("../contracts/Index.sol")

module.exports = function (deployer) {
  deployer.deploy(CrowdFunding)
}
