class String
  def black;          "\033[30m#{self}\033[0m" end
  def red;            "\033[31m#{self}\033[0m" end
  def green;          "\033[32m#{self}\033[0m" end
  def  brown;         "\033[33m#{self}\033[0m" end
  def blue;           "\033[34m#{self}\033[0m" end
  def magenta;        "\033[35m#{self}\033[0m" end
  def cyan;           "\033[36m#{self}\033[0m" end
  def gray;           "\033[37m#{self}\033[0m" end
  def bg_black;       "\033[40m#{self}\0330m"  end
  def bg_red;         "\033[41m#{self}\033[0m" end
  def bg_green;       "\033[42m#{self}\033[0m" end
  def bg_brown;       "\033[43m#{self}\033[0m" end
  def bg_blue;        "\033[44m#{self}\033[0m" end
  def bg_magenta;     "\033[45m#{self}\033[0m" end
  def bg_cyan;        "\033[46m#{self}\033[0m" end
  def bg_gray;        "\033[47m#{self}\033[0m" end
  def bold;           "\033[1m#{self}\033[22m" end
  def reverse_color;  "\033[7m#{self}\033[27m" end
end

module OutputProcessor

  def self.stackoverflow_code_highlight(phrase, options={})
    # require 'colorize'
    phrase.split("\n").each do |line| 
      if line.start_with?('    ') 
        puts line.bold
      else
        unquoted = true
        puts line.split('`').map{ |string| if unquoted then string else string.bold; unquoted ^= true end}.join('')
      end
    end
  end

  def self.default(phrase, options={})
    my_name = BettyConfig.get("name")
    puts "#{ options[:no_name] ? '' : my_name + ': ' }#{phrase}"
  end

end