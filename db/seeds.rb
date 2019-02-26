def tbm_api(url)
  JSON.parse(HTTP.get(url).body.to_s)
end


Favorite.destroy_all
User.destroy_all
Stop.destroy_all
Direction.destroy_all
Line.destroy_all

lines_data = tbm_api("https://ws.infotbm.com/ws/1.0/network/get-lines-informations")

lines_data.each do |line_data|
  next if line_data['isHidden']
  line = Line.create!(
    tbm_id: line_data['id'],
    name: line_data['name'],
    background: line_data['bgColor'],
    text_color: line_data['textColor'],
    kind: line_data['type'].downcase.to_sym,
    code: line_data['code']
  )
  puts "#{line.name}:"

  line_full_data = tbm_api("https://ws.infotbm.com/ws/1.0/network/line-informations/#{line.tbm_id}")

  line_full_data['routes'].each do |route_data|
    direction = Direction.create!(
      name: route_data['end'].blank? ? route_data['name'] : route_data['end'],
      line: line
    )
    puts "\t#{direction.name}:"

    route_data['stopPoints'].each do |stop_point_data|
      stop = Stop.create!(
        direction: direction,
        name: stop_point_data['name'],
        latitude: stop_point_data['latitude'],
        longitude: stop_point_data['longitude'],
        tbm_id: stop_point_data['id']
      )
      puts "\t\t- #{stop.name}"
    end
  end
end
