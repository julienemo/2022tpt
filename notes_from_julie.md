Run project
- `bundle install` to install dependencies
- `rspec trustin_spec.rb` to run integration tests
- `rspec spec/` to run unit tests 

What I'd do had I more time
- adds exception handling for API
- adds model validations : evaluation needs to have all attributes, otherwise error etc
- add factorybot gem and make factories of Evaluation
- singletons on the API classes and Trustin
- uses symbols instead of strings for evaluation attributes
- think of a better organization of `trustin_spec.rb`

What I had a hard time doing
- understanding the rules from readme and putting them into understandable 'if' 
- deciding where to put the common rules and where to put the type-specific rules
- avoiding "sperating for seperating"
- navigating in `trustin_spec.rb` because it's huge