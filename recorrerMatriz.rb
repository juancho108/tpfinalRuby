a.each_index do |i|
  p i
  a[i].each_index do |j|
    puts "#{i},#{j}"
  end
end