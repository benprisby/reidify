# Reidify

[![Hugo](https://img.shields.io/badge/Hugo-FF4088?logo=hugo&logoColor=white)](https://gohugo.io/)
[![GitHub Pages](https://img.shields.io/badge/GitHub%20Pages-222222?logo=github&logoColor=white)](https://pages.github.com/)
[![Build and Deploy Site](https://github.com/benprisby/reidify/actions/workflows/build.yml/badge.svg)](https://github.com/benprisby/reidify/actions/workflows/build.yml)
[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/benprisby/reidify/main.svg)](https://results.pre-commit.ci/latest/github/benprisby/reidify/main)

Brand site for the [Reidify](https://www.youtube.com/@Reidifyy) YouTube gaming channel, built with Hugo and deployed to
GitHub Pages.

## 🌐 Live Site

**<https://reidify.tv>**

## 📋 Overview

A small brand site whose jobs, in order, are to look legitimate to a brand considering a sponsorship, push visitors to
the channel, and be reachable for business. It is deliberately not a replacement for YouTube: video cards link out
rather than embedding, and there are no comments or playlists.

Five pages:

- **Home**: Wordmark, tagline, subscribe button, and a grid of the latest long-form uploads
- **About**: What the channel is and who to contact
- **Links**: Full-width buttons for every destination, built for phones
- **Contact**: Business enquiries, `mailto:` only
- **404**

## 🚀 Getting Started

### Prerequisites

- Git
- [Hugo](https://gohugo.io/installation/) 0.166.0 extended (the version CI pins; *extended* is required for the CSS
  pipeline)
- [pre-commit](https://pre-commit.com) (development only)

There is no Node dependency tree, no build-time JavaScript toolchain, and the site ships no client-side JavaScript.
`hugo` is the entire build.

### Local Development

1. Clone the repository.
2. Install pre-commit hooks: `pre-commit install`.
3. Start the development server: `hugo server --disableFastRender`.
4. View the site (defaulting to <http://localhost:1313>).

To refresh the video list locally the way CI does:

```bash
curl -sSfL -o /tmp/feed.xml \
  "https://www.youtube.com/feeds/videos.xml?playlist_id=UULFE6h5SQHI8Xv3v_F7DZFtTA"
python3 .github/scripts/feed-to-json.py /tmp/feed.xml data/videos.json
```

### Building for Production

```bash
hugo --minify --gc
```

The built site lands in the *public* directory.

## 📦 Deployment

Built and deployed by a [GitHub Actions workflow](.github/workflows/build.yml) that:

1. Pulls the channel's long-form uploads into *data/videos.json*
2. Runs Hugo to generate the site
3. Publishes to GitHub Pages

It runs on push to `main`, hourly, and on manual dispatch.
The custom domain is committed as *static/CNAME*. The site is proxied through Cloudflare to boost performance and
security.

## 🔧 Development Notes

- Shorts are excluded: the build reads the auto-generated `UULF` ("Videos") playlist feed rather than the channel feed
- Thumbnails are hotlinked from *i.ytimg.com* so they update when a thumbnail changes, with no rebuild
- `data/videos.json` is committed on purpose. It looks like build output, but it is what lets a fresh clone build a real
  grid offline
- Pre-commit hooks will automatically fix basic syntax or whitespace issues
- [`tools/check-site.sh`](tools/check-site.sh) runs as a local pre-commit hook and checks the things that have actually
  broken before: the build, HTML comments leaking into pages, the external link policy, and an empty video grid
- `layouts/_markup/render-link.html` ends with a `{{- -}}` trim marker so that *end-of-file-fixer* cannot reintroduce a
  trailing newline, which would render as a space before punctuation following an inline link
- [`CLAUDE.md`](CLAUDE.md) carries the architecture notes, the design rules and the reasoning behind them, and the
  gotchas worth reading before changing anything
