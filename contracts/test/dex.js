const Factory = artifacts.require('Factory');
const Pool = artifacts.require('Pool');
const Token = artifacts.require('ERC20Mock')
const { expectRevert, expectEvent, time } = require('@openzeppelin/test-helpers')


contract("Entire Dex", function (accounts) {

  var factory;
  var token1;
  var token2;
  var token3;
  const address0 = '0x0000000000000000000000000000000000000000';

  describe('Whitelist Tokens', () => {
    before(async () => {
      factory = await Factory.new();
      token1 = await Token.new("Token 1", "T1");
      token2 = await Token.new("Token 2", "T2");
      token3 = await Token.new("Token 3", "T3");
    });

    it("should whitelist token on the platform", async () => {
      const receipt = await factory.whitelistToken(token1.address);
      expectEvent(receipt, 'Whitelist', {
        token: token1.address
      })
    });

    it("should not whitelist token if null address is passed", async () => {
      return await expectRevert(
        factory.whitelistToken(address0),
        "Factory: Invalid Address"
      )
    });

    it("should not whitelist token if already done", async () => {
      return await expectRevert(
        factory.whitelistToken(token1.address),
        "Factory: Invalid Address"
      )
    });
    
  })

});
