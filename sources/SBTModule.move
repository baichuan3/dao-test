address SbtTest {
module SBTModule {
    use StarcoinFramework::Vector;
    use StarcoinFramework::NFT::{Self};
    use StarcoinFramework::IdentifierNFT;
    use StarcoinFramework::Signer;
    use StarcoinFramework::Token::{Self, Token};

    struct SbtTestDAO has copy, drop, store {}

    struct SbtTestDAO2 has copy, drop, store {}

    struct DaoTokenMintCapHolder<phantom DaoT> has key {
        cap: Token::MintCapability<DaoT>,
    }

    struct DaoTokenBurnCapHolder<phantom DaoT> has key {
        cap: Token::BurnCapability<DaoT>,
    }

    struct DaoNFTMintCapHolder<phantom DaoT> has key {
        cap: NFT::MintCapability<DaoMember<DaoT>>,
    }

    struct DaoNFTBurnCapHolder<phantom DaoT> has key {
        cap: NFT::BurnCapability<DaoMember<DaoT>>,
    }

    struct DaoNFTUpdateCapHolder<phantom DaoT> has key {
        cap: NFT::UpdateCapability<DaoMember<DaoT>>,
    }


    /// The Dao member NFT metadata
    struct DaoMember<phantom DaoT> has copy, store, drop {
        //Member id
        id: u64,
    }

    /// The Dao member NFT Body, hold the SBT token
    struct DaoMemberBody<phantom DaoT> has store {
        sbt: Token<DaoT>,
    }

    /// Create a dao with a exists Dao account
    public fun create_dao<DaoT: store>(dao_signer: &signer, name: vector<u8>) {
        Token::register_token<DaoT>(dao_signer, 1);
//        let token_mint_cap = Token::remove_mint_capability<DaoT>(dao_signer);
//        let token_burn_cap = Token::remove_burn_capability<DaoT>(dao_signer);
//
//        move_to(dao_signer, DaoTokenMintCapHolder{
//            cap: token_mint_cap,
//        });
//        move_to(dao_signer, DaoTokenBurnCapHolder{
//            cap: token_burn_cap,
//        });

        let nft_name = *&name;
        let nft_image = b"iamge_data";
        let nft_description = Vector::empty<u8>();
        let basemeta = NFT::new_meta_with_image_data(nft_name, nft_image, nft_description);

        NFT::register_v2<DaoMember<DaoT>>(dao_signer, basemeta);
//        NFT::register_v2<DaoT>(dao_signer, basemeta);
        let nft_mint_cap = NFT::remove_mint_capability<DaoMember<DaoT>>(dao_signer);
        move_to(dao_signer, DaoNFTMintCapHolder{
            cap: nft_mint_cap,
        });
    }


    /// Join Dao and get a membership
    public fun join_member<DaoT: store>(dao_signer: &signer, name: vector<u8>, _to_address: address, init_sbt: u128) acquires DaoNFTMintCapHolder {
        let member_id = 1111;

        let meta = DaoMember<DaoT>{
            id: member_id,
        };

//        let dao_address = dao_address<DaoT>();
//        let dao_signer = dao_signer<DaoT>();
        let dao_address = Signer::address_of(dao_signer);
        let sbt = Token::mint<DaoT>(dao_signer, init_sbt);

        let body = DaoMemberBody<DaoT>{
            sbt,
        };
        //TODO init base metadata
        let nft_name = name;
        let nft_image = b"iamge_data";
        let nft_description = Vector::empty<u8>();
        let basemeta = NFT::new_meta_with_image_data(nft_name, nft_image, nft_description);

        let nft_mint_cap = &mut borrow_global_mut<DaoNFTMintCapHolder<DaoT>>(dao_address).cap;

        let nft = NFT::mint_with_cap_v2(dao_address, nft_mint_cap, basemeta, meta, body);

        IdentifierNFT::accept<DaoMember<DaoT>, DaoMemberBody<DaoT>>(dao_signer);
        IdentifierNFT::grant_to(nft_mint_cap, dao_address, nft);
    }
}

module SBTModuleScripts {
    use SbtTest::SBTModule;

    public(script) fun create_dao<DaoT: store>(dao_signer: signer, name: vector<u8>) {
        SBTModule::create_dao<DaoT>(&dao_signer, name);
    }

    public(script) fun join_member<DaoT:store>(dao_signer: signer, name: vector<u8>, to_address: address, init_sbt: u128){
        SBTModule::join_member<DaoT>(&dao_signer, name, to_address, init_sbt);
    }
}

}