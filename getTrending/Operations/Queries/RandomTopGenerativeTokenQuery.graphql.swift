// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo
// swiftlint: disable all
extension GetTrending {
  class RandomTopGenerativeTokenQuery: GraphQLQuery {
    static let operationName: String = "RandomTopGenerativeToken"
    static let operationDocument: Apollo.OperationDocument = .init(
      definition: .init(
        #"query RandomTopGenerativeToken { randomTopGenerativeToken { __typename author { __typename name } gentkContractAddress issuerContractAddress metadata } }"#
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
          .field("gentkContractAddress", String.self),
          .field("issuerContractAddress", String.self),
          .field("metadata", GetTrending.JSONObject?.self),
        ] }

        /// The account who authored the Generative Token. Due to how collaborations are handled, it is also required to fetch the eventual collaborators on the account to know if it's a single or multiple authors.
        var author: Author { __data["author"] }
        /// The address of the gentk contract that this token will mint iterations on.
        var gentkContractAddress: String { __data["gentkContractAddress"] }
        /// The address of the issuer contract that this token was issued from.
        var issuerContractAddress: String { __data["issuerContractAddress"] }
        /// The JSON metadata of the Generative Token, loaded from the ipfs uri associated with the token when published
        var metadata: GetTrending.JSONObject? { __data["metadata"] }

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
// swiftlint: disable all
