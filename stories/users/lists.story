Activated users should be able to create a new list at any point in the nebulae and add elements to it.

Story: Creating a list
  As a registered user
  I want to be able to create a new list
  So that i can keep track of plenty of new things
  
  # 
  # List Creation from user page
  # 
  Scenario: Activated user creates a new list from his home page
  Given an activated user named 'Nguma' with id:1
  And the activated user status is 'active'
  And the user has a tag with id: 123, label: 'Nguma'
  And that no list with label: 'tests', creator_id:1  exists 
  And he is on his home page '/my_nuniverse'
  When user sends the command to create a new list labeled 'tests'
  Then it should create a new list labeled 'tests' 
  And the list creator_id should be 1
  And the list tag should be nil
  And the user should be redirected to his home page
  And a flash[:notice] message should be sent saying "Tests was created successfully"
  
  # 
  Scenario: Unregistered users shouldn't be able to create a new list
  Given an anonymous user
  User should not be able to send commands
  When user tries to create a list (if he even can)
  Then he should be redirected to "/restricted"
  
  #
  Scenario: User tries to create a list which is already existing
  Given a user named 'Nguma' with id: 1
  And the user status is 'active'
  And the user has a tag with id:123, label: 'Nguma'
  And that a list with label: 'tests', creator_id:1, tag:nil exists
  And the user is on hs home page '/my_nuniverse'
  When user sends the command to create a new list labeled 'tests'
  Then it should return the flash[:error] message: "You already created this list"
  
  
  
  