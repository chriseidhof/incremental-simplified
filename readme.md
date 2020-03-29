# Incremental

This repository provides two libraries: **Incremental** and **Resin**.

## Incremental

This is an implementation of incremental programming. It's based on the ideas in [incremental](https://blog.janestreet.com/introducing-incremental/), which are on turn based on the ideas of [self-adjusting computation](http://www.umut-acar.org/self-adjusting-computation).

For usage, see the [laufpark stechlin](https://github.com/chriseidhof/laufpark-stechlin) app.

## Resin

Resin uses Incremental and additionally provides a framework way to manage application state.

An app using Resin would typically have a single, shared struct that contains the entire application state. Different parts of the app would then *focus* this state to only operate on their subset of the state. This helps keep the concerns of different modules isolated from each other.

As a trivial example, consider

```swift
struct AppState {
    var foo: Foo
    var bar: Bar
}
```

where the app has two components (see *Parcel* below), one of which would operates on a state of the type `Foo`, and the other one on `Bar`.

### Actions

Resin enforces that changes to this global state can only be done through an `Action`. 

An `Action` has value semantics. And it can trigger two things: a `Reducer` can use an action to udpate the app state; and a `Middleware` can handle an `Action` to trigger side effects.

A note of caution: It is important to stress, that the channel to submit actions **is not** intended to be used as an event stream, and should **absolutely not** be misused as such. An `Action` is supposed to be a way for one part of he app to tell another to **do something**. This is **not** a way to notify about events of changes. `NSNotification` and observing the app state are better vehicles for that.

### Store

The app has a (root) store that holds onto the `AppState`. It only exposes the `AppState` through an (Incremental) `I<AppState>` such that various parts of the app can observe change of the state and react upon those changes.

`Middleware` and `Reducer`s can be registered with the store and any `Action` that gets dispatched will then be send to those. The `Reducer`s are the only ones that are given an opportunity to update the state. Their handler gets an `inout AppState` to operate on.

As different parts of the app operate on subsets of the all encompasing `AppState`, each part can operate on a `Store` that’s tied to the root store, but only operates on its subset (as noted above). The `Middleware` and `Reducer`s can then also operate on such a store’s subset, which transparently ties into the root store.

### Navigation

tbd

### Parcel

Each part (usually a Swift module) of an app has a combination of `Reducer`s, `Middleware`, and `PresentationRoute`s to implement its features. All of these needs to be registered with the store. In order to facilitate that, a `Parcel` can wrap a combination of all of these. The parcel can then be registered with the store, which in turn will register all of its `Reducer`s, `Middleware`, and `PresentationRoute`s.

The benefit of this, is that the app itself only needs to register the `Parcel`s that it uses, and doesn’t have to know which `Reducer`s, `Middleware`, and `PresentationRoute`s it needs. This makes updating code within a specific part / domain of an app easier. If, e.g. a new `Middleware` is added, it just needs to be added to its `Parcel`, and will then automatically be registered with the app.

Additionally, a module that has a parcel, does not have to expose its `Reducer`s, etc. as `public`. They only need to be added to the module’s `Parcel`. This reduces the API surface of a module.
