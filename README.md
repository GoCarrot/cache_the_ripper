# Cache The Ripper

Generates unique versions based on template content for key-based cache expiration.

## Using

Specify your fragment caching with:

      <% cache([cache_version(:unique_identifier), @resource]) do %>

Be sure to use a different identifier for each fragment.

Cache The Ripper will take care of the rest.

## Limitations

- Cache The Ripper can only detect changes made in your erb template. It will
not detect changes made to helpers, controllers, or models which affect
the content of the page.
- Cache The Ripper can only detect additional content included via `render`
