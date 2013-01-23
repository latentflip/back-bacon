# Some thoughts on what this is:

- I like backbone because it's nice and lightweight, and no nonsense.

- I don't like:
  - Lack of computed properties
  - Lack of view bindings
  - Boilerplate
  - Dependence on RESTful APIs, how does one merge a realtime API with a RESTful one?

- I like
  - Bacon.js
  - I want bacon in my views


# Models
- I like backbone models
- But I want property composition
- And I want multiple events to happily update my models

- So what needs to happen
  - Get events as eventStream, like https://github.com/raimohanska/bacon.js
  - property getters, let's say getBacon, which returns a (cached?) bacon property for a model's property
  - property pluggers, let's say plugStream, which adds a property stream to an event bus which updates the backbone property

    - Hmm?
      - Is there a difference between a computed property and a live property?
      - How many axes should be able to plug into a stream

