var ECDSAKeepFactory = artifacts.require('ECDSAKeepFactory');

contract("ECDSAKeepFactory test", async accounts => {

    it("ECDSAKeepCreated event emission", async () => {
        let blockNumber = await web3.eth.getBlock("latest").number

        let keepFactory = await ECDSAKeepFactory.deployed();

        let expectedKeepAddress = await keepFactory.createNewKeep.call(
            10, // uint256 _groupSize,
            5, // uint256 _honestThreshold,
            "0xbc4862697a1099074168d54A555c4A60169c18BD" // address _owner
        ).catch((err) => {
            console.log(`ecdsa keep creation for failed: ${err}`);
        });

        await keepFactory.createNewKeep(
            10, // uint256 _groupSize,
            5, // uint256 _honestThreshold,
            "0xbc4862697a1099074168d54A555c4A60169c18BD" // address _owner
        ).catch((err) => {
            console.log(`ecdsa keep creation failed: ${err}`);
        });

        let eventList = await keepFactory.getPastEvents('ECDSAKeepCreated', {
            fromBlock: blockNumber,
            toBlock: 'latest'
        })

        assert.isTrue(
            web3.utils.isAddress(expectedKeepAddress),
            `keep address ${expectedKeepAddress} is not a valid address`,
        );

        assert.equal(eventList.length, 1, "incorrect number of emitted events")

        assert.equal(
            eventList[0].returnValues.keepAddress,
            expectedKeepAddress,
            "incorrect keep address in emitted event",
        )
    });
});
