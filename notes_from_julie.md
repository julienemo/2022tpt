Run project
- `bundle install` to install dependencies
- `rspec trustin_spec.rb` to run integration tests
- `rspec spec/` to run unit tests 

What I'd do had I more time
- adds exception handling for API
- adds model validations : evaluation needs to have all attributes, otherwise error etc
- add factorybot gem and make factories of Evaluation
- some metaprog ? Coz the business logic seems so standard
- singletons on the API classes and Trustin
- uses symbols instead of strings for evaluation attributes

What I had a hard time doing
- understanding the rules from readme and putting them into understandable 'if' 
- deciding where to put the common rules and where to put the type-specific rules, it still looks clumsy
- avoiding "sperating for seperating"
- navigating in `trustin_spec.rb` because it's huge, I did't want to separate it and was afraid to lose pieces in refacto