//
//  .alert + presenting.swift
//  Janitor
//
//  Created by Ky on 2024-09-26.
//

import SwiftUI

public extension View {
    
    /// Presents an alert with a message using the given data to produce the alert's content and a localized string key for a title.
    ///
    /// For the alert to appear, the value wrapped by `value` must not be `nil`. The data should not change after the presentation occurs. Making changes after the presentation occurs is undefined behavior.
    ///
    /// Use this method when you need to populate the fields of an alert with content from a data source.
    ///
    /// The example below shows a custom data source, `SaveDetails`, that provides data to populate the alert:
    ///
    ///     struct SaveErrorDetails: Identifiable {
    ///         let name: String
    ///         let error: String
    ///         let id = UUID()
    ///     }
    ///
    ///     struct SaveButton: View {
    ///         @State private var saveErrorDetails: SaveErrorDetails?
    ///
    ///         var body: some View {
    ///             Button("Save") {
    ///                 model.save(errorDetails: $saveErrorDetails)
    ///             }
    ///             .alert(
    ///                 "Save failed",
    ///                 presenting: $saveErrorDetails
    ///             ) { saveErrorDetails in
    ///                 Button(role: .destructive) {
    ///                     // Handle the deletion.
    ///                 } label: {
    ///                     Text("Delete \(saveErrorDetails.name)")
    ///                 }
    ///
    ///                 Button("Retry") {
    ///                     // Handle the retry action.
    ///                 }
    ///             } message: { saveErrorDetails in
    ///                 Text(saveErrorDetails.error)
    ///             }
    ///         }
    ///     }
    ///
    /// This modifier creates a ``Text`` view for the title on your behalf, and treats the localized key similar to ``Text/init(_:tableName:bundle:comment:)``.
    /// See ``Text`` for more information about localizing strings.
    ///
    /// All actions in an alert dismiss the alert after the action runs.
    /// The default button is shown with greater prominence.  You can influence the default button by assigning it the ``KeyboardShortcut/defaultAction`` keyboard shortcut.
    ///
    /// The system may reorder the buttons based on their role and prominence.
    ///
    /// If no actions are present, the system includes a standard "OK" action.
    /// No default cancel action is provided. If you want to show a cancel action, use a button with a role of ``ButtonRole/cancel``.
    ///
    /// On iOS, tvOS, and watchOS, alerts only support controls with labels that are ``Text``. Passing any other type of view results in the content being omitted.
    ///
    /// Only unstyled text is supported for the message. Why they require this to be a fancy-ass `View` but then don't style the text eludes me. If I were them, I'd just ask for a `LocalizedStringKey` or something lol.
    /// But I am just making a wrapper around system functionality
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized string that describes the title of the alert.
    ///   - value:    A binding to a value that will be used to present the alert when it is not `nil`. When the user presses or taps one of the alert's actions, the system sets this value to `nil` and dismisses.
    ///               In this version of `.alert(`, this acts as the source of truth for the alert. The system passes the contents to the modifier's closures. You use this data to populate the fields of an alert that you create that the system displays to the user.
    ///   - actions:  _optional_ - A ``ViewBuilder`` returning the alert's actions given the currently available data. Defaults to a standard system "OK" action.
    ///   - message:  A ``ViewBuilder`` returning the message for the alert given the currently available data.
    @inline(__always)
    func alert<Value>(
        _ titleKey: LocalizedStringKey,
        presenting value: Binding<Value?>,
        @ViewBuilder actions: (Value) -> some View,
        @ViewBuilder message: (Value) -> some View)
    -> some View {
        self.alert(
            titleKey,
            isPresented: .init {
                nil != value.wrappedValue
            } set: {
                if !$0 { value.wrappedValue = nil }
            },
            presenting: value,
            actions: { value in
                if let value = value.wrappedValue {
                    actions(value)
                }
            },
            message: { value in
                if let value = value.wrappedValue {
                    message(value)
                }
            })
    }
    
    
    /// Presents an alert with a message using the given data to produce the alert's content and a localized string key for a title.
    ///
    /// For the alert to appear, the value wrapped by `value` must not be `nil`. The data should not change after the presentation occurs. Making changes after the presentation occurs is undefined behavior.
    ///
    /// Use this method when you need to populate the fields of an alert with content from a data source.
    ///
    /// The example below shows a custom data source, `SaveDetails`, that provides data to populate the alert:
    ///
    ///     struct SaveErrorDetails: Identifiable {
    ///         let name: String
    ///         let error: String
    ///         let id = UUID()
    ///     }
    ///
    ///     struct SaveButton: View {
    ///         @State private var saveErrorDetails: SaveErrorDetails?
    ///
    ///         var body: some View {
    ///             Button("Save") {
    ///                 model.save(errorDetails: $saveErrorDetails)
    ///             }
    ///             .alert(
    ///                 "Save failed",
    ///                 presenting: $saveErrorDetails
    ///             ) { saveErrorDetails in
    ///                 Button(role: .destructive) {
    ///                     // Handle the deletion.
    ///                 } label: {
    ///                     Text("Delete \(saveErrorDetails.name)")
    ///                 }
    ///
    ///                 Button("Retry") {
    ///                     // Handle the retry action.
    ///                 }
    ///             } message: { saveErrorDetails in
    ///                 Text(saveErrorDetails.error)
    ///             }
    ///         }
    ///     }
    ///
    /// This modifier creates a ``Text`` view for the title on your behalf, and treats the localized key similar to ``Text/init(_:tableName:bundle:comment:)``.
    /// See ``Text`` for more information about localizing strings.
    ///
    /// All actions in an alert dismiss the alert after the action runs.
    /// The default button is shown with greater prominence.  You can influence the default button by assigning it the ``KeyboardShortcut/defaultAction`` keyboard shortcut.
    ///
    /// The system may reorder the buttons based on their role and prominence.
    ///
    /// If no actions are present, the system includes a standard "OK" action.
    /// No default cancel action is provided. If you want to show a cancel action, use a button with a role of ``ButtonRole/cancel``.
    ///
    /// On iOS, tvOS, and watchOS, alerts only support controls with labels that are ``Text``. Passing any other type of view results in the content being omitted.
    ///
    /// Only unstyled text is supported for the message. Why they require this to be a fancy-ass `View` but then don't style the text eludes me. If I were them, I'd just ask for a `LocalizedStringKey` or something lol.
    /// But I am just making a wrapper around system functionality
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized string that describes the title of the alert.
    ///   - value:    A binding to a value that will be used to present the alert when it is not `nil`. When the user presses or taps one of the alert's actions, the system sets this value to `nil` and dismisses.
    ///               In this version of `.alert(`, this acts as the source of truth for the alert. The system passes the contents to the modifier's closures. You use this data to populate the fields of an alert that you create that the system displays to the user.
    ///   - actions:  _optional_ - A ``ViewBuilder`` returning the alert's actions given the currently available data. Defaults to a standard system "OK" action.
    ///   - message:  A ``ViewBuilder`` returning the message for the alert given the currently available data.
    @inline(__always)
    func alert<Value>(
        _ titleKey: LocalizedStringKey,
        presenting value: Binding<Value?>,
        message: (Value) -> some View)
    -> some View {
        self.alert(
            titleKey,
            isPresented: .init {
                nil != value.wrappedValue
            } set: {
                if !$0 { value.wrappedValue = nil }
            },
            presenting: value,
            actions: { _ in },
            message: { value in
                if let value = value.wrappedValue {
                    message(value)
                }
            })
    }
}
