// @generated
// This file was automatically generated and should not be edited.

import Apollo
// swiftlint:disable all
protocol GetTrending_SelectionSet: Apollo.SelectionSet & Apollo.RootSelectionSet
where Schema == GetTrending.SchemaMetadata {}

protocol GetTrending_InlineFragment: Apollo.SelectionSet & Apollo.InlineFragment
where Schema == GetTrending.SchemaMetadata {}

protocol GetTrending_MutableSelectionSet: Apollo.MutableRootSelectionSet
where Schema == GetTrending.SchemaMetadata {}

protocol GetTrending_MutableInlineFragment: Apollo.MutableSelectionSet & Apollo.InlineFragment
where Schema == GetTrending.SchemaMetadata {}

extension GetTrending {
  typealias ID = String

  typealias SelectionSet = GetTrending_SelectionSet

  typealias InlineFragment = GetTrending_InlineFragment

  typealias MutableSelectionSet = GetTrending_MutableSelectionSet

  typealias MutableInlineFragment = GetTrending_MutableInlineFragment

  enum SchemaMetadata: Apollo.SchemaMetadata {
    static let configuration: Apollo.SchemaConfiguration.Type = SchemaConfiguration.self

    static func objectType(forTypename typename: String) -> Object? {
      switch typename {
      case "Query": return GetTrending.Objects.Query
      case "GenerativeToken": return GetTrending.Objects.GenerativeToken
      case "User": return GetTrending.Objects.User
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}
// swiftlint:enable all
