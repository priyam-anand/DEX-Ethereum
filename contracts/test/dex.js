const Factory = artifacts.require('Factory');
const Pool = artifacts.require('Pool');
const Token = artifacts.require('ERC20Mock')
const { expectRevert, expectEvent, time } = require('@openzeppelin/test-helpers')

var factory;
var token1;
var token2;
var token3;
var pool1;
var pool2;
const address0 = '0x0000000000000000000000000000000000000000';

contract("Factory", function (accounts) {
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
  });

  describe("Create Pool", () => {
    it("should not make new pool if token is not whitelisted", async () => {
      return expectRevert(
        factory.createPool(token2.address),
        "Factory: Not whitelisted"
      )
    });

    it("should make new liquidity pool", async () => {
      const receipt = await factory.createPool(token1.address);
      const getPool = await factory.getPool(token1.address);
      const tokenGetter = await factory.getToken(getPool);
      const tokenWithId = await factory.getTokenWithId(1);

      expectEvent(receipt, 'Newpool', {
        token: token1.address,
        pool: getPool
      })
      assert(tokenGetter == tokenWithId && tokenWithId == token1.address);
      pool1 = await Pool.at(getPool);
    });

    it("should not make new pool if one with the same pair exists", async () => {
      return await expectRevert(
        factory.createPool(token1.address),
        "Factory: Pool with same token exist"
      );
    })
  });

  describe("Add liquidity", () => {
    before(async () => {
      await token1.mint(accounts[0], 1000000000);
    })
    it("should not add liquidity if invalid input is provided", async () => {
      return await expectRevert(
        pool1.addLiquidity(
          1000,
          100,
          0,
          { from: accounts[0], value: 1000 }
        ),
        "Pool: INVALID ARGUMENTS"
      )
    });

    it("should add liquidity with initial liquidity 0", async () => {
      await token1.approve(pool1.address, 1000000000);
      const ethAmount = 1000000;
      const tokenAmount = 5 * ethAmount;
      const receipt = await pool1.addLiquidity(
        ethAmount,
        tokenAmount,
        Date.now(),
        { from: accounts[0], value: ethAmount }
      );

      const ethBalOfPool = web3.utils.toNumber(await web3.eth.getBalance(pool1.address));
      const tokenBalance = web3.utils.toNumber(await token1.balanceOf(pool1.address));
      const poolPosition = web3.utils.toNumber(await pool1.balanceOf(accounts[0]));

      assert(ethBalOfPool == ethAmount);
      assert(tokenBalance == tokenBalance);
      expectEvent(receipt, 'AddLiquidity', {
        provider: accounts[0],
        eth_amount: ethAmount + "",
        token_amount: tokenAmount + ""
      });
      assert(poolPosition == ethAmount);
    })

    it("should add liquidity with already some liquidty", async () => {
      await token1.mint(accounts[1], 1000000000, { from: accounts[1] });
      await token1.approve(pool1.address, 1000000000, { from: accounts[1] })


      const prevEthBal = web3.utils.toNumber(await web3.eth.getBalance(pool1.address));
      const prevTokenBal = web3.utils.toNumber(await token1.balanceOf(pool1.address));

      const ethAmount = 1000000;
      const tokenAmount = 5 * ethAmount;
      const receipt = await pool1.addLiquidity(
        ethAmount,
        tokenAmount + 10,
        Date.now(),
        { from: accounts[1], value: ethAmount }
      );

      const ethBalOfPool = web3.utils.toNumber(await web3.eth.getBalance(pool1.address));
      const tokenBalance = web3.utils.toNumber(await token1.balanceOf(pool1.address));
      const poolPosition = web3.utils.toNumber(await pool1.balanceOf(accounts[1]));

      assert(ethBalOfPool - prevEthBal == ethAmount);
      assert(tokenBalance - prevTokenBal <= tokenBalance + 5);
      expectEvent(receipt, 'AddLiquidity', {
        provider: accounts[1],
        eth_amount: ethAmount + "",
        token_amount: "5000001"
      });
      assert(poolPosition == ethAmount);
    })

  })

  describe('Eth to token swap with fixed input', () => {
    it("should not exchange if no eth is sent", async () => {
      const poolAddress = await factory.getPool(token1.address);
      const currPool = await Pool.at(poolAddress);
      return await expectRevert(
        currPool.ethToTokenSwapInput(
          1000,
          Date.now(),
          { from: accounts[2], value: 0 }
        ),
        "Pool: INVALID ARGUMENTS"
      )
    });

    it("should not not exchange if not enough tokens are provided", async () => {
      const poolAddress = await factory.getPool(token1.address);
      const currPool = await Pool.at(poolAddress);
      return await expectRevert(
        currPool.ethToTokenSwapInput(
          100000,
          Date.now(),
          { from: accounts[2], value: 100 }
        ),
        "Pool: Token yield too low"
      )
    });

    it("should exchange eth for tokens", async () => {
      const poolAddress = await factory.getPool(token1.address);
      const currPool = await Pool.at(poolAddress);
      const receipt = await currPool.ethToTokenSwapInput(
        100,
        Date.now(),
        { from: accounts[2], value: 2000 }
      );

      const userTokenBalance = web3.utils.toNumber(await token1.balanceOf(accounts[2]));
      assert(userTokenBalance == 9990)
      expectEvent(receipt, 'TokenPurchase', {
        buyer: accounts[2],
        eth_sold: 2000 + "",
        tokens_bought: userTokenBalance + ""
      })
    });

  })

  describe("Eth to token swap with fixed output", () => {
    it("should not make swap if token yeild is too low", async () => {
      const poolAddress = await factory.getPool(token1.address);
      const currPool = await Pool.at(poolAddress);

      return await expectRevert(
        currPool.ethToTokenSwapOutput(
          1000,
          Date.now(),
          { from: accounts[2], value: 100 }
        ),
        "Pool: Token yeild too low"
      );
    });

    it("should make exchange", async () => {
      const poolAddress = await factory.getPool(token1.address);
      const currPool = await Pool.at(poolAddress);

      const prevBal = web3.utils.toNumber(await token1.balanceOf(accounts[2]));
      const receipt = await currPool.ethToTokenSwapOutput(
        1000,
        Date.now(),
        { from: accounts[2], value: 250 }
      );
      const newBal = web3.utils.toNumber(await token1.balanceOf(accounts[2]));
      assert(newBal - prevBal == 1000);
      expectEvent(receipt, 'TokenPurchase', {
        buyer: accounts[2],
        eth_sold: 201 + "",
        tokens_bought: 1000 + ""
      });
    })
  })

  describe("Token to eth swap with fixed input", () => {
    it("should not make exchange if eth yeild is too low", async () => {
      return await expectRevert(
        pool1.tokenToEthSwapInput(
          100,
          100,
          Date.now(),
          { from: accounts[1] }
        ),
        "Pool: Eth yield too low"
      )
    });

    it("should make exchange", async () => {
      await token1.mint(accounts[4], 1000000, { from: accounts[4] });
      await token1.approve(pool1.address, 5000, { from: accounts[4] });

      const prevTokenBal = web3.utils.toNumber(await token1.balanceOf(accounts[4]));

      const receipt = await pool1.tokenToEthSwapInput(
        5000,
        500,
        Date.now(),
        { from: accounts[4] }
      );

      const currTokenBal = web3.utils.toNumber(await token1.balanceOf(accounts[4]));

      assert(prevTokenBal - currTokenBal == 5000);
      expectEvent(receipt, 'EthPurchase', {
        buyer: accounts[4],
        tokens_sold: '5000',
        eth_bought: '1001'
      });
    })
  });

  describe("Token to eth swap with fixed output", () => {
    it("should not make exchange if more tokens are required", async () => {
      return await expectRevert(
        pool1.tokenToEthSwapOutput(
          5000,
          1000,
          Date.now(),
          { from: accounts[4] }
        ),
        "Pool: Eth yield too low"
      )
    });

    it("should make exchange", async () => {
      await token1.approve(pool1.address, 5000, { from: accounts[4] });

      const prevTokenBal = web3.utils.toNumber(await token1.balanceOf(accounts[4]));

      const receipt = await pool1.tokenToEthSwapOutput(
        500,
        5000,
        Date.now(),
        { from: accounts[4] }
      );

      const currTokenBal = web3.utils.toNumber(await token1.balanceOf(accounts[4]));

      assert(prevTokenBal - currTokenBal == 2498);
      expectEvent(receipt, 'EthPurchase', {
        buyer: accounts[4],
        tokens_sold: '2498',
        eth_bought: '500'
      });
      console.log("eth Reserve", web3.utils.toNumber(await web3.eth.getBalance(pool1.address)));
      console.log("token Reserve", web3.utils.toNumber(await token1.balanceOf(pool1.address)));
    })
  })

  describe("Token to token swap with fixed input", () => {
    before(async () => {
      await factory.whitelistToken(token2.address);
      await factory.createPool(token2.address);
      const pool2Address = await factory.getPool(token2.address);
      pool2 = await Pool.at(pool2Address);

      await token2.mint(accounts[0], 10000000, { from: accounts[0] });
      await token2.approve(pool2Address, 1100000, { from: accounts[0] });

      await pool2.addLiquidity(1, 1100000, Date.now(), { from: accounts[0], value: 100000 });
    });

    it("should not make exchange if pool is same as this one", async () => {
      return await expectRevert(
        pool1.tokenToTokenSwapInput(
          1000,
          100,
          Date.now(),
          token1.address
        ),
        "Pool: Invalid token address"
      )
    });

    it("should not make exchange if pool with second token does not exist", async () => {
      return await expectRevert(
        pool1.tokenToTokenSwapInput(
          1000,
          100,
          Date.now(),
          token3.address
        ),
        "Pool: Invalid token address"
      )
    })

    it("should make exchange", async () => {

      await token1.approve(pool1.address, 5000, { from: accounts[4] });

      const receipt = await pool1.tokenToTokenSwapInput(
        5000,
        1000,
        Date.now(),
        token2.address,
        { from: accounts[4] }
      )
      assert(web3.utils.toNumber(await token2.balanceOf(accounts[4])) == 10891);
      console.log("eth bal 1", web3.utils.toNumber(await web3.eth.getBalance(pool1.address)));
      console.log("token bal 1", web3.utils.toNumber(await token1.balanceOf(pool1.address)));
      console.log("eth bal 2", web3.utils.toNumber(await web3.eth.getBalance(pool2.address)));
      console.log("token bal 2", web3.utils.toNumber(await token2.balanceOf(pool2.address)));
    })
  })

  describe("Token to token swap with fixed output", () => {

  });

})
