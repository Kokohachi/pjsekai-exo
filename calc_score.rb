require "json"
puts "\e[93mスコアを計算します。\e[m"

def get_heavy_notes(type)
  case type
  when 3, 4, 5, 7, 8
    1.0
  when 6, 17
    0.1
  when 10, 12, 14, 15
    2.0
  when 11
    3.0
  when 13
    0.2
  end
end

level = 30
puts "総合力を入力して下さい。"
print "\e[90m>> \e[m"
total_pow = gets.chomp.to_i
level_fax = (level - 5) * 0.005 + 1
notes = []
JSON.parse(File.read("score_data.json"), symbolize_names: true)[:entities][3..].each do |entity|
  next if entity[:data][:values].length > 5
  notes << entity
end
notes.sort_by! { |note| note[:data][:values][0] }
heavy_notes = 0.0
notes.each do |note|
  heavy_notes += get_heavy_notes(note[:archetype])
end

scores = []
notes.each.with_index(1) do |note, index|
  combo_bonus = 0.01 * (index / 100) + 1
  scores << [
    note[:data][:values][0],
    (scores[-1]&.[](1) || 0) + ((total_pow / heavy_notes) \
      * 4 \
      * get_heavy_notes(note[:archetype]) \
      * combo_bonus \
      * level_fax).round,
  ]
end

File.write("score.json", scores.to_json)
