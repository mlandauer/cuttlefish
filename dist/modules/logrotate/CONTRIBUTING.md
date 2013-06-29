Thanks for contributing to puppet-logrotate! A couple of notes to help you out:

 * Please don't bump the module version number.
 * Make sure your changes have tests.
 * Keep your pull requests on topic. Pull requests with a bunch of unrelated
   changes won't get merged. Feel free to open seperate pull requests for the
   other changes though.
 * Yes, I commit vendored gem files into my repositories. No, this is not
   a mistake. Please don't "fix" this in your pull request :)

Before starting, you can prepare your development environment by running:

```
script/bootstap
```

This will install all the dependencies required to run the test suite.

Although TravisCI will automatically run the test suite against your branch
when you push, you can (and should) run them locally as you're working. You can
run the test suite by running:

```
script/cibuild
```

This will run all the rspec-puppet tests followed by puppet-lint to catch any
style issues.
