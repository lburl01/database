# alter table
# insert INTO
# SELECT
#   Count
#   Order by
#   WHERE
#   Sum/avg
# update
#   Where id = {integer} - filter
# delete
#   where id = {integer} - filter
# ---------------

# Build a program that when run will ask if you'd like to search for data or create data.

# It is up to you to make your search as flexible as you would like. Make an option for whatever you think best fits your data.
# And for inserting new data - make it a convenient experience. Prompt for every column value and validate the user input.

# ---------------

require_relative 'database'
require 'pg'

def get_input
  print " > "
  input = gets.chomp
end

def find_farthest_destination(conn)
  longest_distance = conn.exec(
  'SELECT location, MAX(miles_from_rdu) AS Count ' \
  'FROM travel_destinations ' \
  'GROUP BY location ' \
  'ORDER BY Count DESC;'
  )
  return longest_distance.getvalue(0, 0)
end

def find_unvisited_destinations(conn)
  unvisited_destinations = conn.exec(
  'SELECT location, miles_from_rdu, landmark ' \
  'FROM travel_destinations ' \
  'WHERE has_visited = FALSE '
  )
end

def yes_or_no?
  loop do
    choice = get_input.upcase
    if choice == "Y"
      return TRUE
    elsif choice == "N"
      return FALSE
    else
      puts "That's not an option. Try again."
    end
  end
end

def one_or_two?
  loop do
    choice = get_input.to_i
    if choice == 1
      return TRUE
    elsif choice == 2
      return FALSE
    else
      puts "That's not an option. Try again."
    end
  end
end

def print_table_contents(conn)
  table = conn.exec('SELECT * FROM travel_destinations')
  table.each do |destination|
    puts destination
  end
end

def print_confirmation(conn, location_name, distance, landmark, visited)
  table = conn.exec(
  "SELECT * FROM travel_destinations WHERE location = '#{location_name}' " \
  "AND miles_from_rdu = '#{distance}' " \
  "AND landmark = '#{landmark}' " \
  "AND has_visited = '#{visited}' "
  )
  array = table.values
  return array[0]
end

def find_row_by_location(conn, input)
  row_to_edit_obj = conn.exec(
  "SELECT * FROM travel_destinations WHERE location = '#{input}' "
  )
  row_to_edit = row_to_edit_obj.values
  return row_to_edit[0]
end

def update_has_visited(choice, conn, input)
  if choice == TRUE
    conn.exec(
      "UPDATE travel_destinations " \
      "SET has_visited = TRUE " \
      "WHERE location = '#{input}' "
    )
    updated_obj = conn.exec(
    "SELECT * FROM travel_destinations WHERE location = '#{input}' "
    )
    updated_true = updated_obj.values
    return updated_true[0]
  elsif choice == FALSE
    conn.exec(
      "UPDATE travel_destinations " \
      "SET has_visited = FALSE " \
      "WHERE location = '#{input}'"
    )
    updated_obj = conn.exec(
    "SELECT * FROM travel_destinations WHERE location = '#{input}' "
    )
    updated_false = updated_obj.values
    return updated_false[0]
  end
end

def main

  conn = PG.connect(dbname: 'travel_destinations')

  conn.exec('SET client_min_messages TO WARNING;') # don't show things that are below warning level

  loop do
    puts
    puts "What would you like to do?"
    puts "Search the travel destination database (1) "
    puts "Add to the travel destination database (2) "
    puts "Update the \"has visited\" info for a record in the travel destination database (3) "
    puts "Exit the program (4) "
    choice = get_input.to_i

    if choice == 1
      puts "Great! Let's get searching."
      puts "What would you like to do next? "
      puts "Find the destination farthest from RDU (1) "
      puts "Find the places you have yet to visit (2) "
      puts
      search_choice = get_input.to_i

        if search_choice == 1
          farthest_destination = find_farthest_destination(conn)
          puts "The farthest destination from RDU is " + farthest_destination + ". Let's hope you're not planning on walking..."
          puts
        elsif search_choice == 2
          unvisited_destinations = find_unvisited_destinations(conn)
          puts "Oh, the places you still want to go! Add these to the to-do list: "
          unvisited_destinations.each do |destination|
            p destination["location"]
          end
          puts
        end

    elsif choice == 2
      puts "Can't wait to see what destination you're adding! Let's get started. "
      puts "What's the name of the destination? "
      location_name = get_input.capitalize
      puts "How far (in miles) is that location from RDU?"
      distance = get_input
      puts "Are there any landmarks that you'd like to see there? (Y) or (N) "
      if yes_or_no? == TRUE
        puts "What's the landmark you'd like to see?"
        landmark = get_input
      else
        landmark = "none"
      end
      puts "Have you been there before? (Y) or (N)"
      if yes_or_no? == TRUE
        visited = "TRUE"
      else
        visited = "FALSE"
      end
      add_destination(conn, location_name, distance, landmark, visited)
      new_destination_details = print_confirmation(conn, location_name, distance, landmark, visited)
      p "Success! You've added the location #{new_destination_details[1]} that is #{new_destination_details[2]} miles from RDU."

    elsif choice == 3
      puts "Which location would you like to edit?"
      input = get_input.capitalize
      row_info = find_row_by_location(conn, input)
      puts "Here's the info for that entry: "
      puts "Location: #{row_info[1]}"
      puts "Miles from RDU: #{row_info[2]}"
      puts "Landmark: #{row_info[3]}"
      puts "Has visited (t) for true, (f) for false: #{row_info[4]}"
      puts
      puts "Convert that field to true by pressing (1)"
      puts "Convert that field to false by pressing (2)"
      choice = one_or_two?
      updated_row = update_has_visited(choice, conn, input)
      puts "Here's your updated destination info: "
      puts "Location: #{updated_row[1]}"
      puts "Miles from RDU: #{updated_row[2]}"
      puts "Landmark: #{updated_row[3]}"
      puts "Has visited (t) for true, (f) for false: #{updated_row[4]}"

    elsif choice == 4
      puts "See you next time!"
      exit
    end

  end

end

main if __FILE__ == $PROGRAM_NAME
