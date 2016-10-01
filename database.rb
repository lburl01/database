
require 'pg'

def create_table(conn)
  table = conn.exec(
    'CREATE TABLE IF NOT EXISTS travel_destinations (' \
    'id SERIAL PRIMARY KEY,' \
    'location VARCHAR,' \
    'miles_from_rdu NUMERIC,' \
    'landmark VARCHAR,' \
    'has_visited BOOLEAN)'
    )
end

def add_destination(conn, location, miles_from_rdu, landmark, has_visited)
  sql = 'INSERT INTO travel_destinations ' \
    '(location, miles_from_rdu, landmark, has_visited)' \
    "SELECT '#{location}', '#{miles_from_rdu}', '#{landmark}', '#{has_visited}'" \
    'WHERE '\
      'NOT EXISTS (' \
        "SELECT id FROM travel_destinations WHERE location = '#{location}' " \
        "AND miles_from_rdu = '#{miles_from_rdu}' " \
        "AND landmark = '#{landmark}' " \
        "AND has_visited = '#{has_visited}' " \
      ');'

  conn.exec(sql) # will not add anything to table if we don't have this; actually executes the fxn
end

def count_destinations(conn)
  result = conn.exec('SELECT count(*) FROM travel_destinations')

  result.getvalue(0, 0).to_i
end

def main
  conn = PG.connect(dbname: 'travel_destinations')

  conn.exec('SET client_min_messages TO WARNING;') # don't show things that are below warning level

  create_table(conn)

  add_destination(conn, 'Charlotte', 150, 'Panthers Stadium', TRUE)
  add_destination(conn, 'Southport', 174, 'The Beach', TRUE)
  add_destination(conn, 'Vancouver', 2974, 'Butchart Gardens', TRUE)
  add_destination(conn, 'Grand Canyon', 2146, 'The Grand Canyon', TRUE)
  add_destination(conn, 'Chicago', 799, 'Lake Michigan', TRUE)
  add_destination(conn, 'Amsterdam', 4057, 'Rembrandt House', FALSE)
  add_destination(conn, 'Austria', 4585, 'Bohemian Forest', FALSE)
  add_destination(conn, 'Budapest', 4768, 'River Danube', FALSE)

  puts count_destinations(conn)

  table = conn.exec('SELECT * FROM travel_destinations') # can replace * with column names to get more specific data

  table.each do |destination|
    puts destination
  end

end

main if __FILE__ == $PROGRAM_NAME
