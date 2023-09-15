// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo
// swiftlint:disable all
extension GetTrending {
  class GetTrendingQuery: GraphQLQuery {
    static let operationName: String = "getTrending"
    static let operationDocument: Apollo.OperationDocument = .init(
      definition: .init(
        #"query getTrending { randomTopGenerativeToken { __typename author { __typename name } metadataUri gentkContractAddress thumbnailUri displayUri issuerContractAddress name } }"#
      ))

    public init() {}

    struct Data: GetTrending.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: Apollo.ParentType { GetTrending.Objects.Query }
      static var __selections: [Apollo.Selection] { [
        .field("randomTopGenerativeToken", RandomTopGenerativeToken.self),
      ] }

      /// Returns a random Generative Token among the 20 most successful tokens by tezos volume on the marketplace in the last 24h
      var randomTopGenerativeToken: RandomTopGenerativeToken { __data["randomTopGenerativeToken"] }

      /// RandomTopGenerativeToken
      ///
      /// Parent Type: `GenerativeToken`
      struct RandomTopGenerativeToken: GetTrending.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: Apollo.ParentType { GetTrending.Objects.GenerativeToken }
        static var __selections: [Apollo.Selection] { [
          .field("__typename", String.self),
          .field("author", Author.self),
          .field("metadataUri", String?.self),
          .field("gentkContractAddress", String.self),
          .field("thumbnailUri", String?.self),
          .field("displayUri", String?.self),
          .field("issuerContractAddress", String.self),
          .field("name", String.self),
        ] }

        /// The account who authored the Generative Token. Due to how collaborations are handled, it is also required to fetch the eventual collaborators on the account to know if it's a single or multiple authors.
        var author: Author { __data["author"] }
        /// IPFS uri pointing to the JSON metadata of the Generative Token
        var metadataUri: String? { __data["metadataUri"] }
        /// The address of the gentk contract that this token will mint iterations on.
        var gentkContractAddress: String { __data["gentkContractAddress"] }
        /// IPFS uri pointing to the 300x300 (contained) thumbnail of the project
        var thumbnailUri: String? { __data["thumbnailUri"] }
        /// IPFS uri pointing to the full res image of the project
        var displayUri: String? { __data["displayUri"] }
        /// The address of the issuer contract that this token was issued from.
        var issuerContractAddress: String { __data["issuerContractAddress"] }
        /// The name of the Generative Token, as defined in the JSON metadata created with the token when published on the blockchain
        var name: String { __data["name"] }

        /// RandomTopGenerativeToken.Author
        ///
        /// Parent Type: `User`
        struct Author: GetTrending.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: Apollo.ParentType { GetTrending.Objects.User }
          static var __selections: [Apollo.Selection] { [
            .field("__typename", String.self),
            .field("name", String?.self),
          ] }

          /// The name of the user, as it was set in the fxhash user register contract by the user.
          var name: String? { __data["name"] }
        }
      }
    }
  }

}
// swiftlint:enable all
