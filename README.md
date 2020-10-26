# Simple mode to shorten URLs from Emacs.

Bitly is a popular URL shortener with many features. This mode
accesses the Bitly API to enable URL shortening in Emacs.

Use `(bitly-shorten URL)` from an Emacs Lisp program, or
`M-x bitly-url-at-point` to replace the URL at point (or the region)
with a shortened version.

## Installation

The easiest way is with [quelpa](https://github.com/quelpa/quelpa) and
[use-package](https://github.com/jwiegley/use-package).

```elisp
(use-package bitly
  :after org
  :quelpa (bitly :fetcher github :repo "pymander/bitly-el")
  :config
  (require 'org-bitly))
```

To configure this package, go to https://bitly.com/a/oauth_apps to generate your personal
API access token. Then use `M-x customize-variable RET bitly-access-token` and set it to
your access token.

## Bitly API v4

As of April 2020, this package supports v4 of the Bitly API.

## Use with org-mode

This package adds a `bitly:` link type to `org-mode`, allowing
shortened URLs to be used in both `org-mode` documents and various
exported documents. This is not well-documented yet, so please have a
look at [the source code](./org-bitly.el). It is rather short.

## Limitations

This library does not yet support custom domains. It also has problems
shortening URLs that have already been shortened using a custom
domain, such as `amzn.to`.
