//# init -n test --public-keys SbtTest=0x0f946397a0ca1e778416ce2028aae01dea193d48dd42fb973978fdf7423dab68

//# faucet --addr alice

//# faucet --addr bob

//# faucet --addr SbtTest

//# block --author 0x1 --timestamp 86400000

//# publish
module alice::TokenWrapper {
    struct USDT has copy, drop, store {}
    struct SbtTestDAO has copy, drop, store {}
}

//# run --signers SbtTest

script {
//    use SbtTest::SBTModule;
//    use alice::TokenWrapper::{SbtTestDAO};
    use SbtTest::SBTModule::{Self, SbtTestDAO};

    fun test_create_dao(signer: signer) {
        let name = x"64616f313031"; // dao101
        SBTModule::create_dao<SbtTestDAO>(&signer, name);
    }
}
// check: EXECUTED


//# run --signers SbtTest

script {
//    use SbtTest::SBTModule;
//    use alice::TokenWrapper::{SbtTestDAO};
    use SbtTest::SBTModule::{Self, SbtTestDAO};

    fun test_member_join(signer: signer) {
        let name = x"64616f313031"; // dao101
        SBTModule::join_member<SbtTestDAO>(&signer, name, @bob, 100u128);
    }
}
// check: EXECUTED
