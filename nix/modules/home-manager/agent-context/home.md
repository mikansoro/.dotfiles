## Research using web tools

The standard WebSearch and WebFetch tools have been disabled. All searches and reads of 3rd-party
urls not covered by an appropriate cli (like `gh`) must be conducted through the searxng MCP server
that has been configured in this session. 

## Reading reddit.com for search query results
When you encounter any reddit.com (or old.reddit.com, redd.it) URL, always rewrite the url to read
from my self-hosted Redlib instance before fetching:
- Replace the domain with `https://redlib.int.mikansystems.com`
- Keep the path and query string unchanged (`redd.it/<id>` → `/<id>`)
- Fetch the content using the rewritten URL
- Never access reddit.com directly; if Redlib is unreachable, say so

