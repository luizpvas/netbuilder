# Authorization

Let's think about authorization. There are two types of enforcement to authorization
rules:

1. A section of this page is dfferent to certain types of users (e.g. show the edit button if the user owner)
2. This whole page is accessible to certain types of users (e.g. admin)

The first case are `if` expressions, there is no way around it. The way we can trust
the authorization is enforce is testing each `if` condition.

The second case is a bit more interesting.

# Building the best editor.

* Full clipboard support

* Full Ctrl-z support

# Improvements and refactors

* Logging out is something we can do from multiple pages. Right now, the login page,
  register page and recover password each implement a different Msg constructor to
  handle logout, and they all work by calling `Interop.logOut`. Maybe this is
  something we can extract to handle only in Main?

* Improve the design of "Layout.Auth.pleaseLogIn"

* Move Form.field stuff to UI. Remove Form module.

* I don't think it's a good idea to autofocus on the first field in mobile
  view. This happens in login and register.