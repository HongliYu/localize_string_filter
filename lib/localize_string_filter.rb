require "localize_string_filter/version"
require 'fileutils'

def traverse_swift_files(file_path, swift_files)
  if File.directory? file_path
		Dir.foreach(file_path) do |file|
			if file !="." and file !=".."
				traverse_swift_files(file_path+"/"+file, swift_files)
			end
		end
  else
  	if file_path.end_with? ".swift"
			swift_files << file_path
			# puts "File:#{File.basename(file_path)}, Size:#{File.size(file_path)}"
  	end
  end
end

def collect_keys(strings_path)
	strings_keys = Array.new
	File.open(strings_path, "r") do |file|
    file.each_line do |line|
    	if line.start_with? "\""
				temp_array = line.split('=')
				quotation_indexes = Array.new
				temp_array[0].split("").each_with_index do |character, index|
					if character == '"'
						quotation_indexes << index
					end
				end
				str = temp_array[0][quotation_indexes[0], quotation_indexes[1] + 1]
				strings_keys << str
    	end
    end
	end
	return strings_keys
end

def collect_missing_keys(localized_keys, swift_files)
	missing_keys = Array.new
	percentCount = 0

	localized_keys.each do |key|
		the_key_is_valid = false

		# output progress
		percentCount = percentCount + 1
		precent = ((percentCount.to_f / localized_keys.count.to_f) * 10000).round / 10000.0
		str = (precent * 100).to_s
		# print "searching key: #{key} \n"
		puts "#{str[0,4]}% || searching key: #{key}"

		swift_files.each do |swift_file|
			if File.readlines(swift_file).any?{ |l| l[key] }
				the_key_is_valid = true
			  break
			end
		end
		if !the_key_is_valid
			missing_keys << key
		end
	end
	return missing_keys
end

def output_missing_keys(missing_keys, project_path)
	missing_keys_output_path = project_path + "/missing_keys.txt"
	File.open(missing_keys_output_path, "w+") do |f|
		missing_keys.each {
			|element| f.puts(element) 
		}
	end
	puts "\n missing_keys: #{missing_keys}"
	puts "check the file: #{missing_keys_output_path}"
end

def delete_missing_keys(missing_keys, strings_path)
	missing_keys.each do |key|
		open(strings_path, 'r') do |f|
			open(strings_path + '.tmp', 'w') do |f2|
			  f.each_line do |line|
			     f2.write(line) unless line.start_with? key
			  end
			end
		end
		FileUtils.mv strings_path + '.tmp', strings_path
	end
end

module LocalizeStringFilter
	def self.run()

		puts "input project path: "
		project_path = gets.chomp
		if project_path.empty?
			puts "error: invalid project_path"
			return
		end

		puts "input .strings file path: "
		strings_path = gets.chomp
		if strings_path.empty?
			puts "error: invalid strings_path"
			return
		end

		puts "running..."
	  if File.directory?(project_path)
	  	swift_files = Array.new
	    traverse_swift_files(project_path, swift_files)
	    localized_keys = collect_keys(strings_path)
	    missing_keys = collect_missing_keys(localized_keys, swift_files)
	    output_missing_keys(missing_keys, project_path)

			puts "remove all missing keys directly from .strings file? Y/(N)"
			need_delete_missing_keys = gets.chomp
			if need_delete_missing_keys.empty? || need_delete_missing_keys == "Y"
				puts "deleting..."
				delete_missing_keys(missing_keys, strings_path)
			else
				puts "check missing_keys.txt file in project path, and remove keys manually"
			end
			puts "done."

	  else
	    puts "error: project_path is not a directory"
	  end
	end

end
