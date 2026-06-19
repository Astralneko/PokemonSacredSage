module AstralnekoTrivia
	@@reloaded = false
	@@compiledData = nil
	#=====================================================##
	# Compile Data Functions
	#=====================================================##
	def self.compile(mustCompile = false)
		return if !$DEBUG || !FileTest.directory?("PBS")
		if !FileTest.exist?("PBS/default_trivia.txt")
			self.generatePBS()
		end
		
		pbSetWindowText("Compiling Astralneko's Trivia data")
		refresh = mustCompile
		refresh = true if !FileTest.exist?("Data/astralneko_trivia.dat")
		refresh = true if Input.press?(Input::CTRL)
		refresh = true if !refresh && FileTest.exist?("PBS/default_trivia.txt") &&
																	File.mtime("PBS/default_trivia.txt") > File.mtime("Data/astralneko_trivia.dat")

		if refresh
			echoln "Compiling Astralneko's Trivia data...\n"
			data = self.load_from_file
		if not data
			raise _INTL("Compilation of Astralneko's Trivia data failed, default_trivia.txt may not exist or PBS may not exist.")
		end
		save_data(data, "Data/astralneko_trivia.dat")
		puts("Astralneko's Trivia data compiled successfully.")
		@@compiledThisLaunch = true
		end
		pbSetWindowText(nil)
	end
	
	def self.recompile()
		write_fame_targets()
		puts "\nUpdating Data/astralneko_trivia.dat..."
		data = self.load_from_file
		save_data(data, "Data/astralneko_trivia.dat") if data != nil
		if data == nil
			puts "Compiling Failed, somehow couldn't find the file that was written to."
			return
		end
		puts "Compiling of new astralneko_trivia.dat successful.\n" if data != nil
		puts "Reloading compiled data..."
		ensureCompiledData(true)
		puts "Compiled Data reloaded."
	end
	
	def self.ensureCompiledData(overwrite = false)
		return if @@reloaded == true && overwrite == false
		@@compiledData = load_data("Data/astralneko_trivia.dat") rescue {}
		@@reloaded = true
	end

	def self.compiledData()
		if @@compiledData == nil
			self.ensureCompiledData()
		end
		return @@compiledData
	end
	
	def self.load_from_file
		data = {}
		questions = {}
		answerLists = {}
		questionArray = []
		answerArray = []
		begin
			file = File.open(AstralnekoConfig::TRIVIA_PATH)
			begin
				puts("====== TRIVIA LOADING LOG ======") if $DEBUG && AstralnekoConfig::TRIVIA_LOADING_LOG
				line = file.readline()
				currentId = ""
				currentQuestion = ""
				currentAnswer = ""
				while !file.eof?
					if !line.include?("##")
						line = line.tr("\n",'').gsub(": ",":").split(':',-1)
						key = line[0]
						thisdata = line[1]
						
						if key == "ID"
							currentId = thisdata
							puts("\n----------[ #{currentId.upcase} ]----------") if $DEBUG && AstralnekoConfig::TRIVIA_LOADING_LOG
						elsif key == "Question"
							currentQuestion = thisdata
							questions[currentId.to_sym] = currentQuestion
							answerLists[currentId.to_sym] = []
							questionArray.push(currentQuestion)
							puts("Question: #{currentQuestion}") if $DEBUG && AstralnekoConfig::TRIVIA_LOADING_LOG
						elsif key == "Answer"
							currentAnswer = thisdata
							answerLists[currentId.to_sym].push(currentAnswer)
							answerArray.push(currentAnswer)
							puts(" -> Answer: #{currentAnswer}") if $DEBUG && AstralnekoConfig::TRIVIA_LOADING_LOG
						end
					end
					line = file.readline()
				end
				@lastUpdateDate = file.mtime
				data.store(:questions,questions)
				data.store(:answerLists,answerLists)
				MessageTypes.setMessagesAsHash(MessageTypes::AstralnekoTriviaQuestions,questionArray)
				MessageTypes.setMessagesAsHash(MessageTypes::AstralnekoTriviaAnswers,answerArray)
				Translator.gather_script_and_event_texts
				MessageTypes.save_default_messages
				MessageTypes.load_default_messages if FileTest.exist?("Data/messages_core.dat")
				return data
			rescue
				return nil
			end
		rescue
			puts("There was an error opening the file " + AstralnekoConfig::TRIVIA_PATH) if $DEBUG && AstralnekoConfig::TRIVIA_LOADING_LOG
			return nil
		end
	end
end

# Add trivia's PBS files to MessageTypes for translation
module MessageTypes
	AstralnekoTriviaQuestions = 200
	AstralnekoTriviaAnswers   = 201
end

# Compiler
module Compiler
  class << Compiler
    alias compile_all_astralneko_trivia compile_all
  end

  def self.compile_all(mustCompile)
    AstralnekoTrivia.compile
    compile_all_astralneko_trivia(mustCompile) { |msg| pbSetWindowText(msg); echoln(msg) }
  end
end

