# Design Principles for Cuttlefish

Here are some principles that have guided the design of Cuttlefish so far and should be kept
in mind in designing any new features.

## 1. A user should be able to get going quickly without having to configure lots of stuff

Sending email can be surprisingly complicated. We're supposed to be making it easier
for people. So, it's important that we don't make people understand and configure
everything at once. Make the path from a user signing up / setting a server to sending
their first email as quick as possible. That first email doesn't need to be perfect.
It might not have all the bells and whistles.

An example of this is how DKIM works. A user doesn't need to setup DKIM to send email initially.
They can create an "App" and get going. Cuttlefish doesn't care about what domain the email
comes from or goes to. It just does its best to deliver it. If you want to improve
deliverability then you can setup DKIM.

## 2. Minimal configuration

Work hard to figure out what is the simplest possible way we can present things.
Think hard before adding another option. Can we be opinionated about what the right
way to do this is? Can we deduce something automatically? How do we show the
option to the user so their "mental model" is as consistent and simple as
possible?

## 3. Provide just enough visibility

We want to help users understand what's going on. Giving them visibility helps
with that but don't go overboard with it.

Example: On the email detail view you can see at a glance whether the email has been delivered
successfully or not. If you really want you can see the different delivery attempts by
clicking on the little "+" but it's hidden by default because that level of information
would be overwhelming and irrelevant most of the time.

## 4. Assume that users are smart but don't assume they know everything about how email works

Example: When the user sets up a new app they are given the option to "improve deliverability".
This leads them to setting up DKIM. Rather than assuming that they know what DKIM it
says "DomainKeys Identified Mail (DKIM) improves the delivery of your emails by
automatically cryptographically signing each email so that the recipient can check
that it was indeed sent by you."

## 5. Provide specific help and guidance where and when it's needed

Similar to 1, people don't need to know everything at once. Give them help and Documentation
at the point where they're trying to do the new thing. Make that as specific as possible.

Essentially this implies that the documentation for Cuttlefish shouldn't be separate
document but rather be spread out and integrated throughout the application itself.

Example: The section in the Cuttlefish "How to send email with Cuttlefish" takes you to
a page which has instructions on how to send SMTP email from different application
languages with specific values pre-populated with the authentication credentials.
