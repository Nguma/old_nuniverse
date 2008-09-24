# This class wraps and parses the user command input,
# also defines the available scripting commands
class Command
	
	attr_reader :raw_command, :action, :argument
	
	def initialize(command)
		@raw_command = command.downcase.scan(/^(add|create|localize|find|search|invite)\s?(a\s|to\s|on\s|in\s|at\s)?(new\s)?(.*)?/)[0]

		@action = @raw_command[0].nil? ? @raw_command[2] : @raw_command[0]
		@argument = @raw_command[3].nil? ? nil : Nuniverse::Kind.match(@raw_command[3]) 
	end
	
	def self.match(action)
		# if action.match(/^(add|create)\s?((a|to)\s)?(new\s)?(.*)/)
		# 			@action = "add"
		# 			@argument = Nuniverse::Kind.match(@full_command[3])
		# 		elsif action.match(/^(google|((find|search)\s(on\s)?google))\s?$/)
		# 		elsif action.match(/^(find|search)\s(on\s)?(.*)/)
		# 		elsif action.match(/^(invite|email)\s(.*)/)
		# 		elsif action.match(/^(localize)\s)(.*)/)
		# 		else
		# 		end
	end

end