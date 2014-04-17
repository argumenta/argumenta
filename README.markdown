
# Argumenta

Social argument collaboration for the web.

Argumenta's goal is to help people build better arguments online,
by collaborating with others. To do this, we've made Arguments and
Propositions the focus. In Argumenta, they are first-class citizens;
discrete components which can be identified by their contents, and thus
referenced by other entities - no matter who creates them or how they are used.

Here's the essentials:

+ Arguments are composed of propositions - a series of premises leading to a conclusion.
+ Propositions are short, tweet-like strings of text - 240 characters max.
+ Both are identified by the SHA-1 hash of their object record, just as in Git.
+ Support and Dispute tags link a proposition with a related argument.
+ Citation tags link propositions with any external resource, through text, embedded videos, or URLs.

Join us soon at [Argumenta.io][Argumenta.io] to start collaborating! We're currently preparing alpha deployment.  
You can also follow us on Twitter ([@ArgumentaIO]), and ask us anything!

## Install

Install via npm to get the `argumenta` command:

```bash
$ npm install -g argumenta
$ argumenta
Argumenta 0.1.5 (development mode) | http://localhost:3000
```

See [Install][Install] for server configuration details, and [Developers][Developers] for notes on working from source.

## Modules

+ [Argumenta-Widgets][Widgets] - JavaScript Widgets for Argumenta. Share arguments anywhere on the web!

## Documentation

+ [API][API] - Argumenta's REST API.
+ [Install][Install] - Install Argumenta for command-line or server use.
+ [Developers][Developers] - Developer notes for Argumenta.

[Argumenta.io]: http://blog.argumenta.io
[Blog.Argumenta.io]: http://blog.argumenta.io
[@ArgumentaIO]: https://twitter.com/ArgumentaIO

[API]: ./doc/README.API.markdown
[Install]: ./doc/README.Install.markdown
[Developers]: ./doc/README.Developers.markdown

[Widgets]: https://github.com/argumenta/argumenta-widgets

## License

MIT
