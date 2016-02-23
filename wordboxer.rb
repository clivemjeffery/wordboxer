require "prawn/labels"

words = []

# open the text file
fn = ARGV[0]
f = File.open("#{fn}", "r")
boxtitle = ARGV[1]
n = 0
#size = 70 # font size TODO: move to setting

# word or phrase expected on each line
f.each_line { |line|
   words.push(line.strip)
}
words.sort!
words = words.reject { |word| word.empty? }

Prawn::Labels.types = {
  "BoxDef" => {
    "paper_size" => "A4",
	"font_size" => 70,
    "columns"    => 2,
    "rows"       => 4,
    "top_margin" => 4,
    "bottom_margin" => 4,
    "left_margin" => 4,
    "right_margin" => 4,
    "column_gutter" => 2,
    "row_gutter" => 2
}}

def box_the_word(pdf, word, font_size)
	pdf.font_size font_size
	pdf.text word, align: :center, valign: :center, disable_wrap_by_char: true
	
	rescue Prawn::Errors::CannotFit
		print "Couldn't fit '#{word}', trying smaller font."
		box_the_word pdf, word, font_size - 5

end


Prawn::Labels.generate("#{fn.split('.')[0]}.pdf", words, :type => "BoxDef") do |pdf, word|

	n = n + 1

	# font files obtained from https://github.com/google/fonts/tree/master/ofl
	# TODO: work out how to put this before the every word loop!
	pdf.font_families.update(
		"Amaranth" => { 
			:normal => "Amaranth-Regular.ttf",
			:bold => "Amaranth-Bold.ttf" 
		}
	)
	
	if !boxtitle.nil?
		# print a small title at the top of the box
		pdf.font "Helvetica"
		pdf.font_size 8
		pdf.move_down 4
		pdf.indent(4) do
			pdf.text "<color rgb='C0C0C0'>#{boxtitle}. Word #{n} of #{words.length}</color>", inline_format: true
		end
		pdf.move_up 4
	end
	
	# print the word
	pdf.font "Amaranth"
	begin
		box_the_word pdf, word, Prawn::Labels.types["BoxDef"]["font_size"]
	end
	pdf.stroke_bounds
end